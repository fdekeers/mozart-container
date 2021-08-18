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