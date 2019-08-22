#ifndef TUT2_UTILS_H
#define TUT2_UTILS_H

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"

using namespace llvm;

void initModule(Module* mod);

/* printf("%d", d) where type(d) = int */
CallInst* createPrintInt(Module* mod, IRBuilder<> builder, Value* v);

/* printf("%s", s) where type(s) = const char* */
CallInst* createPrintStr(Module* mod, IRBuilder<> builder, const char* s);
CallInst* createPrintStr(Module* mod, IRBuilder<> builder, Value* v);

/* printf("%d\n", d) where type(d) = int */
CallInst* createPrintIntLn(Module* mod, IRBuilder<> builder, Value* v);

/* printf("%s\n", s) where type(s) = const char* */
CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, const char* s);
CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, Value* v);

/* int strtol(const char* s) */
CallInst* createStrToInt(Module* mod, IRBuilder<> builder, Value* str);

#endif // TUT2_UTILS_H
