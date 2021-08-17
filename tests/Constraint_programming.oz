%%%%%%%%%%%%%% constraint programming %%%%%%%%%%%%

declare A in
A::0#10000
A=:X*Y
{Browse A>:4000} % Displays 1
{Browse A} % Displays A{4320#5830}
{Browse X} % Display X{107#109}
{Browse Y} % Display Y{48#49}



proc {Rectangle ?Sol}
    sol(X Y)=Sol
in
    X::1#9 Y::1#9
    X*Y=:24 X+Y=:10 X=<:Y
    {FD.distribute naive Sol}
end
{Browse {SolveAll Rectangle}} % Display [sol(4 6)]




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