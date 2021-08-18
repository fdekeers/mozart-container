%%%%%%%%%%%%%% lists  %%%%%%%%%%%%%%

declare
L = [1 2 3 4 5]
L1 = 1|2|3|4|5|nil
L2 = 1|(2|(3|(4|(5|nil)))) 
{Browse L} % [1 2 3 4 5]
{Browse L1} % [1 2 3 4 5]
{Browse L2}
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






%%%%%%%%%%%%%% Functions with lists %%%%%%%%%%%%%%

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