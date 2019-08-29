#include "stdlib.h" // getenv

#include "llvm/IR/Constants.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

#include "utils.h"

using namespace llvm;

#define TYPE_CHAR     Type::getInt8Ty(Ctx)
#define TYPE_CHAR_PTR Type::getInt8PtrTy(Ctx)
#define TYPE_INT32    Type::getInt32Ty(Ctx)

// Without this initialization, none of the target specific optimizations will be enabled
// (see http://llvm.org/docs/Frontend/PerformanceTips.html#the-basic)
void initModule(Module* Mod) {
    // Format:
    // (see http://llvm.org/docs/LangRef.html#langref-datalayout)
    //    <endianness>  = E | e where E=big endian, e=little endian
    //    <mangling>    = e | m | o | x | w  where x,w = Windows COFF with/without prefix
    //    i<size>:<abi> = alignment for an integer type of a given bit <size>
    //    f<size>:<abi> = alignment for a floating-point type of a given bit <size>
    //    n<size1>:...  = set of native integer widths for the target CPU in bits
    //    S<size>       = 0 (stack alignment in bits)
    //    P<size>       = 0 (code and data share the same space)
    //    A<size>       = 0 (address space of objects created by 'alloca')
#ifdef _WIN64
    // eg. "e-m:w-i64:64-f80:128-n8:16:32:64-S128"
    Mod->setDataLayout("e-m:w-i64:64-f80:128-n8:16:32:64-S128");
#endif
    char* value = std::getenv("LLVM_TARGET_TRIPLE");
    if (value != NULL) {
        // eg. "x86_64-pc-windows-msvc19.22.27905"
        Mod->setTargetTriple(value);
    }
}

static Function* PrintfFunc     = NULL;
static Constant* FmtDecimal     = NULL;
static Constant* FmtDecimalEndl = NULL;
static Constant* FmtString      = NULL;
static Constant* FmtStringEndl  = NULL;
static Function* StrtolFunc     = NULL;

// void printf(const char *fmt, ...);
// (adapted from https://github.com/thomaslee/llvm-demo)
static Function* printf_prototype(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    std::vector<Type*> ArgTypes = { /*fmt*/TYPE_CHAR_PTR };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/TYPE_INT32, ArgTypes, /*isVarArg*/true);
    Function* Func = Function::Create(
        FuncType, Function::ExternalLinkage, Twine("printf"), Mod);
    Func->setCallingConv(CallingConv::C);
    Func->setDSOLocal(true);

    return Func;
}

//////////////////////////////////////////////////////////////////////////////
// printf("%d\n", d) where d = Value*

/* private */
static Constant* createPrintfFmtDecimal(Module* Mod, const char* Fmt = "%d\n") {
    LLVMContext& Ctx = Mod->getContext();
    Constant* Data = ConstantDataArray::getString(Ctx, Fmt);
    Type* VarType = ArrayType::get(TYPE_CHAR, strlen(Fmt) + 1);
    GlobalVariable* Var = new GlobalVariable(*Mod, VarType,
        true, GlobalValue::PrivateLinkage, Data, ".str_d");

    Constant* Zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> Indices = { Zero, Zero };

    return ConstantExpr::getGetElementPtr(VarType, Var, Indices);
}

/* private */
static std::vector<Value *> printf_args_decimal(Module* Mod, Value* Arg) {
    if (FmtDecimal == NULL) { FmtDecimal = createPrintfFmtDecimal(Mod, "%d"); }
    std::vector<Value *> PrintfArgs = { FmtDecimal, Arg };

    return PrintfArgs;
}

/* private */
static std::vector<Value *> createPrintfArgsDecimalEndl(Module* Mod, Value* Arg) {
    if (FmtDecimalEndl == NULL) { FmtDecimalEndl  = createPrintfFmtDecimal(Mod); }
    std::vector<Value *> PrintfArgs = { FmtDecimalEndl , Arg };

    return PrintfArgs;
}

/* exported */
CallInst* createPrintInt(Module* Mod, IRBuilder<> Builder, Value* Arg) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = printf_args_decimal(Mod, Arg);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

/* exported */
CallInst* createPrintIntLn(Module* Mod, IRBuilder<> Builder, Value* Arg) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = createPrintfArgsDecimalEndl(Mod, Arg);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

//////////////////////////////////////////////////////////////////////////////
// printf ("%s\n", s) where type(s) = char* | Value*

/* private */
static Constant* createPrintfFmtString(Module* Mod, const char* Fmt = "%s\n") {
    LLVMContext& Ctx = Mod->getContext();
    Constant* Data = ConstantDataArray::getString(Ctx, Fmt);
    Type* VarType = ArrayType::get(TYPE_CHAR, strlen(Fmt) + 1);
    GlobalVariable* Var = new GlobalVariable(*Mod, VarType,
        true, GlobalValue::PrivateLinkage, Data, ".str_s");

    Constant* Zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> Indices = { Zero, Zero };

    return ConstantExpr::getGetElementPtr(VarType, Var, Indices);
}

/* private */
static std::vector<Value *> createPrintfArgsString(Module* mod, Value* Arg) {
    if (FmtString == NULL) { FmtString = createPrintfFmtString(mod, "%s"); }
    std::vector<Value *> Args = { FmtString, Arg };

    return Args;
}

/* private */
static std::vector<Value *> createPrintfArgsString(Module* Mod, const char* ArgStr) {
    LLVMContext& Ctx = Mod->getContext();
    Constant* Data = ConstantDataArray::getString(Ctx, ArgStr);
    Type* VarType = ArrayType::get(TYPE_CHAR, strlen(ArgStr) + 1);
    GlobalVariable* Var = new GlobalVariable(*Mod, VarType,
        true, GlobalValue::PrivateLinkage, Data, ".str");

    return createPrintfArgsString(Mod, Var);
}

/* private */
static std::vector<Value *> createPrintfArgsStringEndl(Module* Mod, Value* Arg) {
    if (FmtStringEndl == NULL) { FmtStringEndl = createPrintfFmtString(Mod); }
    std::vector<Value *> Args = { FmtStringEndl, Arg };

    return Args;
}

/* private */
static std::vector<Value *> createPrintfArgsStringEndl(Module* Mod, const char* ArgStr) {
    LLVMContext& Ctx = Mod->getContext();
    Constant* Data = ConstantDataArray::getString(Ctx, ArgStr);
    Type* VarType = ArrayType::get(TYPE_CHAR, strlen(ArgStr) + 1);
    GlobalVariable* Var = new GlobalVariable(*Mod, VarType,
        true, GlobalValue::PrivateLinkage, Data, ".str");

    return createPrintfArgsStringEndl(Mod, Var);
}

/* exported */
CallInst* createPrintStr(Module* Mod, IRBuilder<> Builder, const char* ArgStr) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = createPrintfArgsString(Mod, ArgStr);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

/* exported */
CallInst* createPrintStr(Module* Mod, IRBuilder<> Builder, Value* Arg) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = createPrintfArgsString(Mod, Arg);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

/* exported */
CallInst* createPrintStrLn(Module* Mod, IRBuilder<> Builder, const char* ArgStr) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = createPrintfArgsStringEndl(Mod, ArgStr);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

/* exported */
CallInst* createPrintStrLn(Module* Mod, IRBuilder<> Builder, Value* Arg) {
    if (PrintfFunc == NULL) { PrintfFunc = printf_prototype(Mod); }
    std::vector<Value *> PrintfArgs = createPrintfArgsStringEndl(Mod, Arg);

    return Builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
}

//////////////////////////////////////////////////////////////////////////////
// StrToInt

/* private */
// int strtol (const char* str, char** endptr, int base);
static Function* createStrtolPrototype(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    std::vector<Type*> ArgTypes = {
        /*str*/TYPE_CHAR_PTR,
        /*endptr*/PointerType::get(TYPE_CHAR_PTR, 0),
        /*base*/TYPE_INT32
    };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/TYPE_INT32, ArgTypes, true);
    Function* Func = Function::Create(
        FuncType, Function::ExternalLinkage, Twine("strtol"), Mod);
    Func->setCallingConv(CallingConv::C);
    Func->setDSOLocal(true);

    return Func;
}

/* exported */
CallInst* createStrToInt(Module* Mod, IRBuilder<> Builder, Value* Arg) {
    LLVMContext& Ctx = Mod->getContext();
    if (StrtolFunc == NULL) { StrtolFunc = createStrtolPrototype(Mod); }
    Constant* Zero = Constant::getNullValue(PointerType::get(TYPE_CHAR_PTR, 0));
    ConstantInt* Base = ConstantInt::get(Ctx, APInt(32, 10));
    std::vector<Value *> StrtolArgs = { Arg, Zero, Base };

    return Builder.CreateCall(StrtolFunc, StrtolArgs, "strtol");
}

//////////////////////////////////////////////////////////////////////////////
// END
