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