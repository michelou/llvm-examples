#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"

#include <vector>

using namespace llvm;

static LLVMContext Context;

Function *createFunc(Module* mod, std::string Name) {
    Type *resultType = Type::getVoidTy(Context);
    FunctionType *funcType =
        FunctionType::get(resultType, /*isVarArg*/false);
    Function *func =
        Function::Create(funcType, Function::ExternalLinkage, Name, mod);
    return func;
}

int main(int argc, char *argv[]) {
    Module *mod = new Module("my compiler", Context);

    IRBuilder<> Builder(Context);
    Function *funFunc = createFunc(mod, "fun");

    BasicBlock *entry = BasicBlock::Create(Context, "entry", funFunc);
    BasicBlock *header = BasicBlock::Create(Context, "header", funFunc);
    BasicBlock *body = BasicBlock::Create(Context, "body", funFunc);
    BasicBlock *exit = BasicBlock::Create(Context, "exit", funFunc);

    Builder.SetInsertPoint(entry);
    BranchInst* br1 = Builder.CreateBr(header);

    Builder.SetInsertPoint(header);
    PHINode* i = Builder.CreatePHI(Type::getInt32Ty(Context), 2, "i");
    ConstantInt* one = ConstantInt::get(Context, APInt(32, 1));
    i->addIncoming(one, entry);

    ConstantInt* ten = ConstantInt::get(Context, APInt(32, 10));
    Value* cond = Builder.CreateICmpEQ(i, ten, "cond");
    BranchInst* br2 = Builder.CreateCondBr(cond, exit, body);

    Builder.SetInsertPoint(body);
    ConstantInt* five = ConstantInt::get(Context, APInt(32, 5));
    Value* a = Builder.CreateBinOp(Instruction::Mul, i, one, "a");
    Value* b = Builder.CreateBinOp(Instruction::Or, a, five, "a");
    Value* i_next = Builder.CreateBinOp(Instruction::Add, i, one, "i.next");
    i->addIncoming(i_next, body);
    BranchInst* br3 = Builder.CreateBr(header);

    Builder.SetInsertPoint(exit);
    Builder.CreateRetVoid();

    verifyModule(*mod);

    mod->print(outs(), nullptr);
    return 0;
}
