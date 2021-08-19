%%%%%%%%%%%%% distrubuted programming %%%%%%%%%

declare
[Connection]={Module.link ['x-oz://system/Connection.ozf']} % system à la place a marché ! -S
X=the_novel(text:"It was a dark and stormy night. ..."
author:"E.G.E. Bulwer-Lytton"
year:1803)
{Show {Connection.offerUnlimited X}}