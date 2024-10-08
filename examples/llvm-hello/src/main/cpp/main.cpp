#include <cstdio>
#include <fstream>
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Function.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/Support/raw_os_ostream.h"

using namespace llvm;

// see https://stackoverflow.com/questions/38579802/binding-against-llvm-3-8-4-no-getglobalcontext
// static IRBuilder<> Builder(getGlobalContext());
static LLVMContext TheContext;
static IRBuilder<> Builder(TheContext);

std::unique_ptr<Module> buildModule()
{
#if (LLVM_VERSION_MAJOR > 9) // https://reviews.llvm.org/D66259
    std::unique_ptr<Module> module = std::make_unique<Module>("top", TheContext);
#else
    std::unique_ptr<Module> module = llvm::make_unique<Module>("top", TheContext);
#endif

    /* Create main function */
    FunctionType *funcType = FunctionType::get(Builder.getInt32Ty(), false);    
    Function *mainFunc = Function::Create(funcType, Function::ExternalLinkage, "main", module.get());
    BasicBlock *entry = BasicBlock::Create(TheContext, "entrypoint", mainFunc);
    Builder.SetInsertPoint(entry);

    /* String constant */
    Value *helloWorldStr = Builder.CreateGlobalStringPtr("hello world!\n");

    /* Create "puts" function */
    std::vector<Type *> putsTypes;
    putsTypes.push_back(Builder.getInt8Ty()->getPointerTo());
    ArrayRef<Type*> typesRef(putsTypes);
    FunctionType *putsType = FunctionType::get(Builder.getInt32Ty(), typesRef, false);

#if (LLVM_VERSION_MAJOR > 8)
    std::vector<Value *> putsArgs;
    putsArgs.push_back(helloWorldStr);
    ArrayRef<Value *> argsRef(putsArgs);
    FunctionCallee putsFunc = module->getOrInsertFunction("puts", putsType);
    /* Invoke it */
    Builder.CreateCall(putsFunc, argsRef); //helloWorldStr);
#else
    Constant *putsFunc = module->getOrInsertFunction("puts", putsType);
    /* Invoke it */
    Builder.CreateCall(putsFunc, helloWorldStr);
#endif

    /* Return zero */
    Builder.CreateRet(ConstantInt::get(TheContext, APInt(32, 0)));

    return module;
}

void writeModuleToFile(Module *module)
{
    std::ofstream std_file_stream("program.ll");
    raw_os_ostream file_stream(std_file_stream);
    module->print(file_stream, nullptr);
}

int main()
{
    std::unique_ptr<Module> module = buildModule();
    writeModuleToFile(module.get());
    return 0;
}
