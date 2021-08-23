%%%%%%%%%%%%%% State (cell) %%%%%%%%%%%%%%

declare
C={NewCell 0}
C:=@C+1
{Browse @C}

% Pascal with cell
declare
fun {OpList Op L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 {Op H1 H2}|{OpList Op T1 T2}
      end
   else nil end
end

fun {Add X Y} X+Y end

fun {GenericPascal Op N}
   if N==1 then [1]
   else L in
      L={GenericPascal Op N-1}
      {OpList Op {ShiftLeft L} {ShiftRight L}}
   end
end

C={NewCell 0}
fun {FastPascal N}
   C:=@C+1
   {GenericPascal Add N}
end

{Browse {FastPascal 10}}


declare
local C in
   C={NewCell 0}
   fun {Bump}
      C:=@C+1
      @C
   end
   fun {Read}
      @C
   end
end

{Browse {Bump}} % 1
{Browse {Bump}} % 2

% Pascal with Bump
declare
fun {OpList Op L1 L2}
   case L1 of H1|T1 then
      case L2 of H2|T2 then
	 {Op H1 H2}|{OpList Op T1 T2}
      end
   else nil end
end

fun {Add X Y} X+Y end

fun {GenericPascal Op N}
   if N==1 then [1]
   else L in
      L={GenericPascal Op N-1}
      {OpList Op {ShiftLeft L} {ShiftRight L}}
   end
end
fun {FastPascal N}
   {Browse {Bump}}
   {GenericPascal Add N}
end
{Browse {FastPascal 10}}


declare
fun {NewCounter}
   C Bump Read in
   C={NewCell 0}
   fun {Bump}
      C:=@C+1
      @C
   end
   fun {Read}
      @C
   end
   counter(bump:Bump read:Read)
end

Ctr1={NewCounter}
Ctr2={NewCounter}
{Browse {Ctr1.bump}} %1
{Browse {Ctr1.bump}} %2
{Browse {Ctr2.bump}} %1
{Browse {Ctr1.read}} %2
{Browse {Ctr1.bump}} %3