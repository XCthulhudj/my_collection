# ___Makefile学习笔记___

```bash
example
├── calc
│   ├── calc.h
│   ├── getch.c
│   ├── getop.c
│   ├── stack.c
│   └── main.c
├── test
│   ├── input.txt
│   └── run_calc.py
├── out
└── makefile

```

---

不使用构建工具，进行编译，则需要先进入到calc目录下，执行命令：
```bash
Gcc main.c getch.c getop.c statck.c -o ../out/calc
```

| 部分           | 含义         |
| ------------- | ------------ |
| `gcc`         | 调用 GCC 编译器    |
| `main.c`      | 第一个 C 源文件    |
| `getch.c`     | 第二个 C 源文件    |
| `getop.c`     | 第三个 C 源文件    |
| `stack.c`     | 第四个 C 源文件    |
| `-o`          | 指定输出文件的名称和路径 |
| `../out/calc` | 最终生成的可执行文件   |

---

使用构建工具make

* 在项目根目录下创建一个名为`makefile`或`Makefile`的***文件***
* 输入该构建规则：

```bash
out/calc: calc/main.c calc/getch.c calc/getop.c calc/stack.c
mkdir -p out
gcc calc/main.c calc/getch.c calc/getop.c calc/stack.c -o out/calc
```

* 第一行冒号之前的`out/calc`是目标
* 冒号后面的`calc/main.c calc/getch.c calc/getop.c calc/stack.c`是关系依赖表，即编译`calc`程序所需要的源码文件
* 这些源码文件只要有一个发生了变化，就会触发第三行`命令部分`

<p>现在只需要直接在项目根目录下打开终端并输入<code>make</code>命令，就会看到它按照我们的设定去编译程序了。当然，这里有一点需要特别留意：无论是 make 还是 gcc，都不会自动创建目标文件所在的目录，因此在第一次编译之前，我们必须先手动执行<code>mkdir -p out</code>来创建好<code>out</code>目录，否则 gcc 会因为找不到输出目录而报错。后面几个版本沿用同样的设计但省略了这条<code>mkdir</code>命令，请读者在运行它们前务必要记得先创建<code>out</code>目录。</p>
<blockquote>
<p>请注意，在第二行的 gcc 命令之前必须要有一个 tab 缩进。语法规定 Makefile 中的任何命令之前都必须要有一个 tab 缩进，否则就会报错。下文所有 Makefile 代码块出于排版需要均使用 4 空格代替缩进显示，复制到本地时务必改回 Tab 字符，否则 make 会报 <em>missing separator</em> 错误。</p>
</blockquote>

---

```bash
cc = gcc
prom = out/calc
src = calc/main.c calc/getch.c calc/getop.c calc/stack.c

$(prom): $(src)
    $(cc) $(src) -o $(prom)
```

<p>如读者所见，我们在上述代码中定义了<code>cc</code>、<code>prom</code>以及<code>src</code>这三个变量。它们分别用于告诉 make 我们要使用的编译器、要编译的目标以及源文件。这样一来，今后我们要修改这三者中的任何一项，只需要修改变量的定义即可，而不用再去管后面的代码部分了。</p>
<p>但我们现在依然还是没能解决”只修改一个文件，整个项目就要全部重新编译”的问题。而且 make 是基于文件修改时间（mtime）来判断依赖关系是否发生变化的，如果我们只是修改了<code>calc.h</code>而没有将其显式列入目标的依赖关系表，make 就不会察觉到它的变化（所以下面有必要再为头文件专门设置一个变量，并将其加入到依赖关系表中）。下面，我们来想一想如何解决这个问题。考虑到在标准的编译过程中，源文件往往是先被编译成目标文件，然后再由目标文件连接成可执行文件的。我们可以利用这一点来调整一下这些文件之间的依赖关系：</p>

---

```bash
cc =gcc
prom = out/calc
deps = calc/calc.h
obj = out/main.o out/getch.o out/getop.o out/stack.o

$(prom): $(obj)
    $(cc) $(obj) -o  $(prom)

out/main.o: calc/main.c $(deps)
    $(cc) -c calc/main.c -o out/main.o
 
out/getch.o: calc/getch.c $(deps)
    $(cc) -c calc/getch.c -o out/getch.o
 
out/getop.o: calc/getop.c $(deps)
    $(cc) -c calc/getop.c -o out/getop.o
 
out/stack.o: calc/stack.c $(deps)
    $(cc) -c calc/stack.c -o out/stack.o
```