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