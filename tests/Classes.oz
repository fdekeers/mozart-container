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
