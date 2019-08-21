#include <iostream> // cout, cerr

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "tut2_utils.h"

using namespace llvm;

#define CONST_INT32(X) ConstantInt::get(ctx, APInt(32, X))

Module* makeLLVMModule();

int main(int argc, char**argv) {
    Module* Mod = makeLLVMModule();

    verifyModule(*Mod);

    legacy::PassManager PM;
    PM.add(createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;  
    return 0;
}

static LLVMContext TheContext;
static Type* TYPE_INT32 = Type::getInt32Ty(TheContext);
// or: static Type* TYPE_INT32 = IntegerType::get(TheContext, 32);
static Type* TYPE_CHAR_PTR = Type::getInt8PtrTy(TheContext);

// int gcd(int, int)
static Function* createGCDPrototype(Module* mod) {
    std::vector<Type*> gcd_arg_types = { /*x*/TYPE_INT32, /*y*/TYPE_INT32 };
    FunctionType* gcd_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, gcd_arg_types, true);
    Function* func = Function::Create(
        gcd_type, Function::PrivateLinkage, Twine("gcd"), mod);
    func->setCallingConv(CallingConv::C);

    return func;
}

/*
unsigned gcd(unsigned x, unsigned y) {
  if(x == y) {
    return x;
  } else if(x < y) {
    return gcd(x, y - x);
  } else {
    return gcd(x - y, y);
  }
}
*/
static void makeGCD(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    Function* gcdFun = createGCDPrototype(mod);
    Function::arg_iterator args = gcdFun->arg_begin();
    Value* x = args++;
    x->setName("x");
    Value* y = args++;
    y->setName("y");

    BasicBlock* entry = BasicBlock::Create(ctx, "entry", gcdFun);
    BasicBlock* ret = BasicBlock::Create(ctx, "return", gcdFun);
    BasicBlock* cond_false = BasicBlock::Create(ctx, "cond_false", gcdFun);
    BasicBlock* cond_true = BasicBlock::Create(ctx, "cond_true", gcdFun);
    BasicBlock* cond_false_2 = BasicBlock::Create(ctx, "cond_false", gcdFun);
    IRBuilder<> builder(entry);

    Value* xEqualsY = builder.CreateICmpEQ(x, y, "tmp");
    builder.CreateCondBr(xEqualsY, ret, cond_false);

    builder.SetInsertPoint(ret);
    builder.CreateRet(x);

    builder.SetInsertPoint(cond_false);
    Value* xLessThanY = builder.CreateICmpULT(x, y, "tmp");
    builder.CreateCondBr(xLessThanY, cond_true, cond_false_2);

    builder.SetInsertPoint(cond_true);
    Value* yMinusX = builder.CreateSub(y, x, "tmp");
    std::vector<Value*> args1 = {x, yMinusX };
    Value* recur_1 = builder.CreateCall(gcdFun, args1, "tmp");
    builder.CreateRet(recur_1);

    builder.SetInsertPoint(cond_false_2);
    Value* xMinusY = builder.CreateSub(x, y, "tmp");
    std::vector<Value*> args2 = { xMinusY, y };
    Value* recur_2 = builder.CreateCall(gcdFun, args2, "tmp");

    builder.CreateRet(recur_2);
}

LoadInst* loadArrayElement(Module* mod, IRBuilder<> builder, LoadInst* arr_base, unsigned i) {
    LLVMContext& ctx = mod->getContext();
    ConstantInt* offset = ConstantInt::get(ctx, APInt(64, i));
    Value* elemAddr = builder.CreateInBoundsGEP(arr_base, { offset }); // addr = base + offset
    LoadInst* elem_i = builder.CreateLoad(elemAddr, "elem_i");
    elem_i->setAlignment(8); // argv[idx]
    
    return elem_i;
 }

// int main(int argc, char* argv[])
static Function* createMainPrototype(Module* mod) {
    std::vector<Type*> main_arg_types =
        { /*argc*/TYPE_INT32, /*argv*/PointerType::get(TYPE_CHAR_PTR, 0) };
    FunctionType* main_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, main_arg_types, false);
    Function* func = Function::Create(
        main_type, Function::ExternalLinkage, Twine("main"), mod);
    func->setCallingConv(CallingConv::C);
    func->setDSOLocal(true);

    return func;
}

struct MainFrame {
    LoadInst* argc;
    LoadInst* argv;
};
static MainFrame createMainPrologue(Module* mod, IRBuilder<> builder, Function* mainFun) {
    LLVMContext& ctx = mod->getContext();
    Function::arg_iterator args = mainFun->arg_begin();
    Value* argc = args++;
    argc->setName("argc");
    Value* argv = args++;
    argv->setName("argv");
    /*
     * %3 = alloca i32, align 4
     * %4 = alloca i32, align 4
     * %5 = alloca i8**, align 8
     * store i32 0, i32* %3, align 4
     * store i32 %0, i32* %4, align 4
     * store i8** %1, i8*** %5, align 8
     * %6 = load i8**, i8*** %5, align 8
     * %7 = getelementptr inbounds i8*, i8** %6, i64 0
     * %8 = load i8*, i8** %7, align 8
      * %9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i8* %8)
    */
    AllocaInst* a0 = builder.CreateAlloca(TYPE_INT32); a0->setAlignment(4);
    AllocaInst* a1 = builder.CreateAlloca(TYPE_INT32); a1->setAlignment(4);
    Type* argvType = PointerType::get(TYPE_CHAR_PTR, 0);
    AllocaInst* a2 = builder.CreateAlloca(argvType); a2->setAlignment(8);

    ConstantInt* zero = ConstantInt::get(ctx, APInt(32, 0));
    StoreInst* s0 = builder.CreateStore(zero, a0); s0->setAlignment(4);
    StoreInst* s1 = builder.CreateStore(argc, a1); s1->setAlignment(4);
    StoreInst* s2 = builder.CreateStore(argv, a2); s2->setAlignment(8);
    
    MainFrame frame;
    frame.argc = builder.CreateLoad(a1);
    frame.argv = builder.CreateLoad(a2);
    frame.argv->setAlignment(8);

    return frame;
}

/*
int main(int argc, char* argv[]) {
    int res = gcd(argv[1], argv[2]);
    printf("%d\n", res);
    return 0;
}
*/
static void makeMain(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    Function* mainFun = createMainPrototype(mod);

    BasicBlock* block = BasicBlock::Create(ctx, "entry", mainFun);
    IRBuilder<> builder(block);

    MainFrame frame = createMainPrologue(mod, builder, mainFun);
    createPrintStr(mod, builder, "argc=");
    createPrintIntLn(mod, builder, frame.argc);

    LoadInst* argv1 = loadArrayElement(mod, builder, frame.argv, 1);
    LoadInst* argv2 = loadArrayElement(mod, builder, frame.argv, 2);

    createPrintStr(mod, builder, "argv1=");
    createPrintStrLn(mod, builder, argv1);
    createPrintStr(mod, builder, "argv2=");
    createPrintStrLn(mod, builder, argv2);

    Value* x = createStrToInt(mod, builder, argv1);
    Value* y = createStrToInt(mod, builder, argv2);
    Value* result = builder.CreateCall(mod->getFunction("gcd"), { x, y });

    createPrintStr(mod, builder, "result=");
    createPrintIntLn(mod, builder, result);

    builder.CreateRet(CONST_INT32(0));    
}

Module* makeLLVMModule() {
    Module* mod = new Module("tut2_main", TheContext);
    initModule(mod);

    makeGCD(mod);
    makeMain(mod);

    return mod;
}