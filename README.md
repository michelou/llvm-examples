# <span id="top">LLVM on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/"><img src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://llvm.org/">LLVM</a> examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with LLVM on the <b>Microsoft Windows</b> platform.
  </td>
  </tr>
</table>

## <span id="section_01">Project dependencies</span>

This project repository relies on two external software for the **Microsoft Windows** plaform:

- [LLVM 8 Pre-build binaries](http://releases.llvm.org/download.html#8.0.0) ([*release notes*](https://releases.llvm.org/8.0.0/docs/ReleaseNotes.html))
- [Microsoft Visual Studio 2019](https://visualstudio.microsoft.com/en/downloads/) ([*release notes*](https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes))

> **:mag_right:** Command [**`vshere.exe`**](https://github.com/microsoft/vswhere) displays VS properties, including the exact version of our Visual Studio installation:
> <pre style="font-size:80%;">
<b>&gt; "C:\Program Files (x86)\Microsoft Visual Studio"\Installer\vswhere.exe -property installationVersion</b>
16.1.29102.190
</pre>

Optionally one may also install the following software:

- [Git 2.22](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.22.0.txt))

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).

For instance our development environment looks as follows (*August 2019*):

<pre style="font-size:80%;">
C:\opt\LLVM-8.0.0\                                              <i>(1.1  GB) (2.18 GB)</i><sup>[1]</sup>
C:\opt\Git-2.22.0\                                              <i>( 271 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\  <i>(2.98 GB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).

## Directory structure

This repository is organized as follows:
<pre style="font-size:80%;">
bin\llvm\build.bat
docs\
examples\
llvm-8.0.1.src\  <i>(extracted from llvm-8.0.1.src.tar.x> <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>)</i>
README.md
setenv.bat
</pre>

where

- directory [**`bin\`**](bin/) contains utility batch files.
- directory [**`docs\`**](docs/) contains several LLVM related papers/articles.
- directory [**`examples\`**](examples/) contains LLVM code examples (see [**`examples\README.md`**](examples/README.md)).
- directory [**`llvm-8.0.1.src\`**](llvm-8.0.1.src/) contains the LLVM source code distribution.
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
        -verbose    display environment settings
      Subcommands:
        help        display this help message
    </pre>

2. [**`bin\llvm\build.bat`**](bin/llvm/build.bat) - This batch command must be copied manually to the LLVM source distribution **`llvm-8.0.1.src\`**; we can generate/install binaries not present in the installed LLVM distribution (in our case **`C:\opt\LLVM-8.0.0\`**).

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

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`clang.exe`**](https://clang.llvm.org/docs/ClangCommandLineReference.html#introduction), [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
    clang 8.0.0, opt 8.0.1,
    cl version 19.21.27702.2, cmake 3.14.19050301-MSVC_2
    msbuild 16.1.76.45076, nmake 14.21.27702.2, git 2.22.0.windows.1

<b>&gt; where clang</b>
C:\opt\LLVM-8.0.0\bin\clang.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   clang 8.0.0, opt 8.0.1,
   cl version 19.21.27702.2, cmake 3.14.19050301-MSVC_2
   msbuild 16.1.76.45076, nmake 14.21.27702.2, git 2.22.0.windows.1
Tool paths:
   C:\opt\LLVM-8.0.0\bin\clang.exe
   C:\opt\LLVM-8.0.0\bin\opt.exe
   X:\VC\Tools\MSVC\14.21.27702\bin\Hostx64\x64\cl.exe
   X:\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe
   X:\MSBuild\Current\Bin\amd64\MSBuild.exe
   X:\VC\Tools\MSVC\14.21.27702\bin\Hostx64\x64\nmake.exe
   C:\opt\Git-2.22.0\bin\git.exe
</pre>

#### `llvm-8.0.1.src\build.bat`

Command [**`llvm-8.0.1.src\build.bat -verbose install`**](bin/llvm/build.bat) copies the generated binaries to the LLVM installation directory (in our case **`C:\opt\LLVM-8.0.0`**).

<pre style="font-size:80%;">
<b>&gt; build -verbose install</b>
Copy files from directory build\Release\bin to C:\opt\LLVM-8.0.0\bin\
Copy files from directory build\Release\lib to C:\opt\LLVM-8.0.0\lib\
Copy files from directory build\lib\cmake to C:\opt\LLVM-8.0.0\lib\cmake\
Copy files from directory include to C:\opt\LLVM-8.0.0\include\
</pre>

We list below several binaries in the LLVM installation directory; e.g. commands ""`clang.exe`** and **`lld.exe`** belong to the orginal distribution while commands **`llc.exe`** and **`lli.exe`** were build/added from the LLVM source distribution.

<pre style="font-size:80%;">
<b>&gt; where /t clang llc lld lli</b>
  69512704   18.03.2019      16:58:26  C:\opt\LLVM-8.0.0\bin\clang.exe
  39413248   02.08.2019      17:50:13  C:\opt\LLVM-8.0.0\bin\llc.exe
  47860736   18.03.2019      17:00:18  C:\opt\LLVM-8.0.0\bin\lld.exe
  16918528   02.08.2019      17:50:27  C:\opt\LLVM-8.0.0\bin\lli.exe
</pre>

## Resources

### Blogs

- [Life of an instruction in LLVM](https://eli.thegreenplace.net/2012/11/24/life-of-an-instruction-in-llvm) by Eli Bendersky, November 2012.
- [A deeper look into the LLVM code generator, Part 1](https://eli.thegreenplace.net/2013/02/25/a-deeper-look-into-the-llvm-code-generator-part-1) by Eli Bendersky, Feburary 2013.
- [A Tourist’s Guide to the LLVM Source Code](https://blog.regehr.org/archives/1453) by John Regehr, January 2017.

### Books

- [*Getting Started with LLVM Core Libraries*](https://www.packtpub.com/application-development/getting-started-llvm-core-libraries) by B. Cardoso Lopez &amp; R. Auler, Packt Publishing, August 2014 (314p, ISBN 978-1-78216-692-4).
- [*LLVM Cookbook*](https://www.packtpub.com/application-development/llvm-cookbook), by M. Pandey &amp; S. Sarda, Packt Publishing, May 2015 (ISBN 978-1-78528-598-1).
- [*LLVM Essentials*](https://www.packtpub.com/application-development/llvm-essentials) by S. Sarda &amp; M. Pandey, Packt Publishing, December 2015 (ISBN 978-1-78528-080-1).

## Footnotes

<a name="footnote_01">[1]</a>  [↩](#anchor_01)

<div style="margin:0 0 1em 20px;">
<div>In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):</div>
<pre style="font-size:80%;">
LLVM-8.0.0-win64.exe   <i>(131 MB)</i>
llvm-8.0.1.src.tar.xz  <i>( 29 MB)</i>
vs_2019_community.exe  <i>(no offline installer)</i>
</pre>
</div>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
