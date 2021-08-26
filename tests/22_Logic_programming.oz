
%or
declare
proc {Ints N Xs}
   or N = 0 Xs = nil
   [] Xr in  
      N > 0 = true Xs = N|Xr
      {Ints N-1 Xr}
   end  
end 
local  
   proc {Sum3 Xs N R}
      or Xs = nil R = N
      [] X|Xr = Xs in 
         {Sum3 Xr X+N R}
      end 
   end 
in proc {Sum Xs R} {Sum3 Xs 0 R} end 
end 
local N S R in 
   thread {Ints N S} end 
   thread {Sum S {Browse}} end    % 500500
   N = 1000
end


%cond
declare 
proc {Merge Xs Ys Zs}
   cond 
      Xs = nil then Zs = Ys
   [] Ys = nil then Zs = Xs
   [] X Xr in Xs = X|Xr then Zr in 
      Zs = X|Zr {Merge Xr Ys Zr}
   [] Y Yr in Ys = Y|Yr then Zr in 
      Zs = Y|Zr {Merge Xs Yr Zr}
   end 
end
local X in 
    {Merge [1 3 5] [2 4 6] X} % [1 3 5 2 4 6]
    {Browse X}
end


%dis
declare
proc {Append Xs Ys Zs}
   dis 
      Xs = nil Ys = Zs  
   [] X Xr Zr in 
      Xs = X|Xr Zs = X|Zr then 
      {Append Xr Ys Zr}
   end 
end
local X in 
   {Browse X}    % [1 2 3 a b c]
   {Append [1 2 3] [a b c] X}
end

