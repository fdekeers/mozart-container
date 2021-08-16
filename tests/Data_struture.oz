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