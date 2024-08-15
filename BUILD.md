# <span id="top">Building LLVM on Windows</span> <span style="font-size:90%;">[↩](README.md#top)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/" rel="external"><img src="docs/images/llvm.png" width="120" alt="LLVM project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document presents our build from the <a href="https://llvm.org/" rel="external">LLVM</a> source distribution on a Windows machine.
  </td>
  </tr>
</table>

## <span id="build">`build.bat`</span>

Command [**`build.bat`**](bin/llvm/build.bat) consists of ~350 lines of batch/PowerShell code we wrote to generate additional Windows binaries not available in the <a href="https://llvm.org/" rel="external">LLVM</a> binary distribution.

> **:mag_right:** For instance, [LLVM tools][llvm_tools] such as [**`llvm-as.exe`**][llvm_as] (assembler), [**`llvm-dis.exe`**][llvm_dis] (disassembler), [**`opt.exe`**][llvm_opt] (optimizer), [**`llc.exe`**][llvm_llc] (static compiler) and [**`lli.exe`**][llvm_lli] (bitcode interpreter) are not part of the [LLVM] binary distribution (e.g. [`LLVM-15.0.7-win64.exe`][llvm_downloads]).


## <span id="usage_examples">Usage examples</span>

Directory **`llvm-15.0.7.src\`** <sup id="anchor_01">[1](#footnote_01)</sup> is setup as follows:
<pre style="font-size:80%;">
<b>&gt; <a href="https://curl.haxx.se/docs/manpage.html">curl</a> -sL -o llvm-15.0.7.src.tar.xz https://github.com/llvm/llvm-project/releases/tag/llvmorg-15.0.7/<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-15.0.7">llvm-15.0.7.src.tar.xz</a></b>
<b>&gt; <a href="http://linuxcommand.org/lc3_man_pages/tar1.html">tar</a> xzvf llvm-15.0.7.src.tar.xz</b>
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/cp.1.html">cp</cp> <a href="bin/llvm/build.bat">bin\llvm\build.bat</a> llvm-15.0.7.src</b>
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a> llvm-15.0.7.src</b>
</pre>

> **:mag_right:** In our case we successively worked with versions `8.0.1`, `9.0.1`, `10.0.1`, `11.0.1`, `11.1.0`, `12.0.1`, `13.0.1`, `14.0.6`, `15.0.6` of the [LLVM] source distribution and today we build our binaries from directory `L:\llvm-15.0.7.src\`.

Command [**`build.bat -verbose compile`**](bin/llvm/build.bat) <sup id="anchor_02">[2](#footnote_02)</sup> generates the additional binaries (both **`.exe`** and **`.lib`** files) into directory **`build\Release\`** (resp. **`build\Debug\`**). Be patient, build time is about 55 minutes on an Intel i7-4th with 16 GB of memory.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
L:\llvm-15.0.7.src
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
[build] Current directory is: L:\llvm-15.0.7.src\build
[...]
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> build\Release\bin\ll?.exe | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /b [0-9]</b>
07.12.2022  08:07        72 299 520 llc.exe
07.12.2022  08:08        23 104 512 lli.exe
</pre>

> **:mag_right:** Command [**`build -verbose run`**](bin/llvm/build.bat) also execute **`lli.exe -version`** at the end of the build process :
> <pre style="font-size:80%;">
> [...]
> Generate LLVM executables (LLVM.sln)
> Execute build\Release\bin\lli.exe --version
> LLVM (http://llvm.org/):
>   LLVM version 15.0.7
>   Optimized build.
>   Default target: x86_64-pc-windows-msvc
>   Host CPU: haswell
</pre>

Command [**`build.bat -verbose install`**](bin/llvm/build.bat) copies the generated binaries to the [LLVM] installation directory (in our case **`C:\opt\LLVM-15.0.7\`**).

<pre style="font-size:80%;">
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose install</b>
Do really want to copy files from 'build\' to 'c:\opt\LLVM-15.0.7\' (Y/N)? y
Copy files from directory build\Release\bin to C:\opt\LLVM-15.0.7\bin\
Copy files from directory build\Release\lib to C:\opt\LLVM-15.0.7\lib\
Copy files from directory build\lib\cmake to C:\opt\LLVM-15.0.7\lib\cmake\
Copy files from directory include to C:\opt\LLVM-15.0.7\include\
</pre>

> **:mag_right:** Before installation our [LLVM] installation directory contains 18 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-15.0.7 llvm*.exe | <a href="https://man7.org/linux/man-pages/man1/wc.1.html">wc</a> -l</b>
> 18
> </pre>
> and after installation it contains 78 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-15.0.7 llvm*.exe | <a href="https://man7.org/linux/man-pages/man1/wc.1.html">wc</a> -l</b>
> 78
> </pre>

We list below several executables in the [LLVM] installation directory; e.g. commands like [**`clang.exe`**][llvm_clang], [**`lld.exe`**][llvm_lld]  and [**`lldb.exe`**][llvm_lldb] belong to the orginal distribution while commands like [**`llc.exe`**][llvm_llc], [**`lli.exe`**][llvm_lli] and [**`opt.exe`**][llvm_opt] were build/added from the [LLVM] source distribution.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /t clang llc lld lldb lli opt</b>
 111801856   30.11.2022      10:46:14  C:\opt\LLVM-15.0.7\bin\clang.exe
  72299520   07.12.2022      01:34:48  C:\opt\LLVM-15.0.7\bin\llc.exe
  82472960   30.11.2022      10:48:04  C:\opt\LLVM-15.0.7\bin\lld.exe
    215552   30.11.2022      10:50:04  C:\opt\LLVM-15.0.7\bin\lldb.exe
  23104512   07.12.2022      01:35:01  C:\opt\LLVM-15.0.7\bin\lli.exe
  77778432   07.12.2022      01:43:52  C:\opt\LLVM-15.0.7\bin\opt.exe
</pre>

## <span id="footnotes">Footnotes</span> [**&#x25B4;**](#top)

<a name="footnote_01">[1]</a> ***Cmake modules*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
In order to successfully generate the LLVM distribution from the sources we need to copy some missing CMake files to directory <code>L:\llvm-X.Y.Z.src\cmake\modules\</code>:
<table>
<tr><th>LLVM version</th><th>CMake files</th></tr>
<tr><td><a href="https://github.com/llvm/llvm-project/tree/release/15.x/cmake/Modules">15</a></td><td><a href="https://github.com/llvm/llvm-project/blob/release/15.x/cmake/Modules/ExtendPath.cmake" rel="external"><code>ExtendPath.cmake</code></a><br/><a href="https://github.com/llvm/llvm-project/blob/release/15.x/cmake/Modules/FindPrefixFromConfig.cmake" rel="external"><code>FindPrefixFromConfig.cmake</code></a></td></tr>
<tr><td><a href="https://github.com/llvm/llvm-project/tree/release/16.x/cmake/Modules">16</a></td><td><a href="https://github.com/llvm/llvm-project/blob/release/16.x/cmake/Modules/CMakePolicy.cmake" rel="external"><code>CMakePolicy.cmake</code></a><br/><a href="https://github.com/llvm/llvm-project/blob/release/16.x/cmake/Modules/ExtendPath.cmake" rel="external"><code>ExtendPath.cmake</code></a><br/><a href="https://github.com/llvm/llvm-project/blob/release/16.x/cmake/Modules/FindPrefixFromConfig.cmake" rel="external"><code>FindPrefixFromConfig.cmake</code></a><br/><a href="https://raw.githubusercontent.com/llvm/llvm-project/release/16.x/cmake/Modules/GNUInstallPackageDir.cmake"><code>GNUInstallPackageDir.cmake</code></a></td></tr>
</table>
</p>

<a name="footnote_02">[2]</a> ***CmakeLists.txt*** [↩](#anchor_02)

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

*[mics](https://lampwww.epfl.ch/~michelou/)/August 2024* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[batch_file]: https://en.wikibooks.org/wiki/Windows_Batch_Scripting
[llvm]: https://llvm.org/
[llvm_as]: https://llvm.org/docs/CommandGuide/llvm-as.html
[llvm_clang]: https://releases.llvm.org/14.0.0/tools/clang/docs/ClangCommandLineReference.html
[llvm_dis]: https://llvm.org/docs/CommandGuide/llvm-dis.html
[llvm_downloads]: https://github.com/llvm/llvm-project/releases/tag/llvmorg-15.0.7
[llvm_llc]: https://llvm.org/docs/CommandGuide/llc.html
[llvm_lld]: https://lld.llvm.org/
[llvm_lldb]: https://lldb.llvm.org/
[llvm_lli]: https://llvm.org/docs/CommandGuide/lli.html
[llvm_opt]: https://llvm.org/docs/CommandGuide/opt.html
[llvm_tools]: https://llvm.org/docs/CommandGuide/
[mx_cli]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/oracle/graal
[travis_yml]: https://github.com/oracle/graal/blob/master/.travis.yml
