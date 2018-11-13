# VASP-optimization
This is a Python/bash tutorial performing VASP optimization on TH-NET.
## 写在前面的话
- 本篇教程以黑磷为例，演示如何用bash和Python脚本来优化晶格参数。
    - 在学习如何使用脚本前，大家要明白一件事，我们计算用的脚本，不涉及算法（algorithm）方面的效率问题，更多的是一些系统操作， 因此用哪种语言写都没什么差别，用自己喜欢的就好。
    - 当然，在人工智能大行其道的8102年，喊声> “人生苦短，我用Python”
    ，也许也是时代趋势。
    ![1.png](/img/1.png) 
    - 另外，如果读者能够直接看懂程序，就不需要看我接下去写的内容了。
## 晶格优化回顾
- 按照惯例，大家进到TH-1A各自的目录里，然后cp -r ../novice_country/Lesson2/  ./, 然后 cd Lesson2就可以看到基础的VASP四件套：
![2.png](/img/2.png)
- 现在我们回忆晶格优化怎么做的，由于我们要找到能量最低的晶格，所以需要修改POSCAR中的晶格常数，分别计算得到能量，然后找到能量最低点。具体来讲：
    - 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
    - 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。
    - 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。  
    ....  
    - 复制对应文件，用vi编辑POSCAR，然后提交任务，输出能量。