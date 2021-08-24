%%%%%%%%% Socket %%%%%%%%

% Helper functions/imports, feed it before the tests
declare
[Open]={Module.link ["x-oz://system/Open.ozf"]}
MyBrow = {New Browser.'class' init}
{MyBrow option(representation strings:true)} % => to change the default string browsing, ASCII list [1 2 3]
proc {Browse Msg} {MyBrow browse(Msg)} end
proc {ReadingLoop Server}
    {Server read(list:{Browse})}
    {ReadingLoop Server}
end

% Start of tests
% Localhost
declare
X
H
P
Server = {New Open.socket init}
{Server bind(port:X)}
{Browse ("Port: "#X)}
{Server listen}
{Browse ("Client IP: "#H)}
{Browse ("Client port: "#P)}
thread {Server accept(host:H port:P)} end
thread {ReadingLoop Server} end
Client = {New Open.socket init}
{Client connect(host:"localhost" port:X)}
{Client write(vs:'Hello, good'#" old Server!")}
{Delay 2000}
{Client write(vs:"What a lovely day!")}
{Delay 2000}
{Client write(vs:"Goodbye server!")}
% ----- Close when done -----
{Server shutDown(how:[send receive])}
{Server close}
{Client close}
% The browser should display the 3 messages with an interval of 2sec, with additional info such as IP/port


% /!\ for remote socket
% LAN/remote => Server side
declare
X
H
P
% Server
% {Server server(host:H port:P)}
Server = {New Open.socket init}
{Server bind(port:X)}
{Browse ("Port: "#X)}
{Server listen}
{Browse ("Client IP: "#H)}
{Browse ("Client port: "#P)}
thread {Server accept(host:H port:P)} end   % => Once the reading loop started, give to the client the private (LAN) or public (remote)
thread {ReadingLoop Server} end             % IP of the server and the port to connect to (see next block of code)
% ----- Close when done -----
{Server shutDown(how:[send receive])}
{Server close}

% LAN/remote => Client side
declare 
Client = {New Open.socket init}
{Client connect(host:"192.168.1.58" port:55008)}   % => Enter private (LAN) or public (remote) IP of the server in host string and
{Client write(vs:'Hello, good'#" old Server!")}    % port number to connect to
{Delay 2000}
{Client write(vs:"What a lovely day!")}
{Delay 2000}
{Client write(vs:"Goodbye server!")}
% ----- Close when done -----
{Client close}
% The browser should display the 3 messages with an interval of 2sec, with additional info such as IP/port
