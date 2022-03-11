#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"

#include <vector>

using namespace llvm;

static LLVMContext Context;
static Module *ModuleOb = new Module("my compiler", Context);
static std::vector<std::string> FunArgs;

Function *createFunc(IRBuilder<> &Builder, std::string Name) {
    Type *u32Ty = Type::getInt32Ty(Context);
#if (LLVM_VERSION_MAJOR > 11)
    Type *vecTy = VectorType::get(u32Ty, 4, /*Scalable*/false);
#else
    Type *vecTy = VectorType::get(u32Ty, 4);
#endif
    FunctionType *funcType =
        FunctionType::get(Builder.getInt32Ty(), vecTy, false);
    Function *fooFunc =
        Function::Create(funcType, Function::ExternalLinkage, Name, ModuleOb);
    return fooFunc;
}

void setFuncArgs(Function *fooFunc, std::vector<std::string> FunArgs) {
    unsigned Idx = 0;
    Function::arg_iterator AI, AE;
    for (AI = fooFunc->arg_begin(), AE = fooFunc->arg_end(); AI != AE; ++AI, ++Idx)
        AI->setName(FunArgs[Idx]);
}

BasicBlock *createBB(Function *fooFunc, std::string Name) {
    return BasicBlock::Create(Context, Name, fooFunc);
}

Value *getInsertElement(IRBuilder<> &Builder, Value *Vec, Value *Val, Value *Index) {
    return Builder.CreateInsertElement(Vec, Val, Index);
}

int main(int argc, char *argv[]) {
    FunArgs.push_back("a");
    static IRBuilder<> Builder(Context);
    Function *fooFunc = createFunc(Builder, "foo");
    setFuncArgs(fooFunc, FunArgs);
    BasicBlock *entry = createBB(fooFunc, "entry");
    Builder.SetInsertPoint(entry);
    Value *Vec = fooFunc->arg_begin();
    for (unsigned int i = 0; i < 4; i++)
        Value *V = getInsertElement(Builder, Vec, Builder.getInt32((i + 1) * 10), Builder.getInt32(i));
    Builder.CreateRet(Builder.getInt32(0));
    verifyFunction(*fooFunc);

    ModuleOb->print(outs(), nullptr); // ModuleOb->dump();
    return 0;
}
