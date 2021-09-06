
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



declare
fun {Soft} choice beige [] coral end end
fun {Hard} choice mauve [] ochre end end
proc {Contrast C1 C2}
    choice C1={Soft} C2={Hard} [] C1={Hard} C2={Soft} end
end
fun {Suit}
    Shirt Pants Socks
in
    {Contrast Shirt Pants}
    {Contrast Pants Socks}
    if Shirt==Socks then fail end
    suit(Shirt Pants Socks)
end
{Browse {SolveAll Suit}} %[suit(beige mauve coral) suit(beige ochre coral)
                         % suit(coral mauve beige) suit(coral ochre beige)
                         % suit(mauve beige ochre) suit(mauve coral ochre)
                         % suit(ochre beige mauve) suit(ochre coral mauve)]



declare
fun {Digit}
    choice 0 [] 1 [] 2 [] 3 [] 4 [] 5 [] 6 [] 7 [] 8 [] 9 end
end
{Browse {SolveAll Digit}} % [0 1 2 3 4 5 6 7 8 9]


declare
proc {Palindrome ?X}
    X=(10*{Digit}+{Digit})*(10*{Digit}+{Digit}) % Generate
    (X>0)=true % Test 1
    (X>=1000)=true % Test 2
    (X div 1000) mod 10 = (X div 1) mod 10 % Test 3
    (X div 100) mod 10 = (X div 10) mod 10 % Test 4
end
{Browse {SolveAll Palindrome}} %  118

