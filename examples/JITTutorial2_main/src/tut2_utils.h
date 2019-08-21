#ifndef TUT2_UTILS_H
#define TUT2_UTILS_H

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"

using namespace llvm;

void initModule(Module* mod);

CallInst* createPrintInt(Module* mod, IRBuilder<> builder, Value* v);

CallInst* createPrintStr(Module* mod, IRBuilder<> builder, const char* s);
CallInst* createPrintStr(Module* mod, IRBuilder<> builder, Value* v);

CallInst* createPrintIntLn(Module* mod, IRBuilder<> builder, Value* v);

CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, const char* s);
CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, Value* v);

CallInst* createStrToInt(Module* mod, IRBuilder<> builder, Value* str);

#endif // TUT2_UTILS_H
