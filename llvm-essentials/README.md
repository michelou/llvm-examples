# <span id="top">Book <i>LLVM Essentials</i></span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://llvm.org/" rel="external"><img src="../docs/images/llvm.png" width="120" alt="LLVM project"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <a href="."><strong><code>llvm-essentials\</code></strong></a> contains <a href="https://llvm.org/img/LLVM-Logo-Derivative-1.png" rel="external" alt="LLVM">LLVM</a> code examples from the book <a href="https://www.packtpub.com/application-development/llvm-essentials" rel="external">LLVM Essentials</a> by S. Sarda &amp; M. Pandey (Packt Publishing, December 2015).<br/>
  It also includes several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a> for running the example on a Windows machine.
  </td>
  </tr>
</table>

## <span id="1_2">1.2 Getting_familiar_with_LLVM_IR</span>

This code example consists of the two files [**`src\add.c`**](./1_2_Getting_familiar_with_LLVM_IR/src/add.c) and [**`build.bat`**](./1_2_Getting_familiar_with_LLVM_IR/build.bat).

In this first example we simply run [**`clang.exe`**][clang_cli] with option `-emit-llvm` to generate the assembly file `add.ll`<sup id="anchor_01">[1](#footnote_01)</sup>.

<pre style="font-size:80%;">
<b>&gt; <a href="./1_2_Getting_familiar_with_LLVM_IR/build.bat">build</a> -verbose run</b>
Toolset: Clang/CMake, Project: add
Generate IR code to file "build\add.ll"
</pre>

The generated assembly file `add.ll`<sup id="anchor_02">[2](#footnote_02)</sup> looks as follows :

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/type">type</a> target\add.ll</b>
; ModuleID = 'L:\llvm-essentials\1_2_Getting_familiar_with_LLVM_IR\src\add.c'
source_filename = "L:\\llvm-essentials\\1_2_Getting_familiar_with_LLVM_IR\\src\\add.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.28.29912"

@globvar = dso_local global i32 12, align 4

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @add(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = load i32, i32* @globvar, align 4
  %4 = load i32, i32* %2, align 4
  %5 = add nsw i32 %3, %4
  ret i32 %5
}

attributes #0 = { noinline nounwind optnone [...] }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 2}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 14.0.4"}
</pre>

## <span id="3_2">3.2 Getting_address_of_element</span>[**&#x25B4;**](#top)

This code example consists of two files: [**`src\toy.cpp`**](./3_2_Getting_address_of_element/src/toy.cpp) and [**`build.bat`**](./3_2_Getting_address_of_element/build.bat).

Function `main` in source file [**`src\toy.cpp`**](./3_2_Getting_address_of_element/src/toy.cpp) calls LLVM API functions to generate assembly code for the tiny function `foo` :

<pre style="font-size:80%;">
<b>&gt; <a href="./3_2_Getting_address_of_element/build.bat">build</a> -verbose run</b>
Project: toy, Configuration: Release, Platform: x64
Current directory: "L:\llvm-essentials\3_2_Getting_address_of_element\build"
Generate configuration files into directory "build"
Generate executable "toy.exe"
Execute build\Release\toy.exe
; ModuleID = 'my compiler'
source_filename = "my compiler"

define i32 @foo(<2 x i32>* %a) {
entry:
  %a1 = getelementptr i32, <2 x i32>* %a, i32 1
  ret i32 0
}
</pre>

## <span id="3_3">3.3 Reading_from_memory</span>

This code example consists of two files: [**`src\toy.cpp`**](./3_3_Reading_from_memory/src/toy.cpp) and [**`build.bat`**](./3_3_Reading_from_memory/build.bat).

Function `main` in source file [**`src\toy.cpp`**](./3_3_Reading_from_memory/src/toy.cpp) calls LLVM API functions to generate assembly code for the tiny function `foo` :

<pre style="font-size:80%;">
<b>&gt; <a href="./3_3_Reading_from_memory/build.bat">build</a> -verbose run</b>
Project: toy, Configuration: Release, Platform: x64
Current directory: L:\llvm-essentials\3_3_Reading_from_memory\build
Generate configuration files into directory "build"
Generate executable "toy.exe"
Execute build\Release\toy.exe
; ModuleID = 'my compiler'
source_filename = "my compiler"

define i32 @foo(<2 x i32>* %a) {
entry:
  %a1 = getelementptr <2 x i32>*, <2 x i32>* %a, i32 1
  %load = load <2 x i32>*, <2 x i32>** %a1, align 8
  ret <2 x i32>* %load
}
</pre>

## <span id="3_4">3.4 Writing to memory</span>[**&#x25B4;**](#top)

This code example consists of two files: [**`src\toy.cpp`**](./3_4_Writing_to_memory/src/toy.cpp) and [**`build.bat`**](./3_4_Writing_to_memory/build.bat).

Function `main` in source file [**`src\toy.cpp`**](./3_4_Writing_to_memory/src/toy.cpp) calls LLVM API functions to generate assembly code for the tiny function `foo` :

<pre style="font-size:80%;">
<b>&gt; <a href="./3_4_Writing_to_memory/build.bat">build</a> -verbose run</b>
Project: toy, Configuration: Release, Platform: x64
Current directory: "L:\llvm-essentials\3_4_Writing_to_memory\build"
Generate configuration files into directory "build"
Generate executable "toy.exe"
Execute "build\Release\toy.exe"
; ModuleID = 'my compiler'
source_filename = "my compiler"

define i32 @foo(<2 x i32>* %a) {
entry:
  %a1 = getelementptr i32, <2 x i32>* %a, i32 1
  %load = load i32, i32* %a1, align 1
  %multmp = mul i32 %load, 16
  store i32 %multmp, i32* %a1, align 1
  ret i32 %multmp
}
</pre>

## <span id="footnotes">Footnotes</span>

<span id="footnote_01">[1]</span> ***LLVM file extensions*** [↩](#anchor_01)

<dl><dd>
<table>
<tr><th>Extension</th><th>Description</th></tr>
<tr><td><code>.bc</code></td><td>bitcode format (binary)</td></tr>
<tr><td><code>.ll</code></td><td>assembly language format (text)</td></tr>
</table>
</dd></dl>

<span id="footnote_02">[2]</span> **`main`** ***function not found*** [↩](#anchor_02)

<dl><dd>
The assembly code in file <code>add.ll</code> can not be executed with <a href="https://llvm.org/docs/CommandGuide/lli.html"><code><b>lli.exe</b></code></a> since it doesn't define a <code>main</code> function as the program entry point : 
</dd>
<dd>
<pre style="font-size:80%;">
<b>&gt; %LLVM_HOME%\bin\<a href="https://llvm.org/docs/CommandGuide/lli.html">lli.exe</a> build\add.ll</b>
C:\opt\LLVM-15.0.6\bin\lli.exe: error: 'main' function not found in module.
</pre>
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/December 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- hyperrefs -->

[clang_cli]: https://clang.llvm.org/docs/UsersManual.html#id13
