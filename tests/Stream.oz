%%%%%%%%%%%%% stream %%%%%%%%%%%%


%sum
declare
fun {Generate N Limit}
    if N<Limit then
        N|{Generate N+1 Limit}
    else nil end
end

fun {Sum Xs A}
    case Xs
    of X|Xr then {Sum Xr A+X}
    [] nil then A
    end
end

local Xs S in
    thread Xs={Generate 0 150000} end % Producer thread
    thread S={Sum Xs 0} end % Consumer thread
    {Browse S} % 11249925000
end


%sieve
declare 
fun {Generate N Limit}
    if N<Limit then
        N|{Generate N+1 Limit}
    else nil end
end
fun {Sieve Xs}
    case Xs
    of nil then nil
    [] X|Xr then Ys in
        thread Ys={Filter Xr fun {$ Y} Y mod X \= 0 end} end
        X|{Sieve Ys}
    end
end
local Xs Ys in
    thread Xs={Generate 2 100000} end
    thread Ys={Sieve Xs} end
    {Browse Ys} % 2 | 3 | 5 | 7 | 11 | 13 | 17 | 19 | ....
end