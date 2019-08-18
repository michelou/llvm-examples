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

static LLVMContext TheContext;
static Type* TYPE_INT32 = Type::getInt32Ty(TheContext);
// or: static Type* TYPE_INT32 = IntegerType::get(TheContext, 32);

// extern void printf(const char *fmt, ...);
// (adapted from https://github.com/thomaslee/llvm-demo)
static Function* printf_prototype(LLVMContext& ctx, Module *mod) {
    std::vector<Type*> printf_arg_types;
    printf_arg_types.push_back(Type::getInt8PtrTy(ctx));
    FunctionType* printf_type =
        FunctionType::get(/*res_type*/TYPE_INT32, printf_arg_types, true);
    Function* func = Function::Create(
        printf_type, Function::ExternalLinkage, Twine("printf"), mod);
    func->setCallingConv(CallingConv::C);
    return func;
}

// printf("%d\n", v);
static Constant* fmt_constant(LLVMContext& ctx, Module *mod) {
    Constant* format_const = ConstantDataArray::getString(ctx, "%d\n");
    Type * var_type = ArrayType::get(IntegerType::get(ctx, 8), 4);
    GlobalVariable* var = new GlobalVariable(*mod, var_type,
        true, GlobalValue::PrivateLinkage, format_const, ".str");
    Constant* zero = Constant::getNullValue(TYPE_INT32);

    std::vector<Constant*> indices;
    indices.push_back(zero);
    indices.push_back(zero);
    return ConstantExpr::getGetElementPtr(var_type, var, indices);
}

// int main()
static Function* main_prototype(LLVMContext& ctx, Module *mod) {
    std::vector<Type*> main_arg_types;
    FunctionType* main_type =
        FunctionType::get(/*res_type*/TYPE_INT32, main_arg_types, false);
    Function *func = Function::Create(
        main_type, Function::ExternalLinkage, Twine("main"), mod);
    func->setCallingConv(CallingConv::C);
    return func;
}

// int mul_add(int, int, int)
static Function* mul_add_prototype(LLVMContext& ctx, Module *mod) {
    std::vector<Type*> mul_add_arg_types;
    mul_add_arg_types.push_back(TYPE_INT32); // x
    mul_add_arg_types.push_back(TYPE_INT32); // y
    mul_add_arg_types.push_back(TYPE_INT32); // z
    FunctionType* mul_add_type =
        FunctionType::get(/*res_type*/TYPE_INT32, mul_add_arg_types, true);
    Function* func = Function::Create(
        mul_add_type, Function::PrivateLinkage, Twine("mul_add"), mod);
    func->setCallingConv(CallingConv::C);
    return func;
}

void mul_add_body(LLVMContext& ctx, Module *mod, Function* mul_add_func) {
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

void main_body(LLVMContext& ctx, Module *mod, Function* main_func) {
    Function *mul_add_func = mul_add_prototype(ctx, mod);
    mul_add_body(ctx, mod, mul_add_func);

    Function *printf_func = printf_prototype(ctx, mod);

    BasicBlock* block = BasicBlock::Create(ctx, "entry", main_func);
    IRBuilder<> builder(block);

    std::vector<Value *> mul_add_args;
    mul_add_args.push_back(ConstantInt::get(ctx, APInt(32, 10)));
    mul_add_args.push_back(ConstantInt::get(ctx, APInt(32, 2)));
    mul_add_args.push_back(ConstantInt::get(ctx, APInt(32, 3)));
    Value* mul_add_res = builder.CreateCall(mul_add_func, mul_add_args, "mul_add");

    std::vector<Value *> printf_args;
    printf_args.push_back(fmt_constant(ctx, mod));
    printf_args.push_back(mul_add_res);
    CallInst *call = builder.CreateCall(printf_func, printf_args, "printf");

    ConstantInt* zero = ConstantInt::get(ctx, APInt(32, 0));
    builder.CreateRet(zero);    
}

Module* makeLLVMModule() {
    // Module Construction
    Module* mod = new Module("tut1_main", TheContext);

    Function *main_func = main_prototype(TheContext, mod);
    main_body(TheContext, mod, main_func);

    return mod;
}
