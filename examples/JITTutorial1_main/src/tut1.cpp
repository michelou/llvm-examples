#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "tut1.h"

using namespace llvm;

/*
 * int mul_add(int, int, int)
 */
static Function* createMulAddPrototype(Module* Mod) {
    Type* Int32Type = Type::getInt32Ty(Mod->getContext());
    std::vector<Type*> ArgTypes =
        { /*x*/Int32Type, /*y*/Int32Type, /*z*/Int32Type };
    FunctionType* FuncType =
        FunctionType::get(/*ret_type*/Int32Type, ArgTypes, /*isVarArg*/false);
    Function* Func = Function::Create(
        FuncType, Function::PrivateLinkage, Twine("mul_add"), Mod);
    Func->setCallingConv(CallingConv::C);

    return Func;
}

/*
 * int mul_add(int x, int y, int z) {
 *     return x * y + z;
 * }
*/
void emitMulAdd(Module* Mod) {
    LLVMContext& Ctx = Mod->getContext();
    Function* MulAddFunc = createMulAddPrototype(Mod);
    Function::arg_iterator args = MulAddFunc->arg_begin();
    Value* x = args++;
    x->setName("x");
    Value* y = args++;
    y->setName("y");
    Value* z = args++;
    z->setName("z");

    BasicBlock* Block = BasicBlock::Create(Ctx, "entry", MulAddFunc);
    IRBuilder<> Builder(Block);
  
    Value* tmp = Builder.CreateBinOp(Instruction::Mul, x, y, "tmp");
    Value* tmp2 = Builder.CreateBinOp(Instruction::Add, tmp, z, "tmp2");

    Builder.CreateRet(tmp2);
}
