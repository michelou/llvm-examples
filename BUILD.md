# <span id="top">Building LLVM on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/" rel="external"><img src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" width="120" alt="LLVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document presents our build from the <a href="https://llvm.org/" rel="external">LLVM</a> source distribution on a Windows machine.
  </td>
  </tr>
</table>

## `build.bat` command

[**`build.bat`**](bin/llvm/build.bat) consists of ~350 lines of batch/PowerShell code we wrote to generate additional Windows binaries not available in the <a href="https://llvm.org/">LLVM</a> binary distribution.

> **:mag_right:** For instance, [LLVM tools][llvm_tools] such as [**`llvm-as.exe`**][llvm_as] (assembler), [**`llvm-dis.exe`**][llvm_dis] (disassembler), [**`opt.exe`**][llvm_opt] (optimizer), [**`llc.exe`**][llvm_llc] (static compiler) and [**`lli.exe`**][llvm_lli] (bitcode interpreter) are not part of the [LLVM] binary distribution (e.g. [`LLVM-11.0.0-win64.exe`][llvm_downloads]).


## <span id="usage_examples">Usage examples</span>

Directory **`llvm-11.0.0.src\`** is setup as follows:
<pre style="font-size:80%;">
<b>&gt; <a href="https://curl.haxx.se/docs/manpage.html">curl</a> -sL -o llvm-11.0.0.src.tar.xz <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.0.0">llvm-11.0.0.src.tar.xz</a></b>
<b>&gt; <a href="http://linuxcommand.org/lc3_man_pages/tar1.html">tar</a> xzvf llvm-11.0.0.src.tar.xz</b>
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/cp.1.html">cp</cp> <a href="bin/llvm/build.bat">bin\llvm\build.bat</a> llvm-11.0.0.src</b>
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a> llvm-11.0.0.src</b>
</pre>

> **:mag_right:** In our case we have the choice between the source directories `llvm-8.0.1.src\`, `llvm-9.0.1.src\`, `llvm-10.0.1.src\` and `llvm-11.0.0.src\`.

Command [**`build.bat -verbose compile`**](bin/llvm/build.bat) generates the additional binaries (both **`.exe`** and **`.lib`** files) into directory **`build\Release\`** (resp. **`build\Debug\`**). Be patient, build time is about 55 minutes on an Intel i7-4th with 16 GB of memory.

<pre style="font-size:80%;">
<b>&gt; cd</b>
L:\llvm-11.0.0.src
&nbsp;
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose compile</b>
Toolset: MSVC/MSBuild, Project: LLVM
**********************************************************************
** Visual Studio 2019 Developer Command Prompt v16.5.1
** Copyright (c) 2019 Microsoft Corporation
**********************************************************************
[vcvarsall.bat] Environment initialized for: 'x64'
INCLUDE="..."
LIB="..."
Configuration: Debug, Platform: x64
[build] Current directory is: L:\llvm-11.0.0.src\build
[...]
</pre>

Running command [**`build.bat -verbose install`**](bin/llvm/build.bat) copies the generated binaries to the [LLVM] installation directory (in our case **`C:\opt\LLVM-11.0.0\`**).

<pre style="font-size:80%;">
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose install</b>
Do really want to copy files from 'build\' to 'c:\opt\LLVM-11.0.0\' (Y/N)? y
Copy files from directory build\Release\bin to C:\opt\LLVM-11.0.0\bin\
Copy files from directory build\Release\lib to C:\opt\LLVM-11.0.0\lib\
Copy files from directory build\lib\cmake to C:\opt\LLVM-11.0.0\lib\cmake\
Copy files from directory include to C:\opt\LLVM-11.0.0\include\
</pre>

> **:mag_right:** Before installation our [LLVM] installation directory contains 14 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-11.0.0 llvm*.exe | wc -l</b>
> 14
> </pre>
> and after installation it contains 61 `llvm-*.exe` executables:
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\LLVM-11.0.0 llvm*.exe | wc -l</b>
> 63
> </pre>

We list below several executables in the [LLVM] installation directory; e.g. commands like [**`clang.exe`**][llvm_clang], [**`lld.exe`**][llvm_lld]  and [**`lldb.exe`**][llvm_lldb] belong to the orginal distribution while commands like [**`llc.exe`**][llvm_llc], [**`lli.exe`**][llvm_lli] and [**`opt.exe`**][llvm_opt] were build/added from the [LLVM] source distribution.

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /t clang llc lld lldb lli opt</b>
  91283968   12.10.2020      16:11:36  C:\opt\LLVM-11.0.0\bin\clang.exe
  52822528   24.10.2020      00:11:01  C:\opt\LLVM-11.0.0\bin\llc.exe
  63271424   12.10.2020      16:13:32  C:\opt\LLVM-11.0.0\bin\lld.exe
    226816   12.10.2020      16:15:06  C:\opt\LLVM-11.0.0\bin\lldb.exe
  19791872   24.10.2020      00:11:15  C:\opt\LLVM-11.0.0\bin\lli.exe
  57272320   24.10.2020      00:17:52  C:\opt\LLVM-11.0.0\bin\opt.exe
</pre>

<!--
## <span id="troubleshooting">Troubleshooting</span>

No issue so far.


## <span id="footnotes">Footnotes</span>

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
</p>
-->

***

*[mics](https://lampwww.epfl.ch/~michelou/)/October 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[batch_file]: https://en.wikibooks.org/wiki/Windows_Batch_Scripting
[llvm]: https://llvm.org/
[llvm_as]: https://llvm.org/docs/CommandGuide/llvm-as.html
[llvm_clang]: https://releases.llvm.org/11.0.0/tools/clang/docs/ClangCommandLineReference.html
[llvm_dis]: https://llvm.org/docs/CommandGuide/llvm-dis.html
[llvm_downloads]: https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.0.0
[llvm_llc]: https://llvm.org/docs/CommandGuide/llc.html
[llvm_lld]: https://lld.llvm.org/
[llvm_lldb]: https://lldb.llvm.org/
[llvm_lli]: https://llvm.org/docs/CommandGuide/lli.html
[llvm_opt]: https://llvm.org/docs/CommandGuide/opt.html
[llvm_tools]: https://llvm.org/docs/CommandGuide/
[mx_cli]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/oracle/graal
[travis_yml]: https://github.com/oracle/graal/blob/master/.travis.yml
