# <span id="top">LLVM examples</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://llvm.org/"><img style="border:0;width:120px;" src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" alt="LLVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <a href="."><strong><code>examples\</code></strong></a> contains <a href="https://llvm.org/img/LLVM-Logo-Derivative-1.png" alt="LLVM">LLVM</a> examples coming from various websites - mostly from the <a href="https://llvm.org/">LLVM project</a> and tested on a Windows machine.
  </td>
  </tr>
</table>

In the following we present in more detail five examples (each of them is a [**`CMake`**](https://cmake.org/cmake/help/latest/manual/cmake.1.html) project):

- [**`hello\`**](hello/),
- [**`JITTutorial1\`**](JITTutorial1/),
- [**`JITTutorial1_main\`**](JITTutorial1_main/) *(extended version of [**`JITTutorial1\`**](JITTutorial1/))*
- [**`JITTutorial2\`**](JITTutorial2/) and
- [**`JITTutorial2_main\`**](JITTutorial2_main/) *(extended version of [**`JITTutorial2\`**](JITTutorial2/))*


## `hello`

Example [**`hello\`**](hello/) simply prints the message **`"Hello world !"`** to the console (sources: [**`hello.c`**](hello/src/main/c/hello.c) or [**`hello.cpp`**](hello/src/main/cpp/hello.cpp)).

Our main goal here is to refresh our knowledge of the build tools [**`Clang`**](https://clang.llvm.org/docs/ClangCommandLineReference.html), [**`CMake`**](https://cmake.org/cmake/help/latest/manual/cmake.1.html), [**`GCC`**](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html), [**`GNU Make`**](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) and [**`MSBuild`**](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019) (see also the page [*"Getting Started with the LLVM System using Microsoft Visual Studio"*](https://llvm.org/docs/GettingStartedVS.html) from the [LLVM documentation](https://llvm.org/docs/index.html)). 

Command [**`build`**](hello/build.bat) with no argument displays the available options and subcommands:

> **:mag_right:** Command [**`build`**](hello/build.bat) is a basic batch file consisting of ~230 lines of code <sup id="anchor_01">[[1]](#footnote_01)</sup>.

<pre>
<b>&gt; build</b>
Usage: build { options | subcommands }
Options:
  -debug      show commands executed by this script
  -clang      use Clang (GNU Make) instead of CL (MSBuild)
  -gcc        use GCC (GNU Make) instead of CL (MSBuild)
  -verbose    display progress messages
Subcommands:
  clean       delete generated files
  compile     generate executable
  help        display this help message
  run         run the generated executable
</pre>

Command [**`build clean run`**](hello/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
Hello world !
</pre>

Command [**`build -verbose run`**](hello/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; build -verbose clean run</b>
Project: hello, Configuration: Release, Platform: x64
Generate configuration files into directory "build"
Generate executable hello.exe
Execute build\Release\hello.exe
Hello world !
</pre>

Command [**`build -debug run`**](hello/build.bat) uses the [**`MSBuild`**](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019) / [**`CL`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019) toolset to generate executable **`hello.exe`**

<pre style="font-size:80%;">
<b>&gt; build -debug run</b>
[build] _CLEAN=0 _COMPILE=1 _RUN=1 _TOOLSET=0 _VERBOSE=0
[build] Current directory is: L:\examples\hello\build
[build] cmake.exe -Thost=x64 -A x64 -Wdeprecated ..
-- Building for: Visual Studio 16 2019
-- The C compiler identification is MSVC 19.22.27905.0
-- The CXX compiler identification is MSVC 19.22.27905.0
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
[...]
-- Configuring done
-- Generating done
-- Build files have been written to: L:/examples/hello/build
[build] msbuild.exe /nologo /p:Configuration=Release /p:Platform="x64" "hello.sln"
[...]
[... many warnings (eg. C4514) ...]
    1043 Warning(s)
    0 Error(s)
&nbsp;
Elapsed time 00:00:03.19
[build] build\Release\hello.exe
Hello world !
[build] _EXITCODE=0
</pre>

Command [**`build -debug -clang run`**](hello/build.bat) relies on [**`GNU Make`**](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) / [**`Clang`**](https://clang.llvm.org/docs/ClangCommandLineReference.html) instead of [**`MSBuild`**](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019) / [**`CL`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019) to generate executable **`hello.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -debug -clang run</b>
[build] _CLEAN=0 _COMPILE=1 _RUN=1 _TOOLSET=1 _VERBOSE=0
[build] Current directory is: L:\examples\hello\build
[build] cmake.exe -G "Unix Makefiles" ..
-- The C compiler identification is Clang 8.0.1 with GNU-like command-line
-- The CXX compiler identification is Clang 8.0.1 with GNU-like command-line
-- Check for working C compiler: C:/opt/LLVM-8.0.1/bin/clang.exe
-- Check for working C compiler: C:/opt/LLVM-8.0.1/bin/clang.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
[...]
-- Configuring done
-- Generating done
-- Build files have been written to: L:/examples/hello/build
[build] make.exe
[...]
Scanning dependencies of target hello
[ 75%] Building C object CMakeFiles/hello.dir/src/main/c/hello.c.obj
[100%] Linking C executable hello.exe
[100%] Built target hello
[build] call build\hello.exe
Hello world !
[build] _EXITCODE=0
</pre>

Finally, command [**`build -debug -gcc run`**](hello/build.bat) uses the [**`GNU Make`**](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) / [**`GCC`**](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html) toolset to generate executable **`hello.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -debug -gcc run</b>
[build] _CLEAN=0 _COMPILE=1 _RUN=1 _TOOLSET=2 _VERBOSE=0
[build] Current directory is: L:\examples\hello\build
[build] cmake.exe -G "Unix Makefiles" ..
-- The C compiler identification is GNU 9.1.0
-- The CXX compiler identification is GNU 9.1.0
-- Check for working C compiler: C:/opt/msys64/mingw64/bin/gcc.exe
-- Check for working C compiler: C:/opt/msys64/mingw64/bin/gcc.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
[...]
-- Configuring done
-- Generating done
-- Build files have been written to: L:/examples/hello/build
[build] make.exe
[...]
Scanning dependencies of target hello
[ 75%] Building C object CMakeFiles/hello.dir/src/main/c/hello.c.obj
[100%] Linking C executable hello.exe
[100%] Built target hello
[build] build\hello.exe
Hello world !
[build] _EXITCODE=0
</pre>

## `JITTutorial1`

Example [**`JITTutorial1\`**](JITTutorial1/) is based on example [*"A First Function"*](http://releases.llvm.org/2.6/docs/tutorial/JITTutorial1.html) (*outdated*) from the LLVM 2.6 tutorial.

It defines a function **`mul_add`** and generates its [IR code](https://releases.llvm.org/8.0.1/docs/LangRef.html) (source: [**`tut1.cpp`**](JITTutorial1/src/tut1.cpp)).

Command [**`build`**](JITTutorial1/build.bat) with no argument displays the available options and subcommands:

<pre>
<b>&gt; build</b>
Usage: build { options | subcommands }
Options:
  -debug      show commands executed by this script
  -verbose    display progress messages
Subcommands:
  clean       delete generated files
  compile     generate executable
  help        display this help message
  run         run executable
</pre>

Command [**`build clean run`**](JITTutorial1/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>                            
; ModuleID = 'tut1'                            
source_filename = "tut1"                       
                                               
define i32 @mul_add(i32 %x, i32 %y, i32 %z) {  
entry:                                         
  %tmp = mul i32 %x, %y                        
  %tmp2 = add i32 %tmp, %z                     
  ret i32 %tmp2                                
}                                              
</pre>


Command [**`build -verbose`**](JITTutorial1/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; build -verbose clean compile run</b>                         
Delete directory "build"                                    
Project: JITTutorial1, Configuration: Release, Platform: x64
Current directory: L:\examples\JITTUT~1\build               
Generate configuration files into directory "build"         
Generate executable JITTutorial1.exe                        
Execute build\Release\JITTutorial1.exe                      
; ModuleID = 'tut1'                                         
source_filename = "tut1"                                    
                                                            
define i32 @mul_add(i32 %x, i32 %y, i32 %z) {               
entry:                                                      
  %tmp = mul i32 %x, %y                                     
  %tmp2 = add i32 %tmp, %z                                  
  ret i32 %tmp2                                             
}                                                           
</pre>

Finally, command [**`build -debug`**](JITTutorial1/build.bat) displays the commands executed during the build process:

<pre style="font-size:80%;">
<b>&gt; build -debug clean compile run</b> 
[build] _CLEAN=1 _COMPILE=1 _RUN=1 _VERBOSE=0
[build] rmdir /s /q "L:\examples\JITTUT~1\build"
[build] cmake.exe -Thost=x64 -A x64 -Wdeprecated -DLLVM_INSTALL_DIR="C:\opt\LLVM-8.0.1" ..
-- Building for: Visual Studio 16 2019
-- The CXX compiler identification is MSVC 19.21.27702.2
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.21.27702/bin/Hostx64/x64/cl.exe
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.21.27702/bin/Hostx64/x64/cl.exe -- works
-- Detecting CXX compiler ABI info 
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- LLVM installation directory: C:\opt\LLVM-8.0.1
-- Found LLVM 8.0.1
-- Using LLVMConfig.cmake in: C:/opt/LLVM-8.0.1/lib/cmake/llvm 
-- Using header files in: L:/llvm-8.0.1.src/include;L:/llvm-8.0.1.src/build/include 
-- Configuring done
-- Generating done
-- Build files have been written to: L:/examples/JITTutorial1/build
[build] call msbuild.exe /nologo /m /p:Configuration=Release /p:Platform="x64" "L:\example\JITTUT~1\build\JITTutorial1.sln"
The generation has started 02.08.2019 19:36:32.
[...]
    33 Warning(s)
    0 Error(s)

Elapsed time 00:00:03.65
[build] call build\Release\JITTutorial1.exe
; ModuleID = 'tut1'
source_filename = "tut1"

define i32 @mul_add(i32 %x, i32 %y, i32 %z) {
entry:
  %tmp = mul i32 %x, %y
  %tmp2 = add i32 %tmp, %z
  ret i32 %tmp2
}
[build] _EXITCODE=0
</pre>

Finally, one may wonder what's happen if we transform the above [IR code](https://releases.llvm.org/8.0.1/docs/LangRef.html) into an executable:

<pre style="font-size:80%;">
<b>&gt; build run &gt; tut1.ll</b>
&nbsp;
<b>&gt; clang -Wno-override-module -o tut1.exe tut1.ll</b>
LINK : fatal error LNK1561: entry point must be defined
clang: error: linker command failed with exit code 1561 (use -v to see invocation)
</pre>

<!--
> **:mag_right:** we use option **`-Wno-override-module`** ...
> <pre style="font-size:80%;">
<b>&gt; llvm-config --host-target</b>
x86_64-pc-windows-msvc
&nbsp;
<b>&gt; clang -print-target-triple</b>
x86_64-pc-windows-msvc
&nbsp;
<b>&gt; clang -print-effective-triple</b>
x86_64-pc-windows-msvc19.22.27905
</pre>
<p>
In section <a href="http://llvm.org/docs/Frontend/PerformanceTips.html#the-basics">The Basics</a> of the LLVM documentation we can read: "Make sure that your Modules contain both a data layout specification and target triple. Without these pieces, none of the target specific optimization will be enabled. This can have a major effect on the generated code quality."
</p>
-->

The LLVM linker requires an entry point to successfully generate an executable, ie. we have to add a function **`main`** to our code; we present our solution in example [**`JITTutorial1_main\`**](JITTutorial1_main/).

## `JITTutorial1_main`

[**`JITTutorial1_main\`**](JITTutorial1_main/) is an extended version of previous example [**`JITTutorial1\`**](JITTutorial1/):

- it defines the same function **`mul_add`** as in example [**`JITTutorial1\`**](JITTutorial1/),
- it defines a **`main`** function (with no parameter) as program entry point and
- it defines a **`printf`** function to print out the result.

> **:mag_right:** The source code ([**`tut1_main.cpp`**](JITTutorial1_main/src/tut1_main.cpp)) has been reorganized in order to better distinguish between prototype definition and code generation.

Command [**`build clean run`**](JITTutorial1_main/build.bat) produces the following output:

<pre style="font-size:80%;">
 build clean run
; ModuleID = 'tut1_main'
source_filename = "tut1_main"

@.str = private constant [4 x i8] c"%d\0A\00"

define i32 @main() {
entry:
  %mul_add = call i32 (i32, i32, i32, ...) @mul_add(i32 10, i32 2, i32 3)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %mul_add)
  ret i32 0
}

define private i32 @mul_add(i32 %x, i32 %y, i32 %z, ...) {
entry:
  %tmp = mul i32 %x, %y
  %tmp2 = add i32 %tmp, %z
  ret i32 %tmp2
}

declare i32 @printf(i8*, ...)
</pre>

Now, let's transform the above [IR code](https://releases.llvm.org/8.0.1/docs/LangRef.html) into an executable:

<pre style="font-size:80%;">
<b>&gt; build run &gt; tut1.ll</b>
&nbsp;
<b>&gt; clang -Wno-override-module -o tut1.exe tut1.ll</b>
&nbsp;
<b>&gt; tut1.exe</b>
23
</pre>


## `JITTutorial2`

[**`JITTutorial2\`**](JITTutorial2/) is based on example [*"A More Complicated Function"*](http://releases.llvm.org/2.6/docs/tutorial/JITTutorial2.html) (*outdated*) from the LLVM 2.6 tutorial.

It defines a function **`gcd`** (*greatest common denominator*) and generates its [IR code](https://releases.llvm.org/8.0.1/docs/LangRef.html) (source: [**`tut2.cpp`**](JITTutorial2/src/tut2.cpp)).

Command [**`build clean run`**](JITTutorial2/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
; ModuleID = 'tut2'
source_filename = "tut2"

define i32 @gcd(i32 %x, i32 %y) {
entry:
  %tmp = icmp eq i32 %x, %y
  br i1 %tmp, label %return, label %cond_false

return:                                           ; preds = %entry
  ret i32 %x

cond_false:                                       ; preds = %entry
  %tmp2 = icmp ult i32 %x, %y
  br i1 %tmp2, label %cond_true, label %cond_false1

cond_true:                                        ; preds = %cond_false
  %tmp3 = sub i32 %y, %x
  %tmp4 = call i32 @gcd(i32 %x, i32 %tmp3)
  ret i32 %tmp4

cond_false1:                                      ; preds = %cond_false
  %tmp5 = sub i32 %x, %y
  %tmp6 = call i32 @gcd(i32 %tmp5, i32 %y)
  ret i32 %tmp6
}
</pre>

## `JITTutorial2_main`

[**`JITTutorial2_main\`**](JITTutorial2_main/) is an extended version of previous example [**`JITTutorial2\`**](JITTutorial2/):

- it defines the same function **`gcd`** as in example [**`JITTutorial2\`**](JITTutorial2/),
- it defines a **`main`** function with parameters **`argc`** and **`argv`** as program entry point and
- it defines several **`printf`** functions to print out both string and integer values.
- it defined a **`strtol`** function to convert string values to integer values.

> **:mag_right:** The **`printf`** functions are implemented in the separate source file ([**`tut2_utils.cpp`**](JITTutorial2_main/src/tut2_utils.cpp)) to keep the main source file ([**`tut2_main.cpp`**](JITTutorial2_main/src/tut2_main.cpp)) more readable. The corresponding include file ([**`tut2_utils.h`**](JITTutorial2_main/src/tut2_utils.h)) defines the following function headers:
><pre style="font-size:80%;">
><b>void</b> initModule(Module* mod);
>CallInst* createPrintInt(Module* mod, IRBuilder<> builder, Value* v);
>CallInst* createPrintStr(Module* mod, IRBuilder<> builder, const char* s);
>CallInst* createPrintStr(Module* mod, IRBuilder<> builder, Value* v);
>CallInst* createPrintIntLn(Module* mod, IRBuilder<> builder, Value* v);
>CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, const char* s);
>CallInst* createPrintStrLn(Module* mod, IRBuilder<> builder, Value* v);
>CallInst* createStrToInt(Module* mod, IRBuilder<> builder, Value* str);
> </pre>

Command [**`build clean run`**](JITTutorial2_main/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
; ModuleID = 'tut2_main'
source_filename = "tut2_main"
target datalayout = "e-m:w-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.22.27905"

@.str = private constant [6 x i8] c"argc=\00"
@.str_s = private constant [3 x i8] c"%s\00"
@.str_d = private constant [4 x i8] c"%d\0A\00"
@.str.1 = private constant [7 x i8] c"argv1=\00"
@.str_s.2 = private constant [4 x i8] c"%s\0A\00"
@.str.3 = private constant [7 x i8] c"argv2=\00"
@.str.4 = private constant [8 x i8] c"result=\00"

define private i32 @gcd(i32 %x, i32 %y, ...) {
// same as before
}

define dso_local i32 @main(i32 %argc, i8** %argv) {
entry:
  %0 = alloca i32, align 4
  %1 = alloca i32, align 4
  %2 = alloca i8**, align 8
  store i32 0, i32* %0, align 4
  store i32 %argc, i32* %1, align 4
  store i8** %argv, i8*** %2, align 8
  %3 = load i32, i32* %1
  %4 = load i8**, i8*** %2, align 8
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str_s, i32 0, i32 0), [6 x i8]* @.str)
  %printf1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str_d, i32 0, i32 0), i32 %3)
  %5 = getelementptr inbounds i8*, i8** %4, i64 1
  %elem_i = load i8*, i8** %5, align 8
  %6 = getelementptr inbounds i8*, i8** %4, i64 2
  %elem_i2 = load i8*, i8** %6, align 8
  %printf3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str_s, i32 0, i32 0), [7 x i8]* @.str.1)
  %printf4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str_s.2, i32 0, i32 0), i8* %elem_i)
  %printf5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str_s, i32 0, i32 0), [7 x i8]* @.str.3)
  %printf6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str_s.2, i32 0, i32 0), i8* %elem_i2)
  %strtol = call i32 (i8*, i8**, i32, ...) @strtol(i8* %elem_i, i8** null, i32 10)
  %strtol7 = call i32 (i8*, i8**, i32, ...) @strtol(i8* %elem_i2, i8** null, i32 10)
  %7 = call i32 (i32, i32, ...) @gcd(i32 %strtol, i32 %strtol7)
  %printf8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str_s, i32 0, i32 0), [8 x i8]* @.str.4)
  %printf9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str_d, i32 0, i32 0), i32 %7)
  ret i32 0
}

declare dso_local i32 @printf(i8*, ...)

declare dso_local i32 @strtol(i8*, i8**, i32, ...)
</pre>

Command [**`build clean run`**](JITTutorial2_main/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean test</b>
argc=3
argv1=12
argv2=4
result=4
</pre>

And obviously, we can also run the generated executable directly with two numbers of our choice as arguments:

<pre style="font-size:80%;">
<b>&gt; build\tut2.exe 210 45</b>
argc=3
argv1=210
argv2=45
result=15
</pre>


## Footnotes

<a name="footnote_01">[1]</a> ***Coding conventions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
Out batch files (eg. <a href="JITTutorial1/build.bat"><b><code>build.bat</code></b></a>) do obey the following coding conventions:
<ul>
<li>We use at most 80 characters per line. Concretely we observe that 80 characters fit well with 4:3 screens and 100 characters fit well with 16:9 screens (<a href="https://google.github.io/styleguide/javaguide.html#s4.4-column-limit">Google's convention</a> is 100 characters).</li>
<li>We organize our code in 4 sections: <code>Environment setup</code>, <code>Main</code>, <code>Subroutines</code> and <code>Cleanups</code>.</li>
<li>We write exactly <i>one exit instruction</i> (label <b><code>end</code></b> in section <b><code>Cleanups</code></b>).</li>
<li>We adopt the following naming conventions for variables: global variables start with character <code>_</code> (shell variables defined in the user environment start with a letter) and local variables (e.g. inside subroutines or  <b><code>if/for</code></b> constructs) start with <code>__</code> (two <code>_</code> characters).</li>
</ul>
</p>
<pre style="margin:0 0 1em 20px;font-size:80%;">
<b>@echo off</b>
<b>setlocal enabledelayedexpansion</b>
&nbsp;
<i>rem ##########################################################################
rem ## Environment setup</i>
&nbsp;
<b>set</b> _EXITCODE=0
&nbsp;
<b>for</b> %%f <b>in</b> ("%~dp0") <b>do set</b> _ROOT_DIR=%%~sf
&nbsp;
<b>call <span style="color:#9966ff;">:props</span></b>
<b>if not</b> %_EXITCODE%==0 <b>goto <span style="color:#9966ff;">end</span></b>
&nbsp;
<b>call <span style="color:#9966ff;">:args</span> %*</b>
<b>if not</b> %_EXITCODE%==0 <b>goto <span style="color:#9966ff;">end</span></b>
&nbsp;
<i>rem ##########################################################################
rem ## Main</i>
&nbsp;
<b>if</b> %_CLEAN%==1 (
&nbsp;&nbsp;&nbsp;&nbsp;<b>call :clean</b>
&nbsp;&nbsp;&nbsp;&nbsp;<b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>if</b> %_COMPILE%==1 (
&nbsp;&nbsp;&nbsp;&nbsp;<b>call <span style="color:#9966ff;">:compile</span></b>
&nbsp;&nbsp;&nbsp;&nbsp;<b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>if</b> %_RUN%==1 (
&nbsp;&nbsp;&nbsp;&nbsp;<b>call <span style="color:#9966ff;">:run</span></b>
&nbsp;&nbsp;&nbsp;&nbsp;<b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>goto <span style="color:#9966ff;">end</span></b>
&nbsp;
<i>rem ##########################################################################
rem ## Subroutines</i>
&nbsp;
<span style="color:#9966ff;">:props</span>
... <i>(read property file)</i> ...
<b>goto :eof</b>
<span style="color:#9966ff;">:args</span>
... <i>(handle program arguments)</i> ...
<b>goto :eof</b>
<span style="color:#9966ff;">:clean</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:compile</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:run</span>
...
<b>goto :eof</b>
&nbsp;
<i>rem ##########################################################################
rem ## Cleanups</i>
&nbsp;
<span style="color:#9966ff;">:end</span>
...
<b>exit</b> /b %_EXITCODE%
</pre>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
