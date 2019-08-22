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

    verifyModule(*Mod);

    legacy::PassManager PM;
    PM.add(createPrintModulePass(outs()));
    PM.run(*Mod);

    delete Mod;
    return 0;
}

#define CONST_INT32(X) ConstantInt::get(ctx, APInt(32, X))

static LLVMContext TheContext;
static Type* TYPE_INT32 = Type::getInt32Ty(TheContext);
// or: static Type* TYPE_INT32 = IntegerType::get(TheContext, 32);
static Type* TYPE_CHAR = Type::getInt8Ty(TheContext);
static Type* TYPE_CHAR_PTR = Type::getInt8PtrTy(TheContext);

// void printf(const char *fmt, ...);
static Function* printf_prototype(Module* mod) {
    std::vector<Type*> arg_types = { TYPE_CHAR_PTR };
    FunctionType* func_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, arg_types, /*isVarArg*/true);
    Function* func = Function::Create(
        func_type, Function::ExternalLinkage, Twine("printf"), mod);
    func->setCallingConv(CallingConv::C);

    return func;
}

// "%d\n"
static Constant* printf_fmt_decimal(Module* mod, const char* fmt = "%d\n") {
    LLVMContext& ctx = mod->getContext();
    Constant* format_const = ConstantDataArray::getString(ctx, fmt);
    Type* var_type = ArrayType::get(TYPE_CHAR, strlen(fmt) + 1);
    GlobalVariable* var = new GlobalVariable(*mod, var_type,
        true, GlobalValue::PrivateLinkage, format_const, ".str");

    Constant* zero = Constant::getNullValue(TYPE_INT32);
    std::vector<Constant*> indices = { zero, zero };

    return ConstantExpr::getGetElementPtr(var_type, var, indices);
}

// int main()
static Function* main_prototype(Module* mod) {
    FunctionType* func_type = // no parameter list
        FunctionType::get(/*ret_type*/TYPE_INT32, /*isVarArg*/false);
    Function* func = Function::Create(
        func_type, Function::ExternalLinkage, Twine("main"), mod);
    func->setCallingConv(CallingConv::C);

    return func;
}

// int mul_add(int, int, int)
static Function* mul_add_prototype(Module* mod) {
    std::vector<Type*> arg_types =
        { /*x*/TYPE_INT32, /*y*/TYPE_INT32, /*z*/TYPE_INT32 };
    FunctionType* func_type =
        FunctionType::get(/*ret_type*/TYPE_INT32, arg_types, /*isVarArg*/false);
    Function* func = Function::Create(
        func_type, Function::PrivateLinkage, Twine("mul_add"), mod);
    func->setCallingConv(CallingConv::C);

    return func;
}

/*
int mul_add(int x, int y, int z) {
  return x * y + z;
}
*/
void mul_add_body(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    Function* mul_add_func = mul_add_prototype(mod);
    Function::arg_iterator args = mul_add_func->arg_begin();
    Value* x = args++;
    x->setName("x");
    Value* y = args++;
    y->setName("y");
    Value* z = args++;
    z->setName("z");

    BasicBlock* block = BasicBlock::Create(ctx, "entry", mul_add_func);
    IRBuilder<> builder(block);
  
    Value* tmp = builder.CreateBinOp(Instruction::Mul, x, y, "tmp");
    Value* tmp2 = builder.CreateBinOp(Instruction::Add, tmp, z, "tmp2");

    builder.CreateRet(tmp2);
}

/*
int main() {
   printf("%d\n", mul_add(10, 2, 3));
   return 0;   
}
*/
static void main_body(Module* mod) {
    LLVMContext& ctx = mod->getContext();
    Function* main_func = main_prototype(mod);

    Function* printf_func = printf_prototype(mod);
    Constant* printf_fmt = printf_fmt_decimal(mod);

    BasicBlock* block = BasicBlock::Create(ctx, "entry", main_func);
    IRBuilder<> builder(block);

    std::vector<Value *> mul_add_args =
        { CONST_INT32(10), CONST_INT32(2), CONST_INT32(3) };
    Value* mul_add_res = builder.CreateCall(mod->getFunction("mul_add"), mul_add_args, "mul_add");

    std::vector<Value *> printf_args = { printf_fmt, mul_add_res };
    CallInst* call = builder.CreateCall(printf_func, printf_args, "printf");

    builder.CreateRet(CONST_INT32(0));
}

Module* makeLLVMModule() {
    Module* mod = new Module("tut1_main", TheContext);

    mul_add_body(mod);
    main_body(mod);

    return mod;
}
