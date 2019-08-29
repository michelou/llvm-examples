#ifndef UTILS_H
#define UTILS_H

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"

using namespace llvm;

void initModule(Module* Mod);

/* printf("%d", d) where type(d) = int */
CallInst* createPrintInt(Module* Mod, IRBuilder<> Builder, Value* Arg);

/* printf("%s", s) where type(s) = const char* */
CallInst* createPrintStr(Module* Mod, IRBuilder<> Builder, const char* ArgStr);
CallInst* createPrintStr(Module* Mod, IRBuilder<> Builder, Value* Arg);

/* printf("%d\n", d) where type(d) = int */
CallInst* createPrintIntLn(Module* Mod, IRBuilder<> Builder, Value* Arg);

/* printf("%s\n", s) where type(s) = const char* */
CallInst* createPrintStrLn(Module* Mod, IRBuilder<> Builder, const char* ArgStr);
CallInst* createPrintStrLn(Module* Mod, IRBuilder<> Builder, Value* Arg);

/* int strtol(const char* s) */
CallInst* createStrToInt(Module* Mod, IRBuilder<> Builder, Value* ArgStr);

#endif // UTILS_H
