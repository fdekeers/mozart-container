%%%%%%%%%%%%%% tests variable et browse %%%%%%%%%%%%%%

declare
V = 9999*9999
{Browse V * V} % 9996000599960001
{Browse 1*2*3*4*5*6*7*8*9*10} % 3628800
X = 10
Y = 20
{Browse X + Y} %30
{Browse X mod Y} % 10
{Browse Y div X} % 2
local A=1.0 B=3.0 C=2.0 D RealSol X1 X2 in     % ˜ remplacés par ~, et je pense que ça devrait être true#~1.0#~2.0 au lieu de true#2#1 -S
   D=B*B-4.0*A*C
   if D>=0.0 then
      RealSol=true
      X1=(~B+{Sqrt D})/(2.0*A)
      X2=(~B-{Sqrt D})/(2.0*A)
   else
      RealSol=false
      X1=~B/(2.0*A)
      X2={Sqrt ~D}/(2.0*A)
   end
   {Browse RealSol#X1#X2} % true#2#1
end

% enumerate elements
for I in 0..10 do {Browse I} end


%static scoping
local X in
   X=1
   local X in
      X=2
      {Browse X} %2
   end
   {Browse X} %1
end