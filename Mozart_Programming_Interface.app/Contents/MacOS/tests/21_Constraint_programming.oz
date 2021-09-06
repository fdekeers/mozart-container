%%%%%%%%%%%%%% constraint programming %%%%%%%%%%%%


% Imports
declare
[FD]={Module.link ["x-oz://system/FD.ozf"]}
[Schedule]={Module.link ["x-oz://system/Schedule.ozf"]}


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


declare
House = house(tasks:   [a(dur:7            res:constructionInc)
                        b(dur:3  pre:[a]   res:houseInc)
                        c(dur:1  pre:[b]   res:houseInc)
                        d(dur:8  pre:[a]   res:constructionInc)
                        e(dur:2  pre:[c d] res:constructionInc)
                        f(dur:1  pre:[c d] res:houseInc)
                        g(dur:1  pre:[c d] res:houseInc)
                        h(dur:3  pre:[a]   res:constructionInc)
                        i(dur:2  pre:[f h] res:builderCorp)
                        j(dur:1  pre:[i]   res:builderCorp)
                        pe(dur:0 pre:[j])])
fun {GetDur TaskSpec}
    {List.toRecord dur {Map TaskSpec    fun {$ T}
                                            {Label T}#T.dur
                                        end}}
end
fun {GetStart TaskSpec}
    MaxTime = {FoldL TaskSpec   fun {$ Time T}
                                    Time+T.dur
                                end 0}
    Tasks   = {Map TaskSpec Label}
in
    {FD.record start Tasks 0#MaxTime}
end
fun {GetTasksOnResource TaskSpec}
    D={Dictionary.new}
in
    {ForAll TaskSpec
    proc {$ T}
        if {HasFeature T res} then R=T.res in
            {Dictionary.put D R {Label T}|{Dictionary.condGet D R nil}}
        end
    end}
    {Dictionary.toRecord tor D}
end
fun {Compile Spec}
    TaskSpec   = Spec.tasks
    Dur        = {GetDur TaskSpec}
    TasksOnRes = {GetTasksOnResource TaskSpec}
in
    proc {$ Start}
        Start = {GetStart TaskSpec}
        {ForAll TaskSpec
        proc {$ T}
            {ForAll {CondSelect T pre nil}
            proc {$ P}
                Start.P + Dur.P =<: Start.{Label T}
            end}
        end}
        {Schedule.serializedDisj TasksOnRes Start Dur}
        {Record.forAll TasksOnRes
        proc {$ Ts}
            {ForAllTail Ts
            proc {$ T1|Tr}
                {ForAll Tr
                proc {$ T2}
                    choice Start.T1 + Dur.T1 =<: Start.T2
                    []     Start.T2 + Dur.T2 =<: Start.T1
                    end
                end}
            end}
        end}
        {FD.assign min Start}
    end
end
proc {Earlier Old New}
    Old.pe >: New.pe
end
{ExploreBest {Compile House} Earlier} % should plot a sort of graph with shapes (yes)
