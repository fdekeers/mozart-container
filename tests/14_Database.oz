%%%%%%%%% database %%%%%%%%

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

declare
proc {Choose ?X Ys}
    choice Ys=X|_
    [] Yr in Ys=_|Yr {Choose X Yr} end
end
class RelationClass
    attr d
    meth init
        d:={NewDictionary}
    end
    meth assertall(Is)
        for I in Is do {self assert(I)} end
    end
    meth assert(I)
        if {IsDet I.1} then
            Is={Dictionary.condGet @d I.1 nil} in
            {Dictionary.put @d I.1 {Append Is [I]}}
        else
            raise databaseError(nonground(I)) end
        end
    end
    meth query(I)
        if {IsDet I} andthen {IsDet I.1} then
            {Choose I {Dictionary.condGet @d I.1 nil}}
        else
            {Choose I {Flatten {Dictionary.items @d}}}
        end
    end
end


NodeRel={New RelationClass init}
{NodeRel
    assertall([node(1) node(2) node(3) node(4)
        node(5) node(6) node(7) node(8)])}

EdgeRel={New RelationClass init}
{EdgeRel
    assertall([edge(1 2) edge(2 1) edge(2 3) edge(3 4)
               edge(2 5) edge(5 6) edge(4 6) edge(6 7)
               edge(6 8) edge(1 5) edge(5 1)])}

proc {NodeP A} {NodeRel query(node(A))} end
proc {EdgeP A B} {EdgeRel query(edge(A B))} end

proc {Q2 ?X} A B C D in
    {EdgeP A B} A<B=true
    {EdgeP B C} B<C=true
    {EdgeP C D} C<D=true
    X=path(A B C D)
end
{Browse {SolveAll Q2}}
