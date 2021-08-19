%%%%%%%%%%%%%% constraint programming %%%%%%%%%%%%


% Implémentation de la fonction SolveAll, voir p.779 du livre de réf/p.822 du pdf -S

declare
fun {Solve Script}
    {SolveStep {Space.new Script} nil}
end

fun {SolveStep S SolTail}
    case {Space.ask S}
        of failed then SolTail
        [] succeeded then {Space.merge S}|SolTail
        [] alternatives(N) then {SolveLoop S 1 N SolTail}
    end
end

fun lazy {SolveLoop S I N SolTail}
    if I>N then
        SolTail
    elseif I==N then
        {Space.commit S I}
        {SolveStep S SolTail}
    else
        C={Space.clone S}
        NewTail={SolveLoop S I+1 N SolTail}
    in
        {Space.commit C I}
        {SolveStep C NewTail}
    end
end

declare
fun {SolveAll F}
    L={Solve F}
    proc {TouchAll L}
        if L==nil then skip else {TouchAll L.2} end
    end
in
    {TouchAll L}
    L
end


% Début des tests

declare X Y A in
X::90#110
Y::48#53
{Browse X*Y >: 4000} % Displays 1
A::0#10000
A=:X*Y
{Browse A>:4000} % Displays 1
{Browse A} % Displays A{4320#5830}
{Browse X} % Display X{90#110}
{Browse Y} % Display Y{48#53}
X-2*Y=:11 % => updates constraints on X, Y, A without needing to rebrowse


declare
proc {Rectangle ?Sol}
    sol(X Y)=Sol
in
    X::1#9 Y::1#9
    X*Y=:24 X+Y=:10 X=<:Y
    {FD.distribute naive Sol}
end
{Browse {SolveAll Rectangle}} % Display [sol(4 6)]


declare
proc {SendMoreMoney ?Sol}
    S E N D M O R Y
in
    Sol=sol(s:S e:E n:N d:D m:M o:O r:R y:Y)        %1
    Sol:::0#9                                       %2
    {FD.distinct Sol}                               %3
    S\=:0                                           %4
    M\=:0
            1000*S + 100*E + 10*N + D               %5
            + 1000*M + 100*O + 10*R + E
            =: 10000*M + 1000*O + 100*N + 10*E + Y
    {FD.distribute ff Sol}                          %6
end
{Browse {SolveAll SendMoreMoney}} % Display [sol(d:7 e:5 m:1 n:6 o:0 r:8 s:9 y:2)]
