%%%%%%%%% Socket %%%%%%%%

% /!\ ici testé en localhost, il faudra tester entre différents processurs, ordinateurs et réseaux

declare
MyBrow = {New Browser.'class' init}
{MyBrow option(representation strings:true)}

X = _
H = _
P = _

proc {ReadingLoop Server}
    {Server read(list:{MyBrow browse($)})}
    {ReadingLoop Server}
end

[Open]={Module.link ["x-oz://system/Open.ozf"]}
Server = {New Open.socket init(type:stream protocol:"" time:~1)}
{Server bind(port:X)}
{MyBrow browse("Port: "#X)}
{Server listen}
{MyBrow browse(H#": "#P)}
thread {Server accept(host:H port:P)} end
Client = {New Open.socket init(type:stream protocol:"" time:~1)}
{Client connect(host:"127.0.0.1" port:X)}
thread {ReadingLoop Server} end
{Client write(vs:'Hello, good'#" old Server!")}
{Delay 2000}
{Client write(vs:"What a lovely day!")}
{Delay 2000}
{Client write(vs:"Goodbye server!")}
{Server shutDown(how:[send receive])}
{Server close}
{Client close}