# <span id="top">LLVM Resources</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://llvm.org/"><img src="https://llvm.org/img/LLVM-Logo-Derivative-1.png" width="120" alt="LLVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document gathers a few <a href="https://llvm.org/">LLVM</a> related resources.
  </td>
  </tr>
</table>


## <span id="articles">Articles</span>

- [MIR: A lightweight JIT compiler project][article_mir], by Vladimir Makarov, January 2020.
- [*A look at LLVM Advanced Data Types*][article_data_types] by Serge Guelton, April 2019.
- [*Compiler Performance and LLVM*][article_compiler_perf] by Jonathan Goodwin, March 2019.
- [*LLVM IR and Go*][article_ir_go] by Robin Eklind, December 2018.
- [*How LLVM optimizes a function*](https://blog.regehr.org/archives/1603) by John Regehr, September 2018.
- [*How LLVM optimizes power sums*][article_power_sums] by Krister Walfridsson, April 2018.
- [*Adventures in JIT compilation: Part 3 - LLVM*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-3-llvm/) by Eli Bendersky, May 2017.
- [*Adventures in JIT compilation: Part 2 - an x64 JIT*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-2-an-x64-jit/) by Eli Bendersky, March 2017.
- [*Adventures in JIT compilation: Part 1 - an interpreter*](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-1-an-interpreter/) by Eli Bendersky, March 2017.
- [*A Tourist’s Guide to the LLVM Source Code*](https://blog.regehr.org/archives/1453) by John Regehr, January 2017.
- [*LLVM for Grad Students*](http://www.cs.cornell.edu/~asampson/blog/llvm.html) by Adrian Sampson, August 2015.
- [*A deeper look into the LLVM code generator, Part 1*](https://eli.thegreenplace.net/2013/02/25/a-deeper-look-into-the-llvm-code-generator-part-1) by Eli Bendersky, February 2013.
- [*Life of an instruction in LLVM*](https://eli.thegreenplace.net/2012/11/24/life-of-an-instruction-in-llvm) by Eli Bendersky, November 2012.
- [*Create a working compiler with the LLVM framework, Part 2*](https://www.ibm.com/developerworks/library/os-createcompilerllvm2/index.html) by Arpan Sen, June 2012.
- [*Create a working compiler with the LLVM framework, Part 1*](https://www.ibm.com/developerworks/library/os-createcompilerllvm1/index.html) by Arpan Sen, June 2012.
- [*Writing Your Own Toy Compiler Using Flex, Bison and LLVM*][article_toy_compiler], by Loren Segal, September 2009.

<!--
- [*Building an LLVM-based tool. Lessons learned*](https://lowlevelbits.org/building-an-llvm-based-tool.-lessons-learned/) by Alex Denisov, April 2019 ([EuroLLVM 2019](http://llvm.org/devmtg/2019-04/)).
-->

## <span id="books">Books</span>

- [*Tutorial: Creating an LLVM Backend for the Cpu0 Architecture*][book_cpu0] by Chen Chung-Shu, February 2020 (*Release 3.9.1*).
- [*Mapping High Level Constructs to LVVM IR*](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/) (*ebook*) by Michael Rodle, 2018.
- [*LLVM Essentials*](https://www.packtpub.com/application-development/llvm-essentials) by S. Sarda &amp; M. Pandey, Packt Publishing, December 2015 (166 p., ISBN 978-1-78528-080-1).
- [*LLVM Cookbook*](https://www.packtpub.com/application-development/llvm-cookbook), by M. Pandey &amp; S. Sarda, Packt Publishing, May 2015 (296 p., ISBN 978-1-78528-598-1).
- [*Getting Started with LLVM Core Libraries*](https://www.packtpub.com/application-development/getting-started-llvm-core-libraries) by B. Cardoso Lopez &amp; R. Auler, Packt Publishing, August 2014 (314 p., ISBN 978-1-78216-692-4).


## <span id="courses">Courses</span>

- [Compilers](https://anoopsarkar.github.io/compilers-class/index.html): [Code Generation with LLVM](https://anoopsarkar.github.io/compilers-class/llvm-practice.html) by [Anoop Sarkar](https://www2.cs.sfu.ca/~anoop/) (instructor), Summer 2019.
- [EEECS 582: Advanced Compilers](http://web.eecs.umich.edu/~mahlke/courses/583f18/), Fall 2018.
- [Advanced compilers](https://wiki.aalto.fi/display/t1065450/Advanced+compilers+2015) by Vesa Hirvisalo (instructor), 2015.

## News

- [*LLVM Weekly*](http://llvmweekly.org/) - A weekly newsletter covering developments in LLVM, Clang, and related projects.
- [*Planet Clang*](http://planet.clang.org/) - Planet Clang is a window into the world, work and lives of Clang developers, contributors and the standards they implement.

<!--
- [LLVM Archive](https://www.linux-magazin.de/tag/llvm/) - Linux-Magazin.
-->


## <span id="tools">Online Tools</span>

- [Compiler Explorer](https://www.godbolt.org/) (type your C/C++ code in the left pane, then select "*x86-64 clang 8.0.0*" and add a new pane "*IR output*").


## <span id="papers">Papers</span>

<p style="margin:0 0 1em 20px;">
See page <a href="https://llvm.org/pubs/"><i>"LLVM Related Publications"</i></a> on the official <a href="https://llvm.org/">LLVM</a> website.
</p>
<p style="margin:0 0 1em 20px;">
We mention here only the publications from <a href="http://nondot.org/~sabre/">Chris Lattner</a>'s and [Vikram Adve](https://vikram.cs.illinois.edu/):
</p>
<ul style="margin:0 0 1em 20px;">
<li><a href="https://llvm.org/pubs/2002-08-09-LLVMCompilationStrategy.pdf"><i>The LLVM Instruction Set and Compilation Strategy</i></a> by Chris Lattner and Vikram Adve (August 2002).</li>
<li><a href="http://llvm.org/pubs/2002-12-LattnerMSThesis.html"><i>LLVM: An infrastructure for Multi-Stage Optimization</i></a> by Chris Lattner (Master Thesis, December 2002).</li>
</ul>

## TableGen

- [Utilizing TableGen for Non-Compiling Processes](https://www.embecosm.com/2015/04/14/utilizing-tablegen-for-non-compiling-processes/) by Simon Cook, April 2015.
- [LLVM TableGen](https://wiki.aalto.fi/display/t1065450/LLVM+TableGen) by Sami Teräväinen, February 2015.

<!--
## Footnotes

<a name="footnote_01">[1]</a> ***Visual Studio Locator*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
</p>
-->

***

*[mics](https://lampwww.epfl.ch/~michelou/)/June 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[article_compiler_perf]: http://pling.jondgoodwin.com/post/compiler-performance/
[article_data_types]: https://developers.redhat.com/blog/2019/04/01/a-look-at-llvm-advanced-data-types-and-trivially-copyable-types/
[article_ir_go]: https://blog.gopheracademy.com/advent-2018/llvm-ir-and-go/
[article_mir]: https://developers.redhat.com/blog/2020/01/20/mir-a-lightweight-jit-compiler-project/
[article_power_sums]: https://kristerw.blogspot.com/2019/04/how-llvm-optimizes-geometric-sums.html
[article_toy_compiler]: https://gnuu.org/2009/09/18/writing-your-own-toy-compiler/
[book_cpu0]: https://jonathan2251.github.io/lbd/llvmstructure.html
