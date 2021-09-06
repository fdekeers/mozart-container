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
{Browse{Q.delete}} %10
{Browse{Q.delete}} %10
{Browse{Q.delete}} %20
{Browse{Q.delete}} %20
{Browse{Q.delete}} %30
{Browse{Q.delete}} %30

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
   {Browse Y} % 5
end