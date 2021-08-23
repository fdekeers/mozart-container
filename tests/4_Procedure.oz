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


%last call optimization

declare
proc {Loop10 I}
   if I==10 then skip
   else
      {Browse I}
      {Loop10 I+1}
   end
end

{Loop10 0} % display 0 up to 9