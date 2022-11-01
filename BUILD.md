# <span id="top">Building LLVM on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/" rel="external"><img src="docs/images/llvm.png" width="120" alt="LLVM project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document presents our build from the <a href="https://llvm.org/" rel="external">LLVM</a> source distribution on a Windows machine.
  </td>
  </tr>
</table>

## <span id="build">`build.bat`</span>

Command [**`build.bat`**](bin/llvm/build.bat) consists of ~350 lines of batch/PowerShell code we wrote to generate additional Windows binaries not available in the <a href="https://llvm.org/" rel="external">LLVM</a> binary distribution.

> **:mag_right:** For instance, [LLVM tools][llvm_tools] such as [**`llvm-as.exe`**][llvm_as] (assembler), [**`llvm-dis.exe`**][llvm_dis] (disassembler), [**`opt.exe`**][llvm_opt] (optimizer), [**`llc.exe`**][llvm_llc] (static compiler) and [**`lli.exe`**][llvm_lli] (bitcode interpreter) are not part of the [LLVM] binary distribution (e.g. [`LLVM-14.0.6-win64.exe`][llvm_downloads]).


## <span id="usage_examples">Usage examples</span>

Directory **`llvm-14.0.6.src\`** is setup as follows:
<pre style="font-size:80%;">
<b>&gt; <a href="https://curl.haxx.se/docs/manpage.html">curl</a> -sL -o llvm-14.0.6.src.tar.xz <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-14.0.6">llvm-14.0.6.src.tar.xz</a></b>
<b>&gt; <a href="http://linuxcommand.org/lc3_man_pages/tar1.html">tar</a> xzvf llvm-14.0.6.src.tar.xz</b>
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/cp.1.html">cp</cp> <a href="bin/llvm/build.bat">bin\llvm\build.bat</a> llvm-14.0.6.src</b>
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a> llvm-14.0.6.src</b>
</pre>

> **:mag_right:** In our case we successively worked with versions `8.0.1`, `9.0.1`, `10.0.1`, `11.0.1`, `11.1.0`, `12.0.1`, `13.0.1` of the [LLVM] source distribution and today we build our binaries from directory `llvm-14.0.6.src\`.

Command [**`build.bat -verbose compile`**](bin/llvm/build.bat) <sup id="anchor_01">[1](#footnote_01)</sup> generates the additional binaries (both **`.exe`** and **`.lib`** files) into directory **`build\Release\`** (resp. **`build\Debug\`**). Be patient, build time is about 55 minutes on an Intel i7-4th with 16 GB of memory.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
L:\llvm-14.0.6.src
&nbsp;
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose compile</b>
Toolset: MSVC/MSBuild, Project: LLVM
**********************************************************************
** Visual Studio 2019 Developer Command Prompt v16.11.11
** Copyright (c) 2019 Microsoft Corporation
**********************************************************************
[vcvarsall.bat] Environment initialized for: 'x64'
INCLUDE="..."
LIB="..."
Configuration: Debug, Platform: x64
[build] Current directory is: L:\llvm-14.0.6.src\build
[...]
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> build\Release\bin\ll?.exe | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /b [0-9]</b>
31.06.2022  00:32        24 143 872 llc.exe
31.06.2022  00:33        22 501 376 lli.exe
</pre>

> **:mag_right:** Command [**`build -verbose run`**](bin/llvm/build.bat) also execute **`lli.exe -version`** at the end of the build process :
> <pre style="font-size:80%;">
> [...]
> Generate LLVM executables (LLVM.sln)
> Execute build\Release\bin\lli.exe --version
> LLVM (http://llvm.org/):
>   LLVM version 14.0.6
>   Optimized build.
>   Default target: x86_64-pc-windows-msvc
>   Host CPU: haswell
</pre>

Command [**`build.bat -verbose install`**](bin/llvm/build.bat) copies the generated binaries to the [LLVM] installation directory (in our case **`C:\opt\LLVM-14.0.6\`**).

<pre style="font-size:80%;">
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose install</b>
Do really want to copy files from 'build\' to 'c:\opt\LLVM-14.0.6\' (Y/N)? y
Copy files from directory build\Release\bin to C:\opt\LLVM-14.0.6\bin\
Copy files from directory build\Release\lib to C:\opt\LLVM-14.0.6\lib\
Copy files from directory build\lib\cmake to C:\opt\LLVM-14.0.6\lib\cmake\
Copy files from directory include to C:\opt\LLVM-14.0.6\include\
</pre>

> **:mag_right:** Before installation our [LLVM] installation directory contains 14 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-14.0.6 llvm*.exe | <a href="https://man7.org/linux/man-pages/man1/wc.1.html">wc</a> -l</b>
> 18
> </pre>
> and after installation it contains 75 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-14.0.6 llvm*.exe | <a href="https://man7.org/linux/man-pages/man1/wc.1.html">wc</a> -l</b>
> 75
> </pre>

We list below several executables in the [LLVM] installation directory; e.g. commands like [**`clang.exe`**][llvm_clang], [**`lld.exe`**][llvm_lld]  and [**`lldb.exe`**][llvm_lldb] belong to the orginal distribution while commands like [**`llc.exe`**][llvm_llc], [**`lli.exe`**][llvm_lli] and [**`opt.exe`**][llvm_opt] were build/added from the [LLVM] source distribution.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /t clang llc lld lldb lli opt</b>
 105695744   27.06.2022      10:46:14  C:\opt\LLVM-14.0.6\bin\clang.exe
  24143872   14.08.2022      01:34:48  C:\opt\LLVM-14.0.6\bin\llc.exe
  77358592   27.06.2022      10:48:04  C:\opt\LLVM-14.0.6\bin\lld.exe
    212480   27.06.2022      10:50:04  C:\opt\LLVM-14.0.6\bin\lldb.exe
  22501376   14.08.2022      01:35:01  C:\opt\LLVM-14.0.6\bin\lli.exe
  30115840   14.08.2022      01:43:52  C:\opt\LLVM-14.0.6\bin\opt.exe
</pre>

## <span id="footnotes">Footnotes</span>[**&#x25B4;**](#top)

<a name="footnote_01">[1]</a> ***CmakeLists.txt*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
We need to comment out the lines marked with <span style="color:green;"><code>#ME#</code></span> in file <code>CMakeLists.txt</code> in order to build a LLVM distribution in our Windows environment :
<pre style="font-size:80%;">
<b>if</b> (LLVM_INCLUDE_BENCHMARKS)
  ...
  <span style="color:green;"># Since LLVM requires C++11 it is safe to assume that std::regex is available.</span>
  <b>set</b>(HAVE_STD_REGEX ON CACHE BOOL "OK" FORCE)
  <span style="color:green;">#ME# add_subdirectory(${LLVM_THIRD_PARTY_DIR}/benchmark </span>
  <span style="color:green;">#ME#   ${CMAKE_CURRENT_BINARY_DIR}/third-party/benchmark)</span>
  <span style="color:green;">#ME# add_subdirectory(benchmarks)</span>
<b>endif()</b>
</pre>
</p>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/November 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[batch_file]: https://en.wikibooks.org/wiki/Windows_Batch_Scripting
[llvm]: https://llvm.org/
[llvm_as]: https://llvm.org/docs/CommandGuide/llvm-as.html
[llvm_clang]: https://releases.llvm.org/14.0.0/tools/clang/docs/ClangCommandLineReference.html
[llvm_dis]: https://llvm.org/docs/CommandGuide/llvm-dis.html
[llvm_downloads]: https://github.com/llvm/llvm-project/releases/tag/llvmorg-14.0.6
[llvm_llc]: https://llvm.org/docs/CommandGuide/llc.html
[llvm_lld]: https://lld.llvm.org/
[llvm_lldb]: https://lldb.llvm.org/
[llvm_lli]: https://llvm.org/docs/CommandGuide/lli.html
[llvm_opt]: https://llvm.org/docs/CommandGuide/opt.html
[llvm_tools]: https://llvm.org/docs/CommandGuide/
[mx_cli]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/oracle/graal
[travis_yml]: https://github.com/oracle/graal/blob/master/.travis.yml
