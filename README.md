# <span id="top">LLVM on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/"><img src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://llvm.org/">LLVM</a> examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with the LLVM infrastructure on a Windows machine.
  </td>
  </tr>
</table>

## <span id="section_01">Project dependencies</span>

This project repository relies on two external software for the **Microsoft Windows** plaform:

- [LLVM 8 Windows binaries](https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1) ([*release notes*](https://releases.llvm.org/8.0.0/docs/ReleaseNotes.html))
- [Microsoft Visual Studio Community 2019](https://visualstudio.microsoft.com/en/downloads/) ([*release notes*](https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes)) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>

Optionally one may also install the following software:

- [CMake 3.15](https://cmake.org/download/) ([*release notes*](https://cmake.org/cmake/help/v3.15/release/3.15.html))
- [Git 2.22](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.22.0.txt))
- [MSYS2](http://repo.msys2.org/distrib/x86_64/)

<!--
> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).
-->

For instance our development environment looks as follows (*August 2019*):

<pre style="font-size:80%;">
C:\opt\cmake-3.15.2\                                            <i>(  75 MB)</i>
C:\opt\LLVM-8.0.1\                                              <i>(1.1 resp. 2.18 GB)</i><sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>
C:\opt\Git-2.22.0\                                              <i>( 271 MB)</i>
C:\opt\msys64\                                                  <i>(2.85 GB)</i>
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\  <i>(2.98 GB)</i>
</pre>

<!--
https://devblogs.microsoft.com/cppblog/cmake-3-14-and-performance-improvements/
-->

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).

## Directory structure

This project is organized as follows:
<pre style="font-size:80%;">
bin\vswhere.exe
bin\llvm\build.bat
docs\
examples\{hello, JITTutorial1, ..}
llvm-8.0.1.src\  <i>(extracted from file <a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">llvm-8.0.1.src.tar.xz</a>)</i><sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>
README.md
setenv.bat
</pre>

where

- directory [**`bin\`**](bin/) contains a batch file and the <a href="https://github.com/microsoft/vswhere"><b><code>vswhere.exe</code></b></a> tool.
- directory [**`docs\`**](docs/) contains several LLVM related papers/articles.
- directory [**`examples\`**](examples/) contains LLVM code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`llvm-8.0.1.src\`** contains the LLVM source code distribution.
- file [**`README.md`**](README.md) is the Markdown document for this page.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`L:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst L: %USERPROFILE%\workspace\graalvm\llvm-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`clang.exe`**](https://clang.llvm.org/docs/ClangCommandLineReference.html#introduction), [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019), [**`git.exe`**](https://git-scm.com/docs/git), etc. directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -verbose    display progress messages
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\llvm\build.bat`**](bin/llvm/build.bat) - This batch command generates/installs additional files (executables, header files, library files, CMake modules) not available in LLVM installation directory (in our case **`C:\opt\LLVM-8.0.1\`**).

    <pre>
    <b>&gt; build help</b>
    Usage: build { options | subcommands }
    Options:
      -debug      show commands executed by this script
      -verbose    display progress messages
    Subcommands:
      clean       delete generated files
      compile     generate executable
      help        display this help message
      install     install files generated in directory build
      run         run executable
    </pre>

    > **:mag_right:** For instance, [LLVM tools](https://llvm.org/docs/CommandGuide/) such as [**`llvm-as.exe`**](https://llvm.org/docs/CommandGuide/llvm-as.html) (assembler), [**`llvm-dis.exe`**](https://llvm.org/docs/CommandGuide/llvm-dis.html) (disassembler), [**`opt.exe`**](https://llvm.org/docs/CommandGuide/opt.html) (optimizer), [**`llc.exe`**](https://llvm.org/docs/CommandGuide/llc.html) (static compiler) and [**`lli.exe`**](https://llvm.org/docs/CommandGuide/lli.html) (bitcode runner) are not part of the LLVM binary distribution (e.g. [LLVM-8.0.1-win64.exe](https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1)).

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`clang.exe`**](https://clang.llvm.org/docs/ClangCommandLineReference.html#introduction), [**`opt.exe`**](https://llvm.org/docs/CommandGuide/opt.html), [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   clang 8.0.1, lli 8.0.1, opt 8.0.1, cl version 19.22.27905
   dumpbin 14.22.27905.0, nmake 14.22.27905.0
   msbuild 16.200.19.32702, cmake 3.14.19060802-MSVC_2
   cmake 3.15.2, make 4.2.1, gcc 9.1.0, python 3.7.4, diff 3.7
   git 2.22.0.windows.1, vswhere 2.7.1+180c706d56

<b>&gt; where clang nmake vswhere</b>
C:\opt\LLVM-8.0.1\bin\clang.exe
X:\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64\nmake.exe
L:\bin\vswhere.exe
</pre>

> **&#9755;** ***Important note***<br/>
> Command [**`setenv`**](setenv.bat) does not add MSVC CMake and GNU Cmake to the **`PATH`** environment variable because of name conflict. Use either **`%MSVS_CMAKE_CMD%`** or **`%CMAKE_HOME%\bin\cmake.exe`**.

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   clang 8.0.1, lli 8.0.1, opt 8.0.1, cl version 19.22.27905
   dumpbin 14.22.27905.0, nmake 14.22.27905.0
   msbuild 16.200.19.32702, cmake 3.14.19060802-MSVC_2
   cmake 3.15.2, make 4.2.1, gcc 9.1.0, python 3.7.4, diff 3.7
   git 2.22.0.windows.1, vswhere 2.7.1+180c706d56
Tool paths:
   C:\opt\LLVM-8.0.1\bin\clang.exe
   C:\opt\LLVM-8.0.1\bin\lli.exe
   C:\opt\LLVM-8.0.1\bin\opt.exe
   X:\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64\cl.exe
   X:\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64\dumpbin.exe
   X:\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64\nmake.exe
   X:\MSBuild\Current\Bin\amd64\MSBuild.exe
   X:\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe
   C:\opt\cmake-3.15.2\bin\cmake.exe
   C:\opt\msys64\usr\bin\make.exe
   C:\opt\msys64\mingw64\bin\gcc.exe
   C:\opt\Python-3.7.4\python.exe
   C:\opt\msys64\usr\bin\python.exe
   C:\opt\msys64\mingw64\bin\python.exe
   C:\opt\msys64\usr\bin\diff.exe
   C:\opt\Git-2.22.0\bin\git.exe
   C:\opt\Git-2.22.0\mingw64\bin\git.exe
   L:\bin\vswhere.exe
Important notice:
   MSVC CMake and GNU Cmake were not added to PATH (name conflict).
   Use either %MSVS_CMAKE_CMD% or %CMAKE_HOME%\bin\cmake.exe.
</pre>

#### `llvm-8.0.1.src\build.bat`

We make use of the LLVM source distribution to build the addtional binaries not available in the LLVM installation directory (in our case **`C:\opt\LLVM-8.0.1\`**).

Directory **`llvm-8.0.1.src\`** is setup as follows:
<pre>
<b>&gt; curl -L --silent --output llvm-8.0.1.src.tar.xz https://github.com/llvm/llvm-project/releases/download/llvmorg-8.0.1/llvm-8.0.1.src.tar.xz</b>
<b>&gt; tar xzvf llvm-8.0.1.src.tar.xz</b>
<b>&gt; cp bin\llvm\build.bat llvm-8.0.1.src</b>
<b>&gt; cd llvm-8.0.1.src</b>
</pre>

Running command [**`build.bat -verbose compile`**](bin/llvm/build.bat) generates the additional binaries (both **`.exe`** and **`.lib`** files) into directory **`build\Release\`**. Be patient, build time is about 55 minutes.

<pre>
<b>&gt; cd</b>
L:\llvm-8.0.1.src
<b>&gt; build -verbose compile</b>
Project: LLVM, Configuration: Release, Platform: x64
Generate configuration files into directory "build"
[...]
</pre>

Running command [**`build.bat -verbose install`**](bin/llvm/build.bat) copies the generated binaries to the LLVM installation directory (in our case **`C:\opt\LLVM-8.0.1\`**).

<pre style="font-size:80%;">
<b>&gt; build -verbose install</b>
Copy files from directory build\Release\bin to C:\opt\LLVM-8.0.1\bin\
Copy files from directory build\Release\lib to C:\opt\LLVM-8.0.1\lib\
Copy files from directory build\lib\cmake to C:\opt\LLVM-8.0.1\lib\cmake\
Copy files from directory include to C:\opt\LLVM-8.0.1\include\
</pre>

We list below several executables in the LLVM installation directory; e.g. commands like [**`clang.exe`**](https://releases.llvm.org/8.0.0/tools/clang/docs/ClangCommandLineReference.html), [**`lld.exe`**](https://lld.llvm.org/)  and [**`lldb.exe`**](https://lldb.llvm.org/) belong to the orginal distribution while commands like [**`llc.exe`**](https://llvm.org/docs/CommandGuide/llc.html), [**`lli.exe`**](https://llvm.org/docs/CommandGuide/lli.html) and [**`opt.exe`**](https://llvm.org/docs/CommandGuide/opt.html) were build/added from the LLVM source distribution.

<pre style="font-size:80%;">
<b>&gt; where /t clang llc lld lldb lli opt</b>
  69512704   18.03.2019      16:58:26  C:\opt\LLVM-8.0.1\bin\clang.exe
  39413248   02.08.2019      17:50:13  C:\opt\LLVM-8.0.1\bin\llc.exe
  47860736   18.03.2019      17:00:18  C:\opt\LLVM-8.0.1\bin\lld.exe
    229376   18.03.2019      17:01:06  C:\opt\LLVM-8.0.1\bin\lldb.exe
  16918528   02.08.2019      17:50:27  C:\opt\LLVM-8.0.1\bin\lli.exe
  42942976   02.08.2019      17:56:01  C:\opt\LLVM-8.0.1\bin\opt.exe
</pre>


#### `examples\JITTutorial1\build.bat`

See file [**`examples\README.md`**](examples/README.md).

## Resources


### Blogs

- [*A look at LLVM Advanced Data Types*](https://developers.redhat.com/blog/2019/04/01/a-look-at-llvm-advanced-data-types-and-trivially-copyable-types/) by Serge Guelton, April 2019.
- [*Compiler Performance and LLVM*](http://pling.jondgoodwin.com/post/compiler-performance/) by Jonathan Goodwin, March 2019.
- [*LLVM IR and Go*](https://blog.gopheracademy.com/advent-2018/llvm-ir-and-go/) by Robin Eklind, December 2018.
- [*How LLVM optimizes a function*](https://blog.regehr.org/archives/1603) by John Regehr, September 2018.
- [*How LLVM optimizes power sums*](https://kristerw.blogspot.com/2019/04/how-llvm-optimizes-geometric-sums.html) by Krister Walfridsson, April 2018.
- [*Adventures in JIT compilation: Part 3 - LLVM*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-3-llvm/) by Eli Bendersky, May 2017.
- [*Adventures in JIT compilation: Part 2 - an x64 JIT*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-2-an-x64-jit/) by Eli Bendersky, March 2017.
- [*Adventures in JIT compilation: Part 1 - an interpreter*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-1-an-interpreter/) by Eli Bendersky, March 2017.
- [*A Tourist’s Guide to the LLVM Source Code*](https://blog.regehr.org/archives/1453) by John Regehr, January 2017.
- [*LLVM for Grad Students*](http://www.cs.cornell.edu/~asampson/blog/llvm.html) by Adrian Sampson, August 2015.
- [*A deeper look into the LLVM code generator, Part 1*](https://eli.thegreenplace.net/2013/02/25/a-deeper-look-into-the-llvm-code-generator-part-1) by Eli Bendersky, Feburary 2013.
- [*Life of an instruction in LLVM*](https://eli.thegreenplace.net/2012/11/24/life-of-an-instruction-in-llvm) by Eli Bendersky, November 2012.
- [*Create a working compiler with the LLVM framework, Part 2*](https://www.ibm.com/developerworks/library/os-createcompilerllvm2/index.html) by Arpan Sen, June 2012.
- [*Create a working compiler with the LLVM framework, Part 1*](https://www.ibm.com/developerworks/library/os-createcompilerllvm1/index.html) by Arpan Sen, June 2012.
- [*Writing Your Own Toy Compiler Using Flex, Bison and LLVM*](https://gnuu.org/2009/09/18/writing-your-own-toy-compiler/), by Loren Segal, September 2009.


### Books

- [*LLVM Essentials*](https://www.packtpub.com/application-development/llvm-essentials) by S. Sarda &amp; M. Pandey, Packt Publishing, December 2015 (166 p., ISBN 978-1-78528-080-1).
- [*LLVM Cookbook*](https://www.packtpub.com/application-development/llvm-cookbook), by M. Pandey &amp; S. Sarda, Packt Publishing, May 2015 (296 p., ISBN 978-1-78528-598-1).
- [*Getting Started with LLVM Core Libraries*](https://www.packtpub.com/application-development/getting-started-llvm-core-libraries) by B. Cardoso Lopez &amp; R. Auler, Packt Publishing, August 2014 (314 p., ISBN 978-1-78216-692-4).

### News

- [*LLVM Weekly*](http://llvmweekly.org/) - A weekly newsletter covering developments in LLVM, Clang, and related projects.
- [*Planet Clang*](http://planet.clang.org/) - Planet Clang is a window into the world, work and lives of Clang developers, contributors and the standards they implement.

<!--
- [LLVM Archive](https://www.linux-magazin.de/tag/llvm/) - Linux-Magazin.
-->


### Papers

- [*LLVM: An infrastructure for Multi-Stage Optimization*](http://llvm.org/pubs/2002-12-LattnerMSThesis.html) *(Master Thesis)* by Chris Lattner, December 2002.


## Footnotes

<a name="footnote_01">[1]</a>  [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
Command <a href="https://github.com/microsoft/vswhere"><b><code>vswhere.exe</code></b></a> displays VS properties, including the exact version of our Visual Studio installation (starting with VS 2017):
<pre style="margin:0 0 1em 20px; font-size:80%;">
<b>&gt; where vswhere</b>
L:\bin\vswhere.exe

<b>&gt; vswhere -property installationVersion</b>
16.2.29123.88
</pre>
<!-- old: 16.1.29102.190 -->
</p>

<a name="footnote_02">[2]</a>  [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
The original size of the LLVM installation directory is 1.1 GB. The installation of the additional files (i.e. executables, header files, library files and CMake modules) increases its size to 2.18 GB.
</p>

<a name="footnote_03">[3]</a>  [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://cmake.org/download/">cmake-3.15.1-win64-x64.zip</a>  <i>( 30 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">LLVM-8.0.1-win64.exe</a>        <i>(131 MB)</i>
<a href="https://github.com/llvm/llvm-project/releases/tag/llvmorg-8.0.1">llvm-8.0.1.src.tar.xz</a>       <i>( 29 MB)</i>
<a href="http://repo.msys2.org/distrib/x86_64/">msys2-x86_64-20190524.exe</a>   <i>( 86 MB)</i>
vs_2019_community.exe  
</pre>
<p style="margin:0 0 1em 20px;">
Microsoft doesn't provide an offline installer for VS 2019 but we can follow the <a href="https://docs.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2019">following instructions</a> to create a local installer (so called <i>layout cache</i>) for later (re-)installation.
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
