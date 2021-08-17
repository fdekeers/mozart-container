declare
[File]={Module.link [´File.ozf´]}
{File.writeOpen ´foo.txt´}
{File.write ´This comes in the file.\n´}
{File.write ´The result of 43*43 is ´#43*43#´.\n´}
{File.write "Strings are ok too.\n"}
{File.writeClose}
