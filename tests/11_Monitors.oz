%%%%%%%% Monitor %%%%%%%%
declare
fun {NewQueue}
    X C={NewCell q(0 X X)}
    L={NewLock}
    proc {Insert X}
    N F B2 in
        lock L then
            q(N F X|B2)=@C
            C:=q(N+1 F B2)
        end
    end
    proc {Delete X}
    N F2 B in
        lock L then
            q(N X|F2 B)=@C
            C:=q(N-1 F2 B)
        end
    end
    fun {Size}
        lock L then @C.1 end
    end
    fun {DeleteAll}
        lock L then X S E in
            q(_ S E)=@C
            C:=q(0 X X) % Make empty
            E=nil S % Return all
        end
    end
    fun {DeleteNonBlock}
        lock L then
            if {Size}>0 then [{Delete}]
            else nil end
        end
    end
in
    queue(insert:Insert delete:Delete size:Size deleteall:DeleteAll deleteNonBlock:DeleteNonBlock)
end

fun {NewGRLock}
    Token1={NewCell unit}
    Token2={NewCell unit}
    CurThr={NewCell unit}
    fun {GetLock}
        if {Thread.this}\=@CurThr then
            Old New
        in
            {Exchange Token1 Old New}
            {Wait Old}
            Token2:=New % Prepare release
            CurThr:={Thread.this}
            true
        else
            false
        end
    end
    proc {ReleaseLock}
        CurThr:=unit
        unit=@Token2 % Pass the token
    end
in
    'lock'(get:GetLock release:ReleaseLock)
end



fun {NewMonitor}
    Q={NewQueue}
    L={NewGRLock}
    proc {LockM P}
        if {L.get} then
            try {P} finally {L.release} end
        else {P} end
    end
    proc {WaitM}
        X in
        {Q.insert X} {L.release}
        {Wait X} if {L.get} then skip end
    end
    proc {NotifyM}
        U={Q.deleteNonBlock} in
            case U of [X] then X=unit
            else skip end
    end
    proc {NotifyAllM}
        L={Q.deleteall} in
            for X in L do X=unit end
    end
in
    monitor('lock':LockM wait:WaitM notify:NotifyM notifyAll:NotifyAllM)
end


class Buffer
    attr m buf first last n i
    meth init(N)
        m:={NewMonitor}
        buf:={NewArray 0 N-1 null}
        first:=0 last:=0 n:=N i:=0
    end
    meth put(X)
        {@m.'lock' proc {$}
            if @i>=@n then % if full, wait
                {@m.wait}
                {self put(X)} % try again!
            else
                @buf.@last:=X
                last:=(@last+1) mod @n
                i:=@i+1
                {@m.notifyAll} % tell others!
            end
        end}
    end
    meth get(X)
        {@m.'lock' proc {$}
            if @i==0 then
                {@m.wait}
                {self get(X)}
            else
                X=@buf.@first
                first:=(@first+1) mod @n
                i:=@i-1
                {@m.notifyAll}
            end
        end}
    end
end

B = {New Buffer init(3)}

thread 
   for I in 0..5 do 
      {Delay 1}
      {B put(I)}
   end
end
thread 
   for J in 5..10 do 
      {Delay 1}
      {B put(J)}
   end
end
thread 
   for T in 0..11 do 
      local X in 
         {B get(X)}
         {Browse X}
      end
   end
end

% Ca affiche les nombres de 0 à 10 mais l'ordre peut changer d'un run à l'autre.
% Cela commencre juste toujours par 5 pui 0.
