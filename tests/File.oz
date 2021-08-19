declare
[Open]={Module.link ["x-oz://system/Open.ozf"]}
X = {New Open.file init(name: 'foo.txt' flags: [write create] mode: mode(owner:[read write] all:[read write]))}
{X write(vs: 'This comes in the file.\n' len: 24)}
{X write(vs: 'The result of 43*43 is '#43*43#'.\n' len:29)}
{X write(vs: "Strings are ok too.\n" len : 20)}
{X close}

% the created file contains : 
%   This comes in the file.
%   The result of 43*43 is 1849.
%   Strings are ok too.



declare 
X = {New Open.file init(name: 'foo.txt' flags: [read] mode: mode(owner:[read] all:[read]))}
L
{X read(list: L tail: nil size: 1024 len:73)}
for I in L do
    {Browse {Char.toAtom I}}
end
{X close}


