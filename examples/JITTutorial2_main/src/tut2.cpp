#include <iostream> // cout, cerr

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "tut2.h"

using namespace llvm;

/*
 * int gcd(int, int)
 */
static Function* createGCDPrototype(Module* Mod) {
    Type* Int32Type = Type::getInt32Ty(Mod->getContext());
    std::vector<Type*> ArgTypes = { /*x*/Int32Type, /*y*/Int32Type };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/Int32Type, ArgTypes, /*isVarArg*/false);
    Function* Func = Function::Create(
        FuncType, Function::PrivateLinkage, Twine("gcd"), Mod);
    Func->setCallingConv(CallingConv::C);
    Func->setDSOLocal(true);

    return Func;
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
void emitGCD(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    Function* GcdFunc = createGCDPrototype(Mod);
    Function::arg_iterator Args = GcdFunc->arg_begin();
    Value* x = Args++;
    x->setName("x");
    Value* y = Args++;
    y->setName("y");

    BasicBlock* EntryBB = BasicBlock::Create(Ctx, "entry", GcdFunc);
    BasicBlock* RetBB = BasicBlock::Create(Ctx, "return", GcdFunc);
    BasicBlock* CondFalseBB = BasicBlock::Create(Ctx, "condFalse", GcdFunc);
    BasicBlock* CondTrueBB = BasicBlock::Create(Ctx, "condTrue", GcdFunc);
    BasicBlock* CondFalseBB2 = BasicBlock::Create(Ctx, "condFalse", GcdFunc);
    IRBuilder<> Builder(EntryBB);

    Value* xEqualsY = Builder.CreateICmpEQ(x, y, "tmp");
    Builder.CreateCondBr(xEqualsY, RetBB, CondFalseBB);

    Builder.SetInsertPoint(RetBB);
    Builder.CreateRet(x);

    Builder.SetInsertPoint(CondFalseBB);
    Value* xLessThanY = Builder.CreateICmpULT(x, y, "tmp");
    Builder.CreateCondBr(xLessThanY, CondTrueBB, CondFalseBB2);

    Builder.SetInsertPoint(CondTrueBB);
    Value* yMinusX = Builder.CreateSub(y, x, "tmp");
    std::vector<Value*> Args1 = {x, yMinusX };
    Value* recur_1 = Builder.CreateCall(GcdFunc, Args1, "tmp");
    Builder.CreateRet(recur_1);

    Builder.SetInsertPoint(CondFalseBB2);
    Value* xMinusY = Builder.CreateSub(x, y, "tmp");
    std::vector<Value*> Args2 = { xMinusY, y };
    Value* recur_2 = Builder.CreateCall(GcdFunc, Args2, "tmp");

    Builder.CreateRet(recur_2);
}
