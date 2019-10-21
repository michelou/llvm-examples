#include "llvm/Config/llvm-config.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h" // createPrintModulePass
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

Module* makeLLVMModule();

int main(int argc, char**argv) {
    Module* Mod = makeLLVMModule();

    verifyModule(*Mod); // PrintMessageAction);

    legacy::PassManager PM;
    PM.add(createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;
    return 0;
}

static LLVMContext TheContext;

Module* makeLLVMModule() {
    // Module Construction
    Module* mod = new Module("tut1", TheContext);

#if (LLVM_VERSION_MAJOR > 8)
    FunctionCallee c = mod->getOrInsertFunction("mul_add",
    /*ret type*/                           IntegerType::get(TheContext, 32),
    /*args*/  /*x*/                        IntegerType::get(TheContext, 32),
              /*y*/                        IntegerType::get(TheContext, 32),
              /*z*/                        IntegerType::get(TheContext, 32));

    Function* mul_add = cast<Function>(c.getCallee());
#else
    Constant* c = mod->getOrInsertFunction("mul_add",
    /*ret type*/                           IntegerType::get(TheContext, 32),
    /*args*/  /*x*/                        IntegerType::get(TheContext, 32),
              /*y*/                        IntegerType::get(TheContext, 32),
              /*z*/                        IntegerType::get(TheContext, 32));

    Function* mul_add = cast<Function>(c);
#endif
    mul_add->setCallingConv(CallingConv::C);

    Function::arg_iterator args = mul_add->arg_begin();
    Value* x = args++;
    x->setName("x");
    Value* y = args++;
    y->setName("y");
    Value* z = args++;
    z->setName("z");

    BasicBlock* block = BasicBlock::Create(TheContext, "entry", mul_add);
    IRBuilder<> builder(block);

    Value* tmp = builder.CreateBinOp(Instruction::Mul, x, y, "tmp");
    Value* tmp2 = builder.CreateBinOp(Instruction::Add, tmp, z, "tmp2");

    builder.CreateRet(tmp2);

    return mod;
}
