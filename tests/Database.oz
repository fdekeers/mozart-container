%%%%%%%%% database %%%%%%%%
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