# <span id="top">LLVM on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/" rel="external"><img src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" width="120" alt="LLVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://llvm.org/" rel="external">LLVM</a> code examples coming from various websites and books.<br/>
  It also includes several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a> for experimenting with the <a href="https://llvm.org/" rel="external">LLVM</a> infrastructure on a Windows machine.
  </td>
  </tr>
</table>

[GraalVM][graalvm_examples], [Haskell][haskell_examples], [Kotlin][kotlin_examples], [Node.js][nodejs_examples], [Scala 3][scala3_examples] and [TruffleSqueak][trufflesqueak_examples] are other trending topics we are currently monitoring.

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** plaform:

- [CMake 3.21][cmake_downloads] ([*release notes*][cmake_relnotes])
- [LLVM 12 Windows binaries][llvm_downloads] <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup> ([*release notes*][llvm_relnotes])
- [Microsoft Visual Studio Community 2019][vs2019_downloads] <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>  ([*release notes*][vs2019_relnotes])
- [Python 3.9][python_downloads] ([*changelog*][python_changelog])

Optionally one may also install the following software:

- [Cppcheck 2.5][cppcheck_downloads] <sup id="anchor_03"><a href="#footnote_03">[3]</a></sup> ([*changelog*][cppcheck_changelog])
- [Doxygen 1.9][doxygen_downloads] ([*changelog*][doxygen_changelog])
- [Git 2.33][git_downloads] ([*release notes*][git_relnotes])
- [MSYS2][msys2_downloads] <sup id="anchor_04"><a href="#footnote_04">[4]</a></sup>

<!--
> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).
-->

For instance our development environment looks as follows (*August 2021*) <sup id="anchor_05"><a href="#footnote_05">[5]</a></sup>:

<pre style="font-size:80%;max-width:560px;">
C:\opt\cmake-3.21.1-windows-x86_64\                             <i>(  88 MB)</i>
C:\opt\doxygen-1.9.1\                                           <i>(  81 MB)</i>
C:\opt\Git-2.32.0\                                              <i>( 279 MB)</i>
C:\opt\LLVM-8.0.1\                                              <i>(1.1  GB)</i>
C:\opt\LLVM-9.0.1\                                              <i>(1.3  GB)</i>
C:\opt\LLVM-10.0.1\                                             <i>(1.5 resp 2.6 GB)</i>
C:\opt\LLVM-11.1.0\                                             <i>(1.5 resp 3.0 GB)</i>
C:\opt\LLVM-12.0.1\                                             <i>(1.5 resp 3.7 GB)</i>
C:\opt\msys64\                                                  <i>(2.85 GB)</i>
C:\Program Files\Cppcheck\                                      <i>(  48 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\  <i>(2.98 GB)</i>
C:\opt\Python-3.9.6\                                            <i>( 201 MB)</i>
</pre>

<!--
https://devblogs.microsoft.com/cppblog/cmake-3-14-and-performance-improvements/
-->

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][linux_opt] directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;max-width:500px;">
bin\pelook.exe  <i>(<a href="http://bytepointer.com/tools/pelook_changelist.htm">changelist</a>)</i>
bin\vswhere.exe
<a href="bin/llvm/build.bat">bin\llvm\build.bat</a>
docs\
examples\{hello, JITTutorial1, ..}
llvm-8.0.1.src\     <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">llvm-8.0.1.src.tar.xz</a>)</i>
llvm-9.0.1.src\     <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-9.0.1">llvm-9.0.1.src.tar.xz</a>)</i>
llvm-10.0.1.src\    <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-10.0.1">llvm-10.0.1.src.tar.xz</a>)</i>
llvm-11.1.0.src\    <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.1.0">llvm-11.1.0.src.tar.xz</a>)</i>
llvm-12.0.1.src\    <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.1">llvm-12.0.1.src.tar.xz</a>)</i>
<a href="BUILD.md">BUILD.md</a>
README.md
<a href="BUILD.md">RESOURCES.md</a>
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- directory [**`bin\`**](bin/) contains a batch file and the tools [**`vswhere`**][vswhere_exe] and [**`pelook`**][pelook_exe].
- directory [**`docs\`**](docs/) contains several [LLVM] related papers/articles.
- directory [**`examples\`**](examples/) contains [LLVM] code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`llvm-8.0.1.src\`** contains the [LLVM] 8 source code distribution.
- directory **`llvm-9.0.1.src\`** contains the [LLVM] 9 source code distribution.
- directory **`llvm-10.0.1.src\`** contains the [LLVM] 10 source code distribution.
- directory **`llvm-11.1.0.src\`** contains the [LLVM] 11 source code distribution.
- directory **`llvm-12.0.1.src\`** contains the [LLVM] 12 source code distribution.
- file [**`BUILD.md`**](BUILD.md) describes the build from the source distribution.
- file [**`README.md`**](README.md) is the Markdown document for this page.
- file [**`RESOURCES.md`**](RESOURCES.md) is the [Markdown][github_markdown] document presenting external resources.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`L:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst">subst</a> L: %USERPROFILE%\workspace\llvm-examples</b>
> </pre>

In the next section we give a brief description of the [batch files][batch_file] present in this project.

## <span id="commands">Batch commands</span>

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`clang.exe`**][llvm_clang] and [**`git.exe`**][git_exe] directly available from the command prompt (see section [**Project dependencies**](#proj_deps)).

   <pre style="font-size:80%;max-width:484px;">
   <b>&gt; <a href="setenv.bat">setenv</a> help</b>
   Usage: setenv { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options::
       -bash          start Git bash shell instead of Windows command prompt
       -debug         show commands executed by this script
       -llvm:&lt;8..12&gt;  select version of LLVM installation
       -verbose       display progress messages
   &nbsp;
     Subcommands:
       help           display this help message</pre>

2. [**`bin\llvm\build.bat`**](bin/llvm/build.bat) - This batch command generates/installs additional files such as executables, header files, library files, [CMake modules][cmake_modules] not available in [LLVM] installation directory (in our case **`C:\opt\LLVM-12.0.1\`**).

   <pre style="font-size:80%;max-width:484px;">
   <b>&gt; <a href="bin/llvm/build.bat">build</a> help</b>
   Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options
       -debug      show commands executed by this script
       -timer      print total elapsed time
       -verbose    display progress messages
   &nbsp;
     Subcommands:
       clean       delete generated files
       compile     generate executable
       help        display this help message
       install     install files generated in directory build
       run         run executable</pre>


## <span id="usage">Usage examples</span>

### **`setenv.bat`**

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`clang.exe`**][llvm_clang], [**`opt.exe`**][llvm_opt] and [**`git.exe`**][git_exe] directly available from the command prompt:

<pre style="font-size:80%;max-width:520px;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   clang 12.0.1, lli 12.0.1, opt 12.0.1, doxygen 1.9.1, pelook v1.73,
   cmake 3.21.0, cppcheck 2.5, make 4.3, gcc 10.2.0, python 3.9.6, diff 3.7
   git 2.32.0.windows.1, bash 4.4.23(1)-release

<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> clang git</b>
C:\opt\LLVM-12.0.1\bin\clang.exe
C:\opt\Git-2.32.0\bin\git.exe
C:\opt\Git-2.32.0\mingw64\bin\git.exe
</pre>

> **&#9755;** ***Important note***<br/>
> Command [**`setenv`**](setenv.bat) does not add [MSVS CMake][windows_cmake] and [GNU Cmake][gnu_cmake] to the **`PATH`** environment variable because of name conflict. We write either **`%MSVS_CMAKE_HOME%\bin\cmake.exe`** or **`%CMAKE_HOME%\bin\cmake.exe`**. 

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -verbose</b>
Tool versions:
   clang 12.0.1, lli 12.0.1, opt 12.0.1, doxygen 1.9.1, pelook v1.73,
   cmake 3.21.0, cppcheck 2.5, make 4.3, gcc 10.2.0, python 3.9.6, diff 3.7
   git 2.32.0.windows.1, bash 4.4.23(1)-release, vswhere 2.7.1+180c706d56
Tool paths:
   C:\opt\LLVM-12.0.1\bin\clang.exe
   C:\opt\LLVM-12.0.1\bin\lli.exe
   C:\opt\LLVM-12.0.1\bin\opt.exe
   C:\opt\cmake-3.21.0\bin\cmake.exe
   C:\opt\msys64\usr\bin\make.exe
   C:\opt\msys64\mingw64\bin\gcc.exe
   C:\opt\Python-3.9.6\python.exe
   C:\opt\msys64\usr\bin\python.exe
   C:\opt\msys64\mingw64\bin\python.exe
   C:\opt\msys64\usr\bin\diff.exe
   C:\opt\Git-2.32.0\usr\bin\diff.exe
   C:\opt\Git-2.32.0\bin\git.exe
   C:\opt\Git-2.32.0\mingw64\bin\git.exe
   C:\opt\Git-2.32.0\bin\bash.exe
Environment variables:
   "CMAKE_HOME=C:\opt\cmake-3.21.1-win64-x64"
   "CPPCHECK_HOME=C:\Program Files\Cppcheck"
   "DOXYGEN_HOME=C:\opt\doxygen-1.9.1"
   "LLVM_HOME=C:\opt\LLVM-12.0.1"
   "MSVC_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC"
   "MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2019"
   "MSVS_CMAKE_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\..\Cmake"
   "MSYS_HOME=C:\opt\msys64"
   "PYTHON_HOME=C:\opt\Python-3.9.6"
</pre>

### **`llvm-X.Y.Z.src\build.bat`**

We wrote the [batch file][batch_file] [**`build.bat`**](bin/llvm/build.bat) to generate additional Windows binaries not available in the <a href="https://llvm.org/">LLVM</a> binary distribution. 

> **:mag_right:** For instance, [LLVM tools][llvm_tools] such as [**`llvm-as.exe`**][llvm_as] (assembler), [**`llvm-dis.exe`**][llvm_dis] (disassembler), [**`opt.exe`**][llvm_opt] (optimizer), [**`llc.exe`**][llvm_llc] (static compiler) and [**`lli.exe`**][llvm_lli] (bitcode interpreter) are not part of the [LLVM] binary distribution (e.g. [`LLVM-12.0.1-win64.exe`][llvm_downloads]).

It provides the following options and subcommands:

<pre style="font-size:80%;max-width:500px;">
<b>&gt; <a href="bin/llvm/build.bat">build</a></b>
Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
&nbsp;
  Options:
    -debug      show commands executed by this script
    -timer      print total elapsed time
    -verbose    display progress messages
&nbsp;
  Subcommands:
    clean       delete generated files
    compile     generate executable
    help        display this help message
    install     install files generated in directory build
    run         run the generated executable
</pre>

See document [`BUILD.md`](BUILD.md) for more details.

### **`examples\JITTutorial1\build.bat`**

See document [**`examples\README.md`**](examples/README.md).

## <span id="resources">Resources</span>

See document [**`RESOURCES.md`**](RESOURCES.md) for [LLVM] related resources.


## <span id="footnotes">Footnotes</span>

<span name="footnote_01">[1]</span> ***LLVM version*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
We support LLVM versions 8, 9, 10, 11 and 12. Command <b><code>setenv</code></b> searches for version 11 per default; use command <b><code>setenv -llvm:8</code></b> to work with LLVM 8 (and so on).
</p>

<span name="footnote_02">[2]</span> ***Visual Studio version*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
Version 16.5 of Visual Studio 2019 is required to build LLVM 10 while version 16.4 is fine to build LLVM 8 and 9.
</p>

<pre style="margin:0 0 0 20px;font-size:80%;max-width:520px;">
<b>&gt; <a href="bin/llvm/build.bat">build</a> -verbose compile</b>
Toolset: MSVC/MSBuild, Project: LLVM
**********************************************************************
** Visual Studio 2019 Developer Command Prompt v16.4.0
** Copyright (c) 2019 Microsoft Corporation
**********************************************************************
[vcvarsall.bat] Environment initialized for: 'x64'
[...]
Configuration: Debug, Platform: x64
Generate configuration files into directory "build"
CMake Error at cmake/modules/CheckCompilerVersion.cmake:62 (message):
  Host Visual Studio version 16.4 is known to miscompile part of LLVM, please
  use clang-cl or upgrade to 16.5 or above (use
  -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON to ignore)
Call Stack (most recent call first):
  cmake/config-ix.cmake:13 (include)
  CMakeLists.txt:623 (include)

Error: Generation of build configuration failed
</pre>

<span name="footnote_03">[3]</span> ***Cppcheck installation*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
The <a href="http://cppcheck.sourceforge.net/">Cppcheck</a> static analysis tool can be installed in two ways on MS Windows, namely:<p>
<ul>
<li>MS Windows installer <a href="http://cppcheck.sourceforge.net/#download"><code>cppcheck-2.5-x64-Setup.msi</code></a> from the Windows desktop.
<li>MSYS2 package <a href="https://packages.msys2.org/package/mingw-w64-x86_64-cppcheck?repo=mingw64"><code>mingw-w64-x86_64-cppcheck</code></a>.</li>
</ul>
<p style="margin:0 0 1em 20px;">
Below we execute the command <code>pacman -S <a href="https://packages.msys2.org/package/mingw-w64-x86_64-cppcheck?repo=mingw64">mingw-w64-x86_64-cppcheck</a></code> and then check the <code>cppcheck</code> installation :
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<b>$ <a href="https://www.archlinux.org/pacman/pacman.8.html">pacman</a> -S <a href="https://packages.msys2.org/package/mingw-w64-x86_64-cppcheck?repo=mingw64">mingw-w64-x86_64-cppcheck</a></b>
resolving dependencies...
looking for conflicting packages...

Packages (1) mingw-w64-x86_64-cppcheck-2.3-1

Total Download Size:    3.43 MiB
Total Installed Size:  13.39 MiB

:: Proceed with installation? [Y/n] y
:: Retrieving packages...
 mingw-w64-x86_64-cppcheck-2.3-1-any    3.4 MiB   255 KiB/s 00:14 [#############################] 100%
(1/1) checking keys in keyring                                    [#############################] 100%
(1/1) checking package integrity                                  [#############################] 100%
(1/1) loading package files                                       [#############################] 100%
(1/1) checking for file conflicts                                 [#############################] 100%
(1/1) checking available disk space                               [#############################] 100%
:: Processing package changes...
(1/1) installing mingw-w64-x86_64-cppcheck                        [#############################] 100%
Optional dependencies for mingw-w64-x86_64-cppcheck
    mingw-w64-x86_64-qt5: cppcheck-gui
    mingw-w64-x86_64-python-pygments: cppcheck-htmlreport
&nbsp;
<b>$ <a href="https://linux.die.net/man/1/which">which</a> cppcheck</b>
/mingw64/bin/cppcheck
&nbsp;
<b>$ <a href="https://linux.die.net/man/1/cppcheck">cppcheck</a> --version</b>
Cppcheck 2.3
</pre>

<span name="footnote_04">[4]</span> ***MSYS2 versus MinGW*** [↩](#anchor_04)

<p style="margin:0 0 1em 20px;">
We give here three differences between <a href="http://repo.msys2.org/distrib/x86_64/" alt="MSYS2">MSYS64</a> and <a href="https://sourceforge.net/projects/mingw/" rel="external">MingGW-w64</a>:
</p>
<table style="margin:0 0 1em 20px;">
<tr><th>Criteria</th><th>MSYS64</th><th>MingGW-w64</th></tr>
<tr><td>Installation size</td><td>4.74 GB</td><td>614 MB</td></tr>
<tr><td>Version/architecture</td><td><code>gcc 10.3</code></td><td><code>gcc 8.1</code></td></tr>
<tr><td>Update tool</td><td><a href="https://wiki.archlinux.org/index.php/Pacman"><code>pacman -Syu</code></a> <sup>(1)</sup></td><td><a href="https://osdn.net/projects/mingw/releases/68260"><code>mingw-get upgrade</code></a> <sup>(2)</sup></td></tr>
</table>
<p style="margin:-16px 0 1em 30px; font-size:80%;">
<sup>(1)</sup> <a href="https://github.com/msys2/MSYS2-packages/issues/1298"><code>pacman -Syu</code> does nothing</a><br/>
<sup>(2)</sup> <a href="https://www.sqlpac.com/referentiel/docs/mingw-minimalist-gnu-pour-windows.html" rel="external">Minimalist GNU for Windows</a>
</p>

<p style="margin:0 0 1em 20px;">
1. MSYS64 tools:
</p>
<pre style="margin:0 0 1em 35px; font-size:80%;max-width:484px;">
<b>&gt; c:\opt\msys64\usr\bin\<a href="https://www.archlinux.org/pacman/pacman.8.html">pacman.exe</a> -Syu</b>
:: Synchronizing package databases...
[...]
:: Running post-transaction hooks...
(1/3) Compiling GSettings XML schema files...
(2/3) Updating icon theme caches...
(3/3) Updating the info directory file...
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r c:\opt\msys64 gcc.exe make.exe pacman.exe</b>
c:\opt\msys64\mingw64\bin\gcc.exe
c:\opt\msys64\usr\bin\make.exe
c:\opt\msys64\usr\bin\pacman.exe
&nbsp;
<b>&gt; c:\opt\msys64\mingw64\bin\<a href="https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html">gcc.exe</a> --version | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> gcc</b>
gcc (Rev3, Built by MSYS2 project) 10.3.0
&nbsp;
<b>&gt; c:\opt\msys64\usr\bin\<a href="https://www.gnu.org/software/make/manual/make.html">make.exe</a> --version | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> Make</b>
GNU Make 4.3
</pre>

> **&#9755;** ***Key "XXX" is unknown***<br/>
> One may encounter the MSYS error '<code>key "XXX" is unkown</code>' when running **`pacman -Syu`** from the Windows prompt. Simply run the command once from the MingW64 shell (command **`%MSYS_HOME%\mingw64.exe`**) to solve the issue.

<pre style="margin:0 0 1em 35px; font-size:80%;max-width:620px;">
<b>&gt; c:\opt\msys64\usr\bin\<a href="https://www.archlinux.org/pacman/pacman.8.html">pacman.exe</a> -Syu</b>
error: msys: key "4A6129F4E4B84AE46ED7F635628F528CF3053E04" is unknown
:: Import PGP key 4A6129F4E4B84AE46ED7F635628F528CF3053E04? [Y/n] y
    error: key "4A6129F4E4B84AE46ED7F635628F528CF3053E04" could not be looked up remotely
:: Synchronizing package databases...
 mingw32                607.7 KiB  39.0 KiB/s 00:16   [###############################] 100%
 mingw32.sig            438.0   B  0.00   B/s 00:00   [###############################] 100%
 error: mingw32: key "4A6129F4E4B84AE46ED7F635628F528CF3053E04" is unknown
:: Import PGP key 4A6129F4E4B84AE46ED7F635628F528CF3053E04? [Y/n] y
    error: key "4A6129F4E4B84AE46ED7F635628F528CF3053E04" could not be looked up remotely
[..]
</pre>

<p style="margin:0 0 1em 20px;">
2. MinGW-w64 tools:
</p>
<pre style="margin:0 0 1em 35px; font-size:80%;max-width:484px;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r . gcc mingw-get mingw32-make</b>
c:\opt\mingw-w64\mingw64\bin\gcc.exe
c:\opt\mingw-w64\mingw64\bin\mingw-get.exe
c:\opt\mingw-w64\mingw64\bin\mingw32-make.exe
&nbsp;
<b>&gt; <a href="https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html">gcc</a> --version | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> gcc</b>
gcc (x86_64-posix-seh-rev0, Built by MinGW-W64 project) 8.1.0
&nbsp;
<b>&gt; <a href="http://www.gnu.org/software/make/manual/">mingw32-make</a> --version | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> Make</b>
GNU Make 4.2.1
</pre>

<span name="footnote_05">[5]</span> ***Downloads*** [↩](#anchor_05)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;max-width:500px;">
<a href="https://cmake.org/download/">cmake-3.21.1-win64-x64.zip</a>        <i>( 35 MB)</i>
<a href="http://cppcheck.sourceforge.net/">cppcheck-2.5-x64-Setup.msi</a>        <i>( 20 MB)</i>
<a href="https://www.doxygen.nl/download.html">doxygen-1.9.1.windows.x64.bin.zip</a> <i>( 22 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.32.0-64-bit.7z.exe</a>  <i>( 41 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">LLVM-8.0.1-win64.exe</a>              <i>(131 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-10.0.0">LLVM-10.0.0-win64.exe</a>             <i>(150 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.1.0">LLVM-11.1.0-win64.exe</a>             <i>(172 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.1">LLVM-12.0.1-win64.exe</a>             <i>(182 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">llvm-8.0.1.src.tar.xz</a>             <i>( 29 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-10.0.1">llvm-10.0.1.src.tar.xz</a>            <i>( 31 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.1.0">llvm-11.1.0.src.tar.xz</a>            <i>( 37 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.1">llvm-12.0.1.src.tar.xz</a>            <i>( 41 MB)</i>
<a href="http://repo.msys2.org/distrib/x86_64/">msys2-x86_64-20190524.exe</a>         <i>( 86 MB)</i>
<a href="https://www.python.org/downloads/windows/">python-3.9.6-amd64.exe</a>            <i>( 27 MB)</i>
vs_2019_community.exe             <i>(1.7 GB)</i>
</pre>
<p style="margin:0 0 1em 20px;">
Microsoft doesn't provide an offline installer for <a href="https://visualstudio.microsoft.com/vs/2019/">VS 2019</a> but we can follow the <a href="https://docs.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2019">following instructions</a> to create a local installer (so called <i>layout cache</i>) for later (re-)installation.
</p>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/August 2021* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[batch_file]: https://en.wikibooks.org/wiki/Windows_Batch_Scripting
[gnu_cmake]: https://cmake.org/
[cppcheck_changelog]: https://sourceforge.net/p/cppcheck/news/
[cppcheck_downloads]: http://cppcheck.sourceforge.net/#download
[cmake_downloads]: https://cmake.org/download/
[cmake_modules]: https://cmake.org/cmake/help/v3.21/manual/cmake-modules.7.html
[cmake_relnotes]: https://cmake.org/cmake/help/latest/release/3.21.html
[doxygen_changelog]: https://www.doxygen.nl/manual/changelog.html
[doxygen_downloads]: https://www.doxygen.nl/download.html#srcbin
[git_downloads]: https://git-scm.com/download/win
[git_exe]: https://git-scm.com/docs/git
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.33.0.txt
[github_markdown]: https://github.github.com/gfm/
[graalvm_examples]: https://github.com/michelou/graalvm-examples
[haskell_examples]: https://github.com/michelou/haskell-examples
[kotlin_examples]: https://github.com/michelou/kotlin-examples
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm]: https://llvm.org/
[llvm_as]: https://llvm.org/docs/CommandGuide/llvm-as.html
[llvm_clang]: https://releases.llvm.org/12.0.1/tools/clang/docs/ClangCommandLineReference.html
[llvm_dis]: https://llvm.org/docs/CommandGuide/llvm-dis.html
[llvm_downloads]: https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.1
[llvm_llc]: https://llvm.org/docs/CommandGuide/llc.html
[llvm_lld]: https://lld.llvm.org/
[llvm_lldb]: https://lldb.llvm.org/
[llvm_lli]: https://llvm.org/docs/CommandGuide/lli.html
[llvm_opt]: https://llvm.org/docs/CommandGuide/opt.html
[llvm_relnotes]: https://releases.llvm.org/12.0.1/docs/ReleaseNotes.html
[llvm_tools]: https://llvm.org/docs/CommandGuide/
[msys2_downloads]: http://repo.msys2.org/distrib/x86_64/
[nodejs_examples]: https://github.com/michelou/nodejs-examples
[pelook_exe]: http://bytepointer.com/tools/index.htm#pelook
[python_changelog]: https://docs.python.org/release/3.9.6/whatsnew/changelog.html
[python_downloads]: https://www.python.org/downloads/
[scala3_examples]: https://github.com/michelou/dotty-examples
[trufflesqueak_examples]: https://github.com/michelou/trufflesqueak-examples
[vs2019_downloads]: https://visualstudio.microsoft.com/en/downloads/
[vs2019_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes
[vswhere_exe]: https://github.com/microsoft/vswhere
[windows_cmake]: https://devblogs.microsoft.com/cppblog/cmake-support-in-visual-studio/
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
