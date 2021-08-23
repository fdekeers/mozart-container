%%%%%%%%%%%%%% Lazy evalutation %%%%%%%%%%%%%%

declare 
fun lazy {Ints N}
   N|{Ints N+1}
end
L = {Ints 0}
{Browse L}
{Browse L.1}
{Browse L.2.2.1}
{Browse L.1}

L1 = {Ints 0}
case L1 of A|B|C|_ then {Browse A+B+C} end % 3




% Lazy evalutation of Pascal triangle

declare
fun {ShiftLeft L}
   case L of H|T then
      H|{ShiftLeft T}
   else [0] end
end
fun {ShiftRight L} 0|L end
fun {AddList L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 H1+H2|{AddList T1 T2}
      end
   else nil end
end
fun lazy {PascalList Row}
   Row|{PascalList
	{AddList {ShiftLeft Row}
	 {ShiftRight Row}}}
end

L = {PascalList [1]}
{Browse L.2.2.2.2.2.2.2.1}
{Browse L}