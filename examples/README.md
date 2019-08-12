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

In the following we present in more detail the two examples [**`hello`**](hello/) and [**`JITTutorial1\`**](JITTutorial1/); other examples in directory [**`examples\`**](./) behave the same.


## `hello` Example

This first example simply prints the message **`"Hello world !"`** to the console.

The goal here is to refresh our knowledge of the build tools [**`Clang`**](https://clang.llvm.org/docs/ClangCommandLineReference.html), [**`CMake`**](https://cmake.org/cmake/help/latest/manual/cmake.1.html), [**`GNU Make`**](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) and [**`MSBuild`**](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019). 

Command [**`build`**](hello/build.bat) with no argument displays the available options and subcommands:

> **:mag_right:** Command [**`build`**](hello/build.bat) is a basic batch file consisting of ~230 lines of code <sup id="anchor_01">[[1]](#footnote_01)</sup>.

<pre>
<b>&gt; build</b>
Usage: build { options | subcommands }
Options:
  -debug      show commands executed by this script
  -make       use GNU Make instead of MSBuild
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
Hello world !
</pre>

Command [**`build -verbose clean run`**](JITTutorial1/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; build -verbose clean run</b>
Delete directory "build"
Project: hello, Configuration: Release, Platform: x64
Generate configuration files into directory "build"
Generate executable hello.exe
Execute build\Release\hello.exe
Hello world !
</pre>

Command [**`build -verbose -make clean run`**](JITTutorial1/build.bat) further uses [**`GNU Make`**](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) and [**`Clang`**](https://clang.llvm.org/docs/ClangCommandLineReference.html) to generate executable **`hello.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -verbose -make clean run</b>
Delete directory "build"
Generate configuration files into directory "build"
Generate executable hello.exe
Execute build\hello.exe
Hello world !
</pre>


## `JITTutorial1` Example

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

Finally, command [**`build -debug`**](JITTutorial1/build.bat) displays command executed during the build process:

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


## Footnotes

<a name="footnote_01">[1]</a> [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
Batch file <a href="JITTutorial1/build.bat"><b><code>build.bat</code></b></a> does obey the following coding conventions:
<ul>
<li>We use at most 80 characters per line. In general we would say that 80 characters fit well with 4:3 screens and 100 characters fit well with 16:9 screens (<a href="https://google.github.io/styleguide/javaguide.html#s4.4-column-limit">Google's convention</a> is 100 characters).</li>
<li>We organize our code in 4 sections: <code>Environment setup</code>, <code>Main</code>, <code>Subroutines</code> and <code>Cleanups</code>.</li>
<li>We write exactly <i>one exit instruction</i> (label <b><code>end</code></b> in section <b><code>Cleanups</code></b>).</li>
<li>We adopt the following naming conventions: global variables start with character <code>_</code> (shell variables defined in the user environment start with a letter) and local variables (e.g. inside subroutines or  <b><code>if/for</code></b> constructs) start with <code>__</code> (two <code>_</code> characters).</li>
</ul>
</p>
<pre style="margin:0 0 1em 20px;font-size:80%;">
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

***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
