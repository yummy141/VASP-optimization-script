# VASP-optimization
This is a Python/bash tutorial performing VASP optimization on TH-NET.
## 写在前面的话
- 本篇教程以黑磷为例，演示如何用bash和Python脚本来优化晶格参数。
    - 在学习如何使用脚本前，大家要明白一件事，我们计算用的脚本，不涉及算法（algorithm）方面的效率问题，更多的是一些系统操作， 因此用哪种语言写都没什么差别，用自己喜欢的就好。
    - 当然，在人工智能大行其道的8102年，喊声“人生苦短，我用Python”，也许也是时代趋势。
        - ![1.png](/img/1.png) 
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
```bash
i=$(seq 4.57 0.01 4.59)
j=$(seq 3.31 0.01 3.33)
```
- 这里声明“循环变量”，晶格常数a, b的变化范围
- seq是bash的一个指令，输出一系列的值，seq FIRST INCREMENT LAST中的三个参数分别表明第一个参数，间隔值，最后一个参数，举例来讲，i变量就保存了三个数4.57，4.58，4.59
- 值得注意的是，我也曾经想用awk来保存一个数值范围，但是由于精度的问题，awk会出现一些数据错误，有兴趣的读者可以尝试一下我脚本中注释掉的语句。
```bash
label=$(awk 'BEGIN{printf("%03d",1)}')
```
- 这里的label是一个计数变量，我们用awk将它转换为%3d的格式，如这里我们令初值为1，显示为001
```bash
for a in $i
do
    for b in $j 
    do
```
- for循环，分别遍历序列i, 和序列j
- i变量中有3个数字，j变量中有3个数字，所以一共运行3*3=9次循环体（详见worklist）
现在有了循环变量，就对应的在循环体操作就可以了，也就是我们先前提到的重复内容：
- （n）复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
```bash
    kdir opt$label
    cd opt$label
    cp ../run.sh ./
    cp ../POSCAR_initial POSCAR
    ln -sf ../KPOINTS KPOINTS
    ln -sf ../POTCAR POTCAR
    ln -sf ../INCAR INCAR
```
- 首先是复制对应文件：我们创建操作文件夹，进入这个文件夹，然后把对应的运行文件run.sh和VASP四件套复制进来
- 注意这里使用的是[ln -sf](http://www.cnblogs.com/itech/archive/2009/04/10/1433052.html)是创建软连接的意思，类似与windows下的创建快捷方式。
```bash
    ax=$(awk -v a=$a 'BEGIN{printf("%.10f",a)}')
    ay=$(awk -v a=$a 'BEGIN{printf("%.10f",0)}')
    az=$(awk -v a=$a 'BEGIN{printf("%.10f",0)}')
    bx=$(awk -v b=$b 'BEGIN{printf("%.10f",0)}')
    by=$(awk -v b=$b 'BEGIN{printf("%.10f",b)}')
    bz=$(awk -v b=$b 'BEGIN{printf("%.10f",0)}')
```
- 这里使用awk来对对应的晶格常数向量进行赋值，-v代表赋值，而里面的printf与C语言中的类似。
- 注意，之所以这么写，是因为bash下的向量默认为字符变量，要进行数学运算需要用到其它命令。
```bash
    sed -i "3c\ $ax $ay $az" POSCAR
    sed -i "4c\ $bx $by $bz" POSCAR
```
- 接着用sed命令来对POSCAR进行修改，即将第三行和第四行对应修改
- -i表示进行修改并保存（-i）
    - 这是一个方便调试的设计
- 3c\表示修改第三行
- 注意：这里要用到变量，sed后面必须用双引号，用单引号无法识别变量。
```bash
    yhbatch -n $nodes -p TH_NET1 -J wyt.opt ./run.sh
```
- 修改完后就可以提交脚本
- **注意：这里把wyt.opt修改为你们对应的任务名字
```bash
    printf "opt%s %f %f %f %f %f %f\n" $label $ax $ay $az $bx $by $bz >> $worklist
    label=$(awk -v l=$label 'BEGIN{printf("%03d",l+1)}')
    cd ..
    done
done
```
- 最后就是记录下对应的POSCAR修改数值到worklist中，递增label, 回到上级目录  

至此，我们这个小脚本就完成了，那怎么把能量取出来呢？这里我写了另一个脚本：sub_opt_Energy_TH.sh:
```bash
path=`pwd`
worklist=$path/worklist
line=2
Energy_minimum=9999999999
```
- 和前一个脚本类似，这里定义当前路径path, 以及声明worklist路径
- line表明我们要把能量放到worklist的第几行
- Energy_minimum是用来存放最低点能量的，我们把它初值定义得大一些，方便比较
```bash
for i in $(find $path -name OUTCAR | sed 's/\/OUTCAR//g') ; do
```
- find $path -name OUTCAR | sed 's/\/OUTCAR//g'
    - 这行命令就非常trick了，用到了find命令，管道|，和sed替换
    - 先看find $path -name OUTCAR，是找path目录下的OUTCAR路径，单独运行可以看到这样的结果：
        - ![5.png](/img/5.png)
    - 但是我们想要的是OUTCAR所在的路径，要将图中的OUTCAR删去，所以我们就用了sed命令
    - sed 's/\/OUTCAR//g'
        - s/代表select选择，\/OUTCAR/将“/OUTCAR”替换为空，而/g表示global全局替换
    - 而为什么会有个管道|呢？
    - 其实就是把find找到的东西输送给sed作为输入, 运行一下命令，就可以得到我们想要的结果:
        - ![6.png](/img/6.png)
- 之后就只需要在循环体里把能量取出来就可以了
```bash
    cd $i
```
- 进入$i这个文件夹
```bash
    Energy=`grep TOTEN OUTCAR|tail -1|awk '{print $5}'`
```
- 这个命令呢，同样是通过管道，把能量取出来
    - grep是在OUTCAR中搜索TOTEN，得到
        - ![7.png](/img/7.png) 
    - 但我们要的是最后优化的能量，所以用tail -1过滤一下：
        - ![8.png](/img/8.png) 
    - 那再精确点，我们想要的是上图的-21.45537338，所以我们需要再过滤：
        - ![9.png](/img/9.png) 
    - 这里print $5表示打印第五个字段，你可以看到-21.45537338是在图中的第五个位置
```bash
    result=$(awk -va=$Energy -vb=$Energy_minimum 'BEGIN{print a<b?1:0}')
```
- 接下来呢，我们将能量与最小能量比较
    - -va=$Energy -vb=$Energy_minimum
        - 表示分别把能量赋值给a和b
    - 然后就比较a和b, print a<b?1:0
        - 如果你们熟悉C的话，就会非常熟悉，?叫做三目运算符，如果a<b呢，就输出为1，反之则为0
    - 注意：因为bash下的变量都默认为字符变量，所以才需要这么麻烦地比较。
```bash
    if [ $result -eq 1 ];then
        Energy_minimum=$Energy
        vector_a=`awk 'NR==3 {print; exit}' POSCAR`
        vector_b=`awk 'NR==4 {print; exit}' POSCAR`
    fi
```
- 接着呢，我们用个if语句，如果能量比当前最小能量低，我们就把它记录下来
- awk 'NR==3 {print; exit}' POSCAR
    - 同时记录下对应POSCAR中的晶格常数，这里NR==3，表示第三行，注意NR是awk的内置变量
- 同理，NR==4表示第四行
```bash
    sed -i "${line}s/$/ ${Energy}/" $worklist
```
- 然后我们就在worlist中记录下对应的能量
- -i表示修改并保存
- ${line}s/表示选择第line行
- $/表示行末
- ${Energy}/表示我们记录的数据
- 所以合起来，就是在第line行行末记录下Energy
```bash
    line=$(($line+1))
    cd $path;
done
```
- 递增line，以及返回原始目录
```bash
echo -e "Best POSCAR:\n$vector_a\n$vector_b\nEnergy_minimum: $Energy_minimum eV"
```
- 这里就是用echo命令把最优晶格和能量输出出来
- -e表示把转义字符打开，不然\n就不会被识别为回车
