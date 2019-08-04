# <span id="top">LLVM examples</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="http://dotty.epfl.ch/"><img style="border:0;width:120px;" src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" alt="LLVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <strong><code>examples\</code></strong> contains <a href="https://llvm.org/img/LLVM-Logo-Derivative-1.png" alt="LLVM">LLVM</a> examples coming from various websites - mostly from the <a href="https://llvm.org/">LLVM project</a>.
  </td>
  </tr>
</table>

In the following we explain in more detail the build tools available in the [**`JITTutorial1\`**](JITTutorial1/) example (and also in other examples from directory [**`examples\`**](./)):


## Command `build`

Command [**`build`**](JITTutorial1/build.bat) is a basic build tool consisting of ~180 lines of batch code featuring subcommands **`clean`**, **`compile`**, **`doc`**, **`help`** and **`run`**.

> **:mag_right:** The batch file for command [**`build`**](JITTutorial1/build.bat) obeys the following coding conventions:
>
> - We use at most 80 characters per line. In general we would say that 80 characters fit well with 4:3 screens and 100 characters fit well with 16:9 screens ([Google's convention](https://google.github.io/styleguide/javaguide.html#s4.4-column-limit) is 100 characters).
> - We organize our code in 4 sections: `Environment setup`, `Main`, `Subroutines` and `Cleanups`.
> - We write exactly ***one exit instruction*** (label **`end`** in section **`Cleanups`**).
> - We adopt the following naming conventions: global variables start with character `_` (shell variables defined in the user environment start with a letter) and local variables (e.g. inside subroutines or  **`if/for`** constructs) start with `__` (two `_` characters).

<pre style="font-size:80%;">
<b>@echo off</b>
<b>setlocal enabledelayedexpansion</b>
...
<i>rem ##########################################################################
rem ## Environment setup</i>

<b>set</b> _EXITCODE=0

<b>for</b> %%f <b>in</b> ("%~dp0") <b>do set</b> _ROOT_DIR=%%~sf

<b>call <span style="color:#9966ff;">:props</span></b>
<b>if not</b> %_EXITCODE%==0 <b>goto <span style="color:#9966ff;">end</span></b>

<b>call <span style="color:#9966ff;">:args</span> %*</b>
<b>if not</b> %_EXITCODE%==0 <b>goto <span style="color:#9966ff;">end</span></b>

<i>rem ##########################################################################
rem ## Main</i>

<b>if</b> %_CLEAN%==1 (
    <b>call :clean</b>
    <b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>if</b> %_COMPILE%==1 (
    <b>call <span style="color:#9966ff;">:compile</span></b>
    <b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>if</b> %_RUN%==1 (
    <b>call <span style="color:#9966ff;">:run</span></b>
    <b>if not</b> !_EXITCODE!==0 <b>goto end</b>
)
<b>goto <span style="color:#9966ff;">end</span></b>

<i>rem ##########################################################################
rem ## Subroutines</i>

<span style="color:#9966ff;">:props</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:args</span>
...
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

<i>rem ##########################################################################
rem ## Cleanups</i>

<span style="color:#9966ff;">:end</span>
...
<b>exit</b> /b %_EXITCODE%
</pre>

Running command [**`build`**](JITTutorial1/build.bat) in project directory [**`examples\JITTutorial1\`**](JITTutorial1/) displays the available options and subcommands:

<pre>
$ build
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

Running command [**`build clean run`**](JITTutorial1/build.bat) produces the following output:

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


Running command [**`build`**](JITTutorial/build.bat) with option **`-verbose`** in project directory [**`JITTutorial1\`**](JITTutorial1/) displays progress messages:

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

Finally, running command [**`build`**](JITTutorial1/build.bat) with option **`-debug`** in project directory [**`examples\JITTutorial1\`**](JITTutorial1/) also displays internal steps of the build process:

<pre style="font-size:80%;">
<b>&gt; build -debug clean compile run</b> 
[build] _CLEAN=1 _COMPILE=1 _RUN=1 _VERBOSE=0
[build] rmdir /s /q "L:\examples\JITTUT~1\build"
[build] call cmake.exe -Thost=x64 -A x64 -Wdeprecated -DLLVM_INSTALL_DIR="C:\opt\LLVM-8.0.1" ..
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

Temps écoulé 00:00:03.65
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


***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
