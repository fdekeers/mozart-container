%%%%%%%%%%%%%% tests variable et browse %%%%%%%%%%%%%%

declare
V = 9999*9999
{Browse V * V} % 9996000599960001
{Browse 1*2*3*4*5*6*7*8*9*10} % 3628800
X = 10
Y = 20
{Browse X + Y}
local A=1.0 B=3.0 C=2.0 D RealSol X1 X2 in
   D=B*B-4.0*A*C
   if D>=0.0 then
      RealSol=true
      X1=(˜B+{Sqrt D})/(2.0*A)
      X2=(˜B-{Sqrt D})/(2.0*A)
   else
      RealSol=false
      X1=˜B/(2.0*A)
      X2={Sqrt ˜D}/(2.0*A)
   end
   {Browse RealSol#X1#X2} % true#2#1
end

% enumerate elements
for I in 0..10 do {Browse I} end








%%%%%%%%%%%%%% Procedure %%%%%%%%%%%%%%
% proc that translates the expression into machine code for a simple stack machine and it
%calculates the number of instructions in the resulting code
declare
proc {ExprCode E C1 ?Cn S1 ?Sn}
   case E
   of plus(A B) then C2 C3 S2 S3 in
      C2=plus|C1
      S2=S1+1
      {ExprCode B C2 C3 S2 S3}
      {ExprCode A C3 Cn S3 Sn}
   [] I then
      Cn=push(I)|C1
      Sn=S1+1
      end
end
declare Code Size in
{ExprCode plus(plus(a 3) b) nil Code 0 Size}
{Browse Size#Code} % 5#[push(a) push(3) plus push(b) plus]








%%%%%%%%%%%%%% lists  %%%%%%%%%%%%%%

declare
L = [1 2 3 4 5]
L1 = 1|2|3|4|5|nil
{Browse L} % [1 2 3 4 5]
{Browse L1} % [1 2 3 4 5]
{Browse L.1} % 1
{Browse L.2} % [2 3 4 5]
{Browse L.2.1} % 2

declare
X = 7|Y
{Browse X} % 7|Y
Y = 5|Z
Z = 3|nil  % X = [7 5 3]

declare
X = 1
Y = [2 3 4]
{Browse X|Y} % [1 2 3 4]

% test pattern mathcing in list :

declare
L=[5 6 7 8]
case L of H|T then {Browse H} {Browse T} end % 5 [6 7 8]
for I in L do {Browse I} end






%%%%%%%%%%%%%% Functions over lists %%%%%%%%%%%%%%

% function to creat a liste of N elements :

declare
fun {CreatList N}
   if N == 0 then N
   else
      N|{CreatList N-1}
   end
end
{Browse {CreatList 10}}

% len of a liste :

declare
fun {Length Ls}
   case Ls
   of nil then 0
   [] _|Lr then 1+{Length Lr}
   end
end
{Browse {Length [a b c d e f g]}} %7

% append a list to another
declare 
fun {Append Ls Ms}
   case Ls
   of nil then Ms
   [] X|Lr then X|{Append Lr Ms}
   end
end
{Browse {Append [1 2 3] [4 5 6]}} % [1 2 3 4 5 6]

%get the nth element of a list :

declare
fun {Nth Xs N}
   if N==1 then Xs.1
   elseif N>1 then {Nth Xs.2 N-1}
   end
end
{Browse {Nth [1 2 3 4 5 6] 3}} %3

%sum elements of a list :
declare
fun {SumList Xs}
   case Xs
   of nil then 0
   [] X|Xr then X+{SumList Xr}
   end
end
{Browse {SumList [1 2 3 4 5 6]}}%21

%reverse list :
declare
fun {Reverse Xs}
   case Xs
   of nil then nil
   [] X|Xr then
      {Append {Reverse Xr} [X]}
   end
end

{Browse {Reverse [1 2 3 4 5 6]}}


% len of a list of lists :
declare
fun {LengthL Xs}
   case Xs
   of nil then 0
   [] X|Xr andthen {IsList X} then
      {LengthL X}+{LengthL Xr}
   [] X|Xr then
      1+{LengthL Xr}
   end
end
X=[[1 2] 4 nil [[5] 10]]
{Browse {LengthL X}} %5
{Browse {LengthL [X X]}} %10

% merge two lists
declare 
fun {Merge Xs Ys}
   case Xs # Ys
   of nil # Ys then Ys
   [] Xs # nil then Xs
   [] (X|Xr) # (Y|Yr) then
      if X<Y then X|{Merge Xr Ys}
      else Y|{Merge Xs Yr}
      end
   end
end
{Browse {Merge [1 3 5 6] [1 2 4 5 6 7 8 9]}}

% merge sort with accumulator :

declare
fun {MergeSort Xs}
   fun {MergeSortAcc L1 N}
      if N==0 then
	 nil # L1
      elseif N==1 then
	 [L1.1] # L1.2
      elseif N>1 then
	 NL=N div 2
	 NR=N-NL
	 Ys # L2 = {MergeSortAcc L1 NL}
	 Zs # L3 = {MergeSortAcc L2 NR}
      in
	 {Merge Ys Zs} # L3
      end
   end
in
   {MergeSortAcc Xs {Length Xs}}.1
end
{Browse {MergeSort [8 4 5 9 3 1 8 9 5 2 7]}}

% function to calculate the nth row of Pascal's triangle :

declare Pascal AddList ShiftLeft ShiftRight
fun {ShiftLeft L}
   case L of H|T then
      H|{ShiftLeft T}
   else [0] end
end
fun {ShiftRight L} 0|L end
fun {AddList L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 H1+H2|{AddList T1 T2}
      end
   else nil end
end
fun {Pascal N}
   if N==1 then [1]
   else
      {AddList {ShiftLeft {Pascal N-1}}{ShiftRight {Pascal N-1}}}
   end
end

{Browse {Pascal 10}} % [1 9 36 84 126 126 84 36 9 1]
{Browse {Pascal 20}} % [1 19 171 969 3876 11628 27132 50388 75582 92378 92378 75582 50388 27132 11628 3876 969 171 19 1]

% Generic Pascal
declare
fun {OpList Op L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 {Op H1 H2}|{OpList Op T1 T2}
      end
   else nil end
end

fun {Add X Y} X+Y end

fun {GenericPascal Op N}
   if N==1 then [1]
   else L in
      L={GenericPascal Op N-1}
      {OpList Op {ShiftLeft L} {ShiftRight L}}
   end
end

{Browse {GenericPascal Add 10}}







%%%%%%%%%%% Functions  %%%%%%%%%%%%% 


% factoriel
declare
fun {Fact N}
   if N==0 then 1 else N*{Fact N-1} end
end
{Browse {Fact 10}} % 3628800

% combinations :
declare
fun {Comb N R}
   {Fact N} div ({Fact R}*{Fact N-R})
end
{Browse {Comb 10 3}} % 120


% SQRT 
declare
fun {Sqrt X}
   Guess=1.0
in
   {SqrtIter Guess X}
end
fun {SqrtIter Guess X}
   if {GoodEnough Guess X} then Guess
   else
      {SqrtIter {Improve Guess X} X}
   end
end
fun {Improve Guess X}
   (Guess + X/Guess) / 2.0
end
fun {GoodEnough Guess X}
   {Abs X-Guess*Guess}/X < 0.00001
end
fun {Abs X} if X<0.0 then ˜X else X end end

{Browse {Sqrt 2.0}} %1.5

% others tests of differents versions of SQRT
declare
fun {Sqrt X}
   fun {Improve Guess}
      (Guess + X/Guess) / 2.0
   end
   fun {GoodEnough Guess}
      {Abs X-Guess*Guess}/X < 0.00001
   end
   fun {SqrtIter Guess}
      if {GoodEnough Guess} then Guess
      else
	 {SqrtIter {Improve Guess}}
      end
   end
   Guess=1.0
in
   {SqrtIter Guess}
end
{Browse {Sqrt 2.0}} %1.5

declare
local
   fun {Improve Guess X}
      (Guess + X/Guess) / 2.0
   end
   fun {GoodEnough Guess X}
      {Abs X-Guess*Guess}/X < 0.00001
   end
   fun {SqrtIter Guess X}
      if {GoodEnough Guess X} then Guess
      else
	 {SqrtIter {Improve Guess X} X}
      end
   end
in
   fun {Sqrt X}
      Guess=1.0
   in
      {SqrtIter Guess X}
   end
end
{Browse {Sqrt 2.0}} %1.5


%test : pass function in argument :
declare
fun {Iterate S IsDone Transform}
   if {IsDone S} then S
   else S1 in
      S1={Transform S}
      {Iterate S1 IsDone Transform}
   end
end
fun {Sqrt X}
   {Iterate
    1.0
    fun {$ G} {Abs X-G*G}/X<0.00001 end
    fun {$ G} (G+X/G)/2.0 end}
end

{Browse {Sqrt 2.0}} % 1.5

% test with concurrency :

thread P in
   P={GenericPascal Add 100}
   {Browse P}
end
{Browse 99*99}


%queue :
declare
fun {NewQueue} X in q(0 X X) end
fun {Insert Q X}
   case Q of q(N S E) then E1 in E=X|E1 q(N+1 S E1) end
end
fun {Delete Q X}
   case Q of q(N S E) then S1 in S=X|S1 q(N-1 S1 E) end
end
fun {IsEmpty Q}
   case Q of q(N S E) then N==0 end
end
declare Q1 Q2 Q3 Q4 Q5 Q6 Q7 in
Q1={NewQueue}
Q2={Insert Q1 peter}
Q3={Insert Q2 paul}
local X in Q4={Delete Q3 X} {Browse X} end
local X in Q5={Delete Q4 X} {Browse X} end
local X in Q6={Delete Q5 X} {Browse X} end
Q7={Insert Q6 mary}








%%%%%%%%%%%%%% Lazy evalutation %%%%%%%%%%%%%%

declare 
fun lazy {Ints N}
   N|{Ints N+1}
end
L = {Ints 0}
{Browse L}
{Browse L.1}
{Browse L.2.2.1}
{Browse L.1}

L1 = {Ints 0}
case L1 of A|B|C|_ then {Browse A+B+C} end % 3

% Lazy evalutation of Pascal triangle

declare
fun {ShiftLeft L}
   case L of H|T then
      H|{ShiftLeft T}
   else [0] end
end
fun {ShiftRight L} 0|L end
fun {AddList L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 H1+H2|{AddList T1 T2}
      end
   else nil end
end
fun lazy {PascalList Row}
   Row|{PascalList
	{AddList {ShiftLeft Row}
	 {ShiftRight Row}}}
end

L = {PascalList [1]}
{Browse L.2.2.2.2.2.2.2.1}
{Browse L}





%%%%%%%%%%%%%% Dataflow and concurrency %%%%%%%%%%%%%%
declare X1 X2 Y1 Y2 in
thread {Browse X1} end % all|roads|lead|to|rome|_
thread {Browse Y1} end % all|roams|lead|to|rhodes|_
thread X1=all|roads|X2 end
thread Y1=all|roams|Y2 end
thread X2=lead|to|rome|_ end
thread Y2=lead|to|rhodes|_ end


declare X in
thread {Delay 2000} X=99 end
{Browse start} {Browse X*X}

declare
fun {Fib X}
   if X=<2 then 1
   else thread {Fib X-1} end + {Fib X-2} end
end
{Browse {Fib 10}} %55

% stream
declare
proc {DGenerate N Xs}
   case Xs of X|Xr then
      X=N
      {DGenerate N+1 Xr}
   end
end
fun {DSum ?Xs A Limit}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum Xr A+X Limit-1}
   else A end
end
proc {Buffer N ?Xs Ys}
   fun {Startup N ?Xs}
      if N==0 then Xs
      else Xr in Xs=_|Xr {Startup N-1 Xr} end
   end
   proc {AskLoop Ys ?Xs ?End}
      case Ys of Y|Yr then Xr End2 in
	 Xs=Y|Xr 
	 End=_|End2 
	 {AskLoop Yr Xr End2}
      end
   end
   End={Startup N Xs}
in
   {AskLoop Ys Xs End}
end

local Xs Ys S in
   thread {DGenerate 0 Xs} end % Producer thread
   thread {Buffer 4 Xs Ys} end % Buffer thread
   thread S={DSum Ys 0 150000} end % Consumer thread
   {Browse Xs} {Browse Ys}
   {Browse S} %11249925000
end






%%%%%%%%%%%%%% State (cell) %%%%%%%%%%%%%%

declare
C={NewCell 0}
C:=@C+1
{Browse @C}

% Pascal with cell
declare
fun {OpList Op L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 {Op H1 H2}|{OpList Op T1 T2}
      end
   else nil end
end

fun {Add X Y} X+Y end

fun {GenericPascal Op N}
   if N==1 then [1]
   else L in
      L={GenericPascal Op N-1}
      {OpList Op {ShiftLeft L} {ShiftRight L}}
   end
end

C={NewCell 0}
fun {FastPascal N}
   C:=@C+1
   {GenericPascal Add N}
end

{Browse {FastPascal 10}}


declare
local C in
   C={NewCell 0}
   fun {Bump}
      C:=@C+1
      @C
   end
   fun {Read}
      @C
   end
end

{Browse {Bump}} % 1
{Browse {Bump}} % 2

% Pascal with Bump
declare
fun {OpList Op L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 {Op H1 H2}|{OpList Op T1 T2}
      end
   else nil end
end

fun {Add X Y} X+Y end

fun {GenericPascal Op N}
   if N==1 then [1]
   else L in
      L={GenericPascal Op N-1}
      {OpList Op {ShiftLeft L} {ShiftRight L}}
   end
end
fun {FastPascal N}
   {Browse {Bump}}
   {GenericPascal Add N}
end
{Browse {FastPascal 10}}


declare
fun {NewCounter}
   C Bump Read in
   C={NewCell 0}
   fun {Bump}
      C:=@C+1
      @C
   end
   fun {Read}
      @C
   end
   counter(bump:Bump read:Read)
end

Ctr1={NewCounter}
Ctr2={NewCounter}
{Browse {Ctr1.bump}} %1
{Browse {Ctr1.bump}} %2
{Browse {Ctr2.bump}} %1
{Browse {Ctr1.read}} %2
{Browse {Ctr1.bump}} %3



%%%%%%%%%%%%%% Objects/Classes  %%%%%%%%%%%%%%

declare
class Account
   attr balance

   meth init(I)
      balance:=I
   end
   meth transfer(Amt)
      balance:=@balance+Amt
   end

   meth getBal(Bal)
      Bal=@balance
   end

   meth batchTransfer(AmtList)
      for A in AmtList do {self transfer(A)} end
   end
end

A = {New Account init(0)}
B = {New Account init(100)}
local Bal Bal1 Bal2 Bal3 in 
   {A getBal(Bal)}
   {Browse Bal} %0
   {A transfer(500)}
   {A getBal(Bal1)}
   {Browse Bal1} %500
   {A batchTransfer(500|1000|nil)}
   {A getBal(Bal2)}
   {Browse Bal2} %2000
   {B getBal(Bal3)}
   {Browse Bal3} %100
end

% inhéritance

class VerboseAccount from Account
   meth verboseTransfer(Amt)
      {self transfer(Amt)}
   end
end
B1 = {New VerboseAccount init(100)}
{B1 transfer(500)}
{B1 transfer(1000)}
local X in 
   {B1 getBal(X)}
   {Browse X} %1600
end


%%%%%%%%%%%%%% Nondeterminism and time %%%%%%%%%%%%%%

declare
C={NewCell 0}
thread I in
   I=@C
   {Delay 10}
   C:=I+1
end
thread J in
   J=@C
   {Delay 10}
   C:=J+1
end
{Delay 100}
{Browse @C} % 1

% Atomicity with Lock :

declare
C={NewCell 0}
L={NewLock}
thread
   lock L then I in
      I=@C
      {Delay 10}
      C:=I+1
   end
end
thread
   lock L then J in
      J=@C
      {Delay 10}
      C:=J+1
   end
end
{Delay 100}
{Browse @C} % 2








%%%%%%%%%%%%%% Tree %%%%%%%%%%%%%%

% creat a tree
declare
fun {Insert X V T}
   case T
   of leaf then tree(X V leaf leaf)
   [] tree(Y W T1 T2) andthen X==Y then
      tree(X V T1 T2)
   [] tree(Y W T1 T2) andthen X<Y then
      tree(Y W {Insert X V T1} T2)
   [] tree(Y W T1 T2) andthen X>Y then
      tree(Y W T1 {Insert X V T2})
   end
end
fun {RemoveSmallest T}
   case T
      of leaf then none
   [] tree(Y V T1 T2) then
      case {RemoveSmallest T1}
      of none then Y#V#T2
      [] Yp#Vp#Tp then Yp#Vp#tree(Y V Tp T2)
      end
   end
end

fun {Delete X T}
   case T
   of leaf then leaf
   [] tree(Y W T1 T2) andthen X==Y then
      case {RemoveSmallest T2}
      of none then T1
      [] Yp#Vp#Tp then tree(Yp Vp T1 Tp)
      end
   [] tree(Y W T1 T2) andthen X<Y then
      tree(Y W {Delete X T1} T2)
   [] tree(Y W T1 T2) andthen X>Y then
      tree(Y W T1 {Delete X T2})
   end
end


T1 = {Insert 1 2 leaf}
{Browse T1}
T2 = {Insert 2 1 T1}
T3 = {Insert 2 2 T2}
T4 = {Insert 4 5 T3}
T5 = {Insert 5 4 T4}
T6 = {Insert 8 7 T5}
T7 = {Insert 7 8 T6}
T8 = {Insert 3 2 T7}
T9 = {Insert 9 7 T8}
{Browse T9}
T10 = {Delete 5 T9}
T11 = {Delete 9 T10}
{Browse T11}


% look for a key
% use the previous T11 
fun {Lookup X T}
   case T
   of leaf then notfound
   [] tree(Y V T1 T2) andthen X==Y then found(V)
   [] tree(Y V T1 T2) andthen X<Y then {Lookup X T1}
   [] tree(Y V T1 T2) andthen X>Y then {Lookup X T2}
   end
end

{Browse {Lookup 8 T11}} % found(7)
{Browse {Lookup 9 T11}} % notfound


% DFS
proc {DFS T}
   case T
   of leaf then skip
   [] tree(Key Val L R) then
      {DFS L}
      {Browse Key#Val}
      {DFS R}
   end
end
{DFS T11}






%%%%%%%%%% message-passing concurrent %%%%%%%%
declare S P in
{NewPort S P}
{Browse S}
{Send P a}
{Send P b}   

% Port objects 
declare
fun {NewPortObject Init Fun}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
         {MsgLoop S2 {Fun Msg State}}
      [] nil then skip end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

S = {NewPortObject 1 fun {$ Msg State} {Browse State} State+Msg end}
{Send S 3} % browse 1
{Send S 4} % browse 4
{Send S 1} % browse 8


%other test with port object
declare
fun {NewPortObject2 Proc}
Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin}
end
proc {ServerProc Msg}
   case Msg
   of calc(X Y) then
      Y=X*X+2.0*X+2.0
   end
end
Server={NewPortObject2 ServerProc}

proc {ClientProc Msg}
   case Msg
   of work(Y) then
   Y1 Y2 in
      {Send Server calc(10.0 Y1)}
      {Wait Y1}
      {Send Server calc(20.0 Y2)}
      {Wait Y2}
      Y=Y1+Y2
   end
end
Client={NewPortObject2 ClientProc}
{Browse {Send Client work($)}} %564




%%%%%%%%%%%% Array %%%%%%%%%%%%%
declare
A={NewArray 0 10 1} 
{Array.put A 5 9}
{Browse{Array.get A 5}} % 9
{Browse{Array.get A 0}} % 1
{Browse{Array.low A}}   % 0


declare
fun {NewExtensibleArray L H Init}
   A={NewCell {NewArray L H Init}}#Init
   proc {CheckOverflow I}
      Arr=@(A.1)
      Low={Array.low Arr}
      High={Array.high Arr}
   in
      if I>High then
         High2=Low+{Max I 2*(High-Low)}
         Arr2={NewArray Low High2 A.2}
      in
         for K in Low..High do Arr2.K:=Arr.K end
         (A.1):=Arr2
      end
   end
   proc {Put I X}
      {CheckOverflow I}
      @(A.1).I:=X
   end
   fun {Get I}
      {CheckOverflow I}
      @(A.1).I
   end
in extArray(get:Get put:Put)
end

A = {NewExtensibleArray 0 10 1} 
{Browse {A.get 5}}
{A.put 5 8}
{Browse {A.get 5}}




%%%%%%%%%%%% Dico %%%%%%%%%%%%%
declare
D1={NewDictionary}
{Dictionary.put D1 1 'un'}
{Dictionary.put D1 'deux' 2}
R={Dictionary.toRecord 'record' D1}
{Browse R}
D={Record.toDictionary R}
D2={Dictionary.clone D}
R1 = {Dictionary.toRecord 'record' D1}
{Browse R1}
{Browse {Dictionary.get D 1}} % un
{Browse {Dictionary.get D 'deux'}} % 2
{Browse {Dictionary.condGet D 3 'None'}} %None
{Browse {Dictionary.condGet D 1 'None'}} %un
{Dictionary.remove D 1}
{Browse {Dictionary.condGet D 1 'None'}} %None
local B B1 in
   {Dictionary.member D 1 B}
   {Dictionary.member D 'deux' B1}
   {Browse B}%false
   {Browse B1}%true
end

%%%%%%%%% Stack %%%%%%%
declare
fun {NewStack}
   Stack={NewCell nil}
   proc {Push X}
   S in
      {Exchange Stack S X|S}
   end
   fun {Pop}
   X S in
      {Exchange Stack X|S S}
      X
   end
in
   stack(push:Push pop:Pop)
end

N = {NewStack}
{N.push 10}
{N.push 20}
{N.push 30}
{Browse {N.pop}}
{Browse {N.pop}}
{Browse {N.pop}}


%%%%%%% Queue %%%%%%%
declare
fun {NewQueue}
   X C={NewCell q(0 X X)}
   proc {Insert X}
   N S E1 in
      q(N S X|E1)=@C
      C:=q(N+1 S E1)
   end
   fun {Delete}
   N S1 E X in
      q(N X|S1 E)=@C
      C:=q(N-1 S1 E)
      X
   end
in
   queue(insert:Insert delete:Delete)
end

Q = {NewQueue}
{Q.insert 10}
{Q.insert 20}
{Q.insert 30}
{Browse{Q.delete}}
{Browse{Q.delete}}
{Browse{Q.delete}}


% Queue with locks
declare
fun {NewQueue}
   X C={NewCell q(0 X X)}
   L={NewLock}
   proc {Insert X}
   N S E1 in
      lock L then
         q(N S X|E1)=@C
         C:=q(N+1 S E1)
      end
   end
   fun {Delete}
   N S1 E X in
      lock L then
         q(N X|S1 E)=@C
         C:=q(N-1 S1 E)
      end
      X
   end
in
   queue(insert:Insert delete:Delete)
end

Q = {NewQueue}
thread
   {Q.insert 10}
   {Delay 10}
   {Q.insert 20}
   {Delay 10}
   {Q.insert 30}
end
thread
   {Q.insert 10}
   {Delay 10}
   {Q.insert 20}
   {Delay 10}
   {Q.insert 30}
end
{Browse{Q.delete}}
{Browse{Q.delete}}
{Browse{Q.delete}}
{Browse{Q.delete}}
{Browse{Q.delete}}
{Browse{Q.delete}}


%%%%%%%%%% excpetions %%%%%%%%

declare
fun {Eval E}
   if {IsNumber E} then E
   else
      case E
      of plus(X Y) then {Eval X}+{Eval Y}
      [] times(X Y) then {Eval X}*{Eval Y}
      else raise illFormedExpr(E) end
      end
   end
end
try
   {Browse {Eval plus(plus(5 5) 10)}} %20
   {Browse {Eval times(6 11)}}        %66
   {Browse {Eval minus(7 10)}}        % error
catch illFormedExpr(E) then
   {Browse '*** Illegal expression '#E#' ***'}
finally {Browse 'finish'}             % finish
end


%%%%%%%%% wrapper %%%%%%%%%%
declare
proc {NewWrapper ?Wrap ?Unwrap}
   Key={NewName}
in
   fun {Wrap X}
      fun {$ K} if K==Key then X end end
   end
   fun {Unwrap W}
      {W Key}
   end
end

local Wrap Unwrap in
   {NewWrapper Wrap Unwrap}
   fun {NewStack} {Wrap nil} end
   fun {Push S E} {Wrap E|{Unwrap S}} end
   fun {Pop S E}
      case {Unwrap S} of X|S1 then E=X {Wrap S1} end
   end
   fun {IsEmpty S} {Unwrap S}==nil end
end

S = {NewStack}
S1 = {Push S 5}
S2 = {Push S1 10}
%{Browse S2.1} % affiche rien 
local S3 X Y in 
   S3 = {Pop S2 X}
   {Browse X} % 10
   S4 = {Pop S3 Y}
   {Browse Y} % 10
end



%%%%%%%%%%%%%% Ticking  %%%%%%%%%%%%%%
%functor
%import
%   OS
%define
%   fun {NewTicker}
%      fun {Loop T}
%         T1={OS.localTime}
%      in
%         {Delay 900}
%         if T1\=T then T1|{Loop T1} else {Loop T1} end
%      end
%   in
%      thread {Loop {OS.localTime}} end
%   end
%end
%{Browse {NewTicker}}