#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"

#include <vector>

using namespace llvm;

static LLVMContext Context;

Function *createFunc(Module* mod, std::string Name) {
    std::vector<Type*> argTypes = { Type::getInt32Ty(Context) };
    Type *resultType = Type::getVoidTy(Context);
    FunctionType *funcType =
        FunctionType::get(resultType, argTypes, /*isVarArg*/false);
    Function *func =
        Function::Create(funcType, Function::ExternalLinkage, Name, mod);
    return func;
}

int main(int argc, char *argv[]) {
    Module *mod = new Module("my compiler", Context);

    IRBuilder<> Builder(Context);
    Function *func = createFunc(mod, "func");
    Function::arg_iterator args = func->arg_begin();
    Value* i = args++;
    i->setName("i");

    BasicBlock *entry = BasicBlock::Create(Context, "entry", func);
    BasicBlock *loop = BasicBlock::Create(Context, "loop", func);
    BasicBlock *exit = BasicBlock::Create(Context, "exit", func);

    Builder.SetInsertPoint(entry);
    BranchInst* br1 = Builder.CreateBr(loop);

    Builder.SetInsertPoint(loop);
    PHINode* j = Builder.CreatePHI(Type::getInt32Ty(Context), 2, "j");
    ConstantInt* zero = ConstantInt::get(Context, APInt(32, 0));
    j->addIncoming(zero, entry);
    ConstantInt* cst = ConstantInt::get(Context, APInt(32, 17));
    Value* loopinvar = Builder.CreateBinOp(Instruction::Mul, i, cst, "loopinvar");
    Value* val = Builder.CreateBinOp(Instruction::Add, j, loopinvar, "val");
    j->addIncoming(val, loop);

    Value* cond = Builder.CreateICmpEQ(val, zero, "cond");
    BranchInst* br2 = Builder.CreateCondBr(cond, exit, loop);

    Builder.SetInsertPoint(exit);
    Builder.CreateRetVoid();

    verifyModule(*mod);

    mod->print(outs(), nullptr); // mod->dump();
    return 0;
}
