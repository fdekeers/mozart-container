%%%%%%%%%%% GUI %%%%%%%%%%%
declare 
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}


fun {GetText A}
    H T D W in
        D=td(lr(label(text:A) entry(handle:H))
            button(text:"Ok"
                action:proc {$} T={H get($)} {W close} end))
    W={QTk.build D}
    {W show} {W wait}
    T
end

{Browse {GetText "Entrez un texte :"}}



% éditeur de texte
declare 
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
 
proc{SaveText}
   Name={QTk.dialogbox save($)}
in  
   try  
      File={New Open.file init(name:Name flags:[write create truncate])}
      Contents={TextHandle get($)}
   in  
      {File write(vs:Contents)}
      {File close}
   catch _ then skip end  
end  
 
proc{LoadText}
   Name={QTk.dialogbox load($)}
in  
   try  
      File={New Open.file init(name:Name)}
      Contents={File read(list:$ size:all)}
   in  
      {TextHandle set(Contents)}
      {File close}
   catch _ then skip end  
end 
 
Toolbar=lr(glue:we
           tbbutton(text:"Save" glue:w action:SaveText)
           tbbutton(text:"Load" glue:w action:LoadText)
           tbbutton(text:"Quit" glue:w action:toplevel#close))
 
TextHandle
 
Window={QTk.build td(Toolbar
                     text(glue:nswe handle:TextHandle bg:white tdscrollbar:true))}
 
{Window show}


%simple text I/O interface
declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
In Out
A1=proc {$} X in {In get(X)} {Out set(X)} end
A2=proc {$} {W close} end
D=td(title:"Simple text I/O interface"
    lr(label(text:"Input:")
        text(handle:In tdscrollbar:true glue:nswe)
        glue:nswe)
    lr(label(text:"Output:")
        text(handle:Out tdscrollbar:true glue:nswe)
        glue:nswe)
    lr(button(text:"Do It" action:A1 glue:nswe)
        button(text:"Quit" action:A2 glue:nswe)
        glue:we))
W={QTk.build D}
{W show}