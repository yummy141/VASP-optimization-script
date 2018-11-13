# VASP-optimization
This is a Python/bash tutorial performing VASP optimization on TH-NET.
## 写在前面的话
- 本篇教程以黑磷为例，演示如何用bash和Python脚本来优化晶格参数。
    - 在学习如何使用脚本前，大家要明白一件事，我们计算用的脚本，不涉及算法（algorithm）方面的效率问题，更多的是一些系统操作， 因此用哪种语言写都没什么差别，用自己喜欢的就好。
    - 当然，在人工智能大行其道的8102年，喊声> “人生苦短，我用Python”
    ，也许也是时代趋势。
    ![1.png](/img/1.png) 
    - 另外，如果读者能够直接看懂程序，就不需要看我接下去写的内容了。

---

## 晶格优化回顾
- 按照惯例，大家进到TH-1A各自的目录里，然后cp -r ../novice_country/Lesson2/  ./, 然后 cd Lesson2就可以看到基础的VASP四件套：  
    - ![2.png](/img/2.png)
- 现在我们回忆晶格优化怎么做的，由于我们要找到能量最低的晶格，所以需要修改POSCAR中的晶格常数，分别计算得到能量，然后找到能量最低点。具体来讲：
    - (1) 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
    - (2) 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
    - (3) 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。  
    ......  
    - (n) 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
- 直到找到最低点，所有的操作都是重复的，除了vi编辑的POSCAR中的参数不同。那重复性的操作能让人想到编程中的什么呢？——如果回忆一下“面向过程”的编程学习，那肯定就是三大结构里的“循环”了，而循环体内部的内容就应该是前述的可抽象的重复性操作。讲到这里，我们就可以直接取看脚本了。

---

## 运行结果
- 在讲脚本之前，我们先看一下运行脚本后的结果（rz上传脚本*.sh后，chmod a+x *.sh, 然后./*.sh 运行 or rz上传脚本*.py， python ./*.py运行）
    - ![3.png](/img/3.png)
    - ![4.png](/img/4.png)
- 图中我们在对应的opt[num]文件夹里做结构优化，优化完后运行脚本，输出目前得到的最优晶格和能量，并把所有的能量输出到worklist里。那由于作业管理系统的特性，我们把这个拆成两步，（1）执行对应的结构优化 （2）把能量提取出来放到worklist
- 因此我写了两个脚本，分别来执行这两步操作

---

### bash脚本
第一个脚本Sub_opt_TH.sh，是针对第一步来做的，我们一段一段来读程序，看的时候一定要先想想这一行程序是什么意思，再看我的注解，要习惯直接读程序代码：
```bash
#!/bin/bash</pre>
```
- 看到#第一直觉会是这是一行注释，但是注意这里是#！，是有意义的。Linux的脚本基本都需要声明解释器在哪，这行就是声明解释器路径，表示由bin/目录下的bash来[解释](https://blog.csdn.net/jackalfly/article/details/7571616)。
```bash
tartdir=`pwd`  
nodes=12  
run=$startdir/run.sh
```
- startdir声明了当前路径, =`pwd`表示赋值为使用pwd后的输出结果（即获得当前路径），而不是字符串"pwd"。
- nodes=12，声明我们使用12个核。
- run=$startdir/run.sh 即声明了在当前路径下的run.sh文件。
```bash
printf '#! /bin/bash\n' > $run
printf 'yhrun -n %s -p TH_NET1 vasp.std.5.4.1 > log\n' $nodes >> $run
```
- 这里是写出run.sh文件，即运行文件，包含声明解释器位置以及运行指令
- bash里的printf和C语言中的很像，%s即表明为字符串，\n是转义字符即为回车，$nodes表明取nodes变量的值
- \>为新建一个文件，如果这个文件存在则覆盖这个文件
- \>\>为把内容追加到这个文件中
```bash
worklist=$startdir/worklist
printf 'label ax ay az bx by bz Energy\n' > $worklist
```
- 理解上面的，这里就很简单了，就是声明worklist的路径，以及输出worklist的第一行