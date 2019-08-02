#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR//IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

Module* makeLLVMModule();

int main(int argc, char**argv) {
    Module* Mod = makeLLVMModule();
  
    verifyModule(*Mod); //, PrintMessageAction);
  
    legacy::PassManager PM;
    PM.add(createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;  
    return 0;
}

static LLVMContext TheContext;

Module* makeLLVMModule() {
    Module* mod = new Module("tut2", TheContext);
  
    Constant* c = mod->getOrInsertFunction("gcd",
    /*ret type*/                           IntegerType::get(TheContext, 32),
    /*args*/  /*x*/                        IntegerType::get(TheContext, 32),
              /*y*/                        IntegerType::get(TheContext, 32));
    Function* gcd = cast<Function>(c);
  
    Function::arg_iterator args = gcd->arg_begin();
    Value* x = args++;
    x->setName("x");
    Value* y = args++;
    y->setName("y");

    BasicBlock* entry = BasicBlock::Create(TheContext, "entry", gcd);
    BasicBlock* ret = BasicBlock::Create(TheContext, "return", gcd);
    BasicBlock* cond_false = BasicBlock::Create(TheContext, "cond_false", gcd);
    BasicBlock* cond_true = BasicBlock::Create(TheContext, "cond_true", gcd);
    BasicBlock* cond_false_2 = BasicBlock::Create(TheContext, "cond_false", gcd);
 
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
    std::vector<Value*> args1;
    args1.push_back(x);
    args1.push_back(yMinusX);
    Value* recur_1 = builder.CreateCall(gcd, args1, "tmp");
    builder.CreateRet(recur_1);
  
    builder.SetInsertPoint(cond_false_2);
    Value* xMinusY = builder.CreateSub(x, y, "tmp");
    std::vector<Value*> args2;
    args2.push_back(xMinusY);
    args2.push_back(y);
    Value* recur_2 = builder.CreateCall(gcd, args2, "tmp");
    builder.CreateRet(recur_2);
  
    return mod;
}