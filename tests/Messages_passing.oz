%%%%%%%%%% message-passing concurrent %%%%%%%%
declare S P in
{NewPort S P}
{Browse S}
{Send P a}
{Send P b}   

% Port objects 
declare
fun {NewPortObject Init Fun}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
         {MsgLoop S2 {Fun Msg State}}
      [] nil then skip end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

S = {NewPortObject 1 fun {$ Msg State} {Browse State} State+Msg end}
{Send S 3} % browse 1
{Send S 4} % browse 4
{Send S 1} % browse 8


%other test with port object
declare
fun {NewPortObject2 Proc}
Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin}
end
proc {ServerProc Msg}
   case Msg
   of calc(X Y) then
      Y=X*X+2.0*X+2.0
   end
end
Server={NewPortObject2 ServerProc}

proc {ClientProc Msg}
   case Msg
   of work(Y) then
   Y1 Y2 in
      {Send Server calc(10.0 Y1)}
      {Wait Y1}
      {Send Server calc(20.0 Y2)}
      {Wait Y2}
      Y=Y1+Y2
   end
end
Client={NewPortObject2 ClientProc}
{Browse {Send Client work($)}} %564