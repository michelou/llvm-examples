#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h" // createPrintModulePass
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "tut1.h"

using namespace llvm;

static LLVMContext TheContext;

static void emitMain(Module* Mod);

int main(int argc, char**argv) {
    Module* Mod = new Module("tut1_main", TheContext);

    emitMulAdd(Mod);
    emitMain(Mod);

    verifyModule(*Mod);

    legacy::PassManager PM;
    PM.add((Pass*) createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;
    return 0;
}

#define CONST_INT32(X) ConstantInt::get(Ctx, APInt(32, X))

static Type* TYPE_INT32 = Type::getInt32Ty(TheContext);
// or: static Type* TYPE_INT32 = IntegerType::get(TheContext, 32);

// void printf(const char *fmt, ...);
static Function* createPrintfPrototype(Module* Mod) {
    LLVMContext& ctx = Mod->getContext();
    std::vector<Type*> ArgTypes = { Type::getInt8PtrTy(ctx) };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/TYPE_INT32, ArgTypes, /*isVarArg*/true);
    Function* Func = Function::Create(
        FuncType, Function::ExternalLinkage, Twine("printf"), Mod);
    Func->setCallingConv(CallingConv::C);

    return Func;
}

// "%d\n"
static Constant* createPrintfFmtDecimal(Module* Mod, const char* fmt = "%d\n") {
    LLVMContext& ctx = Mod->getContext();
    Constant* Data = ConstantDataArray::getString(ctx, fmt);
    Type* VarType = ArrayType::get(Type::getInt8Ty(ctx), strlen(fmt) + 1);
    GlobalVariable* Var = new GlobalVariable(*Mod, VarType,
        true, GlobalValue::PrivateLinkage, Data, ".str");

    Constant* Zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> Indices = { Zero, Zero };

    return ConstantExpr::getGetElementPtr(VarType, Var, Indices);
}

// int main()
static Function* createMainPrototype(Module* Mod) {
    FunctionType* FuncType = // no parameter list
        FunctionType::get(/*ret_type*/TYPE_INT32, /*isVarArg*/false);
    Function* Func = Function::Create(
        FuncType, Function::ExternalLinkage, Twine("main"), Mod);
    Func->setCallingConv(CallingConv::C);

    return Func;
}

/*
int main() {
   printf("%d\n", mul_add(10, 2, 3));
   return 0;
}
*/
static void emitMain(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    Function* MainFunc = createMainPrototype(Mod);

    Function* PrintfFunc = createPrintfPrototype(Mod);
    Constant* PrintfFmt = createPrintfFmtDecimal(Mod);

    BasicBlock* Block = BasicBlock::Create(Ctx, "entry", MainFunc);
    IRBuilder<> builder(Block);

    std::vector<Value *> MulAddArgs =
        { CONST_INT32(10), CONST_INT32(2), CONST_INT32(3) };
    Value* Result = builder.CreateCall(Mod->getFunction("mul_add"), MulAddArgs, "mul_add");

    std::vector<Value *> PrintfArgs = { PrintfFmt, Result };
    CallInst* Call = builder.CreateCall(PrintfFunc, PrintfArgs, "printf");
    assert(Call != NULL); // avoid warning message "Unused variable" 

    builder.CreateRet(CONST_INT32(0));
}
