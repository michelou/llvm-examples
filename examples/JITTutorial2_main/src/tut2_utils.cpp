#include "stdlib.h" // getenv

#include "llvm/IR/Constants.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

#include "tut2_utils.h"

using namespace llvm;

#define TYPE_CHAR     Type::getInt8Ty(ctx)
#define TYPE_CHAR_PTR Type::getInt8PtrTy(ctx)
#define TYPE_INT32    Type::getInt32Ty(ctx)

// Without this initialization, none of the target specific optimizations will be enabled
// (see http://llvm.org/docs/Frontend/PerformanceTips.html#the-basic)
void initModule(Module* mod) {
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
    mod->setDataLayout("e-m:w-i64:64-f80:128-n8:16:32:64-S128");
#endif
    char* value = std::getenv("LLVM_TARGET_TRIPLE");
    if (value != NULL) {
        // eg. "x86_64-pc-windows-msvc19.22.27905"
        mod->setTargetTriple(value);
    }
}

static Function* printf_func      = NULL;
static Constant* fmt_decimal      = NULL;
static Constant* fmt_decimal_endl = NULL;
static Constant* fmt_string       = NULL;
static Constant* fmt_string_endl  = NULL;
static Function* strtol_func      = NULL;

// void printf(const char *fmt, ...);
// (adapted from https://github.com/thomaslee/llvm-demo)
static Function* printf_prototype(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    std::vector<Type*> arg_types = { /*fmt*/TYPE_CHAR_PTR };
    FunctionType* func_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, arg_types, /*isVarArg*/true);
    Function* func = Function::Create(
        func_type, Function::ExternalLinkage, Twine("printf"), mod);
    func->setCallingConv(CallingConv::C);
    func->setDSOLocal(true);

    return func;
}

//////////////////////////////////////////////////////////////////////////////
// printf("%d\n", d) where d = Value*

/* private */
static Constant* printf_fmt_decimal(Module* mod, const char* fmt = "%d\n") {
    LLVMContext& ctx = mod->getContext();
    Constant* str_const = ConstantDataArray::getString(ctx, fmt);
    Type* str_type = ArrayType::get(TYPE_CHAR, strlen(fmt) + 1);
    GlobalVariable* var = new GlobalVariable(*mod, str_type,
        true, GlobalValue::PrivateLinkage, str_const, ".str_d");

    Constant* zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> indices = { zero, zero };

    return ConstantExpr::getGetElementPtr(str_type, var, indices);
}

/* private */
std::vector<Value *> printf_args_decimal(Module* mod, Value* v) {
    if (fmt_decimal == NULL) { fmt_decimal = printf_fmt_decimal(mod, "%d"); }
    std::vector<Value *> printf_args = { fmt_decimal, v };

    return printf_args;
}

/* private */
std::vector<Value *> printf_args_decimal_endl(Module* mod, Value* v) {
    if (fmt_decimal_endl == NULL) { fmt_decimal_endl  = printf_fmt_decimal(mod); }
    std::vector<Value *> printf_args = { fmt_decimal_endl , v };

    return printf_args;
}

/* exported */
CallInst* createPrintInt(Module* mod, IRBuilder<> builder, Value* v) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> printf_args = printf_args_decimal(mod, v);

    return builder.CreateCall(printf_func, printf_args, "printf");
}

/* exported */
CallInst* createPrintIntLn(Module* mod, IRBuilder<> builder, Value* v) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> printf_args = printf_args_decimal_endl(mod, v);

    return builder.CreateCall(printf_func, printf_args, "printf");
}

//////////////////////////////////////////////////////////////////////////////
// printf ("%s\n", s) where type(s) = char* | Value*

/* private */
static Constant* printf_fmt_string(Module* mod, const char* fmt = "%s\n") {
    LLVMContext& ctx = mod->getContext();
    Constant* str_const = ConstantDataArray::getString(ctx, fmt);
    Type* str_type = ArrayType::get(TYPE_CHAR, strlen(fmt) + 1);
    GlobalVariable* var = new GlobalVariable(*mod, str_type,
        true, GlobalValue::PrivateLinkage, str_const, ".str_s");

    Constant* zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> indices = { zero, zero };

    return ConstantExpr::getGetElementPtr(str_type, var, indices);
}

/* private */
std::vector<Value *> printf_args_string(Module* mod, Value* v) {
    if (fmt_string == NULL) { fmt_string = printf_fmt_string(mod, "%s"); }
    std::vector<Value *> args = { fmt_string, v };

    return args;
}

/* private */
std::vector<Value *> printf_args_string(Module* mod, const char* s) {
    LLVMContext& ctx = mod->getContext();
    Constant* data = ConstantDataArray::getString(ctx, s);
    GlobalVariable* var = new GlobalVariable(*mod, ArrayType::get(TYPE_CHAR, strlen(s) + 1),
        true, GlobalValue::PrivateLinkage, data, ".str");

    return printf_args_string(mod, var);
}

/* private */
std::vector<Value *> printf_args_string_endl(Module* mod, Value* v) {
    if (fmt_string_endl == NULL) { fmt_string_endl = printf_fmt_string(mod); }
    std::vector<Value *> args = { fmt_string_endl, v };

    return args;
}

/* private */
std::vector<Value *> printf_args_string_endl(Module* mod, const char* s) {
    LLVMContext& ctx = mod->getContext();
    Constant* data = ConstantDataArray::getString(ctx, s);
    GlobalVariable* var = new GlobalVariable(*mod, ArrayType::get(TYPE_CHAR, strlen(s) + 1),
        true, GlobalValue::PrivateLinkage, data, ".str");

    return printf_args_string_endl(mod, var);
}

/* exported */
CallInst* createPrintStr(Module* mod, IRBuilder<> builder, const char* s) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> args = printf_args_string(mod, s);

    return builder.CreateCall(printf_func, args, "printf");
}

/* exported */
CallInst* createPrintStr(Module* mod, IRBuilder<> builder, Value* v) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> args = printf_args_string(mod, v);

    return builder.CreateCall(printf_func, args, "printf");
}

/* exported */
CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, const char* s) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> args = printf_args_string_endl(mod, s);

    return builder.CreateCall(printf_func, args, "printf");
}

/* exported */
CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, Value* v) {
    if (printf_func == NULL) {  printf_func = printf_prototype(mod); }
    std::vector<Value *> args = printf_args_string_endl(mod, v);

    return builder.CreateCall(printf_func, args, "printf");
}

//////////////////////////////////////////////////////////////////////////////
// StrToInt

/* private */
// int strtol (const char* str, char** endptr, int base);
static Function* strtol_prototype(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    std::vector<Type*> arg_types = {
        /*str*/TYPE_CHAR_PTR,
        /*endptr*/PointerType::get(TYPE_CHAR_PTR, 0),
        /*base*/TYPE_INT32
    };
    FunctionType* func_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, arg_types, true);
    Function* func = Function::Create(
        func_type, Function::ExternalLinkage, Twine("strtol"), mod);
    func->setCallingConv(CallingConv::C);
    func->setDSOLocal(true);

    return func;
}

/* exported */
CallInst* createStrToInt(Module* mod, IRBuilder<> builder, Value* v) {
    LLVMContext& ctx = mod->getContext();
    if (strtol_func == NULL) { strtol_func = strtol_prototype(mod); }
    Constant* zero = Constant::getNullValue(PointerType::get(TYPE_CHAR_PTR, 0));
    ConstantInt* base = ConstantInt::get(ctx, APInt(32, 10));
    std::vector<Value *> strtol_args = { v, zero, base };

    return builder.CreateCall(strtol_func, strtol_args, "strtol");
}

//////////////////////////////////////////////////////////////////////////////
// END
