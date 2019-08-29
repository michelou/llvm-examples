#include <iostream> // cout, cerr

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "utils.h"
#include "tut2.h"

using namespace llvm;

static LLVMContext TheContext;

static void emitMain(Module* Mod);

int main(int argc, char**argv) {
    Module* Mod = new Module("tut2_main", TheContext);
    initModule(Mod);

    emitGCD(Mod);
    emitMain(Mod);

    verifyModule(*Mod);

    legacy::PassManager PM;
    PM.add(createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;  
    return 0;
}

#define CONST_INT32(X) ConstantInt::get(Ctx, APInt(32, X))

static Type* TYPE_INT32 = Type::getInt32Ty(TheContext);
// or: static Type* TYPE_INT32 = IntegerType::get(TheContext, 32);
static Type* TYPE_CHAR_PTR = Type::getInt8PtrTy(TheContext);

static LoadInst* loadArrayElement(Module* Mod, IRBuilder<> Builder, LoadInst* ArrBase, unsigned i) {
    LLVMContext& Ctx = Mod->getContext();
    ConstantInt* Offset = ConstantInt::get(Ctx, APInt(64, i));
    Value* ElemAddr = Builder.CreateInBoundsGEP(ArrBase, { Offset }); // addr = base + offset
    LoadInst* elem_i = Builder.CreateLoad(ElemAddr, "elem_i");
    elem_i->setAlignment(8); // arr[idx]
    
    return elem_i;
 }

// int main(int argc, char* argv[])
static Function* createMainPrototype(Module* Mod) {
    std::vector<Type*> ArgTypes =
        { /*argc*/TYPE_INT32, /*argv*/PointerType::get(TYPE_CHAR_PTR, 0) };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/TYPE_INT32, ArgTypes, /*isVarArg*/false);
    Function* Func = Function::Create(
        FuncType, Function::ExternalLinkage, Twine("main"), Mod);
    Func->setCallingConv(CallingConv::C);
    Func->setDSOLocal(true);

    return Func;
}

struct MainFrame {
    LoadInst* argc;
    LoadInst* argv;
};
static MainFrame createMainPrologue(Module* Mod, IRBuilder<> Builder, Function* MainFunc) {
    LLVMContext& Ctx = Mod->getContext();
    Function::arg_iterator args = MainFunc->arg_begin();
    Value* argc = args++;
    argc->setName("argc");
    Value* argv = args++;
    argv->setName("argv");

    AllocaInst* a0 = Builder.CreateAlloca(TYPE_INT32); a0->setAlignment(4);
    AllocaInst* a1 = Builder.CreateAlloca(TYPE_INT32); a1->setAlignment(4);
    Type* argvType = PointerType::get(TYPE_CHAR_PTR, 0);
    AllocaInst* a2 = Builder.CreateAlloca(argvType); a2->setAlignment(8);

    ConstantInt* zero = ConstantInt::get(Ctx, APInt(32, 0));
    StoreInst* s0 = Builder.CreateStore(zero, a0); s0->setAlignment(4);
    StoreInst* s1 = Builder.CreateStore(argc, a1); s1->setAlignment(4);
    StoreInst* s2 = Builder.CreateStore(argv, a2); s2->setAlignment(8);
    
    MainFrame Frame = { Builder.CreateLoad(a1), Builder.CreateLoad(a2) };
    Frame.argv->setAlignment(8);

    return Frame;
}

/*
int main(int argc, char* argv[]) {
    printf("%s", "argc="); printf("%d\n", argc);
    printf("%s", "argv1="); printf("%s\n", argv[1]);
    printf("%s", "argv2="); printf("%s\n", argv[2]);
    int x = strtol(argv[1]);
    int y = strtol(argv[2]);
    int result = gcd(x, y);
    printf("%s", "result="); printf("%d\n", result);
    return 0;
}
*/
static void emitMain(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    Function* MainFunc = createMainPrototype(Mod);

    BasicBlock* Block = BasicBlock::Create(Ctx, "entry", MainFunc);
    IRBuilder<> Builder(Block);
    MainFrame Frame = createMainPrologue(Mod, Builder, MainFunc);

    createPrintStr(Mod, Builder, "argc=");
    createPrintIntLn(Mod, Builder, Frame.argc);

    LoadInst* Argv1 = loadArrayElement(Mod, Builder, Frame.argv, 1);
    LoadInst* Argv2 = loadArrayElement(Mod, Builder, Frame.argv, 2);

    createPrintStr(Mod, Builder, "argv1=");
    createPrintStrLn(Mod, Builder, Argv1);
    createPrintStr(Mod, Builder, "argv2=");
    createPrintStrLn(Mod, Builder, Argv2);

    Value* X = createStrToInt(Mod, Builder, Argv1);
    Value* Y = createStrToInt(Mod, Builder, Argv2);
    Value* Result = Builder.CreateCall(Mod->getFunction("gcd"), { X, Y });

    createPrintStr(Mod, Builder, "result=");
    createPrintIntLn(Mod, Builder, Result);

    Builder.CreateRet(CONST_INT32(0));    
}
