unit Compile_Hss;


       //////////////////////////////////////////////////////////////////////////
       //                                                                      //
       //      数学函数动态编译器TCompile类    作者:侯思松  2002.4-2002.11     //
       //                  (包括数学函数、布尔运算和定积分函数)                //
       //           有改进意见或发现任何错误请转告我,本人不胜感激。            //
       //                       E-Mail:HouSisong@GMail.com                       //
       //                      (  转载时请保留本说明:)  )                      //
       //                                                                      //
       //////////////////////////////////////////////////////////////////////////


       ///<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<///
       ///  <<功能简介>>:                                                                   ///
       ///     TCompile可以在程序运行过程中动态完成数学函数表达式字符串的编译执行,          ///
       ///  (可以带参数,布尔运算,定积分;动态生成机器码执行,不是解释执行)执行速度超快!!!     ///
       ///>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>///

       {
         <<使用方法>>:
        var
          Compilation : TCompile; // 声明Compilation为数学函数动态编译器TCompile类的实例
          str         : string;
          xValue      : TCmxFloat;
        begin
            Compilation:=TCompile.Create; //创建类
          try
            str:='x+sin(y*PI/2)*3';
            Compilation.SetText(str);   //str为要 求值的数学表达式字符串
            ......
            //如果有参数,可以获得参数地址,并赋值 (默认值为0)
            //如: PTCmxFloatX:=Compilation.GetParameterAddress('x');
            //如: PTCmxFloatY:=Compilation.GetParameterAddress('y');
            //    if (PTCmxFloatX<>nil) then PTCmxFloatX^:=1.5;
            //    if (PTCmxFloatY<>nil) then PTCmxFloatY^:=0.5;
            //也可以一次获得所有的参数列表:Compilation.GetParameterList(PList);
            ......
            xValue:=Compilation.GetValue(); //获得表达式的值,
                                            //可以多次改变参数值并多次调用(如放在循环中),这样才能显示出效率:)
            ......
          finally
            Compilation.Free;     //释放类
          end;
        end;
       }

       
interface

  uses  SysUtils,Forms, Classes, Math;

       (*

          简要声明：
              任何用户使用本软件属于个人自愿选择，作者不会对用户使用本软件所引起
          的对用户的任何形式的损失负责，作者也不承诺提供对本类的维护和服务等义务。
              本类可以自由拷贝和使用，但必须包含完整的代码和说明，任何修改和用于
          商业化目的的行为都应该尽量与作者取得联系，并得到授权。
              ( E-Mail: HouSisong@GMail.com )

              本类的编写目的只是在程序运行过程中能够多次的快速的执行用户输入的
          数学表达式，程序优化的目标是速度和高精度，所以基本数据类型采用的是80
          位浮点型，很多地方的处理是以速度为首要目标，这样在计算的准确性和错误
          处理方面就有所损失。

         ------------------------------------------------------------------------------

          希望大家能帮忙测试一下本编译类,特别是当把它用到了某些关键性计算事务中时,这
       非常关键!一个小的bug就足以致命!!!您可以就某些方面进行测试,甚至是其中的一个函数,
       然后把发现的错误的具体情况告诉我,以便修改;测试时没有发现错误也把测试情况告诉我,
       万分感谢!!!

          我的 E-Mail: HouSisong@GMail.com    QQ: 9043542

         ------------------------------------------------------------------------------
       *)


       {
           作者以前写过一个解释执行数学函数表达式的程序,因为最近使用到而解释执行太慢了满足不了要求，
       所以编写了本编译类单元(数学函数动态编译器TCompile类)。
           TCompile可以完成数学函数表达式的动态编译和执行(动态生成机器码),编译后的执行
       速度比以前解释执行的版本快了5000倍左右!在多次执行和表达式复杂情况下,TCompile在程序
       执行过程中动态编译的函数执行速度与Delphi6在程序设计阶段静态编译后的函数执行速度
       相当,在有些情况下甚至快很多(注:测试时速度比一般在50%-180%之间,表达式简单的时候类TCompile
       的调用开销太大,影响了测试结果,但只从代码实际执行部分来看,TCompile比Delphi6编译的快很多!!!)。
           测试环境包括:Windows95、Win98、WindowsMe、Windows2000、WindowsXP。
           测试过的CPU包括：奔腾、赛扬A、奔腾3、赛扬2、奔腾4。
       }


       (*
       //2005.08.05

          *为了语言之间的移植性，修改计算时变量用的Extended类型，改为默认为double类型
                 (内部同时支持Single\Double\Extended)

       //2002.11.28-12.05

          *改进参数传递和调用  (但仍保持与以前兼容,以前使用的方法可以继续使用)
              // 调用函数返回表达式的值(实参数值列表);
              function  GetFunctionValue(const PList: array of TCmxFloat): TCmxFloat;
              // 设置需要编译的字符串(要编译的字符串,虚参数列表字符串); 比如：Value:='Sqr(x)+Sqr(y)'; ParameterList:='x,y' ;
              function  SetText(Const Value:string;const ParameterList : string=''):boolean;
              *增加函数 IfHaveUnDefineParameter():boolean;  // 测试是否使用了未定义的变量

          *增加强大的预处理宏  Define(const Key,Value : string):boolean
              可以用来处理常数定义,甚至定义新的函数!
              如 Key:='a'; Value:='-0.5*2' , 或 Key:='f(x,y)',Value:='Max(x,Sin(y))' 等;

              常数预处理  DefineConst(const Key,Value: string):boolean;
                处理常数定义(要代换的标识符,代换的值)  // 常数定义, Value必须是一个可计算的值
                如 Key:='a'; Value:='2' , 或 Key:='b' , Value:='2*sin(PI/2)' 等;
                该功能完全可以用预定义宏(Define)来代替，
                但当值为常数时这样处理有可能使最后得到的编译函数速度更快，并加快编译速度

          *共享外部变量支持
              设置一个外部变量函数， 这样就可以和Delphi或另一个TCompile共享变量了
              SetExteriorParameter(const PName:string;const PAddress:PTCmxFloat):boolean; //(编译前调用,如果是在编译后，需要调用RefreshExeAddressCodeInPointer刷新地址)


          *进行了消除堆栈调用的优化工作,代码速度进一步提升!
             即编译时跟踪到有这样的操作序列： "ST压入堆栈->变量或常数载入ST->弹出数据到ST->二元运算"
                                     优化为： "变量或常数载入ST->视情况交换ST与ST(1)->二元运算"

          各种优化现在可以通过属性关闭或打开; (默认为打开)
             EnabledOptimizeDiv   : Boolean; // 类的属性: 是否要优化常数浮点除法运算 (除以一个常数变为乘以一个常数)
             EnabledOptimizeStack : Boolean; // 类的属性: 是否要优化堆栈调用
             EnabledOptimizeConst : Boolean; // 类的属性: 是否要优化常数运算

          *增加GetUserParameterCount和GetUserParameterList两个函数,使之只返回变量的地址,而不再包含常数地址
             以前使用的是:GetParameterCount和GetParameterList两个函数
            (其实使用上面的传递参数列表调用方式更方便，这里只是为当参数很多而又每次只更新部分变量值的时候使用)

          *对常数除法进行了优化(除以一个常数变为乘以一个常数: x/Const => x*(1/Const)),因为除法运算太慢
             增加控制属性：EnabledOptimizeDiv :boolean;  //是否要优化常数浮点除法运算 默认True

          *增加版本管理

          *修正bug: 忘记处理 '>','<','=' 前后的空格


          *增加IF函数 格式为: If(s,r1,r2) 等价于高级语言的: If (s) Then Result:=r1 Else Result:=r2;

          *增加平方和函数SqrAdd;   SqrAdd(x,y)=x*x+y*y;

          *增加整数次方函数IntPower函数,  IntPower(x,N); N属于整数,且Abs(N)<2^31
          *增加优化指数函数,当次方数为常整数时如:x^0,X^1,X^2,X^N,分别进行优化

          改进Max、Min使速度加快;

         -------------------------------------------------------------------------
             某周一决定写一个表达式编译器 (具体日期忘了)。 程序第一版很快完成了,用
         了两天,是编译型,但采用的是函数调用方式实现,动态编译的代码只是函数调用的接
         口部分,速度比Delphi6慢5倍,但这还是比解释执行版本快了上千倍!后来将所有的函
         数调用消除,而采用动态生成全部函数体的方式,并封装成类,这时的程序速度接近于
         Delphi6，到此差不多用了6天(后面两天增加了定积分函数),代码量约为5千行左右。
             作者不是计算机专业出身的,所以这是作者第一次接触和使用汇编，当然也很少
         有机会接触编译原理方面的知识，所以只好 一边按照自己的设想构造一个一个的函
         数,一边查看大块头的讲述 CPU 指令集的汇编书籍，一边查看和跟踪 Delphi编译器
         生成的机器码(可以显示对应的汇编码,感谢Borland的强大编译器)，一边参看 VC和
         Delphi(感谢Borland的源码和开明)对这些函数的实现方式... 这一周是我大学生活
         中所经历的最紧张繁忙的一周，但也是最有趣的一周:)

                       ( 写于2002.11.29,怀念这一周  侯思松 )
         -------------------------------------------------------------------------

       *)

       (*
       //2002.11.5-11.8
         改进ArcCotH、ArcCscH、ArcSecH使速度加快,
           以前采用的是函数调用，现在采用化简的直接公式计算;
         改进ArcCot函数;

         改进编译后函数的调用方式(采用函数变量调用),
           这对于表达式较短时会加快速度，但对于表达式较长时会慢5%左右;

         改进系统内部使用的常量和系统函数的命名方式,使之更统一
           'Boolean??'        改为:  'TCmSYS_Boolean??'      ,
           'Const_SYS_*'      改为:  'TCmSYS_Const_*'        ,
           'Const_SYS_ff_x_*' 改为:  'TCmSYS_Const_ff_x_*'   ,
           'FF_SYS_*'         改为:  'TCmSYS_FF_*'           ;
           
       //2002.11.5-11.8
       *)

       (*
       //2002.8
          最近更新，列表如下：

          *增加了布尔运算; 引入逻辑运算符和比较运算符 (使用参见详细说明)
               逻辑常量 真     true =1
               逻辑常量 假     false =0
               逻辑运算 与     AND
               逻辑运算 或     OR
               逻辑运算 异或   XOR
               逻辑运算 非     NOT
               相等            =
               不等于          <>
               小于            <
               大于            >
               小于等于        <=
               大于等于        >=

          !标识符 PI 现在被当作系统常量 PI=3.1415926...
           标识符 e 系统给它的默认值为2.718281828...但程序可以重新赋值，与PI不同

          !现在给出一个运算符优先级表：
             由高到低
             ()             (包括各种函数)
             ^
             *  \  /  mod
             +  -
             =  <>  <  >  <=  >=
             AND、OR、XOR  (NOT 可以看作函数)

       //2002.8
       *)


       (*

       // Power(x,2) 优化错误
       // Power(x,0) 优化错误

       //2002.7-2002.8
          最近做了一些修改和除错工作,见下:

        <<更新列表>>:

          *做了一些优化,速度又加快了25%! 现在编译代码的执行效率更高(考虑了数据对齐)。

          *为了减少TCompile类运行时占用的内存空间,而采用了动态的内存空间申请方式,
           并且对能编译的文本长度几乎不再限制(只是受内存和编译时间等系统影响),
           作者曾经测试过上百K的表达式编译和运算:);

          *增加了错误号,以利于将错误描述翻译为其他语言(给出了两个翻译例子:中文繁体BIG5码的错误描述和英文版的错误描述);
          *现在允许在表达式中使用注释(TCopmile.EnabledNote:=true;默认为false),注释写法为:
              单行注释:  双斜杠// 开始到一行结束(即遇到回车换行符)
              长段注释:  '{'、'}' 或'/*'、'*/' 之间的部分

          !!!关键字中不允许插入空格等字符;
              以前版本 如 "Si n (P I/2)" 可以正常运行 等于"Sin(PI/2)", "d 45"被认为是"d45",现在不再允许!

          !!!为了避免混乱,参考数学手册重新对表达式中的数学函数名称和别名做了修订,使用过以前版本的请注意一下;

          *重新考虑了浮点状态标志中RC场的值对各种利用了取整运算的函数的影响

          !!!纠正错误:
              常数运算优化时对 求余函数'Mod'的优化错误   如错误: 10 mod 7=9 !  应该为: 10 mod 7=3
              原来代码:  ConstdValue:=T_PTrueOld.dValue-Trunc(T_PTrueOld.dValue/T_PTrueNow.dValue)
              改为:      ConstdValue:=T_PTrueOld.dValue-Trunc(T_PTrueOld.dValue/T_PTrueNow.dValue)*T_PTrueNow.dValue

          !!!纠正错误:
              常数运算优化时对 反正切2函数'ArcTan2'的优化错误
              原来代码:  ConstdValue:=math.ArcTan2(T_PTrueNow.dValue,T_PTrueOld.dValue)
              改为:      ConstdValue:=math.ArcTan2(T_PTrueOld.dValue,T_PTrueNow.dValue)

          !!!纠正错误:
              常数运算优化时对 取整函数'Int'的优化错误   如错误: Int(-1.5)=-1 ! 应该为: Int(-1.5)=-2  (RC场取整方式造成的)
              原来代码:  ConstdValue:=Trunc(T_PTrueNow.dValue)
              改为:      xTemp:=Trunc(T_PTrueNow.dValue);
                         if Frac(T_PTrueNow.dValue) <0 then
                           xTemp:=xTemp-1;
                         ConstdValue:=xTemp;

          !!!纠正错误:
              修正了编译子函数 整除函数TCompile.F_DivE();  错误: c:=-10; c\7=-2 ! 应该为: c\7=-1  (RC场取整方式造成的)
              (完全改写 具体修改略)

          *增加了表达式中对截断取整函数Trunc的支持, 可以写为:Trunc(x)   (向零取整)
          *增加了表达式中对截断取整函数Ceil的支持, 可以写为:Ceil(x)     (向正无穷大取整)
          *增加了表达式中四舍五入取整函数Round的支持, 可以写为:Round(x)   (四舍五入取整)
              注: Int(x)或Floor(x)函数值为不大于x的最大整数  (向负无穷大取整)

          *增加了表达式中对随机函数Random的支持, 可以写为:Random(x)、RND(x)、Rand(x)
              请使用"TCopmile.SetRandomize();"函数初始化随机函数

          *增加了表达式中对余切函数Cot的支持;
          *增加了表达式中对正割函数Sec的支持;
          *增加了表达式中对余割函数Csc的支持;
          *增加了表达式中对反余切函数ArcCot的支持;
          *增加了表达式中对反正割函数ArcSec的支持;
          *增加了表达式中对反余割函数ArcCsc的支持;

          *增加了表达式中对双曲余切函数CotH的支持;
          *增加了表达式中对双曲正割函数SecH的支持;
          *增加了表达式中对双曲余割函数CscH的支持;
          *增加了表达式中对反双曲余切函数ArcCotH的支持;
          *增加了表达式中对反双曲正割函数ArcSecH的支持;
          *增加了表达式中对反双曲余割函数ArcCscH的支持;

          *增加了表达式中对斜边函数Hypot的支持;
          *增加了表达式中对求倒数函数Rev的支持;

          次方运算现在可以写为:  x**y、x^y、Power(x,y)
          求余运算现在可以写为:  x%y 、x Mod y 、Mod(x,y)

       //2002.7-2002.8
       *)

       {
       //2002.5-2002.6

          完成框架
          
       //2002.5-2002.6
       }

       /////////////////////////////////////////////////////////////////////////
       /////////////////////////////////////////////////////////////////////////

       
       (*

       <<详细说明>>:

       0.支持数学函数表达式的编译执行;

       1.支持带参数编译,参数默认值为0;运行前请赋值;

       2.常数可以用科学计数法表示,如: -1.4E-4=-0.00014;
         系统定义的常量:  圆周率 PI=3.1415926535897932384626433832795...
                          逻辑真 true=1
                          逻辑假 false=0
         当标识符为e时，系统默认值为 自然数
           即 e=2.7182818284590452353602874713527...
           但它和PI,true,false不同，e可以重新赋值, pi,true,false是系统常量，e是用户变量



       3.使用多重括号并不会降低速度,特别是在不容易分清楚计算优先级的时候,请多使用括号;

       4.表达式中函数名和参数名等不区分大小写;关键字中不允许插入空格等字符;

       5.编译的文本长度几乎不受限制(只是受内存和编译时间等系统影响)

       6.利用错误号功能可以将错误描述翻译为其他语言(给出了两个翻译例子:中文繁体BIG5码的错误描述和英文版的错误描述);

       7.允许在表达式中使用注释(TCopmile.EnabledNote:=true;),注释写法为:
              单行注释:  双斜杠// 开始到一行结束(即遇到回车换行符)                                                      
              长段注释:  '{'、'}' 或'/*'、'*/' 之间的部分

       8.系统使用的标识符除去下面列出的函数名(包括别名)外还有 :
         'PI'、'true'、'false'、'TCmSYS_IF_?'、'TCmSYS_Boolean??'、'TCmSYS_Const_*' 、
         'TCmSYS_Const_ff_x_*'、'TCmSYS_DefineFPName_???'和 'TCmSYS_FF_*' 等,
         自定义的标识符名称请不要再次使用它们;  (即前缀不能为'TCmSYS_')

       9.支持的函数:

         这里的实数域为:  R' ,  R'约为 (-1.1E+4932,-3.6E-4951) and [ 0 ] and (+3.6E-4951,+1.1E+4932)
         当实数属于(+-3.6E-4951,0) 时认为实数等于0
         没有特别说明的变量取值范围为实数域 R'

       (函数计算的结果和中间结果也不能超出实数域 R')

       算符(函数)名称       书写格式和变量取值范围                       例子(说明)

       +        加法        x+y     或者: Add(x,y)                       3.5+5=8.5
       -        减法        x-y     或者: Sub(x,y)                       8-3=5
       *        乘法        x*y     或者: Mul(x,y)                       2*3=6
       /        除法        x/y     或者: Div(x,y)   ; y<>0              3/2=1.5
       \        整除        x\y     或者: DivE(x,y)  ; y<>0              25\10=2
       Mod      求余        x Mod y   或者: x%y、Mod(x,y) ; y<>0         14 Mod 5=4
       ^        指数        x^y     或者:  Power(x,y)、x**y              2^3=8
                            ; x<0时,y必须为整数
                            ; x=0时,y>0
       IntPower 整数次方    IntPower(x,N); N<2^31                        IntPower(5,3)=125

           ;比较运算产生的结果为逻辑值(真或假)，即结果只可能为1或0
       =        等于        x=y                                          (2=3-1) =true =1
       <>       不等于      x<>y                                         (2<>3-1) =false =0
       <        小于        x<y                                          (2<3) =true
       >        大于        x>y                                          (2>3) =false
       <=       小于等于    x<=y                                         (sin(a)<=1) =true
       >=       大于等于    x>=y                                         (3>=PI) =false

           ;逻辑运算中 0表示 假(false),非0会被当作 真(true)来参加逻辑运算
           ;用大写X,Y表示逻辑值或实数(注意必须写扩号)
       ADD      逻辑与      (X) ADD (Y)                                  (1>2) AND (true)=false
       OR       逻辑或      (X) OR (Y)                                   (false) OR (true)=true
       XOR      逻辑异或    (X) XOR (Y)                                  (true) XOR (true)=false
       NOT      逻辑非      NOT (X)                                      NOT (1)=false

       Max      最大值      Max(x,y)                                     Max(3,4)=4
       Min      最小值      Min(x,y)                                     Min(3,4)=3
       Sqr      平方        Sqr(x)                                       Sqr(3)=9  //注意平方和开方的函数名称
       Sqr3     立方        Sqr3(x)                                      Sqr3(3)=27
       Sqr4     四次方      Sqr4(x)                                      Sqr4(3)=81
       Sqrt     开方        Sqrt(x)    ; x>=0                            Sqrt(3)=1.73205080756888

       Exp      自然指数    Exp(x)                                       Exp(2)=e*e=e^2
       Ln       自然对数    Ln(x)                    ; x>0               Ln(e)=1
       Log2     2的对数     Log2(x)                  ; x>0               Log2(8)=3
       Log10    10的对数    Log10(x) 或者: Log(x)    ; x>0               Log(100)=2

       Abs      绝对值      Abs(x)                                       Abs(-2)=2 ; Abs(2)=2
       SqrAdd   平方和      SqrAdd(x,y)                                  sqrAdd(3,4)=25
       Rev      倒数        Rev(x)                                       Rev(5)=1/5=0.2
       Int      取整        Int(x)   或者: Floor(x)                      (不超过x的最大整数) Int(2.3)=2 ; Int(-2.3)=-3
       Trunc    截断取整    Trunc(x)                                     (向零取整) Trunc(2.3)=2 ; Trunc(-2.3)=-2
       Round    四舍五入    Round(x)                                     (四舍五入取整)  Round(2.51)=3 ; Round(2.49)=2
       Ceil     舍入取整    Ceil(x)                                      (向正穷大取整)  Ceil(-2.2)=-2 ; Ceil(2.8)=3
       Sgn      符号函数    Sgn(x)                                       Sgn(-2)=-1 ;  Sgn(0)=0 ; Sgn(2)=1
       Hypot    斜边        Hypot(x,y)                                   Hypot(x,y)=Sqrt(x*x+y*y)
       Random   随机函数    Random(x) 或者:RND(x)、Rand(x)               Random(2.5)=2.5*a ,其中a为随机数0<=a<1
               (要产生真正的随机数,而不是固定随机数序列,请在创建或编译完成后
                取得表达式值之前调用一次TCopmile.SetRandomize();函数。)

       Sin      正弦        Sin(x)                                       Sin(pi/6)=0.5
       Cos      余弦        Cos(x)                                       Cos(0)=1
       Tan      正切        Tan(x)   或者: tg(x)                         Tan(pi/4)=1
       ArcSin   反正弦      ArcSin(x)    ; -1<=x<=1                      ArcSin(1)=1.5707963267949=pi/2
       ArcCos   反余弦      ArcCos(x)    ; -1<=x<=1                      ArcCos(0)=1
       ArcTan   反正切      ArcTan(x) 或者:  Arctg(x)                    ArcTan(1)=0.785398163397448=pi/4
       ArcTan2  反正切2     ArcTan2(y,x) 或者:  Arctg2(y,x)              ArcTan2(2,1)=1.10714871779409
                            ;y为纵坐标、x为横坐标
       Cot      余切        Cot(x)    或者: Ctg(x)   ;x<>0               Cot(x)=1/Tan(x)
       Sec      正割        Sec(x)                                       Sec(x)=1/Cos(x)
       Csc      余割        Csc(x)                   ;x<>0               Csc(x)=1/Sin(x)
       ArcCot   反余切函数  ArcCot(x) 或者: ArcCtg(x)   ;x<>0            ArcCtg(x)=ArcTan(1/X)  //Delphi6 误为 ArcCtg(x)=Tan(1/X)  !
       ArcSec   反正割函数  ArcSec(x)              ;|x|>=1               ArcSec(x)=ArcCos(1/X)  //Delphi6 误为 ArcSec(x)=Cos(1/X)  !
       ArcCsc   反余割函数  ArcCsc(x)              ;|x|>=1               ArcCsc(x)=ArcSin(1/X)  //Delphi6 误为 ArcCsc(x)=Sin(1/X)  !

       SinH     双曲正弦    SinH(x)                                      SinH(2)=3.62686040784702=(e^2-e^(-2))/2
       CosH     双曲余弦    CosH(x)                                      CosH(2)=3.76219569108363=(e^2+e^(-2))/2
       TanH     双曲正切    TanH(x)  或者: tgH(x)                        TanH(2)=0.964027580075817=SinH(2)/CosH(2)
       ArcSinH  反双曲正弦  ArcSinH(x)                                   ArcSinH(3.62686040784702)=2
       ArcCosH  反双曲余弦  ArcCosH(x)         ; x>=1                    ArcCosH(3.76219569108363)=2
       ArcTanH  反双曲正切  ArcTanH(x)  或者: ArctgH(x)                  ArcTanH(0.761594155955765)=1
       CotH     双曲余切       CotH(x)  或者: CtgH(x)  ;x<>0             CotH(x)=1/TanH(x)
       SecH     双曲正割       SecH(x)                                   SecH(x)=1/CosH(x)
       CscH     双曲余割       CscH(x)       ;x<>0                       CscH(x)=1/SinH(x)
       ArcCotH  反双曲余切函数 ArcCotH(x) 或者: ArcCtgH(x)   ;x<>0       ArcCtgH(x)=ArcTanH(1/X)  //Delphi6 误为 ArcCotH(x)=1/ArcCot(X) !
       ArcSecH  反双曲正割函数 ArcSecH(x)      ;0<x<=1                   ArcSecH(x)=ArcCosH(1/X)  //Delphi6 误为 ArcSecH(x)=1/ArcSec(X) !
       ArcCscH  反双曲余割函数 ArcCscH(x)      ;x<>0                     ArcCscH(x)=ArcSinH(1/X)  //Delphi6 误为 ArcCscH(x)=1/ArcCsc(X) !
                                                                               //Delphi7 误为：ArcCscH(x)= Ln(Sqrt(1+(1/(X*X))+(1/X)));!!
       If       条件函数    If(s,r1,r2)                                  If(True,2,3)=2; If(0,2,3)=3;
                (等价于高级语言的: If (s) Then Result:=r1 Else Result:=r2;)

       ff       定积分函数  ff(a,b,x,g(x)) 或者: ff(a,b,x,N,g(x))        ff(-1,1,y,Sqrt(1-y*y))=pi/2

                ( ff函数特别说明:
                  函数g(x)是关于'x'的表达式(也可以不含有变量x),这里的自变量x与本函数ff以外的x没有关系;

                  ff函数表示 对函数 g(x) 从 a 积到 b 积分,
                             x表示以x为积分变量对函数g(x)积分, (或其他自变量名称标识符)
                             N (N>0) 表示 把积分区间分成 N 份来积 ,省略 N 时默认为 1000 ;

                  积分函数支持多重积分(较慢)
                  (注意: 多重积分和积分套嵌不是一个意思)

                  比如求单位球体的体积(R=1)
                  二重积分表达式为:
                  ff(-1,1,x,                          //x从-1到1积分
                     ff(-Sqrt(1-x*x),Sqrt(1-x*x),y,   //y从-Sqrt(1-x*x)到sqrt(1-x*x)积分
                        2*Sqrt(1-x*x-y*y)
                       )
                    )

                  =4.18883330446894
                  =4*Pi/3
                  =ff(-1,1,x,PI*(1-x*x))   // (求单位球体体积的一重积分表达式)
                )

       10. 运算符优先级表：
             由高到低
             ()             (包括各种函数)
             ^
             *  \  /  mod
             +  -
             =  <>  <  >  <=  >=
             AND、OR、XOR  (NOT 可以看作函数)

       11. 更强大的功能请参看类的接口函数

       *)

  {$A8}{$A+}
  //{$DEFINE FloatType_Single}
  //{$DEFINE FloatType_Double}
  {$DEFINE FloatType_Extended} //警告:编译器对extended数组的边界对齐有问题

  (* 编译器对extended数组的边界对齐有问题
     {$A8}{$A+}
     type T0 = record
         x,y : Extended;
       end;
     type T1 = record
         x : Extended;
         y : Extended;
       end;
     type T2 = array [0..1] of Extended;
     ///
     结果: sizeof(T0)==12;
           sizeof(T1)==16;
           sizeof(T2)==10;
  *)


  {$IFDEF FloatType_Extended}
    type TCmxFloat=Extended;   //扩展精度
  {$ENDIF}
  {$IFDEF FloatType_Double}
    type TCmxFloat=Double;     //双精度
  {$ENDIF}
  {$IFDEF FloatType_Single}
    type TCmxFloat=Single;     //单精度
  {$ENDIF}

  type _tmpCmxFloatArray = array [0..1] of TCmxFloat;
       PCmxFloatArray =^_tmpCmxFloatArray;
  const SYS_ArrayOneLength = sizeof(_tmpCmxFloatArray) div 2;

  type PTCmxFloat=^TCmxFloat;
  type _tmpTwoTCmxFloat=record
      x   : TCmxFloat;
      y   : TCmxFloat;
  end;
  const SYS_EFLength = sizeof(_tmpTwoTCmxFloat) div 2;

  {$if SYS_EFLength=16}
  {$define FloatType_Extended}
  {$ifend}
  {$if SYS_EFLength=8}
  {$define FloatType_Double}
  {$ifend}
  {$if SYS_EFLength=4}
  {$define FloatType_Single}
  {$ifend}

  type TFunctionList =record
    FName     :string;     //函数名称
    FAddress  :Pointer;    //函数地址入口
    FCCount   :0..2;       //函数所需参数个数
  end;

  type TParameterList =record
    CName     :String;     //参数名称
    CAddress  :PTCmxFloat;  //参数地址
    CIndex    :integer;    //参数地址序号 (在ExeParameter中的位置序号,系统使用)
    IsConst   :boolean;    //是否为常数;  false:变量 true:常数
    IsExterior:boolean;    //是否是外部变量 false:内部变量 true:外部变量
  end;
  const SizeofTParameterList=sizeof(TParameterList);

  type TUserParameterList =record   //用户使用 (系统用 TParameterList)
    CName     :String;     //参数名称
    CAddress  :PTCmxFloat;  //参数地址
  end;

  type TT_PTrue=record
    isConst   :boolean;    //编译优化常数时  参数性质  是否为常数
    dValue    :TCmxFloat;   //编译优化常数时  参数性质  值
  end;

  type TExeAddressPMList=record
    ExeIndex  :integer;     //插入ExeCode的当前位置序号
    PName     :string;       //参数名称
  end;



////////////////////////////////////////////////////////////////////////////////

const
  // 版本
  csTCompile_Version :double =1.44;  //2008.7 修正extended数组间隔的一个bug
    //csTCompile_Version :double =1.43;  //2002.11.28-12.03    改进函数设置和调用、优化常数除法、增加消除堆栈的优化方法、增加强大的预处理宏、共享外部变量支持
    // csTCompile_Version :double =1.31   //2002.11.5-11.8   小的改进、修改用户调用方式等
    // csTCompile_Version :double =1.30;  //2002.8           增加布尔运算和逻辑运算支持等
    // csTCompile_Version :double =1.20;  //2002.7-2002.8    改进、除错、增加允许注释功能、增加错误描述等
    // csTCompile_Version :double =1.10;  //2002.5-2002.6    改进、除错、对常数运算进行优化等
    // csTCompile_Version :double =1.00;  //2002.5           完成框架

type
  TCompile=class    // <<数学函数动态编译器TCompile类>>

  protected  {私有}

    FEnabledNote    :boolean;
    FEnabledOptimizeDiv :boolean;
    FEnabledOptimizeStack  :boolean;
    FEnabledOptimizeConst  :boolean;
    procedure SetEnabledNote(Value:boolean);  //是否允许使用注释 私有
    procedure SetEnabledOptimizeDiv(Value:boolean);  //是否要优化常数浮点除法运算 私有
    procedure SetEnabledOptimizeStack(Value:boolean);  //是否要优化堆栈 私有
    procedure SetEnabledOptimizeConst(Value:boolean);  //是否要优化常数运算 私有

  public
  
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
    //    <<对外可见成员 即 接口部分>>    //
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//

    //Enabled   :boolean;    // 是否有效

    // 调用函数返回表达式的值;
    GetValue:Function():TCmxFloat;     // (编译后才能调用)
    // 调用函数返回表达式的值(实参数值列表); //等价于 SetFunctionParameter + GetValue
    function  GetFunctionValue(const PList: array of TCmxFloat): TCmxFloat;  // (编译后才能调用)
    // 按当前设置的参数表传入参数值(实参数值列表)
    procedure SetFunctionParameter(const PList: array of TCmxFloat);  // (编译前后都能调用)

    // 设置需要编译的字符串(要编译的字符串,虚参数列表字符串,是否自动编译);
    //    比如：Value:='Sqr(x)+Sqr(y)'; ParameterList:='x,y' ;
    function  SetText(const Value:string;const ParameterList : string='';const IfCompile:boolean=true):boolean;//(编译前调用，这是最先要做的)
    // 编译当前字符串
    function  Compile():boolean;

    // 处理预定义宏(要代换的标识符,代换为的描述字符串); // 可以用来处理常数,甚至定义新的函数!
    //   如 Key:='a'; Value:='-0.5' , 或 Key:='f(x,y)',Value:='Max(x,Sin(y))' 等;
    function  Define(const Key,Value : string):boolean; //(编译前调用)

    // 处理常数定义(要代换的标识符,代换的值)  // 常数定义, Value必须是一个可计算的值
    //   如 Key:='a'; Value:='2' , 或 Key:='b' , Value:='2*sin(PI/2)' 等;
    //   该功能完全可以用预定义宏(Define)来代替，
    //   但当值为常数时这样处理有可能使最后得到的编译函数速度更快，并加快编译速度
    function  DefineConst(const Key,Value: string):boolean; //(编译前调用)

    // 测试是否使用了未定义的变量
    function  IfHaveUnDefineParameter():boolean;  //(编译后才能调用)

    //获得当前要编译的字符串
    function  GetText():string;   //随时都可以调用，该值会随着其他函数的调用而产生变化

    // 获得版本号
    class Function GetVersion():double;

    // 类的属性: 是否允许使用注释
    property  EnabledNote: Boolean read FEnabledNote write SetEnabledNote default true; //(编译前调用)
    // 类的属性: 是否要优化常数浮点除法运算 (除以一个常数变为乘以一个常数)
    property  EnabledOptimizeDiv: Boolean read FEnabledOptimizeDiv write SetEnabledOptimizeDiv default true;//(编译前调用)
    // 类的属性: 是否要优化堆栈调用
    property  EnabledOptimizeStack: Boolean read FEnabledOptimizeStack write SetEnabledOptimizeStack default true; //(编译前调用)
    // 类的属性: 是否要优化常数运算
    property  EnabledOptimizeConst: Boolean read FEnabledOptimizeConst write SetEnabledOptimizeConst default true; //(编译前调用)


    //设置一个外部变量(外部变量名称，外部变量地址); 这样就可以和Delphi或另一个TCompile共享变量了
    function  SetExteriorParameter(const PName:string;const PAddress:PTCmxFloat):boolean;overload;
              //(编译前调用,如果是在编译后，需要调用RefreshExeAddressCodeInPointer刷新地址)
      // 设置外部数组(数组名称,数组地址);
      function  SetExteriorArrayParameter(const ArrayPName:string;const ArrayPAddress:PTCmxFloat):boolean;
      function  SetExteriorParameter(const PNameList:array of string;const PAddressList:array of PTCmxFloat):boolean;overload;
      procedure RefreshExeAddressCodeInPointer();  //刷新变更地址  //(设置完所有的外部变量以后需要调用一次该函数)

    //根据参数名称PName得到参数地址值
    function  GetParameterAddress(const PName:string):PTCmxFloat;
    //按参数名称PName设置参数值dValue
    function  SetParameter(const PName:string;const dValue:TCmxFloat):boolean;overload;
    //按参数地址PAddress设置参数值dValue
    procedure SetParameter(const PAddress:PTCmxFloat;const dValue:TCmxFloat);overload;
    //得到参数PName的值
    function  GetParameterValue(const PName:string):TCmxFloat;
    //得到参数的总数目(不包括常数)
    Function  GetUserParameterCount():integer;
    //返回用户设置的参数的数目
    Function  GetFunctionPlistCount():integer;   //封装VB使用的API函数时用到 2003.3.29加入
    //通过PList返回参数列表(不包括常数)
    procedure GetUserParameterList(var PList:array of TUserParameterList);
    //得到参数的总数目(包括常数)
    Function  GetParameterCount():integer;
    //通过PList返回参数列表(包括常数)
    procedure GetParameterList(var PList:array of TParameterList);
    //测试参数PName是否已经存在
    function  IfHaveParameter(const PName:string):boolean;overload;
    //测试常数dValue是否已经存在 并通过cName返回常数名称
    function  IfHaveParameter(const dValue:TCmxFloat;var cName:string):boolean;overload;

    //返回错误描述
    function  GetError():string;
    //返回错误代码号
    function  GetErrorCode():integer;
    //返回错误描述(中文简体) 要更改错误描述或翻译为其他语言时请改写此函数
    function  GetErrorGB(const xErrorCode{错误代码号}:integer):string;overload;
    //返回错误描述(中文繁体) 这是给的例子
    function  GetErrorBIG5(const xErrorCode:integer):string;overload;
    //返回错误描述(英文) 这是给的例子,英语水平有限,希望有大虾更正:)
    function  GetErrorEnglish(const xErrorCode:integer):string;overload;
    //返回编译以后的程序指令区代码长度(字节)
    Function  GetExeCodeLength():integer;
    //返回编译以后的程序数据区代码长度(字节)
    Function  GetExeParameterLength():integer;

    
    //设置随机函数Rnd()的初始种子值为完全随机种子(系统用当前精确到毫秒的时间设置)
    procedure SetRandomize();overload;
    //设置随机函数Random()的初始种子值
    procedure SetRandomize(const RandomSeed :integer);overload;
     
  public
    //定义用户自由使用的未定义属性,用户可以用来储存自己的数据
    //类本身并不会使用
    Tag         : integer;
    Tag_F       : TCmxFloat;
    Tag_P       : Pointer;

  protected

    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
    //         << 私有 部分 >>            //
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//

    FExeText        :string;      //表达式
    ErrorCode       :integer;     //错误描述代码

    RndSeed         :array [0..1] of integer;  //随机函数种子值

    FunctionList    :array [0..128-1] of TFunctionList;     //函数列表,已经有60多个函数了(包括别名)
    PFunctionList   :integer;                               //当前函数信息插入函数列表位置

    FunctionStack   :array  of string;         //函数符号调用堆栈
    PFunctionStack  :integer;                  //函数符号调用堆栈 当前插入位置

    ExeAddressCode  :array of byte; //编译以后的执行码
    PExeAddressCode :integer;       //当前插入机器指令位置

    ExeAddressList  :array of integer;  //记录指针位置列表(因为积分函数用到)
    PExeAddressList :integer;           //当前插入位置

    ExeAddressPMList  :array of TExeAddressPMList;  //记录指针位置列表(因为参数存储地址用到)
    PExeAddressPMList :integer;           //当前插入位置

    ExeAddressTempData  :array [0..16*1024-1] of byte; //临时数据交换地址
    ExeAddressStack     :array [0..16*1024-1] of byte; //数据堆栈地址

    ParameterList     :array  of TParameterList;   //参数列表
    PParameterList    :integer; //保存参数列表当前插入位置

    ExeParameter      :array  of byte; //编译后 参数储存空间
    PExeParameter     :integer; //编译后 参数地址 ,当前分配参数位置
                                //PExeParameterList:=@ExeParameter[PExeParameter]

    TF00            :string;    // 比较符号优先级时 Tf00 用来保存上一次的符号

    T_SYS_FF_ConstN :integer;   //积分变量 序号

    T_PTrueNow      :TT_PTrue;  //编译优化常数时  当前参数性质
    T_PTrueOld      :TT_PTrue;  //编译优化常数时  上一个参数性质
    T_PTrueNowList  :array  of TT_PTrue; //编译优化常数时  参数性质堆栈
    PT_PTrueNowList :integer;            //当前参数性质堆栈插入位置

    CompileInPFirst :integer;   //第几次调用CompileInP()

    FFunctionPlistCount : integer; // 生成函数的参数个数;
    FFunctionPListIsSet : boolean; // 是否设置了参数列表;


    {私有函数}
    procedure Clear();
    function  Parsing(var str:string):boolean;//第一遍语法翻译
    function  CheckBK(const str:string):boolean;//括号配对检查
    procedure CompileInP(const PName:string); //编译 参数堆栈插入参数
    procedure CompileInPReNew(const dValue:TCmxFloat;const Pm:integer); //编译 参数堆栈插入参数 (替换)
    procedure CompileOutP(); //编译 弹出参数
    procedure CompileInF(const FName:string); //编译 函数调用
    function  GetSign(var str:string):string; //返回 str 的第一个算数符
    function  CompareSign(const FName1 : string;const FName2 :string): integer; //比较符号的优先级
    procedure CheckWording(const T1 : string;const T2 : string) ;// 按照先后关系检查语法错误

    // 设置参数调用格式(虚参数列表字符串); 比如：ParameterList='x,y' ;
    function  SetFunctionCallFormart(const ParameterList : string):boolean;

    procedure ExeAddressCodeIn(const B:Byte);  overload;      //编译插入CPU指令
    procedure ExeAddressCodeIn(const B:array of Byte); overload;
    procedure ExeAddressCodeIn(const sB:string);  overload;
    procedure GetExeAddressCodeInPointerRePm(const PName:string);  //记录编译指令中插入的参数名称,变更地址时以便更新
    Function  GetExeAddressCodeInPointerReCode():Pointer; //记录编译指令中插入的执行偏移地址,变更地址时以便更新
    function  OptimizeStackCall(const IfFxch:boolean=true):boolean; // 优化堆栈调用

    procedure FunctionListIn(const s:string;const F:Pointer;const iCount:integer);//把支持的函数插入函数列表
    procedure GetFunctionList();                                 //获得函数列表
    Function  GetFunctionIndex(const fName:string):integer;      //获得指定名称函数的序号
    function  IfHaveFunction (const fName:string):boolean;       //判断指定名称函数是否已经在函数列表中

    procedure FunctionStackIn(const s:string);    //
    Function  FunctionStackOut():string;          //管理  函数符号调用堆栈
    Function  FunctionStackRead():string;         //

    function  ParameterListIn(const PName:string):integer;overload;  //将参数插入参数堆栈  返回序号
    function  GetParameterListConstIndex(const PName:string):integer;
    function  ParameterListIn(const dValue:TCmxFloat):string;overload; //将常数插入参数堆栈 并返回由系统定义的别名
    function  GetParameterIndex(const PName:string):integer;       //得到指定名称参数在ParameterList[]中的序号

    procedure T_PTrueNowListIN(const TP:TT_PTrue);  //管理   (编译优化常数时) 参数性质堆栈
    function  T_PTrueNowListOut():TT_PTrue;         //

    //传入参数str,通过s返回
    function  Dbxch(var s:string;var str:string):boolean; // 书写格式转换函数  f(x,y) => ((x)f(y))
    function  DbxchSYS_ff(var s:string;var str:string):boolean; // 书写格式转换函数 ff(a,b,x,N,g(x)) => ( (a) TCmSYS_FF_0 (b) TCmSYS_FF_1 (N) TCmSYS_FF_2 ( g(x) ) )

    function  DbxchSYS_FunctionIf(var s:string;var str:string):boolean; // 书写格式转换函数  If(a,b,c) =>TCmSYS_IF_1(TCmSYS_IF_0(b,c),a)

    function  DefineMarker(var Text:string;const Key,Value : string):boolean;  // 替换标识符 将Text 中 Key=>Value

    procedure DelStrNote(var str:string); // 去掉str注释部分



    function  ifSYS_ff(const fName:string):boolean;  // fName 中是否有 积分函数
    function  getSYS_ff(const fName:string):string;  // 返回积分函数名称

    {编译 函数}
    //约定:  单元函数 通过 st 传参数值 ,通过 st 返回结果值
    //       双元函数 通过 st 传第一参数值,通过 [ecx] 传第二个参数 ,通过 st 返回结果值
    //       函数可以 通过 [edx] 及以后的临时数据交换区来保存、修改或读取数据
    //       函数可以随意使用EAX

    //数学运算
    Procedure F_Add();
    Procedure F_Sub();
    Procedure F_Mul();
    Procedure F_Div();
    Procedure F_DivE();
    Procedure F_Mod();
    Procedure F_Power();
    Procedure F_IntPower();
    Procedure F_Max();
    Procedure F_Min();
    Procedure F_Bracket(); { ()函数 }
    Procedure F_Rev();
    Procedure F_Sqr();
    Procedure F_Sqr3();
    Procedure F_Sqr4();
    Procedure F_Sqrt();
    Procedure F_Sin();
    Procedure F_Cos();
    Procedure F_Tan();
    Procedure F_ArcSin();
    Procedure F_ArcCos();
    Procedure F_ArcTan();
    Procedure F_ArcTan2();
    Procedure F_Ln();
    Procedure F_Log();
    Procedure F_Log2();
    Procedure F_Abs();
    Procedure F_SqrAdd();
    Procedure F_Floor();
    Procedure F_Trunc();
    Procedure F_Round();
    Procedure F_Ceil();
    Procedure F_Sgn();
    Procedure F_exp();
    Procedure F_SinH();
    Procedure F_CosH();
    Procedure F_TanH();
    Procedure F_ArcSinH();
    Procedure F_ArcCosH();
    Procedure F_ArcTanH();
    procedure F_Rnd();
    procedure F_Ctg();
    procedure F_Sec();
    procedure F_Csc();
    procedure F_CscH();
    procedure F_SecH();
    procedure F_CtgH();
    procedure F_ArcCsc();
    procedure F_ArcSec();
    procedure F_ArcCtg();
    procedure F_ArcCscH();
    procedure F_ArcSecH();
    procedure F_ArcCtgH();
    procedure F_Hypot();


    procedure F_SYS_IF_0();   //IF函数0
    procedure F_SYS_IF_1();   //IF函数1

    procedure F_SYS_FF_0(const N:integer); //积分函数0
    procedure F_SYS_FF_1(const N:integer); //积分函数1
    procedure F_SYS_FF_2(const N:integer); //积分函数2

    procedure F_SYS_Fld_Value();//代码中载入值   相当于mov  st,[st]
    procedure F_SYS_Fstp_Value();//代码中传出值  相当于mov  [st],st(1)

    //布尔运算
    //True;  //常量 true 真=1
    //False; //常量 false 假=0
    procedure FB_AND();   //逻辑 与
    procedure FB_OR();    //逻辑 或
    procedure FB_XOR();   //逻辑 异或
    procedure FB_NOT();   //逻辑 非
    //关系运算(返回布尔值)
    procedure FB_EQ();    //相等
    procedure FB_NE();    //不等于
    procedure FB_LT();    //小于
    procedure FB_GT();    //大于
    procedure FB_LE();    //小于等于
    procedure FB_GE();    //大于等于



    Procedure FF_Fld_X(const x:TCmxFloat); //载入x

    {有限状态自动机}

    //得到参数(常数)列表、函数转换
    function  Conversion0(var s:string;var str:string):boolean;

    // 得到字符串中标识符的位置(源字符串,标识符,起始位置);
    function  GetMarkerPos(const str:string;const key:string;const ifirst:integer):integer;
    // myPos=pos
    function  myPos(const str:string;const key:string;const ifirst:integer):integer;

    //含'@'、'&'取出标识符(源字符串，开始位置，返回结束位置)；失败返回0; Marker:=Copy(Str,iFirst,iEnd-iFirst+1);
    procedure GetMarker(const Str:string;const iFirst:integer;var iEnd:integer);

    //取出标识符的有限状态自动机(源字符串，开始位置，返回结束位置)；失败返回0; Marker:=Copy(Str,iFirst,iEnd-iFirst+1);
    procedure GetMarkerValue0(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetMarkerValue1(const Str:string;const iFirst:integer;var iEnd:integer);

    //取出常数的有限状态自动机(源字符串，开始位置，返回结束位置)；失败返回0; FloatValue:=strtofloat(Copy(Str,iFirst,iEnd-iFirst+1));
    procedure GetFloatValue0(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue1(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue2(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue3(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue4(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue5(const Str:string;const iFirst:integer;var iEnd:integer);
    procedure GetFloatValue6(const Str:string;const iFirst:integer;var iEnd:integer);

    

  public
    { Public declarations }
    constructor Create();
    destructor  Destroy();Override;
  end;

  {$IFDEF MSWINDOWS}

  TSystemTime = record
          wYear   : Word;
          wMonth  : Word;
          wDayOfWeek  : Word;
          wDay    : Word;
          wHour   : Word;
          wMinute : Word;
          wSecond : Word;
          wMilliSeconds: Word;
          reserved    : array [0..7] of char;
  end;
  function exFloatToStr(const value:extended):String;
  procedure GetSystemTime(var lpSystemTime: TSystemTime); stdcall;
  {$EXTERNALSYM GetSystemTime}

  {$ENDIF}


  //错误号定义
  const
        csTCompile_NoError              = 0;    //没有发现错误!
        csTCompile_NoKnownError         = 1;    //不知道的错误!
        csTCompile_NoErrorCode          = 2;    //找不到错误号所对应的错误描述!
        csTCompile_CompileHexCodeError  = 3;    //编译时指令的十六进制代码错误!
        csTCompile_HexMod2_EQ_1_Error   = 4;    //编译时传入指令长度错误!
        csTCompile_PMMarker_Error       = 5;    //编译得到参数名称时发生错误!
        csTCompile_FMMarker_Error       = 6;    //编译得到函数名称时发生错误!
        csTCompile_Wording_Error        = 7;    //语法发生错误!
        csTCompile_Bracket_Error        = 8;    //语法错误,在 ( ) 处!
        csTCompile_Optimize_Error       = 9;    //编译优化时发生错误!
        csTCompile_Define_Error         =10;    //函数编译错误(或超出定义域)!
        csTCompile_Handwriting_Error    =11;    //函数书写格式错误!
        csTCompile_FFHandwriting_Error  =12;    //积分函数书写格式错误!
        csTCompile_ReadFloat_Error      =13;    //编译读取常数数字时发生错误!
        csTCompile_ReadMarker_Error     =14;    //编译读取标识符时发生错误!
        csTCompile_Read_Error           =15;    //语法错误,有不识别的字符!
        csTCompile_Note_Match_Error     =16;    //注释符号不匹配!  { } 或 /*  */
        csTCompile_FPList_Error         =17;    //参数列表错误!
        csTCompile_IFHandwriting_Error  =18;    //If函数书写格式错误!


implementation

  const
    MaxTanhDomain :TCmxFloat = 5678.22249441322; // Ln(MaxExtended)/2
    two2neg32: TCmxFloat = 1.0/4294967295;  // 1/(2^32-1)
    MaxInt:TCmxFloat=2147483647.0;
    Infinity:TCmxFloat=1.0/0.0;

function  TCompile.GetError():string;
begin
  result:=GetErrorGB(ErrorCode);
end;

function  TCompile.GetErrorGB(const xErrorCode:integer):string;     //返回错误描述
begin
  case xErrorCode of
    csTCompile_NoError              :result:='';//没有发现错误!
    csTCompile_NoKnownError         :result:='不知道的错误!';
    csTCompile_NoErrorCode          :result:='找不到错误号所对应的错误描述!';
    csTCompile_CompileHexCodeError  :result:='编译时指令的十六进制代码错误!';
    csTCompile_HexMod2_EQ_1_Error   :result:='编译时传入指令长度错误!';
    csTCompile_PMMarker_Error       :result:='编译得到参数名称时发生错误!';
    csTCompile_FMMarker_Error       :result:='编译得到函数名称时发生错误!';
    csTCompile_Wording_Error        :result:='语法发生错误!';
    csTCompile_Bracket_Error        :result:='语法错误,在 ( ) 处!';
    csTCompile_Optimize_Error       :result:='编译优化时发生错误!';
    csTCompile_Define_Error         :result:='函数编译错误(或超出定义域)!';
    csTCompile_Handwriting_Error    :result:='函数书写格式错误!';
    csTCompile_FFHandwriting_Error  :result:='积分函数书写格式错误!';
    csTCompile_ReadFloat_Error      :result:='编译读取常数数字时发生错误!';
    csTCompile_ReadMarker_Error     :result:='编译读取标识符时发生错误!';
    csTCompile_Read_Error           :result:='语法错误,有不识别的字符!';
    csTCompile_Note_Match_Error     :result:='注释符号不匹配!  { } 或 /*  */';
    csTCompile_FPList_Error         :result:='参数列表错误!';
    csTCompile_IfHandwriting_Error  :result:='If函数书写格式错误!';
  else result:=GetErrorGB(csTCompile_NoErrorCode);
  end;
end;

function  TCompile.GetErrorBIG5(const xErrorCode:integer):string;     //返回错误描述
begin
  //注意:以下使用的是中文繁体BIG5码,要使用内码转换器才能察看
  case xErrorCode of
    csTCompile_NoError              :result:='';//⊿Τ祇瞷岿粇!
    csTCompile_NoKnownError         :result:='ぃ笵岿粇!';
    csTCompile_NoErrorCode          :result:='тぃ岿粇腹┮癸莱岿粇磞瓃!';
    csTCompile_CompileHexCodeError  :result:='絪亩せ秈絏岿粇!';
    csTCompile_HexMod2_EQ_1_Error   :result:='絪亩肚岿粇!';
    csTCompile_PMMarker_Error       :result:='絪亩眔把计嘿祇ネ岿粇!';
    csTCompile_FMMarker_Error       :result:='絪亩眔ㄧ计嘿祇ネ岿粇!';
    csTCompile_Wording_Error        :result:='粂猭祇ネ岿粇!';
    csTCompile_Bracket_Error        :result:='粂猭岿粇, ( ) 矪!';
    csTCompile_Optimize_Error       :result:='絪亩涩て祇ネ岿粇!';
    csTCompile_Define_Error         :result:='ㄧ计絪亩岿粇(┪禬﹚竡办)!';
    csTCompile_Handwriting_Error    :result:='ㄧ计糶Α岿粇!';
    csTCompile_FFHandwriting_Error  :result:='縩だㄧ计糶Α岿粇!';
    csTCompile_ReadFloat_Error      :result:='絪亩弄盽计计祇ネ岿粇!';
    csTCompile_ReadMarker_Error     :result:='絪亩弄夹醚才祇ネ岿粇!';
    csTCompile_Read_Error           :result:='粂猭岿粇,Τぃ醚才!';
    csTCompile_Note_Match_Error     :result:='猔睦才腹ぃで皌!  { } ┪ /*  */';
    csTCompile_FPList_Error         :result:='把计岿粇!';
    csTCompile_IfHandwriting_Error  :result:='Ifㄧ计糶Α岿粇!';
  else result:=GetErrorBIG5(csTCompile_NoErrorCode);
  end;
end;

function  TCompile.GetErrorEnglish(const xErrorCode:integer):string;     //返回错误描述
begin
  //注意:作者是使用工具软件翻译的,希望能有大虾更正:)
  case xErrorCode of
    csTCompile_NoError              :result:='';//Not found error!
    csTCompile_NoKnownError         :result:='Not knowing error.';
    csTCompile_NoErrorCode          :result:='Can not find the error code opposite describe.';
    csTCompile_CompileHexCodeError  :result:='The CPU instruction''s HEX code error, when compile the text.';
    csTCompile_HexMod2_EQ_1_Error   :result:='Stream into the instruction length is error, when compile the text.';
    csTCompile_PMMarker_Error       :result:='Find a error when do compile to get the parameters''s name.';
    csTCompile_FMMarker_Error       :result:='Find a error when do compile to get the functions''s name.';
    csTCompile_Wording_Error        :result:='Wording error!';
    csTCompile_Bracket_Error        :result:='Wording error for the "( )" .';
    csTCompile_Optimize_Error       :result:='Find a error when do the compile optimize.';
    csTCompile_Define_Error         :result:='Get the error when compile then function, or overstep the define extent.';
    csTCompile_Handwriting_Error    :result:='The Function''s writeing format error.';
    csTCompile_FFHandwriting_Error  :result:='The integral function''s writeing format error.';
    csTCompile_ReadFloat_Error      :result:='Find a error when do compile to get the constant''s character.';
    csTCompile_ReadMarker_Error     :result:='Find a error when do compile to get the marking''s character.';
    csTCompile_Read_Error           :result:='Wording error,have characters did not define.';
    csTCompile_Note_Match_Error     :result:='Note match error!  { } or /*  */';
    csTCompile_FPList_Error         :result:='Function parameter List Error.';
    csTCompile_IfHandwriting_Error  :result:='The ''If'' function''s writeing format error.';
  else result:=GetErrorEnglish(csTCompile_NoErrorCode);
  end;
end;

function  TCompile.GetErrorCode():integer;
begin
  result:=ErrorCode;
end;

constructor TCompile.Create();
begin
  inherited Create();
  //Enabled:=true;
  FEnabledNote:=true;
  FEnabledOptimizeDiv:=true;
  FEnabledOptimizeStack:=true;
  EnabledOptimizeConst:=true;
  GetFunctionList();
  RndSeed[0]:=0;//随机函数初始种子值
  RndSeed[1]:=0; //保证 @RndSeed[0] 以后的4字节单元恒为零 使指令 FILD  qword ptr [E?X] 能按要求执行
end;

destructor TCompile.Destroy;
begin
  inherited Destroy;
end;

function  TCompile.SetText(const Value:string;const ParameterList : string='';const IfCompile:boolean=true):boolean;
  function IsEmpty(const Value:string):boolean;
  var
    i : integer;
  begin
    for i:=1 to length(Value) do
    begin
      if not (Value[i] in [#0,#13,#10,' ',' ','#']) then
      begin
        result:=false;
        exit;
      end;
    end;
    result:=true;
  end;
var
  i : integer;
begin
  //if not Enabled then
 // begin
 //   result:=true;
 //   exit;
 // end;
  try
    //application.MessageBox(pchar(inttostr(length(value))),'!');
    result:=false;
    Clear();
    if not SetFunctionCallFormart(ParameterList) then
    begin
      self.ErrorCode:=0;
      exit;
    end;

    if not IsEmpty(Value) then
    begin
      FExeText:=Value;
      for i:=1 to length(FExeText) do
      begin
        if (FExeText[i]='[') then
          FExeText[i]:='('
        else if (FExeText[i]=']') then
          FExeText[i]:=')';
      end;
    end
    else
      FExeText:='0.0';
    if IfCompile then
    begin
      if not Compile() then exit;
    end;
    result:=true;
  except
    result:=false;
  end;
end;

function  TCompile.GetText():string; //获得当前编译的字符串
begin
  result:=FExeText;
end;


class function TCompile.GetVersion: double;
begin
  result:=csTCompile_Version;
end;

procedure  TCompile.SetFunctionParameter(const PList: array of TCmxFloat); register;assembler
asm

    push    edi

        mov     edi,[eax+ParameterList]
        mov     ecx,[eax+FFunctionPlistCount]
        lea     eax,[edi+TParameterList.CAddress]
        test    ecx,ecx
        jz      @Endfor
      @StartFor:

        {$ifdef FloatType_Extended}
        fld  tbyte ptr  [edx]
        {$else}
          {$ifdef FloatType_Single}
          fld  dword ptr  [edx]
          {$else}
          fld  qword ptr  [edx]
          {$endif}
        {$endif}

        mov     edi,[eax]
        add     edx,SYS_ArrayOneLength //  PList++
        {$ifdef FloatType_Extended}
        fstp tbyte  [edi]
        {$else}
          {$ifdef FloatType_Single}
          fstp dword  [edi]
          {$else}
          fstp qword  [edi]
          {$endif}
        {$endif}
        add     eax,SizeofTParameterList

        dec     ecx
        jnz     @StartFor
      @endFor:

    pop   edi
//}
end;

function TCompile.GetFunctionValue(const PList: array of TCmxFloat): TCmxFloat; register;assembler
{
var
  i  : integer;
begin
  for i:=0 to FFunctionPlistCount-1 do
  begin
    self.ParameterList[i].CAddress^:=PList[i];
  end;
  result:=self.GetValue();
  //}

asm
//  eax   Self
//  edx   PList

    push    eax
    push    edi

        mov     edi,[eax+ParameterList]
        mov     ecx,[eax+FFunctionPlistCount]
        lea     eax,[edi+TParameterList.CAddress]
        test    ecx,ecx
        jz      @Endfor
      @StartFor:

        {$ifdef FloatType_Extended}
        fld  tbyte ptr  [edx]
        {$else}
          {$ifdef FloatType_Single}
          fld  dword ptr  [edx]
          {$else}
          fld  qword ptr  [edx]
          {$endif}
        {$endif}

        mov     edi,[eax]
        add     edx,SYS_ArrayOneLength //  PList++
        {$ifdef FloatType_Extended}
        fstp tbyte  [edi]
        {$else}
          {$ifdef FloatType_Single}
          fstp dword  [edi]
          {$else}
          fstp qword  [edi]
          {$endif}
        {$endif}
        add     eax,SizeofTParameterList

        dec     ecx
        jnz     @StartFor
      @endFor:

    pop   edi
    pop   eax

    call dword ptr  [eax+GetValue]

//}
end;
//*)

function TCompile.SetFunctionCallFormart( const ParameterList: string): boolean;
var
  P,iEnd: integer;
  L     : integer;
  Str   : string;
  PName : string;
  sign  : integer;
begin
    L:=0;
    P:=0;
    sign:=0;  // 状态机初始状态
    while true do
    begin
      case  sign of
        -1: begin   // 出错退出状态
              FFunctionPlistIsSet:=false;
              FFunctionPlistCount:=0;
              result:=false;
              PParameterList:=0; //参数堆栈清空
              exit;
            end;
        10: begin   // 成功退出状态
              FFunctionPlistIsSet:=true;
              result:=true;
              exit;
            end;
        0 : begin   // 初始状态
              str:=uppercase(ParameterList);
              L:=length(ParameterList);
              FFunctionPlistCount:=0;
              P:=0;
              PParameterList:=0;
              if L=0 then
              begin
                sign:=10;
              end
              else
              begin
                sign:=1;
                P:=1;
              end;
            end;
        1:  begin   // 刚开始取名称前或取道','后 的状态
              if P=L+1 then
                sign:=10
              else if str[p] in [' ',#13,#10,#9] then
              begin
                sign:=1;
                inc(P);
              end
              else if (str[p] in ['A'..'Z','_']) then
              begin
                sign:=2;
              end
              else
              begin
                sign:=-1;
              end;
            end;
        2:  begin  //取参数名称状态
              self.GetMarkerValue0(str,P,iEnd);
              if iEnd=0 then
                sign:=-1
              else
              begin
                inc(FFunctionPlistCount);
                PName:=copy(str,P,iEnd-P+1);
                self.ParameterListIn(PName);
                p:=iEnd+1;
                sign:=3;
              end;
            end;
        3:  begin  //取完参数名称后状态
              if P=L+1 then
                sign:=10
              else if str[p] in [' ',#13,#10,#9] then
              begin
                sign:=3;
                inc(P);
              end
              else if str[p]=',' then
              begin
                sign:=1;
                inc(P);
              end;
            end;
      end;//case
    end;  //while

end;


function  TCompile.SetParameter(const PName:string;const dValue:TCmxFloat):boolean;
var
  i     :integer;
  sKey  :string;
begin
  //if not Enabled then
  //begin
  //  result:=true;
 //   exit;
  //end;
  try
    result:=false;
    sKey:=uppercase(PName);
    if sKey[1]<>'&' then sKey:='&'+sKey;
    for i:=0 to PParameterList-1 do
    begin
      if uppercase(ParameterList[i].CName)=sKey then
      begin
         ParameterList[i].CAddress^:=dValue;
         result:=true;
         exit;
      end;
    end;
  except
    result:=false;
  end;
end;

function  TCompile.SetExteriorArrayParameter(const ArrayPName:string;const ArrayPAddress:PTCmxFloat):boolean;
var
  Add :string;
begin
  try
    Add:='TCmSYS_ArrayAddress_'+ArrayPName;
    //todo:Test it!!!
    //result:=self.Define(ArrayPName+'(Index)','TCmSYS_Fld_Value(Round(Index)*'+inttoHex(SYS_ArrayOneLength,2)+'+'+Add+')');
    result:=self.Define(ArrayPName+'(Index)','TCmSYS_Fld_Value( (Index)*'+inttoStr(SYS_ArrayOneLength)+'+'+Add+')');
    if not result then exit;
    result:=self.DefineConst(Add,inttostr(Cardinal(ArrayPAddress)));
  except
    result:=false;
  end;
end;



function  TCompile.SetExteriorParameter(const PNameList:array of string;const PAddressList:array of PTCmxFloat):boolean;
var
  i  : integer;
begin
  try
    for i:=low(PNameList) to high(PNameList) do
    begin
      if not SetExteriorParameter(PNameList[i],PAddressList[i]) then
      begin
        result:=false;
        exit;
      end;
    end;
    result:=true;
  except
    result:=false;
  end;
end;


function  TCompile.SetExteriorParameter(const PName:string;const PAddress:PTCmxFloat):boolean;
var
  i     :integer;
  sKey  :string;
begin
  try
    sKey:=uppercase(PName);
    if sKey[1]<>'&' then sKey:='&'+sKey;
    for i:=0 to PParameterList-1 do
    begin
      if uppercase(ParameterList[i].CName)=sKey then
      begin
         ParameterList[i].CAddress:=PAddress;
         ParameterList[i].IsExterior:=true;
         ParameterList[i].IsConst:=false;
         result:=true;
         exit;
      end;
    end;

    //  没有找到，则新建一个变量
    i:=self.ParameterListIn(PName);
    if i>=0 then
    begin
      ParameterList[i].CAddress:=PAddress;
      ParameterList[i].IsExterior:=true;
      ParameterList[i].IsConst:=false;
      result:=true;
      exit;
    end;

    result:=false;
  except
    result:=false;
  end;
end;

procedure  TCompile.SetParameter(const PAddress:PTCmxFloat;const dValue:TCmxFloat);
begin
  //if not Enabled then exit;
  PAddress^:=dValue;
end;

function  TCompile.GetParameterAddress(const PName:string):PTCmxFloat;
var
  i     :integer;
  sKey  :string;
begin
  try
    result:=PTCmxFloat(0);
    sKey:=uppercase(PName);
    if sKey[1]<>'&' then sKey:='&'+sKey;
    for i:=0 to PParameterList-1 do
    begin
      if uppercase(ParameterList[i].CName)=sKey then
      begin
         result:=ParameterList[i].CAddress;
         exit;
      end;
    end;
  except
    result:=PTCmxFloat(0);
  end;
end;

function  TCompile.GetParameterIndex(const PName:string):integer; //得到参数序号
var
  i     :integer;
  sKey  :string;
begin
  try
    result:=-1;
    sKey:=uppercase(PName);
    if sKey[1]<>'&' then sKey:='&'+sKey;
    for i:=0 to PParameterList-1 do
    begin
      if uppercase(ParameterList[i].CName)=sKey then
      begin
         result:=i;//ParameterList[i].CIndex;
         exit;
      end;
    end;
  except
    result:=-1;
  end;
end;

procedure TCompile.Clear();
begin
  ErrorCode:=0;
  CompileInPFirst:=0;
  FFunctionPlistCount:=0;
  TF00:='';
  T_SYS_FF_ConstN:=0;

  PExeAddressCode:=0;   //(编译以后的执行码) 初始化
  setlength(ExeAddressCode,1024);

  PParameterList:=0;    //(参数列表) 初始化
  setlength(ParameterList,1024);

  PExeParameter:=0;        //(编译后 参数储存空间) 初始化
  setlength(ExeParameter,1024);

  PExeAddressList:=0;      //(记录指针位置列表 积分) 初始化
  setlength(ExeAddressList,1024);

  PExeAddressPMList:=0;    //(记录指针位置列表 参数存储地址) 初始化
  setlength(ExeAddressPMList,1024);

  PFunctionStack := 0 ;        //(函数符号调用堆栈) 初始化
  setlength(FunctionStack,1024);

  T_PTrueNow.isConst:=false;   //(编译优化常数时  参数性质堆栈) 初始化
  T_PTrueOld.isConst:=false;
  PT_PTrueNowList:=0;
  setlength(T_PTrueNowList,1024);

end;

procedure TCompile.ExeAddressCodeIn(const B:Byte);
begin
  if PExeAddressCode>=high(ExeAddressCode)-1 then
  begin
    setlength(ExeAddressCode,2*high(ExeAddressCode)+2);
  end;
  ExeAddressCode[PExeAddressCode]:=B;
  inc(PExeAddressCode);
end;

procedure TCompile.ExeAddressCodeIn(const B:array of Byte);
var
  i   :integer;
begin
  for i:=low(b) to high(b) do
  begin
     ExeAddressCodeIn(b[i]);
  end;
end;

var
  HEXToINT: array[0..255] of integer;//查询表
//构造 HEXToINT: array[0..255] of integer 查询表
procedure SetHEXToINTValue();
var
  i    : integer;
begin
  for i:=0 to 255 do
    HEXToINT[i]:=0;
  for i:=byte('0') to byte('9') do
    HEXToINT[i]:=i-byte('0');
  for i:=byte('A') to byte('F') do
    HEXToINT[i]:=i-byte('A')+10;
  for i:=byte('a') to byte('f') do
    HEXToINT[i]:=i-byte('a')+10;
end;

procedure TCompile.ExeAddressCodeIn(const sB:string);
var
  i   :integer;
  b   :byte;
  {function hextoint(const cB:char):byte;
  begin
    case upcase(cB) of
      '0'..'9':
        result:=strtoint(cB);
      'A':
        result:=10;
      'B':
        result:=11;
      'C':
        result:=12;
      'D':
        result:=13;
      'E':
        result:=14;
      'F':
        result:=15;
      else
        begin
          //application.MessageBox('Compile Error!','Error:');
          ErrorCode:=csTCompile_CompileHexCodeError;
          result:=0;
        end;
    end; 
  end; }
begin
  if length(sb) Mod 2=1 then  //application.MessageBox('Compile Error!','Error:');
      ErrorCode:=csTCompile_HexMod2_EQ_1_Error;
  for i:=1 to length(sB) Div 2 do
  begin
    b:=hextoint[byte(sb[i*2-1])] shl 4 or hextoint[byte(sb[i*2])];
    ExeAddressCodeIn(b);
  end;
end;

procedure  TCompile.GetExeAddressCodeInPointerRePm(const PName:string);
begin
  if PExeAddressPMList>=high(ExeAddressPMList)-1 then
  begin
    setlength(ExeAddressPMList,2*high(ExeAddressPMList)+2);
  end;
  ExeAddressPMList[PExeAddressPMList].ExeIndex:=PExeAddressCode;
  ExeAddressPMList[PExeAddressPMList].PName:=PName;
  inc(PExeAddressPMList);
end;

Function  TCompile.GetExeAddressCodeInPointerReCode():Pointer;
begin
  if PExeAddressList>=high(ExeAddressList)-1 then
  begin
    setlength(ExeAddressList,2*high(ExeAddressList)+2);
  end;
  result:=@ExeAddressCode[PExeAddressCode];
  ExeAddressList[PExeAddressList]:=PExeAddressCode;
  inc(PExeAddressList);
end;

procedure TCompile.RefreshExeAddressCodeInPointer();
var
  i     :integer;
  pExe  :pointer;
  iExe  :integer;
  j     :Cardinal;
  pM    :pointer;
  index :integer;

begin
  for i:=0 to PExeAddressList-1 do
  begin

    pExe:=@ExeAddressCode[ExeAddressList[i]];
    iExe:=Cardinal(PExe)+5;
    ExeAddressCode[ExeAddressList[i]]:=$B8;     //mov eax
    ExeAddressCode[ExeAddressList[i]+1]:=(byte(iExe Mod 256));
    ExeAddressCode[ExeAddressList[i]+2]:=(byte((iExe Div 256) Mod 256));
    ExeAddressCode[ExeAddressList[i]+3]:=(byte((iExe Div (256*256)) Mod 256));
    ExeAddressCode[ExeAddressList[i]+4]:=(byte((iExe Div (256*256*256)) Mod 256)); //  mov   eax,iExe   //return Address

  end;
  for i:=0 to PExeAddressPMList-1 do
  begin
    index:=self.GetParameterIndex(ExeAddressPMList[i].PName);

    if not ParameterList[index].IsExterior then  //内部变量
       pExe:=@ExeParameter[ParameterList[index].CIndex]
    else
       pExe:=ParameterList[index].CAddress;
       
    iExe:=Cardinal(pExe);

    ExeAddressCode[ExeAddressPMList[i].ExeIndex]:=(byte(iExe Mod 256));
    ExeAddressCode[ExeAddressPMList[i].ExeIndex+1]:=(byte((iExe Div 256) Mod 256));
    ExeAddressCode[ExeAddressPMList[i].ExeIndex+2]:=(byte((iExe Div (256*256)) Mod 256));
    ExeAddressCode[ExeAddressPMList[i].ExeIndex+3]:=(byte((iExe Div (256*256*256)) Mod 256));//return Address

  end;


  //刷新两个数据地址
  //mov  ecx,@ExeAddressStack[0]
  pM:=@ExeAddressStack[0];
  j:=Cardinal(pM);
  ExeAddressCode[1]:=byte(j Mod 256);
  ExeAddressCode[2]:=byte((j Div 256) Mod 256);
  ExeAddressCode[3]:=byte((j Div (256*256)) Mod 256);
  ExeAddressCode[4]:=byte((j Div (256*256*256)) Mod 256);
  //mov  edx,@ExeAddressTempData[0]
  pM:=@ExeAddressTempData[0];
  j:=Cardinal(pM);
  ExeAddressCode[6]:=byte(j Mod 256);
  ExeAddressCode[7]:=byte((j Div 256) Mod 256);
  ExeAddressCode[8]:=byte((j Div (256*256)) Mod 256);
  ExeAddressCode[9]:=byte((j Div (256*256*256)) Mod 256);
  
end;

function TCompile.OptimizeStackCall(const IfFxch:boolean=true):boolean;    // 优化堆栈调用
const
  StackCallOLD: array [0..11] of byte=(
      {$ifdef FloatType_Extended}
      $DB,$39,                // fstp   tbyte ptr  [ecx]
      {$else}
        {$ifdef FloatType_Single}
        $D9,$19,                // fstp   dword ptr  [ecx]
        {$else}
        $DD,$19,                // fstp   dword ptr  [ecx]
        {$endif}
      {$endif}
      $83,$C1,SYS_EFLength,          // add    ecx,SYS_EFLength
      $B8,$00,$00,$00,$00,  // mov    eax,$00000000
      {$ifdef FloatType_Extended}
      $DB,$28                 // fld    tbyte ptr  [eax]
      {$else}
        {$ifdef FloatType_Single}
        $D9,$00                 // fld    dword ptr  [eax]
        {$else}
        $DD,$00                 // fld    qword ptr  [eax]
        {$endif}
      {$endif}
      );
  StackCallNEW: array [0..8] of byte=(
      $B8,$00,$00,$00,$00,  // mov    eax,$00000000
      {$ifdef FloatType_Extended}
      $DB,$28,                 // fld    tbyte ptr  [eax]
      {$else}
        {$ifdef FloatType_Single}
        $D9,$00,                 // fld    dword ptr  [eax]
        {$else}
        $DD,$00,                 // fld    qword ptr  [eax]
        {$endif}
      {$endif}
      $D9,$C9               // fxch   st(1)
      );
  // 这些代码当压栈弹栈函数变化时需要更新
  // CompileInP
var
  i,L   : integer;
  k     : integer;
begin
  result:=false;
  if not EnabledOptimizeStack then exit;

  L:=PExeAddressCode-1;
  if L<11 then exit;

  k:=0;
  for i:=L-11 to L do
  begin
    if StackCallOLD[k]<>ExeAddressCode[i]  then exit;
    inc(k);
  end;

  // 满足要求可以优化
  k:=0;
  for i:=L-11 to L-3 do
  begin
    ExeAddressCode[i]:=StackCallNEW[k];
    inc(k);
  end;
  if IfFxch then
    dec(PExeAddressCode,3)   // 编译位置回退3字节
  else
    dec(PExeAddressCode,5);  // 编译位置回退5字节
  dec(ExeAddressPMList[PExeAddressPMList-1].ExeIndex,5); // 参数插入位置回退5字节
  result:=true;
end;


Function  TCompile.GetExeCodeLength():integer;
begin
  result:=PExeAddressCode;
end;

Function  TCompile.GetExeParameterLength():integer;
begin
  result:=PParameterList*SYS_EFLength;
end;

procedure TCompile.SetRandomize(const RandomSeed :integer);
begin
  RndSeed[0]:=RandomSeed;
end;

{$IFDEF MSWINDOWS}
procedure GetSystemTime; external 'kernel32.dll' name 'GetSystemTime'; 
{$ENDIF}

{$IFDEF MSWINDOWS}
procedure TCompile.SetRandomize();
var
        systemTime : TSystemTime;
begin
  GetSystemTime(systemTime);
  RndSeed[0]:=((systemTime.wHour*60+systemTime.wMinute)*60+systemTime.wSecond)*1000+systemTime.wMilliSeconds;
end;
{$ENDIF}

{$IFDEF LINUX }
procedure TCompile.SetRandomize();
begin
  RndSeed[0]:=Trunc(24.0*3600.0*1000*double(Time));
end;
{$ENDIF}

///---------

function TCompile.GetSign(var str:string):string;//返回 str 的第一个算数符
var
  T1    : char;
  i1,i2 :integer;
  TName :string;
begin
  // TF00 用来保存上一次的符号
  try
    result:='';
    T1 := str[1];
    Case T1 of
      '&':
      begin
        i1:=2;
        i2:=0;
        GetMarker(str,i1,i2);
        if i2<>0 then
        begin
          TName:=copy(str,1,i2);
          CompileInP(TName);    //编译 参数堆栈插入参数
          str:=copy(str,i2+1,Length(str)-i2) ; //去掉前面的数据段
          CheckWording(Tf00, TName) ;   // 按照先后关系检查语法错误
          TF00 := TName ;
          result := GetSign(str);  //**递归调用**
          Exit;
        end
        else
        begin
          ErrorCode:= csTCompile_PMMarker_Error;
          result:='';
        end;
      end;
      '@':
      begin      
        i1:=2;
        i2:=0;
        GetMarker(str,i1,i2);
        if i2<>0 then
        begin
          TName:=copy(str,1,i2);
          result :=TName;
          str:=copy(str,i2+1,Length(str)-i2) ;
          CheckWording(Tf00, TName);    // 按照先后关系检查语法错误
          TF00 := TName;
          Exit;
        end
        else
        begin
          ErrorCode :=csTCompile_FMMarker_Error;
          result:='';
        end;
      end ;
      '#':
      begin
        result:='@#';
        CheckWording(Tf00,'@#');  
        Tf00 :='@#';
        Exit;
      end;
    End;
except
  If ErrorCode= 0 Then
    ErrorCode := csTCompile_NoKnownError;
  result:='';
end;

end;

//比较符号的优先级
//
//     '1'       从符号栈弹出一个算术符f,计算f的值。
//
//     '-1'      把当前算术符压入符号栈,读入下一个算术符。
//
//     '0'       当前符号为'#'时,标志编译完成。
//               当前符号为')'时,从符号栈弹出一个算术符f,计算f,读入下一个算术符。
//
//     '-2'      出错。
//
function TCompile.CompareSign(const FName1 : string; const FName2 :string): integer;
var
  sF1,sF2   :string;
  function FIn(const F:string;const Af:array of string):boolean;
  var
    i   :integer;
  begin
    result:=false;
    for i:=Low(Af) to High(Af) do
    begin
      if uppercase(F)=uppercase(Af[i]) then
      begin
        result:=true;
        exit;
      end;
    end;
  end;
begin
  sF1:=uppercase(FName1);
  sF2:=uppercase(FName2);
  if (sF1<>'') and (sF1[1]<>'@') then sF1:=sF1+'@';
  if (sF2<>'') and (sF2[1]<>'@') then sF2:=sF1+'@';
  if (ifSYS_ff(sF1)) then sF1:=getSYS_ff(sF1);
  if (ifSYS_ff(sF2)) then sF2:=getSYS_ff(sF2);

  if Fin(sF1,['@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE']) then
  begin
    if Fin(sF2,['@)','@#']) then
      result := 1
    Else
      result := -1;
  end
 { else if Fin(sF1,['@AND','@OR','@XOR']) then
  begin
    if Fin(sF2,['@AND','@OR','@XOR','@)','@#']) then
      result := 1
    Else
      result := -1;
  end}
  else if Fin(sF1,['@Add','@Sub','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2']) then
  begin
    if Fin(sF2,['@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                '@Add','@Sub','@)','@#','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2']) then
      result := 1
    Else
      result := -1;
  end
  else if  Fin(sF1, ['@Mul','@Div','@DivE','@Mod','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2'] )then
  begin
    if  Fin(sF2,['@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                 '@Add','@Sub','@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@)','@#'] )then
      result := 1
    Else
      result := -1;
  end
  else if  Fin(sF1,['@AND','@OR','@XOR','@Power','@IntPower']) then
  begin
    if  Fin(sF2, ['@AND','@OR','@XOR',
                  '@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                  '@Add','@Sub','@Mul','@Div','@DivE','@Mod','@)','@#','@Power','@IntPower','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2'] )then
      result := 1
    Else
      result := -1;
  end
  else if sF1='@)' then
  begin
    result := -2;
  end
  else if sF1='@#' then
  begin
    if sF2='@#' then
      result := 0
    else if sF2='@)' then
      result := -2
    else
      result := -1;
  end
  Else
  begin
    if sF2 ='@)' then
      result := 0
    else if sF2 ='@#' then
      result := -2
    Else
      result := -1
  end;
end;


// 按照先后关系检查语法错误
procedure TCompile.CheckWording(const T1 : string;const T2 : string) ;// 按照先后关系检查语法错误
var
  sF1,sF2  :string;
  function FIn(const F:string;const Af:array of string):boolean;
  var
    i   :integer;
  begin
    result:=false;
    for i:=Low(Af) to High(Af) do
    begin
      if uppercase(F)=uppercase(Af[i]) then
      begin
        result:=true;
        exit;
      end;
    end;
  end;
begin
  sF1:=uppercase(T1);
  sF2:=uppercase(T2);

  if (ifSYS_ff(sF1)) then sF1:=getSYS_ff(sF1);
  if (ifSYS_ff(sF2)) then sF2:=getSYS_ff(sF2);

  if (sF1<>'') and (sF1[1]='&') then
  begin
    if not (Fin(sF2,['@AND','@OR','@XOR',
                     '@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                     '@Add','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2','@Sub','@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@Power','@IntPower','@)','@#'])) then
      ErrorCode:=csTCompile_Wording_Error;
  end
  else if sF1='@)' then
  begin
    if not (Fin(sF2,['@AND','@OR','@XOR',
                     '@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                     '@Add','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2','@Sub','@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@Power','@IntPower','@)','@#'])) then
      ErrorCode:=csTCompile_Wording_Error;
  end
  else if Fin(sF1,['@#','']) then
  begin
    if sF2='@)' then
      ErrorCode:=csTCompile_Wording_Error;
  End
  else if Fin(sF1,['@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                   '@Add','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2','@Sub','@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@Power','@IntPower']) then
  begin
    if Fin(sF2,['@TCmSYS_BooleanEQ','@TCmSYS_BooleanNE','@TCmSYS_BooleanLT','@TCmSYS_BooleanGT','@TCmSYS_BooleanLE','@TCmSYS_BooleanGE',
                '@Add','@TCmSYS_FF_0','@TCmSYS_FF_1','@TCmSYS_FF_2','@Sub','@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@Power','@IntPower','@)','@#']) then
      ErrorCode:=csTCompile_Wording_Error;
  end
  else
  begin
    if Fin(sF2,['@AND','@OR','@XOR', '@Mul','@Max','@Hypot','@TCmSYS_Fstp_Value','@TCmSYS_IF_0','@TCmSYS_IF_1','@SqrAdd','@Min','@ArcTan2','@Div','@DivE','@Mod','@Power','@IntPower','@)','@#']) then
      ErrorCode:=csTCompile_Wording_Error;
  end;
End;

//根据优先级的处理方法
//
//     '-2'      出错。
//
//     '-1'      把当前算术符压入符号栈,读入下一个算术符。
//
//     '1'       从符号栈弹出一个算术符f,调用f。
//
//     '0'       当前符号为'#'时,编译完成。
//               当前符号为')'时,从符号栈弹出一个算术符f,调用f,读入下一个算术符。
//
function TCompile.Compile():boolean;
var
  ok    :integer;
  T1,T2 :string;
  TQ    :string;
  f     :string;
begin
  try
    result:=false;
    PExeAddressCode:=0;

    ExeAddressCodeIn('b900000000');   //mov  ecx,@ExeAddressStack[0]
    ExeAddressCodeIn('ba00000000');   //mov  edx,@ExeAddressTempData[0]
    //ExeAddressCodeIn('53');  //push ebx
    //ExeAddressCodeIn('dbe3');  //fninit 初始化FPU

    TQ:=FExeText;
    if not Parsing(TQ) then exit;
    T2 := GetSign(TQ);
    if ErrorCode>0 then
    begin
      exit;
    end;
    FunctionStackIn('@#');
    ok:=0;
    while ok=0 do
    begin
        If ErrorCode> 0 Then
        begin
          exit;
        end;
        T1 := FunctionStackRead();
        Case CompareSign(T1, T2) of
            -2:
                ErrorCode :=csTCompile_Bracket_Error;
            -1:
              begin
                FunctionStackIn(T2);
                T2 := GetSign(TQ);
              end;
            1:
              begin
                f := FunctionStackOut();
                CompileInF(f) ;   //编译 函数调用
              end;
            0 :
              begin
                If FunctionStackRead()='@#' Then
                begin
                     ok:=1;
                end
                else
                begin
                    f := FunctionStackOut() ;
                    CompileInF(f);   //编译 函数调用
                    T2 := GetSign(TQ);
                end;
              end;
        End;
    end;

    //ExeAddressCodeIn('5b');  //pop  ebx
    ExeAddressCodeIn('C3');  //ret

    RefreshExeAddressCodeInPointer();
    self.GetValue:=@ExeAddressCode[0];

    if self.ErrorCode<>0 then
      result:=false
    else
      result:=true;
  except
    result:=false;
  end;
end;

procedure TCompile.CompileInP(const PName :string); //编译 插入参数堆栈
var
 // P   :PTCmxFloat;
 // i   :Cardinal; {unsigned 32}
  index :integer;

begin           //++7 or ++12

  if (CompileInPFirst=0) then
  begin
    CompileInPFirst:=1;
  end
  else
  begin
    inc(CompileInPFirst);
    {$ifdef FloatType_Extended}
    ExeAddressCodeIn('DB39');                           //fstp  tbyte ptr  [ecx]
    {$else}
      {$ifdef FloatType_Single}
      ExeAddressCodeIn('D919');                         //fstp  dword ptr  [ecx]
      {$else}
      ExeAddressCodeIn('DD19');                         //fstp  qword ptr  [ecx]
      {$endif}
    {$endif}
    ExeAddressCodeIn('83c1'+inttoHex(SYS_EFLength,2));  //inc ecx,SYS_EFLength
  end;

 // p:=getParameterAddress(PName);
 // i:=Cardinal(p);
  ExeAddressCodeIn('B8');  //mov eax
  GetExeAddressCodeInPointerRePm(PName);
  ExeAddressCodeIn('00000000');

  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db28');  //fld  tbyte ptr [eax] ,  [eax] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D900');  //fld  dword ptr [eax] ,  [eax] -> st
    {$else}
    ExeAddressCodeIn('DD00');  //fld  qword ptr [eax] ,  [eax] -> st
    {$endif}
  {$endif}

  index:=GetParameterListConstIndex(PName);
  if index>=0 then
  begin
    T_PTrueNowListIn(T_PTrueOld);
    T_PTrueOld:=T_PTrueNow;
    T_PTrueNow.isConst:=true;
    T_PTrueNow.dValue:=ParameterList[index].CAddress^;
  end
  else
  begin                 
    T_PTrueNowListIn(T_PTrueOld);
    T_PTrueOld:=T_PTrueNow;
    T_PTrueNow.isConst:=false;
  end;
end;
procedure TCompile.CompileInPReNew(const dValue:TCmxFloat;const Pm:integer); //编译 参数堆栈插入参数 (替换)
begin
  if pm=1 then
  begin
    if CompileInPFirst=1 then          
      dec(PExeAddressCode,7)          // CompileInP()函数 生成的代码长度为 7 Byte
    else
      dec(PExeAddressCode,12);         // CompileInP()函数 生成的代码长度为 12 Byte
    Dec(PExeAddressPMList);
    dec(CompileInPFirst);
  end
  else //if pm=2 then
  begin
    if CompileInPFirst=2 then
      dec(PExeAddressCode,7+12)
    else
      dec(PExeAddressCode,12+12);
    Dec(PExeAddressPMList,2);
    dec(CompileInPFirst,2);
  end;

  
  if (CompileInPFirst=0) then
  begin
    CompileInPFirst:=1;
  end
  else
  begin
    inc(CompileInPFirst);
    {$ifdef FloatType_Extended}
    ExeAddressCodeIn('DB39');                           //fstp  tbyte ptr  [ecx]
    {$else}
      {$ifdef FloatType_Single}
      ExeAddressCodeIn('D919');                         //fstp  dword ptr  [ecx]
      {$else}
      ExeAddressCodeIn('DD19');                         //fstp  qword ptr  [ecx]
      {$endif}
    {$endif}
    ExeAddressCodeIn('83c1'+inttoHex(SYS_EFLength,2));  //inc ecx,SYS_EFLength
  end;

  FF_Fld_X(dValue);

  if pm=1 then
  begin
    T_PTrueNow.isConst:=true;
    T_PTrueNow.dValue:=dValue;
  end
  else //if pm=2 then
  begin
    T_PTrueOld:=T_PTrueNowListOut();
    T_PTrueNow.isConst:=true;
    T_PTrueNow.dValue:=dValue;
  end;
  
end;
procedure TCompile.CompileOutP(); //编译 弹出参数
begin
  ExeAddressCodeIn('83e9'+inttoHex(SYS_EFLength,2));  //dec ecx ，SYS_EFLength
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db29');  //fld  tbyte ptr [ecx]
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D901');  //fld  dword ptr [ecx]
    {$else}
    ExeAddressCodeIn('DD01');  //fld  qword ptr [ecx]
    {$endif}
  {$endif}
end;

procedure TCompile.CompileInF(const FName:string); //编译 函数调用
var
  sName          :string;
  ConstdValue    :TCmxFloat;
  CCost2         :boolean;
  CCost1         :boolean;
 // CConstDiv      :boolean;
//  CCost0         :boolean;
  ff_N           :integer;
  xTemp           :TCmxFloat;
//  sTemp          :string;
//label
//  CompileFunction;

begin

  try
    sName:=uppercase(FName);
    if (sName<>'') and (sName[1]<>'@') then sName:='@'+sName;
    ConstdValue:=0;

    if (FEnabledOptimizeDiv) and    //优化 常数Div
       (T_PTrueNow.isConst) and (not T_PTrueOld.isConst) and (sName=('@DIV')) then
    begin
      sName:='@MUL';
      if T_PTrueNow.dValue<>0 then
        T_PTrueNow.dValue:=1.0/T_PTrueNow.dValue
      else
        T_PTrueNow.dValue:=Infinity;

      dec(PExeAddressCode,7);  // CompileInP()函数 插入参数 生成的代码长度在这里衡为 7 Byte
      dec(self.PExeAddressPMList);
      FF_FLD_x(T_PTrueNow.dValue); // FF_FLD_x()函数 生成的代码长度也为 7 Byte
    end;

    if FEnabledOptimizeConst then    // 优化常数运算
    begin

      if T_PTrueNow.isConst  then
      begin
      //对常数计算时进行优化
        CCost2:=false;
        if T_PTrueOld.isConst  then    // 二元运算
        begin
          CCost2:=true;
          if sName=uppercase('@AND') then
          begin
            if (T_PTrueOld.dValue<>0) and (T_PTrueNow.dValue<>0) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@OR') then
          begin
            if (T_PTrueOld.dValue<>0) or (T_PTrueNow.dValue<>0) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@XOR') then
          begin
            if ((T_PTrueOld.dValue<>0) and (T_PTrueNow.dValue=0))
            or ((T_PTrueOld.dValue=0) and (T_PTrueNow.dValue<>0)) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanEQ') then
          begin
            if (T_PTrueOld.dValue=T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanNE') then
          begin
            if (T_PTrueOld.dValue<>T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanLT') then
          begin
            if (T_PTrueOld.dValue<T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanGT') then
          begin
            if (T_PTrueOld.dValue>T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanLE') then
          begin
            if (T_PTrueOld.dValue<=T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          else if sName=uppercase('@TCmSYS_BooleanGE') then
          begin
            if (T_PTrueOld.dValue>=T_PTrueNow.dValue) then
              ConstdValue:=1.0
            else
              ConstdValue:=0;
          end
          //------------------------------------
          else if sName=uppercase('@Add') then
            ConstdValue:=T_PTrueOld.dValue+T_PTrueNow.dValue
          else if sName=uppercase('@Sub') then
            ConstdValue:=T_PTrueOld.dValue-T_PTrueNow.dValue
          else if sName=uppercase('@Mul') then
            ConstdValue:=T_PTrueOld.dValue*T_PTrueNow.dValue
          else if sName=uppercase('@Div') then
          begin
            if T_PTrueNow.dValue<>0 then
              ConstdValue:=T_PTrueOld.dValue/T_PTrueNow.dValue
            else if T_PTrueOld.dValue=0 then
              ConstdValue:=Infinity
            else if T_PTrueOld.dValue>0 then
              ConstdValue:=Infinity
            else if T_PTrueOld.dValue<0 then
              ConstdValue:=NegInfinity;
          end
          else if sName=uppercase('@DivE') then
          begin
            if T_PTrueNow.dValue<>0 then
              ConstdValue:=Trunc(T_PTrueOld.dValue/T_PTrueNow.dValue)
            else if T_PTrueOld.dValue=0 then
              ConstdValue:=Infinity
            else if T_PTrueOld.dValue>0 then
              ConstdValue:=Infinity
            else if T_PTrueOld.dValue<0 then
              ConstdValue:=NegInfinity;
          end
          else if sName=uppercase('@Mod') then
            ConstdValue:=T_PTrueOld.dValue-Trunc(T_PTrueOld.dValue/T_PTrueNow.dValue)*T_PTrueNow.dValue
          else if sName=uppercase('@Power') then
            ConstdValue:=math.Power(T_PTrueOld.dValue,T_PTrueNow.dValue)
          else if sName=uppercase('@IntPower') then
            ConstdValue:=math.IntPower(T_PTrueOld.dValue,integer(Round(T_PTrueNow.dValue)))
          else if sName=uppercase('@Max') then
            ConstdValue:=math.Max(T_PTrueOld.dValue,T_PTrueNow.dValue)
          else if sName=uppercase('@Hypot') then
            ConstdValue:=Sqrt(Sqr(T_PTrueOld.dValue)+Sqr(T_PTrueNow.dValue))
          else if sName=uppercase('@SqrAdd') then
            ConstdValue:=(Sqr(T_PTrueOld.dValue)+Sqr(T_PTrueNow.dValue))
          else if sName=uppercase('@Min') then
            ConstdValue:=math.Min(T_PTrueOld.dValue,T_PTrueNow.dValue)
          else if (sName=uppercase('@ArcTan2'))or(sName=uppercase('@Arctg2')) then
            ConstdValue:=math.ArcTan2(T_PTrueOld.dValue,T_PTrueNow.dValue)
          else
            CCost2:=false;
        end
        else
        begin
            //  优化x^0,x^1,x^2,x^N  常整数次方
            if ((sName=uppercase('@Power')) or (sName=uppercase('@IntPower')))
            and (Round(T_PTrueNow.dValue)=T_PTrueNow.dValue)
            and (abs(T_PTrueNow.dValue)<MaxInt) then
            begin
             { case round(T_PTrueNow.dValue) of
                //0:
                //todo: ERROR Power(1-x_3,2) 优化
                //  begin
                //    CCost2:=true;
                //    ConstdValue:=1;
                //  end;
                1:
                  begin
                    sName:=uppercase('@Add');
                    T_PTrueNow.dValue:=0;
                    dec(PExeAddressCode,7);  // CompileInP()函数 插入参数 生成的代码长度在这里衡为 7 Byte
                    dec(self.PExeAddressPMList);
                    FF_FLD_x(T_PTrueNow.dValue); // FF_FLD_x()函数 生成的代码长度也为 7 Byte
                  end;
                //todo: ERROR Power(1-x_3,2) 优化
                //2:
                //  begin
                //    sName:=uppercase('@Mul');
                //    ExeAddressPMList[PExeAddressPMList-1].PName:=ExeAddressPMList[PExeAddressPMList-2].PName;
                //  end; 
                else  }
                  begin
                    sName:=uppercase('@IntPower');
                  end;
              //end;
            end;
        end;

        CCost1:=true;
        if sName=uppercase('@NOT') then   // 一元运算
        begin
          if T_PTrueNow.dValue<>0 then
            ConstdValue:=0
          else
            ConstdValue:=1;
        end
        else if sName=uppercase('@Bracket') then
          ConstdValue:=(T_PTrueNow.dValue)
        else if sName=uppercase('@Sqr') then
          ConstdValue:=Sqr(T_PTrueNow.dValue)
        else if sName=uppercase('@Sqr3') then
          ConstdValue:=Sqr(T_PTrueNow.dValue)*T_PTrueNow.dValue
        else if sName=uppercase('@Sqr4') then
          ConstdValue:=Sqr(Sqr(T_PTrueNow.dValue))
        else if sName=uppercase('@Sqrt') then
          ConstdValue:=Sqrt(T_PTrueNow.dValue)
        else if sName=uppercase('@Rev') then
          begin
            if T_PTrueNow.dValue<>0 then
              ConstdValue:=1.0/T_PTrueNow.dValue
            else
              ConstdValue:=Infinity;
          end
        else if sName=uppercase('@Sin') then
          ConstdValue:=Sin(T_PTrueNow.dValue)
        else if sName=uppercase('@Cos') then
          ConstdValue:=Cos(T_PTrueNow.dValue)
        else if (sName=uppercase('@Tan')) or (sName=uppercase('@tg')) then
          ConstdValue:=math.Tan(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcSin'))  then
          ConstdValue:=math.ArcSin(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCos') ) then
          ConstdValue:=math.ArcCos(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcTan')) or (sName=uppercase('@Arctg')) then
          ConstdValue:=ArcTan(T_PTrueNow.dValue)
        else if sName=uppercase('@Sec') then
          ConstdValue:=1.0/Cos(T_PTrueNow.dValue)
        else if sName=uppercase('@Csc') then
          ConstdValue:=1.0/Sin(T_PTrueNow.dValue)
        else if (sName=uppercase('@Ctg')) or ( sName=uppercase('@Cot'))  then
          ConstdValue:=1.0/math.Tan(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcSec'))  then
          ConstdValue:=ArcCos(1/T_PTrueNow.dValue)//math.ArcSec(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCsc'))  then
          ConstdValue:=ArcSin(1/T_PTrueNow.dValue)//math.ArcCsc(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCtg')) or (sName=uppercase('@ArcCot')) then
          ConstdValue:=ArcTan(1/T_PTrueNow.dValue)//math.ArcCot(T_PTrueNow.dValue)
        else if sName=uppercase('@Ln') then
          ConstdValue:=Ln(T_PTrueNow.dValue)
        else if (sName=uppercase('@Log')) or (sName=uppercase('@Log10')) then
          ConstdValue:=math.Log10(T_PTrueNow.dValue)
        else if sName=uppercase('@Log2') then
          ConstdValue:=math.Log2(T_PTrueNow.dValue)
        else if sName=uppercase('@Abs') then
          ConstdValue:=Abs(T_PTrueNow.dValue)
        else if (sName=uppercase('@Floor')) or( sName=uppercase('@Int')) then
        begin
          xTemp:=Trunc(T_PTrueNow.dValue);
          if Frac(T_PTrueNow.dValue) <0 then
            xTemp:=xTemp-1;
          ConstdValue:=xTemp;
        end
        else if sName=uppercase('@Trunc') then
          ConstdValue:=Trunc(T_PTrueNow.dValue)
        else if sName=uppercase('@Round') then
          ConstdValue:=Round(T_PTrueNow.dValue)
        else if sName=uppercase('@Ceil') then
          ConstdValue:=Ceil(T_PTrueNow.dValue)
        else if sName=uppercase('@Sgn') then
          if T_PTrueNow.dValue>0 then
             ConstdValue:=1.0
          else if T_PTrueNow.dValue<0 then
             ConstdValue:=-1.0
          else
             ConstdValue:=0.0
        else if sName=uppercase('@Exp') then
          ConstdValue:=Exp(T_PTrueNow.dValue)
        else if sName=uppercase('@SinH') then
          ConstdValue:=math.SinH(T_PTrueNow.dValue)
        else if sName=uppercase('@CosH') then
          ConstdValue:=math.CosH(T_PTrueNow.dValue)
        else if (sName=uppercase('@TanH')) or ( sName=uppercase('@tgH')) then
          ConstdValue:=math.TanH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcSinH')) then
          ConstdValue:=math.ArcSinH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCosH')) then
          ConstdValue:=math.ArcCosH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcTanH'))or( sName=uppercase('@ArctgH')) then
          ConstdValue:=math.ArcTanH(T_PTrueNow.dValue)
        else if (sName=uppercase('@SecH')) then
          ConstdValue:=math.SecH(T_PTrueNow.dValue)
        else if (sName=uppercase('@CscH'))  then
          ConstdValue:=math.CscH(T_PTrueNow.dValue)
        else if (sName=uppercase('@CtgH')) or (sName=uppercase('@CotH')) then
          ConstdValue:=math.CotH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcSecH'))  then
          ConstdValue:=ArcCosH(1/T_PTrueNow.dValue)//math.ArcSecH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCscH')) then
          ConstdValue:=ArcSinH(1/T_PTrueNow.dValue)//math.ArcCscH(T_PTrueNow.dValue)
        else if (sName=uppercase('@ArcCotH')) or (sName=uppercase('@ArcCtgH')) then
          ConstdValue:=ArcTanH(1/T_PTrueNow.dValue)//math.ArcCotH(T_PTrueNow.dValue)
        else
          CCost1:=false;

        if (CCost1) and (CCost2) then
        begin
          ErrorCode:=csTCompile_Optimize_Error;
        end
        else if CCost1 then
        begin
          CompileInPReNew(ConstdValue,1);
          exit;
        end
        else if CCost2 then
        begin
          CompileInPReNew(ConstdValue,2);
          exit;
        end
        else
        begin
         // goto CompileFunction;
        end;

      end;

   end;//if FEnabledOptimizeStack
   
   // CompileFunction:

    // 没有进行常数优化

    T_PTrueNowListIn(T_PTrueOld);
    T_PTrueOld:=T_PTrueNow;
    T_PTrueNow.isConst:=false;

    //由函数决定编译代码
    if sName=uppercase('@Add') then
      F_Add
    else if sName=uppercase('@Sub') then
      F_sub
    else if sName=uppercase('@Mul') then
      F_Mul
    else if sName=uppercase('@Div') then
      F_Div
    else if sName=uppercase('@DivE') then
      F_DivE
    else if sName=uppercase('@Mod') then
      F_Mod
    else if sName=uppercase('@Power') then
      F_Power
    else if sName=uppercase('@IntPower') then
      F_IntPower
    else if sName=uppercase('@Max') then
      F_Max
    else if sName=uppercase('@Min') then
      F_Min
    else if sName=uppercase('@Bracket') then
      F_Bracket
    else if sName=uppercase('@Sqr') then
      F_Sqr
    else if sName=uppercase('@Sqr3') then
      F_Sqr3
    else if sName=uppercase('@Sqr4') then
      F_Sqr4
    else if sName=uppercase('@Sqrt') then
      F_Sqrt
    else if sName=uppercase('@Rev') then
      F_Rev
    else if sName=uppercase('@Sin') then
      F_Sin
    else if sName=uppercase('@Cos') then
      F_Cos
    else if sName=uppercase('@Tan') then
      F_Tan
    else if sName=uppercase('@tg') then
      F_Tan
    else if sName=uppercase('@ArcSin') then
      F_ArcSin
    else if sName=uppercase('@ArcCos') then
      F_ArcCos
    else if sName=uppercase('@ArcTan') then
      F_ArcTan
    else if sName=uppercase('@Arctg') then
      F_ArcTan
    else if sName=uppercase('@ArcTan2') then
      F_ArcTan2
    else if sName=uppercase('@Arctg2') then
      F_ArcTan2
    else if sName=uppercase('@Ln') then
      F_Ln
    else if sName=uppercase('@Log') then
      F_Log
    else if sName=uppercase('@Log10') then
      F_Log
    else if sName=uppercase('@Log2') then
      F_Log2
    else if sName=uppercase('@TCmSYS_Fld_Value') then
      F_SYS_Fld_Value
    else if sName=uppercase('@Abs') then
      F_Abs
    else if sName=uppercase('@Floor') then
      F_Floor
    else if sName=uppercase('@Int') then
      F_Floor
    else if sName=uppercase('@Trunc') then
      F_Trunc
    else if sName=uppercase('@Round') then
      F_Round
    else if sName=uppercase('@Ceil') then
      F_Ceil
    else if sName=uppercase('@Sgn') then
      F_Sgn
    else if sName=uppercase('@Exp') then
      F_exp
    else if sName=uppercase('@Ctg') then
      F_Ctg
    else if sName=uppercase('@Cot') then
      F_Ctg
    else if sName=uppercase('@Sec') then
      F_Sec
    else if sName=uppercase('@Csc') then 
      F_Csc
    else if sName=uppercase('@Hypot') then
      F_Hypot
    else if sName=uppercase('@TCmSYS_Fstp_Value') then
      F_SYS_Fstp_Value
    else if sName=uppercase('@TCmSYS_IF_0') then
      F_SYS_IF_0
    else if sName=uppercase('@TCmSYS_IF_1') then
      F_SYS_IF_1
    else if sName=uppercase('@SqrAdd') then
      F_SqrAdd
    else if sName=uppercase('@SinH') then
      F_SinH
    else if sName=uppercase('@CosH') then
      F_CosH
    else if sName=uppercase('@TanH') then
      F_Tanh
    else if sName=uppercase('@tgH') then
      F_Tanh
    else if sName=uppercase('@ArcCosH') then
      F_ArcCosH
    else if sName=uppercase('@ArcSinH') then
      F_ArcSinH
    else if sName=uppercase('@ArcTanH') then
      F_ArcTanh
    else if sName=uppercase('@ArctgH') then
      F_ArcTanh
    else if sName=uppercase('@SecH') then
      F_SecH
    else if sName=uppercase('@CscH') then
      F_CscH
    else if sName=uppercase('@CtgH') then
      F_CtgH
    else if sName=uppercase('@CotH') then
      F_CtgH
    else if sName=uppercase('@ArcSec') then
      F_ArcSec
    else if sName=uppercase('@ArcCsc') then
      F_ArcCsc
    else if sName=uppercase('@ArcCtg') then
      F_ArcCtg
    else if sName=uppercase('@ArcCot') then
      F_ArcCtg
    else if sName=uppercase('@ArcSecH') then
      F_ArcSecH
    else if sName=uppercase('@ArcCscH') then
      F_ArcCscH
    else if sName=uppercase('@ArcCotH') then
      F_ArcCtgH
    else if sName=uppercase('@ArcCtgH') then
      F_ArcCtgH
    else if sName=uppercase('@RND') then
      F_Rnd
    else if sName=uppercase('@Rand') then
      F_Rnd
    else if sName=uppercase('@Random') then
      F_Rnd

    else if sName=uppercase('@AND') then
      FB_AND
    else if sName=uppercase('@OR') then
      FB_OR
    else if sName=uppercase('@XOR') then
      FB_XOR
    else if sName=uppercase('@NOT') then
      FB_NOT
    else if sName=uppercase('@TCmSYS_BooleanEQ') then
      FB_EQ
    else if sName=uppercase('@TCmSYS_BooleanNE') then
      FB_NE
    else if sName=uppercase('@TCmSYS_BooleanLT') then
      FB_LT
    else if sName=uppercase('@TCmSYS_BooleanGT') then
      FB_GT
    else if sName=uppercase('@TCmSYS_BooleanLE') then
      FB_LE
    else if sName=uppercase('@TCmSYS_BooleanGE') then
      FB_GE
    ;
    if (ifSYS_ff(sName)) then
    begin
      ff_n:=strtoint(copy(sName,Length('@TCmSYS_FF_0_')+1,4));
      sName:=getSYS_ff(sName);
      if sName=uppercase('@TCmSYS_FF_0') then
        F_SYS_FF_0(ff_n)
      else if sName=uppercase('@TCmSYS_FF_1') then
        F_SYS_FF_1(ff_n)
      else if sName=uppercase('@TCmSYS_FF_2') then
        F_SYS_FF_2(ff_n);
    end;
  except
    ErrorCode:=csTCompile_Define_Error ;
  end;
end;

// 得到字符串中标识符的位置
function  TCompile.myPos(const str:string;const key:string;const ifirst:integer):integer;
var
  L,KeyL,i   : integer;
  newStr,newKey : string;
begin
  result:=0;
  newStr:=uppercase(str);
  newKey:=uppercase(key);
  L:=length(newstr);
  keyL:=length(newkey);
  for i:=ifirst to L do
  begin
    if (newstr[i])=(newkey[1]) then
    begin
      if L-i+1>=KeyL then
      begin
        if copy(newStr,i,KeyL)=newKey then
        begin
          result:=i;
          exit;
        end;
      end;
    end;
  end;
end;

function  TCompile.GetMarkerPos(const str:string;const key:string;const ifirst:integer):integer;
var
  i  : integer;
  p  : integer;
begin
  i:=1;
  p:=ifirst;
  while i<>0 do
  begin
    i:=myPos(Str,Key,p);
    if i=0 then  //没有找到
    begin
      result:=0;
      exit;
    end
    else
    begin
      if ( (i=1) or (not (str[i-1] in ['A'..'Z','a'..'z','_','0'..'9'])) ) //前
      and ((i-1+length(key)=length(Str)) or (not (Str[i+length(key)] in ['A'..'Z','a'..'z','_','0'..'9'])) )   then   //后
      begin
        result:=i;
        exit;
      end
      else
      begin
        p:=i+1;
      end;
    end;
  end;
  result:=0;
end;

  function exFloatToStr(const value:extended):String;
  var
    Buffer: array[0..63] of Char;
  begin
    SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended,
      ffGeneral, 21, 0));
  end;

// 处理常数定义(要代换的标识符,代换的值)  // 常数定义, Value必须是一个可计算的值
//   如 Key:='a'; Value:='2' , 或 Key:='b' , Value:='2*sin(PI/2)' 等;
//   该功能完全可以用预定义宏(Define)来代替，
//     但当值为常数时这样处理有可能使最后得到的编译函数速度更快，并加快编译速度
function  TCompile.DefineConst(const Key,Value: string):boolean;
var
  TCm : TCompile;
  x   : TCmxFloat;
  strX: string;
begin
  //
  TCm:=TCompile.Create;
  try
    TCm.SetText(Value);
    if (TCm.GetErrorCode<>0) or (TCm.IfHaveUnDefineParameter) then
      result:=false
    else
    begin
      try
        x:=TCm.GetValue();
        strX:=exFloatToStr(x);
        result:=self.DefineMarker(self.FExeText,Key,'('+strX+')');
      except
        result:=false;
      end;
    end;
  finally
    TCm.Free;
  end;
end;


// 替换标识符
function  TCompile.DefineMarker(var Text:string;const Key,Value : string):boolean;
var
  L,sign: integer;
  i,p,j : integer;
  sNew  : string;
  sNewKey : string;
  sNewValue : string;

begin
  L:=length(key);
  if L=0 then
  begin
    result:=false;
    exit;
  end;

    i:=0;
    j:=0;
    p:=0;
    sign:=0;
    while true do
    begin
      case sign of
        -1:    // 出错状态
          begin
            result:=false;
            exit;
          end;
        10:   // 成功退出
          begin
            Text:=sNew;
            result:=true;
            exit;
          end;
        0:    // 初始状态
          begin
            sNew:=uppercase(Text);
            sign:=1;
            p:=1;
          end;
        1:   // 找到标识符开始位置
          begin
            if key[p] in [' ',#13,#10,#9] then
            begin
              inc(p);
              sign:=1;
            end
            else if key[p] in ['A'..'Z','a'..'z','_'] then
            begin
              sign:=2;
            end
            else
              sign:=-1;
          end;
        2:  // 得到标识符位置
          begin
            j:=P;
            self.GetMarkerValue0(key,p,i);
            if i=0 then
              sign:=-1
            else
            begin
              P:=i+1;
              sign:=3;
            end;
          end;
        3:  // 取出标识符
          begin
            if p=L+1 then
            begin
              sNewKey:=uppercase(copy(key,j,i-j+1));
              sNewValue:= uppercase(Value);
              P:=1;
              sign:=4;
            end
            else if Key[P] in [' ',#13,#10,#9] then
            begin
              inc(p);
              sign:=3;
            end
            else
              sign:=-1;
          end;
        4:  // 进行替换
          begin
            i:=GetMarkerPos(sNew,sNewKey,P);
            if i=0 then
              sign:=10
            else
            begin
              j:=i+length(sNewKey);
              sNew:=copy(sNew,1,i-1)+sNewValue+copy(sNew,j,length(sNew)-j+1);
              p:=i+length(sNewValue);
              sign:=4;
            end;
          end;
      end;
    end;
end;

// 处理预定义宏(要代换的标识符,代换为的描述值); // 可以用来处理常数,甚至定义新的函数!
//   如 Key:='a'; Value:='-0.5' , 或 Key:='f(x,y)',Value:='Max(x,Sin(y))'
function  TCompile.Define(const Key,Value : string):boolean;
var
  L     : integer;
  i ,j  : integer;
  sign,p    : integer;
  sOldText  : string;
  sOldKey   : string;
  sOldValue : string;
  sTemp     : string;

  PListCount      : integer;   // 参数个数
  PListName       : array of String;   //参数名称
  FName           : string;  // 函数名称
  Pf1,Pf2         : integer;  // 模式匹配起止位置
  PListD          : array of integer;  // 匹配模式中参数位置 (即括号和逗号的位置,长度为PListCount+1)

  SYS_DefineFPName_TempFName: string;//临时函数名称

  //宏函数处理步骤:
  //  第一步: 检查Key的合法性 a:有函数名称 b:标识符不重复 c:格式正确，并得到函数名称，参数个数，参数名称
  //     接着 替换Key和Value中的参数名称，改为系统专用参数名称TCmSYS_DefineFPName_???(序号)
  //  第二步: 找出Text中Key的匹配模式的起止位置 ,并得到匹配模式中参数位置 (即括号和逗号的位置,长度为PListCount+1)
  //    第三步: 按顺序替换子项得到函数替换体
  //    第四步: 替换整个模式
  //  第五步: 前移匹配位置，转到第二步。

  function MyPos(const str:string;const Ch:char;const IFirst:integer):integer;
  var
    i  : integer;
  begin
    result:=0;
    for i:=IFirst to length(str) do
    begin
      if str[i]=ch then
      begin
        result:=i;
        exit;
      end;
    end;
  end;

  function getd(const str:string;const iFirst,iEnd:integer;var id:integer):boolean;// get next ,
  var
    i,iR   :integer;
  begin
    iR:=0;
    for i:=iFirst to iEnd do
    begin
      if str[i]='(' then
        iR:=iR-1
      else if str[i]=')' then
        iR:=iR+1
      else if (str[i]=',') and (iR=0) then
      begin
        result:=true;
        id:=i;
        exit;
      end;
    end;
    result:=false;
    id:=0;
  end;

  function GetR(const str :string;const iFirst:integer;var iEnd:integer):boolean; // 得到  )
  var
    i,iR  :integer;
  begin
    ir:=0;
    for i:=iFirst to length(str) do
    begin
      if str[i]='(' then
        ir:=ir-1
      else if str[i]=')' then
        ir:=ir+1;
      if ir=1 then
      begin
        result:=true;
        iEnd:=i;
        exit;
      end;
    end;
    result:=false;
    iEnd:=0;
  end;

  // 寻找匹配模式具体匹配位置
  function  GetPListD(const sText:string;const iFirst:integer;var PListD:array of integer):boolean;
  var
    i,id : integer;
    p    : integer;
    iEnd : integer;
  begin
    // 定位'('
    for i:=iFirst+length(FName) to length(sText) do
    begin
      if sText[i]='(' then
      begin
        PListD[0]:=i;
        break;
      end
      else if sText[i] in [' ',#13,#10,#9] then
      begin

      end
      else
      begin
        result:=false;
        exit;
      end;
    end;
    P:=PListD[0];

    // 定位')'
    if not GetR(sText,p+1,iEnd) then
    begin
      result:=false;
      exit;
    end
    else
    begin
      PListD[PListCount]:=iEnd;
    end;

    // 定位','
    for i:=1 to PListCount-1 do  //有PListCount-1个','需要定位
    begin
      if GetD(sText,P+1,iEnd,id) then
      begin
        PListD[i]:=id;
        P:=id;
      end
      else
      begin
        result:=false;
        exit;
      end;
    end;

    // 检查最后','后面到')'间的语法是否正确
    if GetD(sText,P+1,iEnd,id) then
    begin
      result:=false;
      exit;
    end;
    result:=true;

  end;

begin
  L:=length(key);
  if L=0 then
  begin
    result:=false;
    exit;
  end;

  P:=0;
  i:=myPos(key,'(',1);
  j:=myPos(key,')',1);
  if (i=0) and (j=0) then  // 处理常数或变量代换
  begin
    result:=self.DefineMarker(self.FExeText,Key,'('+Value+')');
  end
  else     // 处理预处理函数代换
  begin
    sOldText :=uppercase(self.FExeText);
    sOldKey  :=uppercase(Key);
    sOldValue:=uppercase(Value);
    //第一步：
    sign:=0;
    while true do
    begin
      case sign of
        -1 :    // 出错状态
          begin
            result:=false;
            exit;
          end;
        10:    // 成功状态
          begin
            //
            break;
          end;
        0:    // 初始状态
          begin
            P:=1;
            sign:=1;
            PListCount:=0;
          end;
        1:     // 得到函数名称
          begin
            if sOldKey[p] in [' ',#13,#10,#9] then
            begin
              inc(p);
              sign:=1;
            end
            else if sOldKey[P] in ['A'..'Z','_'] then
            begin
              self.GetMarkerValue0(sOldKey,P,i);
              if i=0 then
                sign:=-1
              else
              begin
                Fname:=copy(sOldKey,P,i-p+1);
                P:=i+1;
                sign:=2;
              end;
            end
            else
              sign:=-1;
          end;
        2:   //
          begin
            if sOldKey[P] in [' ',#13,#10,#9] then
              inc(p)
            else if  sOldKey[P]='(' then
            begin
              inc(p);
              sign:=3;
            end
            else
              sign:=-1;
          end;
        3:
          begin
            if  sOldKey[P] in [' ',#13,#10,#9] then
              inc(p)
            else if  sOldKey[P] in ['A'..'Z','_'] then
            begin
              self.GetMarkerValue0(sOldKey,P,i);
              if i=0 then
                sign:=-1
              else
              begin
                inc(PListCount);
                setlength(PListName,PListCount);
                PListName[PListCount-1]:=copy(sOldKey,P,i-P+1);
                P:=i+1;
                sign:=4;
              end;
            end
            else
              sign:=-1;
          end;
        4:  //
          begin
            if sOldKey[P] in [' ',#13,#10,#9] then
              inc(p)
            else if sOldKey[P]=')' then
            begin
              inc(p);
              sign:=5;
            end
            else if sOldKey[P]=',' then
            begin
              inc(p);
              sign:=3;
            end
            else
              sign:=-1;
          end;
        5:
          begin
            if P=Length(sOldKey)+1 then
              sign:=10
            else if sOldKey[P] in [' ',#13,#10,#9] then
              inc(p)
            else
              sign:=-1;
          end;
      end;//end case
    end;//end while

    // 检查是否有重复的参数名称
    for i:=0 to PListCount-1 do
    begin
      if PListName[i]=FName then   //宏函数不允递归调用
      begin
        result:=false;
        exit;
      end;
      for j:=0 to i-1 do
      begin
        if PListName[i]=PListName[j] then
        begin
          result:=false;
          exit;
        end;
      end;
    end;

    //宏函数不允递归调用,但可以同名(重载),所以先做临时替换，避免循环调用
    SYS_DefineFPName_TempFName:='TCmSYS_DefineFPName_TempFName';
    if  FName=SYS_DefineFPName_TempFName then
    begin
      SYS_DefineFPName_TempFName:='TCmSYS_DefineFPName_TempFName2';
      self.DefineMarker(sOldValue,FName,SYS_DefineFPName_TempFName);
    end
    else
      self.DefineMarker(sOldValue,FName,SYS_DefineFPName_TempFName);
    {//
    if self.GetMarkerPos(sOldValue,Fname,1)>0 then
    begin
      result:=false;
      exit;
    end;}

    // 转换参数名称为系统名称
    for i:=0 to PListCount-1 do
    begin
      sTemp:='TCmSYS_DefineFPName_'+formatFloat('000',i);
      self.DefineMarker(sOldKey,PListName[i],sTemp);
      self.DefineMarker(sOldValue,PListName[i],sTemp);
      PListName[i]:=sTemp;
    end;

    setlength(PListD,PListCount+1);

    sign:=0;
    while true do
    begin
      case sign of
        -1:   // 出错状态
          begin
            result:=false;
            exit;
          end;
        10:  // 成功替换状态状态
          begin
            if self.DefineMarker(sOldtext,SYS_DefineFPName_TempFName,FName) then
            begin
              self.FExeText:=sOLdText;
              result:=true;
            end
            else
              result:=false;
            exit;
          end;
        0:   // 初始状态
          begin
            P:=1;
            sign:=1;
          end;
        1:
          begin
            i:=self.GetMarkerPos(sOldText,Fname,P);
            if i=0 then
              sign:=10
            else
            begin
              if GetPListD(sOldtext,i,PListD) then
              begin
                ///
                sTemp:=sOldValue;

                for j:=0 to PListCount-1 do
                begin
                  self.DefineMarker(sTemp,PListName[j],'('+copy(sOldText,PListD[j]+1,PListD[j+1]-PListD[j]-1)+')')
                end;
                pf1:=i;
                pf2:=PListD[pListCount];
                sOldText:=copy(sOldText,1,pf1-1)+'('+sTemp+')'+copy(sOldText,pf2+1,length(sOldText)-pf2);

                p:=i;//有可能陷入死循环 , 所以不允许宏函数递归调用
                sign:=1;
              end
              else
              begin
                p:=i+Length(Fname);
                sign:=1;
              end;
            end;
          end;

      end;//case
    end;//end while

  end;

end;

function TCompile.Dbxch(var s:string;var str:string):boolean; // f(x,y) => ((x)f(y))
var
  i0,i1   : integer;
  i2,i3   : integer;

  function getd(const str:string;var i0:integer):boolean;  // get ,
  var
    i   :integer;
  begin
    for i:=1 to length(str) do
    begin
      if str[i]=','  then
      begin
        result:=true;
        i0:=i;
        exit;
      end;
    end;
    result:=false;
    i0:=0;
  end;

  function GetR(const str :string;const iFirst:integer;var i1:integer):boolean; // get )
  var
    i,iR  :integer;
  begin
    ir:=0;
    for i:=iFirst to length(str) do
    begin
      if str[i]='(' then
        ir:=ir-1
      else if str[i]=')' then
        ir:=ir+1;
      if ir=1 then
      begin
        result:=true;
        i1:=i;
        exit;
      end;
    end;
    result:=false;
    i1:=0;
  end;

  function GetL(const i0:integer;const str :string;var i2:integer):boolean;  // get (
  var
    i,iL  :integer;
  begin
    iL:=0;
    for i:=i0 downto 1 do
    begin
      if str[i]=')' then
        iL:=iL-1
      else if str[i]='(' then
        iL:=iL+1;
      if iL=1 then
      begin
        result:=true;
        i2:=i;
        exit;
      end;
    end;
    result:=false;
    i2:=0;
  end;

  function GetLF(const i2:integer;const str :string;var i3:integer):boolean;  // get Function Name
  var
    i   :integer;
  begin
    for i:=i2-1 downto 1 do
    begin
      if i=0 then
      begin
        result:=false;
        i3:=0;
        exit;
      end;
      case upcase(str[i]) of
        '0'..'9','A'..'Z','_':;
        else
        begin
          if i=i2-1 then
          begin
            result:=false;
            i3:=0;
            exit;
          end
          else
          begin
            result:=true;
            i3:=i+1;
            exit;
          end;
        end;
      end;
      if i=1 then
      begin
          if i=i2-1 then
          begin
            result:=false;
            i3:=0;
            exit;
          end
          else
          begin
            result:=true;
            i3:=i;
            exit;
          end;
      end;
    end;
    result:=false;
    i3:=0;
  end;

begin
  while getd(str,i0) do
  begin
    if (GetR(str,i0+1,i1)) and (GetL(i0,str,i2)) then
    begin
      if (GetLF(i2,str,i3)) then
      begin
        str:= copy(str,1,i3-1)+'('+copy(str,i2,i0-i2)+')'
             +copy(str,i3,i2-i3)+'('+copy(str,i0+1,i1-i0-1)+')'
             +copy(str,i1,length(str)-i1+1);  //以前 ...-i1);
                    //这个错误太隐秘了,只有执行该句很多次的情况才会出错!终于找出来了:)
      end
      else
      begin
        ErrorCode:=csTCompile_Handwriting_Error;
        result:=false;
        exit;
      end;
    end
    else
    begin
      ErrorCode:=csTCompile_Handwriting_Error;
      result:=false;
      exit;
    end;
  end;
  s:=str;
  result:=true;
end;

// 书写格式转换函数  IF(a,b,c) =>TCmSYS_IF_1(TCmSYS_IF_0(b,c),a)
function  TCompile.DbxchSYS_Functionif(var s:string;var str:string):boolean;
var
  i,p   : integer;
  sign  : integer;
  sTemp : string;
  st    : string;
  PIF   : integer;
  P0,P1,P2,P3,P4 : integer;


  function getd(const str:string;const iFirst,iEnd:integer;var id:integer):boolean;// get next ,
  var
    i,iR   :integer;
  begin
    iR:=0;
    for i:=iFirst to iEnd do
    begin
      if str[i]='(' then
        iR:=iR-1
      else if str[i]=')' then
        iR:=iR+1
      else if (str[i]=',') and (iR=0) then
      begin
        result:=true;
        id:=i;
        exit;
      end;
    end;
    result:=false;
    id:=0;
  end;

  function GetR(const str :string;const iFirst:integer;var P4:integer):boolean; // 得到 if( ) 中的 )
  var
    i,iR  :integer;
  begin
    ir:=0;
    for i:=iFirst to length(str) do
    begin
      if str[i]='(' then
        ir:=ir-1
      else if str[i]=')' then
        ir:=ir+1;
      if ir=1 then
      begin
        result:=true;
        p4:=i;
        exit;
      end;
    end;
    result:=false;
    p4:=0;
  end;

  function GetP2P3P4(const str:string;const p1:integer;var p2,p3,p4:integer):boolean;
  begin
    if GetR(str,p1+1,p4) then
    begin
      if (GetD(str,p1+1,p4,p2))
      and (GetD(str,p2+1,p4,p3)) then
      begin
        result:=true;
        exit;
      end
      else
      begin
        result:=false;
        exit;
      end;
    end
    else
    begin
      result:=false;
      exit;
    end;
  end;

  function MYPos(const str: string):integer;
  var
    i : integer;
  begin
    result:=0;
    for i:=1 to length(str)-1 do
    begin
      if (str[i]='I') and (str[i+1]='F') then
      begin
        result:=i;
        exit;
      end;
    end;
  end;

begin
  P:=0;
  pIF:=0;
  sign:=0;
  sTemp:=str;
  while true do
  begin
    case sign of
      -1:   // 出错状态
        begin
          self.ErrorCode:=csTCompile_IFHandwriting_Error;
          result:=false;
          exit;
        end;
      10:   // 成功退出
        begin
          s:=sTemp;
          result:=true;
          exit;
        end;
      0 :   // 初始状态
        begin
          P:=1;
          sign:=1;
        end;
      1 :   // 查找IF状态
        begin
          st:=copy(stemp,p,length(stemp)-p+1);
          i:=MYPos(st);
          if (i=0) then
            sign:=10
          else
          begin
            if ((i=1) or
            (not (st[i-1] in ['A'..'Z','0'..'9','_'])))
            and ((i<=length(st)-2) and (st[i+2] in [' ',#13,#10,#9,'('] )) then
            begin
              PIF:=P-1+i;
              P:=PIF+2;
              sign:=2;
            end
            else  // not 'if'
            begin
              P:=p-1+i+2;
              sign:=1;
            end;
          end;
        end;
      2 :   // 找到IF状态  pIF->'IF'
        begin
          if p>=length(stemp) then
            sign:=-1
          else if (stemp[p] in [' ',#13,#10,#9])  then
          begin
            inc(p);
            sign:=2;
          end
          else if stemp[p]='(' then
          begin
            p0:=PIf;
            p1:=p;
            if GetP2P3P4(stemp,p1,p2,p3,p4) then
            begin
              //替换   IF(a,b,c) =>TCmSYS_IF_1(TCmSYS_IF_0(b,c),a)
              str:=stemp;
              stemp:=copy(str,1,p0-1)+'TCmSYS_IF_1(TCmSYS_IF_0(';
              stemp:=stemp+copy(str,p2+1,p4-p2-1)+'),';
              stemp:=stemp+copy(str,p1+1,p2-p1-1)+')';
              stemp:=stemp+copy(str,p4+1,length(str)-p4);
              P:=Pif;
              sign:=1;
            end
            else
              sign:=-1;
          end
          else
          begin
            sign:=-1;
          end;
        end;
    end;
  end;

end;

function  TCompile.DbxchSYS_ff(var s:string;var str:string):boolean; // ff(a,b,N,g(x)) => ( (a) F_TCmSYS_FF_0 (b) F_TCmSYS_FF_1 (N) F_TCmSYS_FF_2 ( g(x) ) )
var
  i0      :integer;
  i1,i2   :integer;
  i3,i4   :integer;
  i5      :integer;
  strX    :string;
  A_Z     :boolean;

  function GetStrX(var strX:string):boolean;  //得到积分变量字符串
  var
    //L   :integer;
    s   :string;
    iEnd  :integer;
  begin
    s:=strX;
    //L:=length(s);
    //if (L>2) and ( ((s[1]='''')and(s[L]='''')) or ((s[1]='"')and(s[L]='"')) ) then
    //begin
    //  s:=copy(s,2,L-2);
    //end;
    GetMarkerValue0(s,1,iEnd);
    if iEnd>0 then
    begin
      if iEnd=length(s) then
      begin
        result:=true ;
        strX:=copy(s,1,iEnd);
      end
      else
      begin
        result:=false;
        strX:='';
      end;
    end
    else
    begin
      result:=false;
      strX:='';
    end;
  end;

  function Getff(const st : string;var i0 :integer):boolean;   //得到 ff() 中的 (
  var
    i   :integer;
    str:string;
  begin
    A_Z:=false;
    str:=st+'#######';
    for i:=1 to length(str)-3 do
    begin
      if (A_Z=False) and (upcase(str[i])=upcase('f')) and (upcase(str[i+1])=upcase('f')) and (upcase(str[i+2])='(') then
      begin
        i0:=i+2;
        result:=true;
        exit;
      end;
      if str[i] in ['a'..'z','A'..'Z','0'..'9','_'] then
        A_Z:=true
      else
        A_Z:=false;
    end;
    i0:=0;
    result:=false;
  end;

  function getd(const str:string;const iFirst,iEnd:integer;var id:integer):boolean;// get next ,
  var
    i,iR   :integer;
  begin
    iR:=0;
    for i:=iFirst to iEnd do
    begin
      if str[i]='(' then
        iR:=iR-1
      else if str[i]=')' then
        iR:=iR+1
      else if (str[i]=',') and (iR=0) then
      begin
        result:=true;
        id:=i;
        exit;
      end;
    end;
    result:=false;
    id:=0;
  end;

  function GetR(const str :string;const iFirst:integer;var i5:integer):boolean; // 得到 ff( ) 中的 )
  var
    i,iR  :integer;
  begin
    ir:=0;
    for i:=ifirst to length(str) do
    begin
      if str[i]='(' then
        ir:=ir-1
      else if str[i]=')' then
        ir:=ir+1;
      if ir=1 then
      begin
        result:=true;
        i5:=i;
        exit;
      end;
    end;
    result:=false;
    i5:=0;
  end;

  function  GetGxd(const str:string;const iff2:integer;var il:integer):boolean; //找到g(x)前面的','位置
  var
    i,iR  :integer;
  begin
    ir:=0;
    for i:=iff2-1 downto 1 do
    begin
      if str[i]='(' then
        ir:=ir-1
      else if str[i]=')' then
        ir:=ir+1;
      if (ir=0) and (str[i]=',') then
      begin
        result:=true;
        iL:=i;
        exit;
      end;
    end;
    result:=false;
    iL:=0;
  end;

  Function Xch(const str:string;const sX:string):string; //  积分变量 'x' => 'TCmSYS_Const_ff_x_N'
  var
    cName   :string;
    strT    :string;
    i       :integer;
    s       :string;
    iEnd    :integer;

  begin
    cName:=uppercase('TCmSYS_Const_ff_x_')+inttostr(T_SYS_FF_ConstN); //积分变量名称
    inc(T_SYS_FF_ConstN);

    strT:='('+str+')';
    i:=2;
    while i<=length(strT)-1 do
    begin
      GetMarkerValue0(strT,i,iEnd);
      if iEnd<>0 then
      begin
        s:=copy(strT,i,iEnd-i+1);
        if uppercase(s)=uppercase(sX) then
        begin
          strT:=copy(strT,1,i-1)+cName+copy(strT,iEnd+1,Length(strT)-iEnd);
        end;
      end;
      i:=i+1;
    end;

    DbxchSYS_ff(s,strT);

    dec(T_SYS_FF_ConstN);
    
    result:=strT;
  end;

begin
  while getff(str,i0) do
  begin
    if (GetR(str,i0+1,i5)) then
    begin
      if (GetD(str,i0+1,i5,i1)) then
      begin
        if (GetD(str,i1+1,i5,i2)) then
        begin
          if (GetD(str,i2+1,i5,i3)) then
          begin
            strX:=copy(str,i2+1,i3-i2-1);
            if not  GetstrX(strX) then
            begin
              ErrorCode:=csTCompile_FFHandwriting_Error;
              result:=false;
              exit;
            end;
            if (GetD(str,i3+1,i5,i4)) then
            begin
              s:= copy(str,1,i0-3)+'(';
              s:=s +'('+copy(str,i0+1,i1-1-i0)+')TCmSYS_FF_0_'+formatFloat('0000',T_SYS_FF_ConstN);   //a
              s:=s +'('+copy(str,i1+1,i2-1-i1)+')TCmSYS_FF_1_'+formatFloat('0000',T_SYS_FF_ConstN);   //b
              s:=s +'('+copy(str,i3+1,i4-1-i3)+')TCmSYS_FF_2_'+formatFloat('0000',T_SYS_FF_ConstN);   //N
              s:=s +'('+Xch(copy(str,i4+1,i5-1-i4),strX)+')';           //g(x)
              s:=s +')'+copy(str,i5+1,length(str)-i5);
              str:=s;
            end
            else   //no  N  ,默认为 1000
            begin
              s:= copy(str,1,i0-3)+'(';
              s:=s +'('+copy(str,i0+1,i1-1-i0)+')TCmSYS_FF_0_'+formatFloat('0000',T_SYS_FF_ConstN);   //a
              s:=s +'('+copy(str,i1+1,i2-1-i1)+')TCmSYS_FF_1_'+formatFloat('0000',T_SYS_FF_ConstN);   //b
              s:=s +'(1000)TCmSYS_FF_2_'+formatFloat('0000',T_SYS_FF_ConstN);   //N =1000
              s:=s +'('+Xch(copy(str,i3+1,i5-1-i3),strX)+')';           //g(x)
              s:=s +')'+copy(str,i5+1,length(str)-i5);
              str:=s;
            end;
          END
          else
          begin
            ErrorCode:=csTCompile_FFHandwriting_Error;
            result:=false;
            exit;
          end;
        end
        else
        begin
           ErrorCode:=csTCompile_FFHandwriting_Error;
           result:=false;
           exit;
        end;
      end
      else
      begin
         ErrorCode:=csTCompile_FFHandwriting_Error;
         result:=false;
         exit;
      end;
    end
    else
    begin
       ErrorCode:=csTCompile_FFHandwriting_Error;
       result:=false;
       exit;
    end;
  end;
  s:=str;
  result:=true;
end;

function  TCompile.Conversion0(var s:string;var str:string):boolean; //得到参数(常数)列表、函数转换
var
  i1,i2 :integer;
  d     :TCmxFloat;
  PName :string;
  sTemp :string;
  iNow  :integer;
  iInc  :integer;
begin
  try
    result:=false;
    if (str<>'') and (str[1]<>'#') then
    begin
      iNow:=1;
      while (ErrorCode=0) and (iNow<=Length(str)) and (str[iNow]<>'#')do
      begin
        if upcase(str[iNow]) in ['0'..'9','.'] then
        begin
          i1:=iNow;
          i2:=0;
          GetFloatValue0(str,i1,i2);
          if i2<>0 then
          begin
             d:=strtofloat(copy(str,i1,i2-i1+1));
             pName:=ParameterListIn(d);
             s:=s+PName;
             iNow:=i2+1;
          end
          else
          begin
            ErrorCode:=csTCompile_ReadFloat_Error;
            result:=false;
          end;
        end
        else if ('A'<=upcase(str[iNow])) and (upcase(str[iNow])<='Z') or ('_'=upcase(str[iNow])) then
        begin
          i1:=iNow;
          i2:=0;
          GetMarkerValue0(str,i1,i2);
          if i2<>0 then
          begin
             sTemp:=copy(str,i1,i2-i1+1);
             if IfHaveFunction(sTemp) then
             begin
               s:=s+'@'+sTemp;
               if (str[i2+1]='(') and ( FunctionList[GetFunctionIndex(sTemp)].FCCount=1) then
                 iNow:=i2+2
               else
                 iNow:=i2+1;
             end
             else
             begin
               ParameterListIn(sTemp);
               s:=s+'&'+sTemp;
               iNow:=i2+1;
             end;
          end
          else
          begin                                      
            ErrorCode:=csTCompile_ReadMarker_Error;
            result:=false;
          end;
        end
        else if upcase(str[iNow]) in ['+','-','*','/','\','%','^'] then
        begin
          case str[iNow] of
            '+': sTemp:='@Add';
            '-': sTemp:='@Sub';
            '*': sTemp:='@Mul';
            '/': sTemp:='@Div';
            '\': sTemp:='@DivE';
            '%': sTemp:='@Mod';
            '^': sTemp:='@Power';
          end;
          s:=s+sTemp;
          inc(iNow);
        end
        else if upcase(str[iNow]) in ['=','<','>'] then
        begin
          iInc:=1;
          case str[iNow] of
            '=':begin
                  sTemp:='@TCmSYS_BooleanEQ';
                  iInc:=1;
                end;
            '<':begin
                  if str[iNow+1]='>' then
                  begin
                    sTemp:='@TCmSYS_BooleanNE';
                    iInc:=2;
                  end
                  else if str[iNow+1]='=' then
                  begin
                    sTemp:='@TCmSYS_BooleanLE';
                    iInc:=2;
                  end
                  else
                  begin
                    sTemp:='@TCmSYS_BooleanLT';
                    iInc:=1;
                  end;
                end;
            '>':begin
                  if str[iNow+1]='=' then
                  begin
                    sTemp:='@TCmSYS_BooleanGE';
                    iInc:=2;
                  end
                  else
                  begin
                    sTemp:='@TCmSYS_BooleanGT';
                    iInc:=1;
                  end;
                end;
          end;
          s:=s+sTemp;
          inc(iNow,iInc);
        end
        else if upcase(str[iNow]) in ['(',')'] then
        begin
          if str[iNow]='(' then
            s:=s+'@Bracket'
          else
            s:=s+'@'+upcase(str[iNow]);
          inc(iNow);
        end
        else
        begin
          ErrorCode:=csTCompile_Read_Error;
          result:=false;
        end;
      end;//while
    end
    else
      result:=true;
  except
    ErrorCode:=csTCompile_Read_Error;
    result:=false;
  end;
end;

procedure TCompile.SetEnabledNote(Value:boolean);  //是否允许使用注释
begin
  FEnabledNote:=Value;
end;


procedure TCompile.SetEnabledOptimizeDiv(Value: boolean);
begin
  FEnabledOptimizeDiv:=Value;
end;

procedure TCompile.SetEnabledOptimizeStack(Value:boolean);  
begin
  FEnabledOptimizeStack:=Value;
end;

procedure TCompile.SetEnabledOptimizeConst(Value:boolean);
begin
  FEnabledOptimizeConst:=Value;
end;

procedure TCompile.DelStrNote(var str:string);
var
  Nstr  :string;
  i     :integer;
  iEnd  :integer;

  function GetCL(const s:string;const iFirst:integer):integer; //返回 #13 #10 的位置
  var
    i   :integer;
  begin
    for i:=iFirst to length(s)-1 do
    begin
      if (s[i]=#13) and (s[i+1]=#10) then
      begin
        result:=i;
        exit;
      end;
    end;
    result:=0;
  end;

  function GetNextStar(const s:string;const iFirst:integer):integer; //返回 */ 的位置
  var
    i   :integer;
  begin
    for i:=iFirst to length(s)-1 do
    begin
      if (s[i]='*') and (s[i+1]='/') then
      begin
        result:=i;
        exit;
      end;
    end;
    result:=0;
  end;

  function GetNextSP(const s:string;const iFirst:integer):integer; //返回 } 的位置
  var
    i   :integer;
  begin
    for i:=iFirst to length(s)-1 do
    begin
      if (s[i]='}') then
      begin
        result:=i;
        exit;
      end;
    end;
    result:=0;
  end;

begin

  if not FEnabledNote then exit;  //不允许使用注释

  // 去掉注释部分
  str:='  '+str+'     ';
  Nstr:='';
  i:=3;
  while i<=length(str)-4 do
  begin
    if str[i]='/' then
    begin
      if str[i+1]='/' then
      begin
        iEnd:=GetCL(Str,i+2); //返回 #13 #10 的位置
        if iEnd=0 then
          break
        else
        begin
          i:=iEnd+2;
          Nstr:=NStr+' ';
        end;
      end
      else if str[i+1]='*' then
      begin
        iEnd:=GetNextStar(Str,i+2); //返回 */ 的位置
        if iEnd=0 then
        begin
          ErrorCode:=csTCompile_Note_Match_Error;
          exit;
        end
        else
        begin
          i:=iEnd+2;
          Nstr:=NStr+' ';
        end;
      end
      else
      begin
        Nstr:=Nstr+str[i];
        inc(i);
      end;
    end
    else if str[i]='{' then
    begin
      iEnd:=GetNextSP(Str,i+1); //返回 } 的位置
      if iEnd=0 then
      begin
        ErrorCode:=csTCompile_Note_Match_Error;
        exit;
      end
      else
      begin
        i:=iEnd+1;
        Nstr:=NStr+' ';
      end;
    end
    else
    begin
      Nstr:=Nstr+str[i];
      inc(i);
    end;
  end;
  str:=Nstr;
end;

function  TCompile.CheckBK(const str:string):boolean;//括号配对检查
var
  i     :integer;
  bk    :integer;
begin
  result:=true;
  bk:=0;
  for i:=1 to length(str) do
  begin
    if str[i]='(' then
      inc(bk)
    else if str[i]=')' then
    begin
      dec(bk);
      if bk<0 then
      begin
        result:=false;
        exit;
      end;
    end;
  end;
  if bk<>0 then
  begin
    result:=false;
    exit;
  end;
end;

function TCompile.Parsing(var str:string):boolean;//第一遍翻译
var
  s     :string;
  st    :string;
  i,k,j :integer;
  i1,i2 :integer;
begin
  try
    result:=true;

    if not CheckBK(str) then
    begin
      ErrorCode:=csTCompile_Bracket_Error;
      exit;
    end;

    s:=uppercase(str);    //不区分大小写

    
    DelStrNote(s); // 去掉注释部分
    if ErrorCode<>0  then
    begin
      result:=false;
      exit;
    end;

    s:='  '+s+'     ';
    st:='';
    for i:=3 to length(s)-4 do
    begin
      if (s[i]=#13) or (s[i]=#10) or (s[i]=#9) then  //去除 TAB键 回车 和 换行->替换为 空格
        st:=st+' '
      else if (s[i-1]=' ') and (s[i]='M') and (s[i+1]='O') // Mod 的处理 Mod ==> %
          and (s[i+2]='D') and (s[i+3]=' ') then
        st:=st+'%'
      else if (s[i-2]=' ') and (s[i-1]='M') and (s[i]='O') // Mod 的处理 Mod ==> %
          and (s[i+1]='D') and (s[i+2]=' ') then
        st:=st
      else if (s[i-3]=' ') and (s[i-2]='M') and (s[i-1]='O') // Mod 的处理 Mod ==> %
          and (s[i]='D') and (s[i+1]=' ') then
        st:=st
      else if s[i]='#' then
      begin
        ErrorCode:=csTCompile_Read_Error;
        result:=false;
        exit;
      end
      else
        st:=st+s[i];
    end;

    s:='  '+st+'  ';
    st:='';
    for i:=3 to length(s)-2 do
    begin
      if (s[i]='*') then       // ** ==> ^
      begin
        if (s[i+1]='*') and (s[i-1]<>'*') and (s[i+2]<>'*') then
          st:=st+'^'
        else if (s[i-1]='*') and (s[i-2]<>'*') and (s[i+1]<>'*') then
          st:=st
        else
          st:=st+s[i];
      end
      else
        st:=st+s[i];
    end;

    //       去掉 + - * / \ %  ^ , 前后的空格
    //       去掉 ( ) 前后的空格
    s:='   '+st+ '   ' ;
    st:='';
    i:=2;
    while i<=length(s)-1 do
    begin
      if s[i] in ['+','-','*','/','\','%','^',','  ,'(',')', '>','<','='] then   
      begin
        i1:=1;    //去前空格
        for k:=length(st) downto 1 do
        begin
          if st[k]<>' ' then
          begin
            i1:=k;
            break;
          end;
        end;
        st:=copy(st,1,i1)+s[i];
        
        i2:=length(s)+1;   //去后空格
        for j:=i+1 to length(s) do
        begin
          if s[j]<>' ' then
          begin
            i2:=j;
            break;
          end;
        end;
        st:=st;
        i:=i2;
      end
      else
      begin
        st:=st+s[i];
        inc(i);
      end;
    end;


    //去掉首尾的空格
    st:= '    '+st+'    ';
    i:=length(st)+1; //去首
    for k:=1 to length(st) do
    begin
      if st[k]<>' ' then
      begin
        i:=k;
        break;
      end;
    end;
    st:=copy(st,i,length(st)-i-1);
    i:=0; //去尾
    for k:=length(st) downto 1 do
    begin
      if st[k]<>' ' then
      begin
        i:=k;
        break;
      end;
    end;
    st:=copy(st,1,i);

    s:=st;
    st:='';
    for i:=1 to length(s) do       // 求正 和 求负 的先期处理 (去掉求正,求负时插入'0')
    begin
      if (s[i]='+') or (s[i]='-') then
      begin
        if i=1 then
          if s[i]='+' then
            st:=st
          else
            st:=st+'0'+s[i]
        else if (s[i-1]='(') or(s[i-1]=',') then
          if s[i]='+' then
            st:=st
          else
            st:=st+'0'+s[i]
        else
          st:=st+s[i];
      end
      else
        st:=st+s[i];
    end;

    s:=st+'########';      // '#' 为结束标志
    st:='';
    DbxchSYS_ff(st,s);    // ff(a,b,N,g(x)) => ( (a) TCmSYS_FF_0 (b) TCmSYS_FF_1 (N) TCmSYS_FF_2 ( g(x) ) )
    if ErrorCode<>0  then
    begin
      result:=false;
      exit;
    end;

    s:=st+'#######';      // '#' 为结束标志
    st:='';
    DbxchSYS_FunctionIf(st,s);
    if ErrorCode<>0  then
    begin
      result:=false;
      exit;
    end;


    s:=st+'#######';      // '#' 为结束标志
    st:='';
    Dbxch(st,s);        //f(x,y) => ((x)f(y))
    if ErrorCode<>0  then
    begin
      result:=false;
      exit;
    end;


    s:=st+'#######';      // '#' 为结束标志
    st:='';
    Conversion0(st,s); //得到参数(常数)列表、函数转换
    if ErrorCode<>0  then
    begin
      result:=false;
      exit;
    end;
    
    st:=uppercase(st);

    str:=st+'#######';
  except
    result:=false;
  end;
end;

function  TCompile.ifSYS_ff(const fName:string):boolean;
var
  L :integer;
begin
  result:=false;
  L:=length('@TCmSYS_FF_');
  if  ( length(fName)>=L) then
  begin
    if (uppercase(copy(fName,1,L-1))=uppercase('TCmSYS_FF_'))
      or (uppercase(copy(fName,1,L))=uppercase('@TCmSYS_FF_')) then
    begin
      result:=true;
    end;
  end
  else
    result:=false;
end;

function  TCompile.getSYS_ff(const fName:string):string;
var
  L  : integer;
begin
  L:=Length('@TCmSYS_FF_');
  if fName[1]='@' then
    result:=copy(fName,1,L+1)   //@TCmSYS_FF_N
  else
    result:='@'+copy(fName,1,L);
end;

procedure TCompile.T_PTrueNowListIN(const TP:TT_PTrue);
begin
  if PT_PTrueNowList>=high(T_PTrueNowList)-1 then
  begin
    setlength(T_PTrueNowList,2*high(T_PTrueNowList)+2);
  end;
  T_PTrueNowList[PT_PTrueNowList]:=TP;
  inc(PT_PTrueNowList);
end;

function  TCompile.T_PTrueNowListOut():TT_PTrue;
begin
  dec(PT_PTrueNowList);
  result:=T_PTrueNowList[PT_PTrueNowList];
end;

procedure  TCompile.FunctionStackIn(const s:string); //压入
begin
  if PFunctionStack>=high(FunctionStack)-1 then
  begin
    setlength(FunctionStack,2*high(FunctionStack)+2);
  end;
  FunctionStack[PFunctionStack] := s;
  inc(PFunctionStack);
End ;

Function TCompile.FunctionStackOut() :string;  //弹出
begin
  dec(PFunctionStack) ;
  result:= FunctionStack[PFunctionStack] ;
End ;

Function TCompile.FunctionStackRead() :string;  //读出
begin
  result:= FunctionStack[PFunctionStack-1] ;
End ;

function TCompile.ParameterListIn(const PName:string):integer;
var
  sName :string;
  i     :integer;
begin
  result:=-1;
  sName:=PName;
  if (sName<>'')  then
  begin
    if sName[1]<>'&' then sName:='&'+sName;
    if not IfHaveParameter(sName) then
    begin
      if PExeParameter>=high(ExeParameter)-64 then
      begin
        setlength(ExeParameter,2*high(ExeParameter)+2);
        for i:=0 to PParameterList-1 do
        begin
          if not ParameterList[i].IsExterior then
            ParameterList[i].CAddress:=@ExeParameter[ParameterList[i].CIndex];
        end;
      end;
      if PParameterList>=high(ParameterList)-1 then
      begin
        setlength(ParameterList,2*high(ParameterList)+2);
      end;
      ParameterList[PParameterList].CName:=uppercase(sName);
      ParameterList[PParameterList].CAddress:=@ExeParameter[PExeParameter];
      ParameterList[PParameterList].isConst:=false;
      ParameterList[PParameterList].CIndex:=PExeParameter;
      ParameterList[PParameterList].IsExterior:=false;
      result:=PParameterList;

      if sName='&PI' then       //常量 PI=3.1415926...
      begin
        PTCmxFloat(@ExeParameter[PExeParameter])^:=3.1415926535897932384626433832795;
        ParameterList[PParameterList].isConst:=true;
      end
      else if sName='&TRUE' then     //常量 true=1
      begin
        PTCmxFloat(@ExeParameter[PExeParameter])^:=1.0;
        ParameterList[PParameterList].isConst:=true;
      end
      else if sName='&FALSE' then    //常量 false=0
      begin
        PTCmxFloat(@ExeParameter[PExeParameter])^:=0.0;
        ParameterList[PParameterList].isConst:=true;
      end
      else if sName='&E' then   //变量e=2.718281828...
        PTCmxFloat(@ExeParameter[PExeParameter])^:=2.7182818284590452353602874713527
      else
        PTCmxFloat(@ExeParameter[PExeParameter])^:=0;

      inc(PExeParameter,SYS_EFLength);
      inc(PParameterList);
    end;
  end;
end;

function TCompile.ParameterListIn(const dValue:TCmxFloat):string;
var
   //strName  :string;
   i        :integer;
begin
  //if not IfHaveParameter(dValue,strName) then
  //begin
    if PExeParameter>=high(ExeParameter)-64 then
    begin
      setlength(ExeParameter,2*high(ExeParameter)+2);
      for i:=0 to PParameterList-1 do
      begin
        if not ParameterList[i].IsExterior then
          ParameterList[i].CAddress:=@ExeParameter[ParameterList[i].CIndex];
      end;
    end;
    if PParameterList>=high(ParameterList)-1 then
    begin
      setlength(ParameterList,2*high(ParameterList)+2);
    end;
    ParameterList[PParameterList].CName:=uppercase('&TCmSYS_Const_'+inttostr(PParameterList));
    result:=ParameterList[PParameterList].CName;
    ParameterList[PParameterList].CAddress:=@ExeParameter[PExeParameter];
    ParameterList[PParameterList].isConst:=true;        
    ParameterList[PParameterList].CIndex:=PExeParameter;
    ParameterList[PParameterList].IsExterior:=false;

    PTCmxFloat(@ExeParameter[PExeParameter])^:=dValue;

    inc(PExeParameter,SYS_EFLength);  
    inc(PParameterList);

  //end
  //else
  //begin
  //  result:=strName;
  //end;
end;

function  TCompile.GetParameterListConstIndex(const PName:string):integer;
var
  sName   :string;
  i       :integer;
begin
  sName:=PName;
  if (sName<>'')  then
  begin
    if sName[1]<>'&' then sName:='&'+sName;
    if IfHaveParameter(sName) then
    begin
      for i:=0 to PParameterList-1 do
      begin
        if (ParameterList[i].CName=uppercase(sName))
          and (ParameterList[i].isConst=true) then
        begin
          result:=i;
          exit;
        end;
      end;
    end;
  end;
  result:=-1;
end;

function TCompile.GetParameterValue(const PName:string):TCmxFloat;
var
  i     :integer;
  sName :string;
begin
  try
    result:=0;
    sName:=uppercase(PName);
    if (sName<>'')  then
    begin
      if sName[1]<>'&' then sName:='&'+sName;
      for i:= 0 to PParameterList-1 do
      begin
        if uppercase(ParameterList[i].CName)=sName then
        begin   
          result:=ParameterList[i].CAddress^;
          exit;
        end;
      end;
    end;
  except
    result:=0;
  end;
end;

Function  TCompile.GetParameterCount():integer;    //得到参数的总数目
begin
  result:=PParameterList;
end;

Function  TCompile.GetFunctionPlistCount():integer;    //返回用户设置的参数的数目
begin
  result:=self.FFunctionPlistCount;
end;

Function  TCompile.GetUserParameterCount():integer;    //得到参数的总数目(不包含常数)
var
  i     : integer;
  Ls    : integer;
begin
  Ls:=0;
  for i:=0 to PParameterList-1 do
  begin
    if ParameterList[i].isConst=false then
      inc(Ls);
  end;
  result:=Ls;
end;

procedure TCompile.GetParameterList(var PList:array of TParameterList); //返回参数列表
var
  i     :integer;
  Ls    : integer;
begin
  Ls:=low(PList);
  for i:=0 to PParameterList-1 do
  begin
    PList[Ls+i]:=ParameterList[i];
  end;
end;

procedure TCompile.GetUserParameterList(var PList:array of TUserParameterList); //返回参数列表(不包含常数)
var
  i     :integer;
  Ls    : integer;
begin
  Ls:=low(PList);
  for i:=0 to PParameterList-1 do
  begin
    if ParameterList[i].isConst=false then
    begin
      PList[Ls].CName:=ParameterList[i].CName;
      PList[Ls].CAddress:=ParameterList[i].CAddress;
      inc(Ls);
    end;
  end;
end;

function  TCompile.IfHaveParameter(const PName:string):boolean;
var
  i     :integer;
  sName :string;
begin
  try
    result:=false;
    sName:=uppercase(PName);
    if (sName<>'')  then
    begin
      if sName[1]<>'&' then sName:='&'+sName;
      for i:= 0 to PParameterList-1 do
      begin
        if uppercase(ParameterList[i].CName)=sName then
        begin
          result:=true;
          exit;
        end;
      end;
    end;
  except
    result:=false;
  end;
end;

function  TCompile.IfHaveUnDefineParameter():boolean;
begin
  if self.FFunctionPlistCount<>self.GetUserParameterCount then
    result:=true
  else
    result:=false;
end;

function  TCompile.IfHaveParameter(const dValue:TCmxFloat;var cName:string):boolean;
var
  i     :integer;
begin
  try
    result:=false;
    for i:= 0 to PParameterList-1 do
    begin
      if (ParameterList[i].isConst=true)
         and (ParameterList[i].CAddress^=dValue) then
      begin
        result:=true;
        cName:=ParameterList[i].CName;
        exit;
      end;
    end;
  except
    result:=false;
  end;
end;

procedure TCompile.FunctionListIn(const s:string;const F:Pointer;const iCount:integer);
begin
  FunctionList[PFunctionList].FName:=uppercase(s);
  FunctionList[PFunctionList].FAddress:=F;
  FunctionList[PFunctionList].FCCount:=iCount;
  PFunctionList:=PFunctionList+1;
end;

procedure TCompile.GetFunctionList();
var
  i  :integer;
begin
  for i:=low(FunctionList) to high(FunctionList) do
  begin
    FunctionList[i].FName:='';
    FunctionList[i].FAddress:=Pointer(0);
    FunctionList[i].FCCount:=0;
  end;
  PFunctionList:=0;
  FunctionListIn('@Add',@TCompile.F_Add,2);
  FunctionListIn('@Sub',@TCompile.F_Sub,2);
  FunctionListIn('@Mul',@TCompile.F_Mul,2);
  FunctionListIn('@Div',@TCompile.F_Div,2);
  FunctionListIn('@DivE',@TCompile.F_DivE,2);
  FunctionListIn('@Mod',@TCompile.F_Mod,2);
  FunctionListIn('@Power',@TCompile.F_Power,2);
  FunctionListIn('@IntPower',@TCompile.F_IntPower,2);
  FunctionListIn('@Max',@TCompile.F_Max,2);
  FunctionListIn('@Min',@TCompile.F_Min,2);
  FunctionListIn('@Bracket',@TCompile.F_Bracket,1);
  FunctionListIn('@Sqr',@TCompile.F_Sqr,1);
  FunctionListIn('@Sqr3',@TCompile.F_Sqr3,1);
  FunctionListIn('@Sqr4',@TCompile.F_Sqr4,1);
  FunctionListIn('@Sqrt',@TCompile.F_Sqrt,1);
  FunctionListIn('@Rev',@TCompile.F_Rev,1);
  FunctionListIn('@Sin',@TCompile.F_Sin,1);
  FunctionListIn('@Cos',@TCompile.F_Cos,1);
  FunctionListIn('@Tan',@TCompile.F_Tan,1);
    FunctionListIn('@tg',@TCompile.F_Tan,1);
  FunctionListIn('@ArcSin',@TCompile.F_ArcSin,1);
  FunctionListIn('@ArcCos',@TCompile.F_ArcCos,1);
  FunctionListIn('@ArcTan',@TCompile.F_ArcTan,1);
  FunctionListIn('@Arctg',@TCompile.F_ArcTan,1);
  FunctionListIn('@ArcTan2',@TCompile.F_ArcTan2,2);
  FunctionListIn('@Arctg2',@TCompile.F_ArcTan2,2);
  FunctionListIn('@Ln',@TCompile.F_Ln,1);
  FunctionListIn('@Log',@TCompile.F_Log,1);
    FunctionListIn('@Log10',@TCompile.F_Log,1);
  FunctionListIn('@Log2',@TCompile.F_Log2,1);
  FunctionListIn('@TCmSYS_Fld_Value',@TCompile.F_SYS_Fld_Value,1);
  FunctionListIn('@Abs',@TCompile.F_Abs,1);
  FunctionListIn('@Floor',@TCompile.F_Floor,1);
    FunctionListIn('@Int',@TCompile.F_Floor,1);
  FunctionListIn('@Trunc',@TCompile.F_Trunc,1);
  FunctionListIn('@Round',@TCompile.F_Round,1);
  FunctionListIn('@Ceil',@TCompile.F_Ceil,1);
  FunctionListIn('@Sgn',@TCompile.F_Sgn,1);
  FunctionListIn('@Exp',@TCompile.F_exp,1);
  FunctionListIn('@Ctg',@TCompile.F_Ctg,1);
    FunctionListIn('@Cot',@TCompile.F_Ctg,1);
  FunctionListIn('@Sec',@TCompile.F_Sec,1);
  FunctionListIn('@Csc',@TCompile.F_Csc,1);
  FunctionListIn('@Hypot',@TCompile.F_Hypot,2);
  FunctionListIn('@TCmSYS_Fstp_Value',@TCompile.F_SYS_Fstp_Value,2);
  FunctionListIn('@TCmSYS_IF_0',@TCompile.F_SYS_IF_0,2);
  FunctionListIn('@TCmSYS_IF_1',@TCompile.F_SYS_IF_1,2);
  FunctionListIn('@SqrAdd',@TCompile.F_SqrAdd,2);
  FunctionListIn('@SinH',@TCompile.F_SinH,1);
  FunctionListIn('@CosH',@TCompile.F_CosH,1);
  FunctionListIn('@TanH',@TCompile.F_Tanh,1);
    FunctionListIn('@tgH',@TCompile.F_Tanh,1);
  FunctionListIn('@ArcCosH',@TCompile.F_ArcCosH,1);
  FunctionListIn('@ArcSinH',@TCompile.F_ArcSinH,1);
  FunctionListIn('@ArcTanH',@TCompile.F_ArcTanh,1);
    FunctionListIn('@ArctgH',@TCompile.F_ArcTanh,1);
  FunctionListIn('@SecH',@TCompile.F_SecH,1);
  FunctionListIn('@CscH',@TCompile.F_CscH,1);
  FunctionListIn('@CtgH',@TCompile.F_CtgH,1);
    FunctionListIn('@CotH',@TCompile.F_CtgH,1);
  FunctionListIn('@ArcSec',@TCompile.F_ArcSec,1);
  FunctionListIn('@ArcCsc',@TCompile.F_ArcCsc,1);
  FunctionListIn('@ArcCtg',@TCompile.F_ArcCtg,1);
    FunctionListIn('@ArcCot',@TCompile.F_ArcCtg,1);
  FunctionListIn('@ArcSecH',@TCompile.F_ArcSecH,1);
    FunctionListIn('@ASecH',@TCompile.F_ArcSecH,1);
  FunctionListIn('@ArcCscH',@TCompile.F_ArcCscH,1);
    FunctionListIn('@ACscH',@TCompile.F_ArcCscH,1);
  FunctionListIn('@ArcCotH',@TCompile.F_ArcCtgH,1);
    FunctionListIn('@ACotH',@TCompile.F_ArcCtgH,1);
  FunctionListIn('@RND',@TCompile.F_Rnd,1);
    FunctionListIn('@Rand',@TCompile.F_Rnd,1);
    FunctionListIn('@Random',@TCompile.F_Rnd,1);

  FunctionListIn('@TCmSYS_FF_0',@TCompile.F_SYS_FF_0,2);
  FunctionListIn('@TCmSYS_FF_1',@TCompile.F_SYS_FF_1,2);
  FunctionListIn('@TCmSYS_FF_2',@TCompile.F_SYS_FF_2,2);

  FunctionListIn('@AND',@TCompile.FB_AND,2);
  FunctionListIn('@OR',@TCompile.FB_OR,2);
  FunctionListIn('@XOR',@TCompile.FB_XOR,2);
  FunctionListIn('@NOT',@TCompile.FB_NOT,1);
  FunctionListIn('@TCmSYS_BooleanEQ',@TCompile.FB_EQ,2);
  FunctionListIn('@TCmSYS_BooleanNE',@TCompile.FB_NE,2);
  FunctionListIn('@TCmSYS_BooleanLT',@TCompile.FB_LT,2);
  FunctionListIn('@TCmSYS_BooleanGT',@TCompile.FB_GT,2);
  FunctionListIn('@TCmSYS_BooleanLE',@TCompile.FB_LE,2);
  FunctionListIn('@TCmSYS_BooleanGE',@TCompile.FB_GE,2);


end;

Function TCompile.GetFunctionIndex(const fName:string):integer;
var
  i     :integer;
  sName :string;
begin
  try
    result:=-1;
    sName:=uppercase(fName);
    if (sName<>'')  then
    begin
      if sName[1]<>'@' then sName:='@'+sName; 
      if ifSYS_ff(sName) then sName:=GetSYS_ff(sName);
      for i:= 0 to PFunctionList-1 do
      begin
        if uppercase(FunctionList[i].FName)=sName then
        begin
          result:=i;
          exit;
        end;
      end;
    end;
  except
    result:=-1;
  end;
end;

function  TCompile.IfHaveFunction (const fName:string):boolean;
var
  i     :integer;
  sName :string;
begin
  try
    result:=false;
    sName:=uppercase(fName);
    if (sName<>'')  then
    begin
      if sName[1]<>'@' then sName:='@'+sName;
      if ifSYS_ff(sName) then sName:=GetSYS_ff(sName);
      for i:= 0 to PFunctionList-1 do
      begin
        if uppercase(FunctionList[i].FName)=sName then
        begin
          result:=true;
          exit;
        end;
      end;
    end;
  except
    result:=false;
  end;
end;


//======================
//编译 函数
Procedure TCompile.F_Add();
begin
  //加法
  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  ExeAddressCodeIn('dec1'); //faddp st(1),st    st+st(1) -> st
end;

Procedure TCompile.F_Sub();
begin
  //减法
  if not OptimizeStackCall(false) then
  begin
    CompileOutP();  //[ecx] -> st , old st -> st(1)
    ExeAddressCodeIn('dee1');  //fsubrp st(1),st    st-st(1) -> st
  end
  else
  begin
    ExeAddressCodeIn('dee9');  //fsubp st(1),st    st-st(1) -> st
  end;
  //}
end;

Procedure TCompile.F_Mul();
begin
  //乘法
  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  ExeAddressCodeIn('dec9');  //fmulp st(1),st  ,  st*st(1) -> st
end;

Procedure TCompile.F_Div();
begin
  //除法
  if not OptimizeStackCall(false) then
  begin
    CompileOutP();  //[ecx] -> st , old st -> st(1)
    ExeAddressCodeIn('def1');  //fdivrp st(1),st    st/st(1) -> st
  end
  else
  begin
    ExeAddressCodeIn('def9');  //fdivp st(1),st    st/st(1) -> st
  end;
  //}
end;

Procedure TCompile.F_DivE();
begin
  //整除
  if not OptimizeStackCall(false) then
  begin
    CompileOutP();  //[ecx] -> st , old st -> st(1)
    ExeAddressCodeIn('def1');  //fdivrp st(1),st    st/st(1) -> st
  end
  else
  begin
    ExeAddressCodeIn('def9');  //fdivp st(1),st    st/st(1) -> st
  end;
  F_Trunc();

end;

Procedure TCompile.F_Mod();
begin
  //求余
  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  ExeAddressCodeIn('d9f8');  //fprem ,  st-Trunc(st/st(1))*st(1) -> st
  ExeAddressCodeIn('ddd9');  //fstp st(1) ,  st ->st(1)  ,pop
end;

Procedure TCompile.F_Max();
begin
  //最大值
  {
  if x1>=x0 then
    result:=x1
  else
    result:=x0;

 }
 {
  asm

            fcom
            fstsw   ax
            sahf
            jnb     @elsex
              fxch    st(1)
    @elsex:
            fstp    st(1)

  end; //}
  //{
  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('d8d1');     // fcompp
  ExeAddressCodeIn('9b');       // fwait
  ExeAddressCodeIn('dfe0');     // fstsw ax
  ExeAddressCodeIn('9e');       // sahf
  ExeAddressCodeIn('7302');     // jnb + $02

  ExeAddressCodeIn('d9c9');     // @else:  fxch  st(1)
  ExeAddressCodeIn('ddd9');     //fstp st(1) ,  st ->st(1)  ,pop
  //}
end;

Procedure TCompile.F_Min();
begin
  //最小值
  {
  if x1>=x0 then
    result:=x0
  else
    result:=x1;

  asm

            fcom
            fstsw   ax
            sahf
            jb      @elsex
              fxch    st(1)
    @elsex:
            fstp    st(1)

  end; }

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('d8d1');     // fcompp
  ExeAddressCodeIn('9b');       // fwait
  ExeAddressCodeIn('dfe0');     // fstsw ax
  ExeAddressCodeIn('9e');       // sahf
  ExeAddressCodeIn('7202');     // jb + $02    //jnb @else

  ExeAddressCodeIn('d9c9');     // @else:  fxch  st(1)
  ExeAddressCodeIn('ddd9');     //fstp st(1) ,  st ->st(1)  ,pop
  //}
  
end;

//(*
Procedure TCompile.F_Power();
begin
  //指数次方 Power(x,y); 求x的y次方
  {
      if y = 0.0 then
        x := 1.0               // x^0 = 1
      else if (x = 0.0) and (y > 0.0) then
        x := 0.0               // 0^y = 0, y > 0
      else if Frac(y) = 0.0 then
      begin
        if x > 0.0 then
          x:=Exp(y*Ln(x))
        else if (Trunc(y) Mod 2)=0 then
          x:=Exp(y*Ln(-x))
        else
          x:=-Exp(y*Ln(-x));
      end
      else
        x := Exp(y * Ln(x))

  asm
        @if0:
                  fldz
                  fcomp
                  fstsw     ax
                  sahf
                  jb        @else  //(x>0)

        @elseif1:
                  fxch      st(1)
                  fldz
                  fcomp
                  fxch      st(1)
                  fstsw     ax
                  sahf
                  jne       @elseif2   //(y<>0)

                    fld1
                    fstp      st(1)
                    fstp      st(1)
                    jmp       @end

        @elseif2:
                  fldz
                  fcomp
                  fstsw     ax
                  sahf
                  jne       @elseif3  //(x<>0)

                    fldz
                    fcomp     st(2)
                    fstsw     ax
                    sahf
                    jnb       @elseif3 //(y<=0)

                      fldz
                      fstp      st(1)
                      fstp      st(1)
                      jmp       @end

        @elseif3:
                  fld       st(1)
                  fld1
                  fxch      st(1)
                  fprem
                  fstp      st(1)

                  fldz
                  fcomp
                  fxch      st(1)
                  fstp      st(1)
                  fstsw     ax
                  sahf
                  jne       @else    //(y mod 1<>0)

                    fchs
                    fldln2
                    fxch
                    fyl2x
                    fmul      st,st(1)

                    FLDL2E            //exp()...
                    FMULp   st(1),st
                    FLD  ST(0)
                    FRNDINT
                    FSUB  ST(1), ST
                    FXCH  ST(1)
                    F2XM1
                    FLD1
                    FADDp   st(1),st
                    FSCALE
                    FSTP    ST(1)

                    fxch      st(1)
                    fld1
                    fadd      st,st(0)
                    fxch      st(1)
                    fprem
                    fstp      st(1)

                    fldz
                    fcomp
                    fxch      st(1)
                    fstp      st(1)
                    fstsw     ax
                    sahf
                    je        @end    //(y mod 2=0)

                      fchs
                      jmp       @end

        @else:
                  fldln2
                  fxch  
                  fyl2x
                  fmulp     st(1),st

                  FLDL2E            //exp()...
                  FMULp   st(1),st
                  FLD  ST(0)
                  FRNDINT
                  FSUB  ST(1), ST
                  FXCH  ST(1)
                  F2XM1
                  FLD1
                  FADDp   st(1),st
                  FSCALE
                  FSTP    ST(1)

        @end:
                  fwait
                  
  end;
}

  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('0F828B000000');

  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('750B');

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('DDD9');
    ExeAddressCodeIn('DDD9');
    ExeAddressCodeIn('E990000000');

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7512');

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('D8DA');
    ExeAddressCodeIn('9B');
    ExeAddressCodeIn('DFE0');
    ExeAddressCodeIn('9E');
    ExeAddressCodeIn('7308');

      ExeAddressCodeIn('D9EE');
      ExeAddressCodeIn('DDD9');
      ExeAddressCodeIn('DDD9');
      ExeAddressCodeIn('EB74');

  ExeAddressCodeIn('D9C1');
  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('D9F8');
  ExeAddressCodeIn('DDD9');

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('DDD9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('753E');
  
    ExeAddressCodeIn('D9E0');
    ExeAddressCodeIn('D9ED');
    ExeAddressCodeIn('D9C9');
    ExeAddressCodeIn('D9F1');
    ExeAddressCodeIn('D8C9');

    F_Exp();

    ExeAddressCodeIn('D9C9');
    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('D8C0');
    ExeAddressCodeIn('D9C9');
    ExeAddressCodeIn('D9F8');
    ExeAddressCodeIn('DDD9');

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('D8D9');
    ExeAddressCodeIn('D9C9');
    ExeAddressCodeIn('DDD9');
    ExeAddressCodeIn('9B');
    ExeAddressCodeIn('DFE0');
    ExeAddressCodeIn('9E');
    ExeAddressCodeIn('7422');

      ExeAddressCodeIn('D9E0');
      ExeAddressCodeIn('EB1E');

  ExeAddressCodeIn('D9ED');
  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('D9F1');
  ExeAddressCodeIn('DEC9');

  F_Exp();

end;
//power *)

Procedure TCompile.F_IntPower();
begin
  //指数次方 Power(x,N); 求x的N次方 N为整数
  {
  asm
        fistp   dword ptr  [edx]
        fld1
        mov     eax,[edx]
        fxch    st(1)

        test    eax,eax
        jz      @@4
        jg      @@3
          fld1
          fdivrp  st(1),st
          neg  eax

        jmp     @@3

      @@2:
        fmul    ST(0), ST
      @@3:
        shr     eax,1
        jnc     @@2

        fmul    ST(1),ST
        jnz     @@2

      @@4:
        fstp    st
  end;
  //}

      if not OptimizeStackCall(false) then
      begin
        CompileOutP();
        ExeAddressCodeIn('D9C9');
      end;

      ExeAddressCodeIn('DB1A');
      ExeAddressCodeIn('D9E8');
      ExeAddressCodeIn('8B02');
      ExeAddressCodeIn('D9C9');
      ExeAddressCodeIn('85C0');
      ExeAddressCodeIn('7414');
      ExeAddressCodeIn('7F0A');

        ExeAddressCodeIn('D9E8');
        ExeAddressCodeIn('DEF1');
        ExeAddressCodeIn('F7D8');

      ExeAddressCodeIn('EB02');

      ExeAddressCodeIn('D8C8');
      ExeAddressCodeIn('D1E8');
      ExeAddressCodeIn('73FA');
      ExeAddressCodeIn('DCC9');
      ExeAddressCodeIn('75F6');
      ExeAddressCodeIn('DDD8');
      
end;

Procedure TCompile.F_Bracket(); { ()函数 }
begin
  //什么都不干  ,所以增加表达式中的括号并不会降低编译以后的代码执行速度
  //在不容易分清楚计算顺序时请多使用括号
end;

Procedure TCompile.F_Sqr();
begin
  //平方
  ExeAddressCodeIn('d8c8');  // fmul st(0)  ,st*st -> st
end;

Procedure TCompile.F_Sqr3();
begin
  //立方
{
asm
    fld     st(0)
    fmul    st(0),st
    fmulp   st(1),st
end;
//}
  ExeAddressCodeIn('D9C0');
  ExeAddressCodeIn('D8C8');
  ExeAddressCodeIn('DEC9');
end;

Procedure TCompile.F_Sqr4();
begin
  //立方
  ExeAddressCodeIn('d8c8');  // fmul st(0)  ,st*st -> st
  ExeAddressCodeIn('d8c8');  // fmul st(0)  ,st*st -> st
end;

Procedure TCompile.F_Sqrt();
begin
  //开平方
  ExeAddressCodeIn('d9fa');  // fsqrt  ,st^0.5-> st
end;

Procedure TCompile.F_Rev();
begin
  //倒数
  ExeAddressCodeIn('d9e8');  // fld1
  ExeAddressCodeIn('def1');  //fdivrp st(1), st  st/st(1) -> st
end;

Procedure TCompile.F_Sin();
begin
  //正弦 Sin
  ExeAddressCodeIn('d9fe');  // fsin  ,Sin(st)-> st
end;

Procedure TCompile.F_Cos();
begin
  //余弦 Cos
  ExeAddressCodeIn('d9ff');    // fcos  ,Cos(st)-> st
end;

Procedure TCompile.F_Tan();
begin
  //正切 tg 或 Tan
  ExeAddressCodeIn('d9f2');  // ftan ,tg(st)-> st(1) : 1 -> st
  ExeAddressCodeIn('ddd8');  // fstp ,st(1)->st
end;

Procedure TCompile.F_Ln();
begin
  //自然对数 Ln
   //Ln(x)=Ln(2)*Log2(x)

  ExeAddressCodeIn('d9ed');  // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st

end;

Procedure TCompile.F_Log();
begin
  //10的对数
   //Log10(x)=Log(2)*Log2(x)

  ExeAddressCodeIn('d9ec');  // fldlg2   , Log10(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st

end;

Procedure TCompile.F_Log2();
begin
  //2的对数
   //Log2(x)=1*Log2(x)

  ExeAddressCodeIn('d9e8');  // fld1   , 1 -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st

end;

procedure TCompile.F_SYS_Fld_Value();//代码中载入值
begin
//相当于 fld  [st]  用以支持数组
{
  asm
     fistp  dword ptr   [edx]
     mov    eax,[edx]
     fld    [eax]

  end;
 }

  ExeAddressCodeIn('DB1A');
  ExeAddressCodeIn('8B02');
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db28');  //fld  tbyte ptr [eax] ,  [eax] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D900');  //fld  dword ptr [eax] ,  [eax] -> st
    {$else}
    ExeAddressCodeIn('DD00');  //fld  qword ptr [eax] ,  [eax] -> st
    {$endif}
  {$endif}

end;

procedure TCompile.F_SYS_Fstp_Value();//代码中传出值  相当于mov  [st],st(1)
begin
  //可以用来处理数组赋值
  // SYS_Fstp(a,b)=mov [a],b ;result:=b;
{
  asm
     fistp  dword ptr  [edx]
     fld    st(0)
     mov    eax,[edx]
     fstp   [eax]
  end;
}
  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DB1A');
  ExeAddressCodeIn('D9C0');
  ExeAddressCodeIn('8B02');
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('DB38');                           //fstp  tbyte ptr  [eax]
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D918');                         //fstp  dword ptr  [eax]
    {$else}
    ExeAddressCodeIn('DD18');                         //fstp  qword ptr  [eax]
    {$endif}
  {$endif}

end;

Procedure TCompile.F_Abs();
begin
  //绝对值
  ExeAddressCodeIn('d9e1');  // fabs   , |st|-> st
end;

Procedure TCompile.F_SqrAdd();
begin 
{
   x:=x*x+y*y

   asm
       fmul  st,st(0)
       fxch  st(1)
       fmul  st,st(0)
       faddp st(1),st
   end;
}
  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('D8C8');
  ExeAddressCodeIn('D9C9');
  ExeAddressCodeIn('D8C8');
  ExeAddressCodeIn('DEC1');

end;


Procedure TCompile.F_Floor();
begin
  //向负无穷大取整  Floor(x)或int(x) 值为不大于x的最大整数
  {
    asm

        FNSTCW  [EDX].Word          // 保存协处理器控制字,用来恢复
        FNSTCW  [EDX+2].Word        // 保存协处理器控制字,用来修改
        FWAIT
        OR      [EDX+2].Word, $0700  // 使RC场向负无穷大取整    //必须保证 RC=00  然后改为 RC=01
        FLDCW   [EDX+2].Word         // 载入协处理器控制字,RC场已经修改
        FRNDINT                      // 向零取整
        FWAIT
        FLDCW   [EDX].Word           // 恢复协处理器控制字

    emd;
  }

  ExeAddressCodeIn('d93a');
  ExeAddressCodeIn('d97a02');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('66814a020007');
  ExeAddressCodeIn('d96a02');
  ExeAddressCodeIn('d9fc');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('d92a');

end;

Procedure TCompile.F_Trunc();
begin
  //截断取整  即  向零取整
  {
    asm

        FNSTCW  [EDX].Word          // 保存协处理器控制字,用来恢复
        FNSTCW  [EDX+2].Word        // 保存协处理器控制字,用来修改
        FWAIT
        OR      [EDX+2].Word, $0F00  // 使RC场向零取整     改为 RC=11
        FLDCW   [EDX+2].Word         // 载入协处理器控制字,RC场已经修改
        FRNDINT                      // 向零取整
        FWAIT
        FLDCW   [EDX].Word           // 恢复协处理器控制字

    emd;
  }

  ExeAddressCodeIn('d93a');
  ExeAddressCodeIn('d97a02');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('66814a02000f');
  ExeAddressCodeIn('d96a02');
  ExeAddressCodeIn('d9fc');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('d92a');

end;

Procedure TCompile.F_Round();
begin
  //Round(x) 四舍五入取整
  ExeAddressCodeIn('d9fc');  //frndint , Round(st)->st        // !!! Round(2.5)->2
end;

Procedure TCompile.F_Ceil();
begin
  //Ceil(x) 向无穷大取整
{
    asm

        FNSTCW  [EDX].Word          // 保存协处理器控制字,用来恢复
        FNSTCW  [EDX+2].Word        // 保存协处理器控制字,用来修改
        FWAIT
        OR      [EDX+2].Word, $0B00  // 使RC场向负无穷大取整    //必须保证 RC=00  然后改为 RC=10
        FLDCW   [EDX+2].Word         // 载入协处理器控制字,RC场已经修改
        FRNDINT                      // 向零取整
        FWAIT
        FLDCW   [EDX].Word           // 恢复协处理器控制字

    emd;
}

  ExeAddressCodeIn('d93a');
  ExeAddressCodeIn('d97a02');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('66814a02000B');
  ExeAddressCodeIn('d96a02');
  ExeAddressCodeIn('d9fc');
  ExeAddressCodeIn('9b');
  ExeAddressCodeIn('d92a');

end;

Procedure TCompile.F_Sgn();
begin
  //求符号函数
{
  if x>0 then
    x:=1
  else if x<0 then
    x:=-1
  else
    x:=0;

    asm
                fldz
                fcomp
                fstsw   ax
                sahf
                jnb     @else

                fld1
                fstp    st(1)
                jmp     @endx

        @else:
                fldz
                fcomp
                fstsw   ax
                sahf
                jbe     @else0

                fld1
                fchs
                fstp    st(1)
                jmp     @endx

        @else0:
                fldz
                fstp    st(1)

        @endx:
                fwait


  end;


}

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7306');

  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('DDD9');
  ExeAddressCodeIn('EB16');

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7608');

  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('D9E0');
  ExeAddressCodeIn('DDD9');
  ExeAddressCodeIn('EB04');

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DDD9');

  //ExeAddressCodeIn('9B');  //fwait


end;

Procedure TCompile.F_exp();
begin
  //求自然数e的次方
// e^x = 2^(x*Log2(e))

  ExeAddressCodeIn('d9ea');           //  FLDL2E              //log2e
  ExeAddressCodeIn('dec9');           //  FMULp   st(1),st    //x*log2e
  ExeAddressCodeIn('d9c0');           //  FLD  ST(0)
  ExeAddressCodeIn('d9fc');           //  FRNDINT             //Round(x*log2e)
  ExeAddressCodeIn('dce9');           //  FSUB  ST(1), ST     //x*log2e - Round(x*log2e)
  ExeAddressCodeIn('d9c9');           //  FXCH  ST(1)         //y:=2^( x*log2e - Round(x*log2e) )
  ExeAddressCodeIn('d9f0');           //  F2XM1
  ExeAddressCodeIn('d9e8');           //  FLD1
  ExeAddressCodeIn('dec1');           //  FADDp   st(1),st
  ExeAddressCodeIn('d9fd');           //  FSCALE              //st := y * 2^Round(x*log2e)
  ExeAddressCodeIn('ddd9');           //  FSTP    ST(1)

end;

Procedure TCompile.F_SinH();
begin
  //双曲正弦
  //SinH(x)=0.5*(Exp(x) - Exp(-x))

  F_Exp();
  ExeAddressCodeIn('d9e8');           //  fld1          // , 1 ->st :st -> st(1)
  ExeAddressCodeIn('d8f1');           //  fdiv  st,st(1)  // st/st(1) -> st
  ExeAddressCodeIn('dee9');           //  fsubp  st(1),st  // st(1)-st -> st
  FF_Fld_x(0.5);
  ExeAddressCodeIn('dec9');           //  fMulp  St(1),st  //, st/st(1) -> st

end;

Procedure TCompile.F_CosH();
begin
  //双曲余弦
  //CosH(x)=0.5*(Exp(x) + Exp(-x))

  F_Exp();

  ExeAddressCodeIn('d9e8');           //  fld1      //, 1 ->st :st -> st(1)
  ExeAddressCodeIn('d8f1');           //  fdiv  st,st(1)    //, st/st(1) -> st
  ExeAddressCodeIn('dec1');           //  faddp st(1),st    // , st(1)+st -> st
  FF_Fld_x(0.5);
  ExeAddressCodeIn('dec9');           //  fMulp  St(1),st  //, st/st(1) -> st

end;

Procedure TCompile.F_Tanh();
//const
//  MaxTanhDomain = 5678.22249441322; // Ln(MaxExtended)/2
var
  PMName  :string;
begin
   //双曲正切
  {

  if X > MaxTanhDomain then
    Result := 1.0
  else if X < -MaxTanhDomain then
    Result := -1.0
  else
  begin
    Result := Exp(X);
    Result := Result * Result;
    Result := (Result - 1.0) / (Result + 1.0)
  end;

  //

  asm
               push edx
               mov  edx,$12345678    //PM

      @if1:    fst  st(1)
               fld  tbyte ptr [edx]         // MaxTanhDomain -> st
               fcompp
               fstsw ax
               sahf
               jnb @if2                // jmp if  MaxTanhDomain > x
               fld1
               jmp @exit

      @if2:    fst  st(1)
               fld  tbyte ptr [edx]         // MaxTanhDomain -> st
               fchs
               fcompp
               fstsw  ax
               sahf
               jbe @else
               fld1
               fchs
               jmp @exit

      @else:   //++ st:=F_EXP(st)  // +22 = +$16
               fmul  st(0),st
               fst  st(1)
               fld1
               fsubp  st(1),st     //st(1):=st(1)-st  , pop
               fxch
               fld1
               faddp  st(1),st     //st(1):=st(1)+st, pop
               fdivp   st(1),st     //st(1):=st(1)/st ,pop

      @exit:   pop  edx

  end;
  }
  PMName:=ParameterListIn(MaxTanhDomain);
  ExeAddressCodeIn('52');  //push edx
  //pM ->edx
  ExeAddressCodeIn('BA');  //mov edx
  GetExeAddressCodeInPointerRePm(PMName);
  ExeAddressCodeIn('00000000');

  ExeAddressCodeIn('ddd1');   // @if1:    fst  st(1)
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7304');   // jnb @if2      // jmp if  MaxTanhDomain > x
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('eb3a');   // jmp @exit

  ExeAddressCodeIn('ddd1');   // @if2:    fst  st(1)
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st    // MaxTanhDomain -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}
  ExeAddressCodeIn('d9e0');   // fchs
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7606');   // jbe @else
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('d9e0');   // fchs
  ExeAddressCodeIn('eb26');   // jmp @exit

  F_EXP();

  ExeAddressCodeIn('d8c8');   // fmul  st(0),st
  ExeAddressCodeIn('ddd1');   // fst  st(1)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dee9');   // fsubp  st(1),st     //st(1):=st(1)-st  , pop
  ExeAddressCodeIn('d9c9');   // fxch
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dec1');   // faddp  st(1),st     //st(1):=st(1)+st, pop
  ExeAddressCodeIn('def9');   // fdivp   st(1),st     //st(1):=st(1)/st ,pop

  ExeAddressCodeIn('5a');     //pop  edx

end;

Procedure TCompile.F_ArcSin();
begin
  //反正弦
  // ArcSin=ArcTan2(X, Sqrt(1 - X * X))

  ExeAddressCodeIn('ddd1');           //  FST    ST(1)=st :st=st
  ExeAddressCodeIn('d8c8');           //  Fmul    x*x -> st
  ExeAddressCodeIn('d9e8');           //  fld1    1 -> st : st -> st(1) : st(1) -> st(2)
  ExeAddressCodeIn('dee1');           //  Fsubr   1-x*x -> st : st(2)-> st(1)
  ExeAddressCodeIn('d9fa');           //  Fsqrt   Sqrt(st) -> st
  ExeAddressCodeIn('d9f3');           //  Fpatan , ArcTan(st(1),st) -> st

end;

Procedure TCompile.F_ArcCos();
begin
  //反余弦
  // ArcCos=ArcTan2(Sqrt(1 - X * X), X)

  ExeAddressCodeIn('ddd1');           //  FST    ST(1)=st :st=st
  ExeAddressCodeIn('d8c8');           //  Fmul    x*x -> st
  ExeAddressCodeIn('d9e8');           //  fld1    1 -> st : st -> st(1) : st(1) -> st(2)
  ExeAddressCodeIn('dee1');           //  Fsubr   1-x*x -> st : st(2)-> st(1)
  ExeAddressCodeIn('d9fa');           //  Fsqrt   Sqrt(st) -> st
  ExeAddressCodeIn('d9c9');           //  Fxch    st <-> st(1)
  ExeAddressCodeIn('d9f3');           //  Fpatan , ArcTan(st(1),st) -> st

end;

Procedure TCompile.F_ArcTan();
begin
  //反正切
  ExeAddressCodeIn('d9e8');           //  Fld1 , 1 -> st : st-> st(1)
  ExeAddressCodeIn('d9f3');           //  Fpatan , ArcTan(st) -> st
end;

Procedure TCompile.F_ArcTan2();
begin
  //反正切 ,两个参数
{
        //ArcTan2(y,x);
        FLD     y
        FLD     x
        FPATAN
        FWAIT
}
  if not OptimizeStackCall(false) then
  begin
    CompileOutP();  //[ecx] -> st , old st -> st(1)
    ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
    ExeAddressCodeIn('d9f3');           //  Fpatan , ArcTan(st/st(1)) -> st
  end
  else
  begin
    ExeAddressCodeIn('d9f3');           //  Fpatan , ArcTan(st/st(1)) -> st
  end;
end;

Procedure TCompile.F_ArcSinH();
var
  PMName  :string;
begin
  //反双曲正弦
  {
  if X = 0.0 then
    Result := 0.0
  else
  begin
    LX := Abs(X);
    if LX > 1.0e10 then
      Result := Ln(LX + LX)
    else
    begin
      Result := LX * LX;
      Result := Ln(LX + 1 + Result / (1.0 + Sqrt(1.0 + Result)));
    end;
    if X < 0.0 then
      Result := -Result;
  end;

  asm
      @if1:    fst     st(1)
               fldz                
               fcompp
               fstsw ax
               sahf
               jnz     @else1
               fldz
               jmp     @exit

      @else1:  fst     st(1)
               fstp    tbyte ptr [edx]
               fabs

         @if21:  fst     st(1)
                 push    edx
                 mov     edx,$12345678    //Pe10
                 fld     tbyte ptr [edx]         // 1.0e10 -> st
                 pop     edx
                 fcompp
                 fstsw  ax
                 sahf
                 jae     @else2
                 fadd    st,st(0)
                 fldln2            // Ln(2) -> st : st-> st(1)
                 fxch              // st <-> st(1)
                 fyl2x             // st(1)*Log2(st)   -> st
                 jmp     @exit2

         @else2: fst    st(2)
                 fmul   st,st(0)
                 fst    st(1)
                 fld1
                 faddp  st(1),st
                 fsqrt
                 fld1
                 faddp  st(1),st
                 fdivp  st(1),st
                 faddp  st(1),st
                 fld1
                 faddp  st(1),st
                 fldln2            // Ln(2) -> st : st-> st(1)
                 fxch              // st <-> st(1)
                 fyl2x             // st(1)*Log2(st)   -> st

         @exit2: fld    tbyte ptr [edx]
                 fldz
                 fcompp
                 fstsw  ax
                 sahf
                 jbe    @exit
                 fchs

      @exit:   fwait
  end;
  }
  PMName:=ParameterListIn(1.0e10);

  ExeAddressCodeIn('ddd1');   // @if1:    fst  st(1)
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7504');   // jnz @else1
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('eb4f');   // jmp @exit

  ExeAddressCodeIn('ddd1');   // @else1:    fst  st(1)
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('DB3A');                           //fstp  tbyte ptr  [edx]
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D91A');                         //fstp  dword ptr  [edx]
    {$else}
    ExeAddressCodeIn('DD1A');                         //fstp  qword ptr  [edx]
    {$endif}
  {$endif}
  ExeAddressCodeIn('d9e1');     //fabs

  ExeAddressCodeIn('ddd1');   // @if21:    fst  st(1)
  ExeAddressCodeIn('52');     //push edx
  //pe10 ->edx
  ExeAddressCodeIn('BA');     //mov edx  pe10
  GetExeAddressCodeInPointerRePm(PMName);
  ExeAddressCodeIn('00000000');
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st    // 1.0e10 -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}
  ExeAddressCodeIn('5a');     //pop edx
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('730a');   // jnb @else2
  ExeAddressCodeIn('d8c0');   // fadd st,st(0)
  ExeAddressCodeIn('d9ed');  // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st
  ExeAddressCodeIn('eb1e');  // jmp @exit2

  ExeAddressCodeIn('ddd2');   // @else2:   fst  st(2)
  ExeAddressCodeIn('d8c8');   // fmul st,st(0)
  ExeAddressCodeIn('ddd1');   // fst  st(1)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dec1');   // faddp st(1),st
  ExeAddressCodeIn('d9fa');   // fsqrt
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dec1');   // faddp st(1),st
  ExeAddressCodeIn('def9');   // fdivp st(1),st
  ExeAddressCodeIn('dec1');   // faddp st(1),st
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dec1');   // faddp st(1),st
  ExeAddressCodeIn('d9ed');   // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');   // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');   // fyl2x   , st(1)*Log2(st)   -> st

  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st     @exit2:
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7602');   // jbe  @exit
  ExeAddressCodeIn('d9e0');   // fchs   
  ExeAddressCodeIn('ddd9');  //fstp st(1) ,  st ->st(1)  ,pop
  
end;

Procedure TCompile.F_ArcCosH();
var
  PMName  :string;
begin
  //反双曲余弦
  {
  if X <= 1.0 then
    Result := 0.0
  else if X > 1.0e10 then
    Result := Ln(X+X)
  else
    Result := Ln(X + Sqrt(X*X - 1.0));

  asm
      @if1:    fst  st(1)
               fld1                   // 1 -> st
               fcompp
               fstsw  ax
               sahf
               jb @if2                // jmp if  1 < x
               fldz
               jmp @exit

      @if2:    fst  st(1)
               push edx
               mov  edx,$12345678    //Pe10
               fld  tbyte ptr [edx]         // 1.0e10 -> st
               pop  edx
               fcompp
               fstsw  ax
               sahf
               jnb @else
               fadd st,st(0)
               fldln2            // Ln(2) -> st : st-> st(1)
               fxch              // st <-> st(1)
               fyl2x             // st(1)*Log2(st)   -> st
               jmp @exit

      @else:   fst  st(1)
               fmul st,st(0)
               fld1
               fsubp  st(1),st     //st(1):=st(1)-st  , pop
               fsqrt               //st^0.5-> st
               faddp  st(1),st
               fldln2            // Ln(2) -> st : st-> st(1)
               fxch              // st <-> st(1)
               fyl2x             // st(1)*Log2(st)   -> st

      @exit:   fwait

  end;
  }
  PMName:=ParameterListIn(1.0e10);

  ExeAddressCodeIn('ddd1');   // @if1:    fst  st(1)
  ExeAddressCodeIn('d9e8');   // fld1     // 1 -> st
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw  ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7204');   // jb @if2
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('eb2f');   // jmp @exit

  ExeAddressCodeIn('ddd1');   // @if1:    fst  st(1)
  ExeAddressCodeIn('52');     //push edx
  //pe10 ->edx
  ExeAddressCodeIn('BA');     //mov edx  pe10
  GetExeAddressCodeInPointerRePm(PMName);
  ExeAddressCodeIn('00000000');
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}
  ExeAddressCodeIn('5a');     //pop edx
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('730a');   // jnb @else
  ExeAddressCodeIn('d8c0');   // fadd st,st(0)
  ExeAddressCodeIn('d9ed');  // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st
  ExeAddressCodeIn('eb12');  // jmp @exit

  ExeAddressCodeIn('ddd1');   // @else:   fst  st(1)
  ExeAddressCodeIn('d8c8');   // fmul st,st(0)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dee9');   // fsubp  st(1),st     //st(1):=st(1)-st  , pop
  ExeAddressCodeIn('d9fa');   // fsqrt               //st^0.5-> st
  ExeAddressCodeIn('dec1');   // faddp  st(1),st
  ExeAddressCodeIn('d9ed');  // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');  // fyl2x   , st(1)*Log2(st)   -> st 
  ExeAddressCodeIn('ddd9');  //fstp st(1) ,  st ->st(1)  ,pop

end;

Procedure TCompile.F_ArcTanh();
//const
//  MaxTanhDomain = 5678.22249441322; // Ln(MaxExtended)/2
var
  i       :integer;
  PM      :pointer;
  PMName  :string;
begin
  //反双曲正切
  {
  
  if X = 0.0 then
    Result := 0.0
  else
  begin
    LX := Abs(X);
    if LX >= 1.0 then
      Result := MaxExtended
    else
      Result := 0.5 * Ln(1+(2.0 * LX) / (1.0 - LX));
    if X < 0.0 then
      Result := -Result;
  end;

  asm
      @if1:    fst     st(1)
               fldz                   // 1 -> st
               fcompp
               fstsw  ax
               sahf
               jnz     @else1
               fldz
               jmp     @exit

      @else1:  fst     st(1)
               fstp    tbyte ptr [edx]
               fabs

         @if21:  fst     st(1)
                 fld1
                 fcompp
                 fstsw  ax
                 sahf
                 ja      @else2
                 push    edx
                 mov     edx,$12345678    //PM
                 fld     tbyte ptr [edx]  
                 pop     edx
                 jmp     @exit2

         @else2: fst    st(1)
                 fld1
                 fsub   st,st(1)
                 fxch   st(1)
                 fadd   st(0),st
                 fdiv   st,st(1)
                 fld1
                 faddp  st(1),st
                 fldln2            // Ln(2) -> st : st-> st(1)
                 fxch              // st <-> st(1)
                 fyl2x             // st(1)*Log2(st)   -> st
                 fld1
                 fadd   st(0),st
                 fdivp  st(1),st

         @exit2: fld    tbyte ptr [edx]
                 fldz
                 fcompp
                 fstsw  ax
                 sahf
                 jbe    @exit
                 fchs

      @exit:   fwait
  end;
  }
  PMName:=ParameterListIn(MaxTanhDomain);
  PM:=GetParameterAddress(PMName);

  ExeAddressCodeIn('ddd1');   // @if1:    fst  st(1)
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7504');   // jnz @else1
  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('eb47');   // jmp @exit

  ExeAddressCodeIn('ddd1');   // @else1:    fst  st(1)
    {$ifdef FloatType_Extended}
    ExeAddressCodeIn('DB3A');                           //fstp  tbyte ptr  [edx]
    {$else}
      {$ifdef FloatType_Single}
      ExeAddressCodeIn('D91A');                         //fstp  dword ptr  [edx]
      {$else}
      ExeAddressCodeIn('DD1A');                         //fstp  qword ptr  [edx]
      {$endif}
    {$endif}
  ExeAddressCodeIn('d9e1');     //fabs

  ExeAddressCodeIn('ddd1');   // @if21:    fst  st(1)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('770b');   // ja @else2   //jnbe + $0b
  ExeAddressCodeIn('52');     //push edx
  //pM ->edx
  i:=Cardinal(pM);
  ExeAddressCodeIn('BA');     //mov edx
  GetExeAddressCodeInPointerRePm(PMName);
  ExeAddressCodeIn(byte(i Mod 256));
  ExeAddressCodeIn(byte((i Div 256) Mod 256));
  ExeAddressCodeIn(byte((i Div (256*256)) Mod 256));
  ExeAddressCodeIn(byte((i Div (256*256*256)) Mod 256));
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}

  ExeAddressCodeIn('5a');     //pop edx
  ExeAddressCodeIn('eb1c');  // jmp @exit2

  ExeAddressCodeIn('ddd1');   // @else2:   fst  st(1)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('d8e1');   // fsub  st, st(1)
  ExeAddressCodeIn('d9c9');   // fxch  st(1)
  ExeAddressCodeIn('d8c0');   // fadd  st(0), st
  ExeAddressCodeIn('d8f1');   // fdiv  st, st(1)
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('dec1');   // faddp st(1) ,st
  ExeAddressCodeIn('d9ed');   // fldln2   , Ln(2) -> st : st-> st(1)
  ExeAddressCodeIn('d9c9');   // fxch   , st <-> st(1)
  ExeAddressCodeIn('d9f1');   // fyl2x   , st(1)*Log2(st)   -> st
  ExeAddressCodeIn('d9e8');   // fld1
  ExeAddressCodeIn('d8c0');   // fadd  st(0),st
  ExeAddressCodeIn('def9');   // fdivp st(1),st

  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2A');  //fld  tbyte ptr [edx] ,  [edx] -> st    @exit2:
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D902');  //fld  dword ptr [edx] ,  [edx] -> st
    {$else}
    ExeAddressCodeIn('DD02');  //fld  qword ptr [edx] ,  [edx] -> st
    {$endif}
  {$endif}

  ExeAddressCodeIn('d9ee');   // fldz
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7602');   // jbe  @exit
  ExeAddressCodeIn('d9e0');   // fchs
  ExeAddressCodeIn('ddd9');  //fstp st(1) ,  st ->st(1)  ,pop
  ExeAddressCodeIn('ddd9');  //fstp st(1) ,  st ->st(1)  ,pop

end;

procedure TCompile.F_Rnd();
//const two2neg32: TCmxFloat = 1.0/4294967295;  // 1/(2^32-1)
var
  PRndSeed  :Pointer;
  i         :integer;
begin
  //随机函数
{
asm
        push    ebx
        FF_Fld_X(two2neg32);
        MOV     EBX,PRndSeed // RndSeed[0]

        IMUL    EAX,[EBX],08088405H
        INC     EAX
        MOV     [EBX],EAX
        FILD    qword ptr [EBX]


        FMULP   ST(1), ST(0)
        pop     ebx
        FMULP   ST(1), ST(0)
end;
}

  ExeAddressCodeIn('53');  //push  ebx
  FF_Fld_X(two2neg32);
  
  PRndSeed:=@RndSeed[0];
  //PRndSeed ->ebx
  i:=Cardinal(PRndSeed);      // 不需要刷新
  ExeAddressCodeIn('BB');     //mov ebx  ,RndSeed
  ExeAddressCodeIn(byte(i Mod 256));
  ExeAddressCodeIn(byte((i Div 256) Mod 256));
  ExeAddressCodeIn(byte((i Div (256*256)) Mod 256));
  ExeAddressCodeIn(byte((i Div (256*256*256)) Mod 256));

  ExeAddressCodeIn('690305840808');  //IMUL    EAX,[EBX],08088405H
  ExeAddressCodeIn('40');            //INC     EAX
  ExeAddressCodeIn('8903');          //MOV     [EBX],EAX
  ExeAddressCodeIn('df2B');          //FILD    qword ptr [EBX]
 
  ExeAddressCodeIn('dec9');          //FMULP   ST(1), ST(0)
  ExeAddressCodeIn('5b');  //pop  ebx
  ExeAddressCodeIn('dec9');          //FMULP   ST(1), ST(0)


end;

procedure TCompile.F_Ctg();
begin
  //Ctg(x) =1/tg(x)

  ExeAddressCodeIn('d9f2');  // ftan ,tg(st)-> st(1) : 1 -> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;

procedure TCompile.F_Sec();
begin
  //Sec(x) =1/Cos(x)

  F_Cos();
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;

procedure TCompile.F_Csc();
begin
  //Csc(x) =1/Sin(x)

  F_Sin();
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;


procedure TCompile.F_CscH();
begin
  //CosH(x)=1 / SinH(X);

  F_SinH();
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;

procedure TCompile.F_SecH();
begin
  //SecH(x)=1 / CosH(X);

  F_CosH();
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;

procedure TCompile.F_CtgH();
begin
  //CtgH(x)=1 / TanH(X);

  F_tanH();
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop

end;

procedure TCompile.F_ArcCsc();
begin
  //反余割函数
  //ArcCsc(x)=ArcSin(1/X)  //Delphi6 误为 ArcCsc(x)=Sin(1/X)  !

  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop
  F_ArcSin();

end;

procedure TCompile.F_ArcSec();
begin
  //反正割函数
  //ArcSec(x)=ArcCos(1/X)  //Delphi6 误为 ArcSec(x)=Cos(1/X)  !

  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop
  F_ArcCos();

end;

procedure TCompile.F_ArcCtg();
begin
  //反余切函数
  //ArcCtg(x)=ArcTan(1/X)  //Delphi6 误为 ArcCtg(x)=Tan(1/X)  !
  {
  if x=0 then
    result:=pi/2
  else
    result:=ArcTan(1/X);
     
  asm
      fldz
      fcomp
      fstsw   ax
      sahf
      jnz     @elseif
        ++Fld_X(PI/2)  //++7
        fstp    st(1)
        jmp     @endif
      @elseif:
        fld1
        fdivrp  st(1),st
        fld1
        fpatan
      @endif:
  end;
  }

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('D8D9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('750B');   // jnz   $0b // @elseif

    self.FF_Fld_X(PI/2);  //++7Byte
    ExeAddressCodeIn('DDD9');
    ExeAddressCodeIn('EB08');   // jmp   $08 // @endif
  //@elseif:
    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('DEF1');
    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('D9F3');
  //@endif:
  
end;

procedure TCompile.F_ArcCscH();
begin   
  //ArcCscH(x)=ArcSinH(1/x);
  //  Delphi6 误为：ArcCscH(x)= 1 / ArcCsc(X);!
  //  Delphi7 误为：ArcCscH(x)= Ln(Sqrt(1 + (1 / (X * X)) + (1 / X)));!! 注意括号位置

  {
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop
  F_ArcSinH();
  }
  //化简后公式：ArcCscH(x)= Ln(Sqrt(1 + (1 / (X * X))) + (1 / X));
  {
      asm
          fld1
          fdivrp    st(1),st
          fld       st
          fmul      st(0),st
          fld1
          faddp     st(1),st
          fsqrt
          faddp     st(1),st

          ++F_Ln();

      end;
  }

  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('DEF1');
  ExeAddressCodeIn('D9C0');
  ExeAddressCodeIn('D8C8');
  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('DEC1');
  ExeAddressCodeIn('D9FA');
  ExeAddressCodeIn('DEC1');

  F_Ln();

end;

procedure TCompile.F_ArcSecH();
begin
  //反双曲正割函数
  //ArcSecH(x)=ArcCosH(1/X)  //Delphi6 误为 ArcSecH(x)=1/ArcSec(X) !
  {
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop
  F_ArcCosH();
  }
  //化简后公式: ArcSecH(x)=Ln((Sqrt(1 - X * X) + 1) / X);
  {
      asm
          fld     st
          fmul    st(0),st
          fld1
          fsubrp  st(1),st
          fsqrt
          fld1
          faddp   st(1),st
          fdivrp  st(1),st

          ++F_Ln();

      end;
  }
  
  ExeAddressCodeIn('D9C0');
  ExeAddressCodeIn('D8C8');
  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('DEE1');
  ExeAddressCodeIn('D9FA');
  ExeAddressCodeIn('D9E8');
  ExeAddressCodeIn('DEC1');
  ExeAddressCodeIn('DEF1');

  F_Ln();

end;

procedure TCompile.F_ArcCtgH();
begin
  //反双曲余切函数
  //ArcCtgH(x)=ArcTanH(1/X)  //Delphi6 误为 ArcCotH(x)=1/ArcCot(X) !
  {
  ExeAddressCodeIn('d9e8');  // fld1  ,1-> st
  ExeAddressCodeIn('def1');  // fdivrp st(1)  : st/st(1)->st , pop
  F_ArcTanH();
  }
  //化简后公式：ArcCtgH(x)= 0.5 * Ln((X + 1) / (X - 1));
  {
     asm   
       fld    st
       fld1
       fsub   st(2),st
       faddp  st(1),st
       fdivrp st(1),st

       ++F_Ln();
       ++FFLD_Half;

       fmulp  st(1),st
     end;
  }
        
  ExeAddressCodeIn('d9c0');
  ExeAddressCodeIn('d9e8');
  ExeAddressCodeIn('dcea');
  ExeAddressCodeIn('dec1');
  ExeAddressCodeIn('def1');

  F_Ln();
  FF_Fld_X(0.5);

  ExeAddressCodeIn('dec9');

end;

procedure TCompile.F_Hypot();
begin
  //Hypot(x,y)=Sqrt(x*x+y*y)

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('d8c8');  // fmul  st,st(0)
  ExeAddressCodeIn('d9c9');  // fxch   , st <-> st(1)
  ExeAddressCodeIn('d8c8');  // fmul  st,st(0)
  ExeAddressCodeIn('dec1');  // faddp st(1),st    st+st(1) -> st

  F_Sqrt();

end;

procedure  TCompile.F_SYS_IF_0();   //IF函数0
begin
  // 函数 IF(a,b,c) =>TCmSYS_IF_1(TCmSYS_IF_0(b,c),a)
  // 这时  c->st , b->堆栈
  // 什么也不做
end;

procedure  TCompile.F_SYS_IF_1();   //IF函数1
begin
  // 函数 IF(a,b,c) =>TCmSYS_IF_1(TCmSYS_IF_0(b,c),a)
  // 这时  a->st(0) , c->堆栈 , b->堆栈
  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  // 这时  c->st(0) , b->st(1), a->st(2)

 { asm
      fxch      st(2)
      fldz
      fcompp
      fstsw ax
      sahf
      jnz        @elseif

        fstp      st(1)
        jmp       @endif
    @elseif:
        fstp      st(0)
    @endif:
    
  end;
 }

  ExeAddressCodeIn('D9CA');
  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7504');

  ExeAddressCodeIn('DDD9');
  ExeAddressCodeIn('EB02');
  ExeAddressCodeIn('DDD8');

end;

procedure  TCompile.F_SYS_FF_0(const N:integer); //积分函数0
begin
  //( (a) TCmSYS_FF_0 (b) TCmSYS_FF_1 (N) TCmSYS_FF_2 ( g(x) ) )
  //这时 b -> st : a -> 堆栈
  //所以什么都不做
end;

procedure  TCompile.F_SYS_FF_1(const N:integer); //积分函数1
var
  ix   :integer;
  Px   :pointer;
 // ,iExe  ,Pexe
  function  GetEDXFstp(const i0:integer):string;
  var
    i :integer;
  begin
    i:=i0+N*8*SYS_EFLength;   //处理重积分(或套嵌)
    {$ifdef FloatType_Extended}
    result:=('DBBA');                           //fstp  tbyte ptr  [edx+i]
    {$else}
      {$ifdef FloatType_Single}
      result:=('D99A');                         //fstp  dword ptr  [edx+i]
      {$else}
      result:=('DD9A');                         //fstp  qword ptr  [edx+i]
      {$endif}
    {$endif}
    result:=result+inttohex(byte(i Mod 256),2);
    result:=result+inttohex(byte((i Div 256) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256)) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256*256)) Mod 256),2);
  end;

  function  GetEDXFld(const i0:integer):string;
  var
    i :integer;
  begin
    i:=i0+N*8*SYS_EFLength;   //处理重积分(或套嵌)
    {$ifdef FloatType_Extended}
    result:=('dbAA');  //fld  tbyte ptr [edx+i]
    {$else}
      {$ifdef FloatType_Single}
      result:=('D982');  //fld  dword ptr [edx+i]
      {$else}
      result:=('DD82');  //fld  qword ptr [edx+i]
      {$endif}
    {$endif}
    result:=result+inttohex(byte(i Mod 256),2);
    result:=result+inttohex(byte((i Div 256) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256)) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256*256)) Mod 256),2);
  end;
  
begin
  //( (a) TCmSYS_FF_0 (b) TCmSYS_FF_1 (N) TCmSYS_FF_2 ( g(x) ) )
  //这时 N -> st : b -> 堆栈 : a -> 堆栈
  //弹出并保存 N,b,a
  //产生循环的代码 (循环外的预处理,得到 TCmSYS_FF_2 所需要的返回地址)

  //  GetExeAddressCodeInPointer:当前编译地址  TCmSYS_Const_ff_x_N:积分变量名称


  //ExeAddressCodeIn('d9e1');       //fabs   , |st|-> st  // N:=|N|
  //ExeAddressCodeIn('d9e8');       //fld1
  //ExeAddressCodeIn('dec1');       //faddp st(1),st   //N=N+1;
  ExeAddressCodeIn('d9fc');       //frndint          //N=Trunc(N)

  CompileOutP();  //[ecx] -> st , old st -> st(1)   //b out
  CompileOutP();  //[ecx] -> st , old st -> st(1)   //a out

  ExeAddressCodeIn(GetEDXFstp(2*SYS_EFLength));     //fstp tByte ptr [edx+2*SYS_EFLength]  //a
  ExeAddressCodeIn(GetEDXFstp(3*SYS_EFLength));     //fstp tByte ptr [edx+3*SYS_EFLength]  //b
  ExeAddressCodeIn(GetEDXFstp(4*SYS_EFLength));     //fstp tByte ptr [edx+4*SYS_EFLength]  //N
  //ExeAddressCodeIn('db5a40');     //fistp dWord ptr [edx+4*SYS_EFLength]  //N

  ExeAddressCodeIn('53');//  push      ebx
  ExeAddressCodeIn('50');//  push      eax
  px:=GetParameterAddress('TCmSYS_Const_ff_x_'+inttostr(N));
  if Cardinal(px)=0 then
  begin
     ParameterListIn('TCmSYS_Const_ff_x_'+inttostr(N));
     px:=GetParameterAddress('TCmSYS_Const_ff_x_'+inttostr(N));
  end;
  ix:=Cardinal(Px);
  ExeAddressCodeIn('BB');     //mov ebx
  GetExeAddressCodeInPointerRePm('TCmSYS_Const_ff_x_'+inttostr(N));
  ExeAddressCodeIn(byte(ix Mod 256));
  ExeAddressCodeIn(byte((ix Div 256) Mod 256));
  ExeAddressCodeIn(byte((ix Div (256*256)) Mod 256));
  ExeAddressCodeIn(byte((ix Div (256*256*256)) Mod 256));  //  mov   ebx,ix   //x Address


  ExeAddressCodeIn(GetEDXFld(2*SYS_EFLength));//  fld       tByte ptr [edx+2*SYS_EFLength]  //a
  ExeAddressCodeIn(GetEDXFld(3*SYS_EFLength));//  fld       tByte ptr [edx+3*SYS_EFLength]  //b
  ExeAddressCodeIn('dee1');  //  fsubrp    st(1),st            //b-a
  ExeAddressCodeIn(GetEDXFld(4*SYS_EFLength));//  fld       tByte ptr [edx+4*SYS_EFLength]  //n
  ExeAddressCodeIn('def9');  //  fdivp     st(1),st            //(b-a)/n =dx
  ExeAddressCodeIn('ddd1');  //  fst       st(1),st
  ExeAddressCodeIn(GetEDXFstp(5*SYS_EFLength));//  fstp      tByte ptr [edx+5*SYS_EFLength]  //dx
  ExeAddressCodeIn('d9e8');  //  fld1
  ExeAddressCodeIn('d8c0');  //  fadd      st(0),st
  ExeAddressCodeIn('def9');  //  fdivrp    st(1),st            //dx/2
  ExeAddressCodeIn(GetEDXFld(2*SYS_EFLength));//  fld       tByte ptr [edx+2*SYS_EFLength]  //a
  ExeAddressCodeIn('dec1');  //  faddp     st(1),st            //a+dx/2 =x0
    {$ifdef FloatType_Extended}
    ExeAddressCodeIn('DB3B');                           //fstp  tbyte ptr  [ebx]
    {$else}
      {$ifdef FloatType_Single}
      ExeAddressCodeIn('D91B');                         //fstp  dword ptr  [ebx]
      {$else}
      ExeAddressCodeIn('DD1B');                         //fstp  qword ptr  [ebx]
      {$endif}
    {$endif}  ExeAddressCodeIn('d9ee');  // fldz
  ExeAddressCodeIn(GetEDXFstp(6*SYS_EFLength));// fstp      tByte ptr [edx+6*SYS_EFLength]  // Sum = 0
  ExeAddressCodeIn('d9ee');  // fldz
  ExeAddressCodeIn(GetEDXFstp(7*SYS_EFLength));// fstp      tByte ptr [edx+7*SYS_EFLength]  // i = 0

  //pExe:=
  GetExeAddressCodeInPointerReCode();    //这里的地址有可能变动(SetLength函数),编译完成后会重新设置
  //iExe:=Cardinal(PExe)+5;
  ExeAddressCodeIn('B8');     //mov eax
  ExeAddressCodeIn('00000000');
  //ExeAddressCodeIn(byte(iExe Mod 256));
 // ExeAddressCodeIn(byte((iExe Div 256) Mod 256));
 // ExeAddressCodeIn(byte((iExe Div (256*256)) Mod 256));
 // ExeAddressCodeIn(byte((iExe Div (256*256*256)) Mod 256)); //  mov   eax,iExe   //return Address

  ExeAddressCodeIn('50');//  push      eax

  ExeAddressCodeIn('d9ee');     // fldz  // 返回值'零' 以利于编译器处理  

end;

procedure  TCompile.F_SYS_FF_2(const N:integer); //积分函数2

  function  GetEDXFstp(const i0:integer):string;
  var
    i :integer;
  begin
    i:=i0+N*8*SYS_EFLength;   //处理重积分(或套嵌)
    {$ifdef FloatType_Extended}
    result:=('DBBA');                           //fstp  tbyte ptr  [edx+i]
    {$else}
      {$ifdef FloatType_Single}
      result:=('D99A');                         //fstp  dword ptr  [edx+i]
      {$else}
      result:=('DD9A');                         //fstp  qword ptr  [edx+i]
      {$endif}
    {$endif}
    result:=result+inttohex(byte(i Mod 256),2);
    result:=result+inttohex(byte((i Div 256) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256)) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256*256)) Mod 256),2);
  end;

  function  GetEDXFld(const i0:integer):string;
  var
    i :integer;
  begin
    i:=i0+N*8*SYS_EFLength;   //处理重积分(或套嵌)
    {$ifdef FloatType_Extended}
    result:=('dbAA');  //fld  tbyte ptr [edx+i]
    {$else}
      {$ifdef FloatType_Single}
      result:=('D982');  //fld  dword ptr [edx+i]
      {$else}
      result:=('DD82');  //fld  qword ptr [edx+i]
      {$endif}
    {$endif}
    result:=result+inttohex(byte(i Mod 256),2);
    result:=result+inttohex(byte((i Div 256) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256)) Mod 256),2);
    result:=result+inttohex(byte((i Div (256*256*256)) Mod 256),2);
  end;

begin
  //( (a) TCmSYS_FF_0 (b) TCmSYS_FF_1 (N) TCmSYS_FF_2 ( g(x) ) )
  //这时 g(x) -> st
  //判断是否需要返回到 TCmSYS_FF_1 所约定的地址
  //

  CompileOutP();  //[ecx] -> st , old st -> st(1)  //弹出值'零'
  ExeAddressCodeIn('d9c9');     //fxch  st(1)    //st <-> st(1)
  ExeAddressCodeIn('ddd9');     //fstp st(1)     //st -> st(1),pop    //g(x)=h  (高)

  ExeAddressCodeIn(GetEDXFld(6*SYS_EFLength)); //  fld       tByte  ptr  [edx+6*SYS_EFLength]  // Sum
  ExeAddressCodeIn('dec1'); //  faddp     st(1),st
  ExeAddressCodeIn(GetEDXFstp(6*SYS_EFLength)); //  fstp      tByte ptr [edx+6*SYS_EFLength]  // Sum:=sum+h


  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db2B');  //fld  tbyte ptr [ebx]
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D903');  //fld  dword ptr [ebx]
    {$else}
    ExeAddressCodeIn('DD03');  //fld  qword ptr [ebx]
    {$endif}
  {$endif}
  ExeAddressCodeIn(GetEDXFld(5*SYS_EFLength));//  fld     tByte ptr [edx+5*SYS_EFLength]  //dx
  ExeAddressCodeIn('dec1');//  faddp   st(1),st
    {$ifdef FloatType_Extended}
    ExeAddressCodeIn('DB3B');                           //fstp  tbyte ptr  [ebx]
    {$else}
      {$ifdef FloatType_Single}
      ExeAddressCodeIn('D91B');                         //fstp  dword ptr  [ebx]
      {$else}
      ExeAddressCodeIn('DD1B');                         //fstp  qword ptr  [ebx]
      {$endif}
    {$endif}

  ExeAddressCodeIn(GetEDXFld(7*SYS_EFLength)); //  fld       tByte ptr  [edx+7*SYS_EFLength]  // i
  ExeAddressCodeIn('d9e8'); //  fld1
  ExeAddressCodeIn('dec1'); //  faddp     st(1),st             //i:=i+1;
  ExeAddressCodeIn('ddd1'); //  fst       st(1)
  ExeAddressCodeIn(GetEDXFstp(7*SYS_EFLength)); //  fstp      tByte ptr  [edx+7*SYS_EFLength]  // i+1 -> [edx+7*SYS_EFLength]

  ExeAddressCodeIn(GetEDXFld(4*SYS_EFLength)); //  fld       tByte ptr  [edx+4*SYS_EFLength]  // N
  ExeAddressCodeIn('ded9');   // fcompp
  ExeAddressCodeIn('9b');     // wait
  ExeAddressCodeIn('dfe0');   // fstsw ax
  ExeAddressCodeIn('9e');     // sahf
  ExeAddressCodeIn('7e03');   // jle @else

  ExeAddressCodeIn('58');  //  pop eax
  ExeAddressCodeIn('ffe0');//  jmp eax

  ExeAddressCodeIn('58');// @else: pop     eax
  ExeAddressCodeIn('58');//  pop     eax
  ExeAddressCodeIn('5b');//  pop     ebx
  ExeAddressCodeIn(GetEDXFld(6*SYS_EFLength));//  fld     tByte ptr [edx+6*SYS_EFLength]  // Sum
  ExeAddressCodeIn(GetEDXFld(5*SYS_EFLength));//  fld     tByte ptr [edx+5*SYS_EFLength]  //dx
  ExeAddressCodeIn('dec9');//  fmulp   st(1),st

  
end;                        

Procedure TCompile.FF_Fld_X(const x:TCmxFloat); //载入x
var
  PMName  :string;
begin
  //++ 7 byte
  ExeAddressCodeIn('B8');
  PMName:=ParameterListIn(x);
  GetExeAddressCodeInPointerRePm(PMName);
  ExeAddressCodeIn('00000000');
  {$ifdef FloatType_Extended}
  ExeAddressCodeIn('db28');  //fld  tbyte ptr [eax] ,  [eax] -> st
  {$else}
    {$ifdef FloatType_Single}
    ExeAddressCodeIn('D900');  //fld  dword ptr [eax] ,  [eax] -> st
    {$else}
    ExeAddressCodeIn('DD00');  //fld  qword ptr [eax] ,  [eax] -> st
    {$endif}
  {$endif}

end;


//------------------------------------------------------------------------------

//逻辑运算
procedure TCompile.FB_AND();
begin
{
    if (x<>0) and (y<>0) then
      t:=1
    else
      t:=0;

    asm
    
            fldz
            fcompp
            fstsw      ax
            sahf
            jz         @else

              fldz
              fcomp
              fstsw      ax
              sahf
              jz         @else

                fld1
                jmp        @end

        @else:
            fldz

        @end:
            fstp     st(1)

    emd;
}

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('740E');

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('D8D9');
    ExeAddressCodeIn('9B');
    ExeAddressCodeIn('DFE0');
    ExeAddressCodeIn('9E');
    ExeAddressCodeIn('7404');

      ExeAddressCodeIn('D9E8');
      ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

  ExeAddressCodeIn('DDD9');

end;

procedure TCompile.FB_NOT();
begin
{
    if x<>0 then
      x:=0
    else
      x:=1;



    asm
    
            fldz
            fcompp
            fstsw     ax
            sahf
            jz        @else
              fldz
              jmp       @end
        @else:
            fld1
        @end:

    end;

}

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7404');

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9E8');

end;

procedure TCompile.FB_OR();
begin
{
    //if (x<>0) OR (y<>0) then
    //  t:=1
    //else
    //  t:=0;

    if (x=0) AND (y=0) then
      t:=0
    else
      t:=1;

    asm
            fldz
            fcompp
            fstsw      ax
            sahf
            jnz        @else   //

              fldz
              fcomp
              fstsw      ax
              sahf
              jnz        @else   //

                fldz             //
                jmp        @end

        @else:
            fld1                 //

        @end:
            fstp     st(1)

    emd;
}

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('750E');   //

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('D8D9');
    ExeAddressCodeIn('9B');
    ExeAddressCodeIn('DFE0');
    ExeAddressCodeIn('9E');
    ExeAddressCodeIn('7504');  //

      ExeAddressCodeIn('D9Ee');//
      ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9E8');   //

  ExeAddressCodeIn('DDD9');

end;

procedure TCompile.FB_XOR();
begin
{
    if x<>0 then
      if y=0 then
        t:=1
      else
        t:=0
    elseif y<>0 then
      t:=1
    else
      t:=0;


    asm

            fldz
            fcompp
            fstsw       ax
            sahf
            jnz         @elseif
              fldz
              fcompp
              fstsw       ax
              sahf
              jz          @else
                fld1
                jmp       @end

        @elseif:
            fldz
            fcompp
            fstsw       ax
            sahf
            jnz         @else
              fld1
              jmp         @end

        @else:
            fldz

        @end:

    end;
      
}
                        
  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)
  
  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('750E');

    ExeAddressCodeIn('D9EE');
    ExeAddressCodeIn('DED9');
    ExeAddressCodeIn('9B');
    ExeAddressCodeIn('DFE0');
    ExeAddressCodeIn('9E');
    ExeAddressCodeIn('7412');

      ExeAddressCodeIn('D9E8');
      ExeAddressCodeIn('EB10');

  ExeAddressCodeIn('D9EE');
  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7504');

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

//关系运算
procedure TCompile.FB_EQ;
begin
{
    if x=y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jnz        @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7504');

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

procedure TCompile.FB_NE();
begin
{
    if x<>y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jz         @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall(false) then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7404');  //

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

procedure TCompile.FB_GT;
begin
{
    if x>y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jbe        @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7604');   //

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

procedure TCompile.FB_LT;
begin
{
    if x<y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jbe        @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7304'); //

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

procedure TCompile.FB_GE;
begin
{
    if x>=y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jb         @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7204');   //

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;

procedure TCompile.FB_LE;
begin
{
    if x<=y then
      t:=true
    else
      t:=false;

    asm
            fcompp
            fstsw      ax
            sahf
            jnbe       @else
              fld1
              jmp        @end
         @else:
            fldz
         @end:
    end;
}

  if not OptimizeStackCall() then
    CompileOutP();  //[ecx] -> st , old st -> st(1)

  ExeAddressCodeIn('DED9');
  ExeAddressCodeIn('9B');
  ExeAddressCodeIn('DFE0');
  ExeAddressCodeIn('9E');
  ExeAddressCodeIn('7704');   //

    ExeAddressCodeIn('D9E8');
    ExeAddressCodeIn('EB02');

  ExeAddressCodeIn('D9EE');

end;


//------------------------------------------

procedure TCompile.GetMarkerValue0(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    'a'..'z','A'..'Z','_':
      begin
        if iFirst=length(str) then
          iEnd:=iFirst
        else
          GetMarkerValue1(str,iFirst+1,iEnd);
      end;
    else
      iEnd:=0;
  end;
end;

procedure TCompile.GetMarkerValue1(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    'a'..'z','A'..'Z','0'..'9','_':
      begin
        if iFirst=length(str) then
          iEnd:=ifirst
        else
          GetMarkerValue1(str,iFirst+1,iEnd);
      end;
    else
      iEnd:=iFirst-1;
  end;
end;

procedure  TCompile.GetMarker(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    'a'..'z','A'..'Z','0'..'9','_','(',')':
      GetMarker(str,iFirst+1,iEnd);
    '@','&','#':
      iEnd:=iFirst-1;
    else
      iEnd:=0;
  end;
end;


//------------------------------------------------------------------------------


procedure TCompile.GetFloatValue0(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue1(Str,iFirst+1,iEnd);
    '.':
      GetFloatValue6(Str,iFirst+1,iEnd);
    else
      iEnd:=0;
  end;
end;

procedure TCompile.GetFloatValue1(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue1(Str,iFirst+1,iEnd);
    '.':
      GetFloatValue2(Str,iFirst+1,iEnd);
    'E','e'://,'D','d':
      GetFloatValue3(Str,iFirst+1,iEnd);
    else
      iEnd:=iFirst-1;
  end;
end;

procedure TCompile.GetFloatValue6(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue2(Str,iFirst+1,iEnd);
    else
      iEnd:=0;
  end;
end;

procedure TCompile.GetFloatValue2(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue2(Str,iFirst+1,iEnd);
    'E','e'://,'D','d':
      GetFloatValue3(Str,iFirst+1,iEnd);
    else
      iEnd:=iFirst-1;
  end;
end;

procedure TCompile.GetFloatValue3(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue5(Str,iFirst+1,iEnd);
    '+','-':
      GetFloatValue4(Str,iFirst+1,iEnd);
    else
      iEnd:=0;
  end;
end;

procedure TCompile.GetFloatValue4(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue5(Str,iFirst+1,iEnd);
    else
      iEnd:=0;
  end;
end;

procedure TCompile.GetFloatValue5(const Str:string;const iFirst:integer;var iEnd:integer);
begin
  case Str[iFirst] of
    '0'..'9':
      GetFloatValue5(Str,iFirst+1,iEnd);
    else
      iEnd:=iFirst-1;
  end;
end;


//构造 HEXToINT: array[0..255] of integer 查询表
initialization
begin
  SetHEXToINTValue();
end;
//==============================================================================

            {  数学函数动态编译器TCompile(包括实数函数和积分函数)  作者:侯思松   }

{ 编译单元结束 }

end.
