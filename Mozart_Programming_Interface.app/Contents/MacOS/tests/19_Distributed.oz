%%%%%%%%%%%%% distrubuted programming %%%%%%%%%

% Helper functions/imports, feed it before the tests
declare
[Connection]={Module.link ['x-oz://system/Connection.ozf']} % system à la place a marché ! -S
MyBrow = {New Browser.'class' init}
{MyBrow option(representation strings:true)}
proc {Browse Msg} {MyBrow browse(Msg)} end % => to change the default string browsing, ASCII list [1 2 3]
proc {Offer X FN} {Pickle.save {Connection.offerUnlimited X} FN} end % => store tickets in a file
fun {Take FN} {Connection.take {Pickle.load FN}} end % => get tickets from a file

% Start of tests
% Localhost
declare
X=the_novel(text:"It was a dark and stormy night. ..."
author:"E.G.E. Bulwer-Lytton"
year:1803)
{Browse X}
T = {Connection.offerUnlimited X}
{Browse T}
X2={Connection.take T}
{Browse X2}

declare
fun {MyEncoder X} (X*4449+1234) mod 33667 end
{Browse {MyEncoder 10000}} % => 17127
T2 = {Connection.offerUnlimited MyEncoder}
{Browse T2}
X3 = {Connection.take T2}
{Browse {X3 10000}} % => 17127

% LAN/remote #1 => side 1
declare T X in
T = {Connection.offerUnlimited X}
{Browse T}
% Do the side 2 part before assigning a value to X
X = 11

% LAN/remote #1 => side 2
declare X2 in
X2 = {Connection.take 'oz-ticket://192.168.1.58:9000/h8015188#0'}  % => replace '...' with the string of the ticket created in side 1
{Browse X2*X2}

% LAN/remote #2 => side 1
declare Xs Sum in
{Offer Xs ticketfile}
fun {Sum Xs A}
    case Xs of X|Xr then {Sum Xr A+X} [] nil then A end
end
{Browse Xs}
{Browse {Sum Xs 0}}

% LAN/remote #2 => side 2
declare Xs Generate in
Xs = {Take ticketfile}
fun {Generate N Limit}
    if N<Limit then N|{Generate N+1 Limit} else nil end
end
Xs = {Generate 0 10}
