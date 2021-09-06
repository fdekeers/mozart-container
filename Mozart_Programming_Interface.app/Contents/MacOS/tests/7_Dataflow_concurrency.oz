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
{Browse start} {Browse X*X} % start 9801

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


% test {wait}
declare X % (1)
thread X={fun lazy {$} {Delay 3000} 11*11 end} end % (2)
thread {Wait X} {Browse X} end % wait 3sec and then display 121