unit actunit;

{$mode objfpc}{$H+}

interface

uses Classes,//tstringlist
     SysUtils,//exception;
     Dialogs,//messagedlg;inputBox;
     fpHTTPclient,   // mhttpget
     opensslsockets, // mhttpget
     typeunit;//ustring;

var idxreact:  cardinal = 0;

procedure initactprims;
procedure domonad;

implementation

uses apiunit, serveunit, vmunit;

var idxdefine: cardinal = xnil;
    idxredefine: cardinal = xnil;
    idxshowgraph: cardinal = xnil;
    idxshowinfo: cardinal = xnil;
    idxprint: cardinal = xnil;
    idxinput: cardinal = xnil;
    idxloadtext: cardinal = xnil;
    idxsavetext: cardinal = xnil;
    idxrun: cardinal = xnil;
    idxquit: cardinal = xnil;
    idxtime: cardinal = xnil;
    idxdate: cardinal = xnil;
    idxbeep: cardinal = xnil;
    idxhttpget: cardinal = xnil;

// ------- legacy -------
procedure mundef;
begin raise exception.create('m-function undefined.')// provi
end;

procedure mdefine;  // provi             ,def?
begin apiget(idxdefine,mdict,xself);
      //ifxundef
      //ifxerror
      epush(etop);
      apiget(idxdefine,mdict,xpara);
      //ifxundef,etc...dec()
      //ifxerror...dec()
      efun:=estack[eptr];  dec(eptr);//pull
      einf:=infix[efun];
      if ((einf=xident) or (einf=xprefix)) then begin
         if (cell[efun].value=xreserve) then begin
            cell[efun].value:=etop;
            apiput(mdict,xit,xnil)//etop:=mdict ,oder ok oder success ???
         end
         else apiput(mdict,xit,newerror(idxdefine,eopmutnoreserve))
      end
      else apiput(mdict,xit,newerror(idxdefine,eopnomutable))
end;

procedure mredefine;                   // ,redef?
begin apiget(idxredefine,mdict,xself);
      //ifxundef
      //ifxerror
      epush(etop);
      apiget(idxredefine,mdict,xpara);
      //ifxundef...dec()
      //ifxerror...dec()
      efun:=estack[eptr];  dec(eptr);
      einf:=infix[efun];
      if ((einf=xident) or (einf=xprefix)) then begin
         cell[efun].value:=etop;
         apiput(mdict,xit,xnil)//etop:=mdict ,oder ok oder success ???
      end
      else apiput(mdict,xit,newerror(idxredefine,eopnomutable))
end;

procedure mshowgraph; // legacy überarbeitet ,height=1? ,errorconstanten
var delta: longint;
begin apiget(idxshowgraph,mdict,xit);//umgestellt auf monaden
      trail:=etop; // ? tests?
      if ((uipaintbox<>nil) and (uipanel<>nil) and (uiform<>nil)) then begin
         if uipanel.visible then delta:=uipanel.height
                            else delta:=0;
         if (uipaintbox.height<=1) then
            uipaintbox.height:=uiform.clientheight-delta-splitterheight;
         uipaintbox.repaint;
         apiput(mdict,xit,xnil)
      end
      else apiput(mdict,xit,newerror(idxshowgraph,'Device is not installed...'))
end;

procedure mshowinfo;
begin apiget(idxshowinfo,mdict,xit);
      serveinput:=true;//test für wine
      messagedlg(AnsiDequotedStr(tovalue(etop),qot2),mtinformation,[mbok],0);
      serveinput:=false;//test für wine
      etop:=mdict;
      //xbind?
end;

procedure mprint;
begin apiget(idxprint,mdict,xit);
      serveprint(AnsiDequotedStr(tovalue(etop),qot2)); // pre: (totable(etop));
      etop:=mdict;
      //xbind?
end;

// auf errors von apiget und apiput achten/reagieren !!!

procedure minput;
const title='input';
var s0,s1,s: ustring;
begin apiget(idxinput,mdict,xself);
      s0:=AnsiDequotedStr(tovalue(etop),qot2);
      apiget(idxinput,mdict,xpara);
      if (infix[etop]=xnull) then s1:=''
      else s1:=AnsiDequotedStr(tovalue(etop),qot2);
      serveinput:=true;
      s:=inputBox(title,s0,s1);
      serveinput:=false;
      apiput(mdict,xit,newstring(s))
      // errors? ...
end;

procedure minputpre;
var s: ustring;
begin apiget(idxinput,mdict,xit);
      s:=AnsiDequotedStr(tovalue(etop),qot2);
      serveinput:=true;
      s:=inputbox('input',s,'');
      serveinput:=false;
      apiput(mdict,xit,newstring(s));//etop:=newstring(s)??? ,wie mit #var
      //xbind? ,error?
end;

procedure mloadtext;
var txtlist: tstringlist;
    i: longint;//groß genug?
    txt,crlf,fname: ustring;
begin apiget(idxloadtext,mdict,xit);
      fname:=AnsiDequotedStr(tovalue(etop),qot2);//path?,lokal;
      txtlist:=tstringlist.create;
      try if fileexists(fname) then begin
             txtlist.loadfromfile(fname);
             txt:='';  crlf:='';
             for i:=0 to txtlist.count-1 do begin
                 txt:=txt+crlf+txtlist.strings[i];
                 crlf:=#13#10
             end;
             txtlist.clear;
             apiput(mdict,xit,newstring(txt))
          end
          else apiput(mdict,xit,newerror(idxloadtext,efilenotfound+' - '+fname)); // genauer?
          txtlist.free
      except on e: exception do begin
                txtlist.free;
                apiput(mdict,xit,newerror(idxloadtext,e.message)) // +fname ?
             end
      end
end;

procedure msavetext;// provi ,para und self vertauscht! ,it? ,errorconstanten
var txtlist: tstringlist;
    txt,fname: ustring;
begin apiget(idxsavetext,mdict,xpara);
      if (infix[etop]<>xstring) then begin
         apiput(mdict,xit,newerror(idxsavetext,'For savetext [1] string expected.'));
         //fehler genauer behandeln oder flexibler
         exit
      end;
      txt:=cell[etop].pstr^;//if nil?
      apiget(idxsavetext,mdict,xself);
      fname:=AnsiDequotedStr(tovalue(etop),qot2);
      //path?,lokal;
      txtlist:=tstringlist.create;
      try txtlist.text:=txt;  txt:='';
          txtlist.WriteBOM:=true;
          txtlist.savetofile(fname,TEncoding.UTF8);// gerne UTF8BOM
          txtlist.clear;
          apiput(mdict,xit,newstring(fname));// xnil oder bessere lösung?
          txtlist.free
      except on e: exception do begin
                txtlist.free;
                apiput(mdict,xit,newerror(idxsavetext,e.message)) // genauere bessere lösung?
             end
      end;
      //hier weiter machen?
end;

procedure mrun;
begin apiget(idxrun,mdict,xit);
      try serverun(AnsiDequotedStr(tovalue(etop),qot2));
          apiput(mdict,xit,xnil)
      except on e: exception do apiput(mdict,xit,newerror(idxrun,e.message))
      end//try und _error...
end;

procedure mquit;
begin etop:=mdict;
      servequit:=true;//position? ,bedingungen? ,etc?;
      //
end;

procedure mtime;
var f: extended;
begin f:=time;
      apiput(mdict,xit,newreal(f))
end;

procedure mdate;
var f: extended;
begin f:=date;
      apiput(mdict,xit,newreal(f))
end;

procedure mbeep;
begin beep;
      etop:=mdict
end;

procedure mhttpget;
var url,txt: ustring;
begin apiget(idxhttpget,mdict,xit);
      if (infix[etop]<>xstring) then begin
         apiput(mdict,xit,newerror(idxhttpget,'For httpget string expected.'));
         //fehler genauer ...
         exit
      end;
      url:=cell[etop].pstr^;// if nil?
      try txt:=Tfphttpclient.simpleget(url);
          apiput(mdict,xit,newstring(txt))
      except on e: exception do begin
                apiput(mdict,xit,newerror(idxhttpget,e.message)) // ... ?
             end
      end;
end;

var aindex: int64 = 0;

// ------------------
// ----- legacy -----
// ------------------
{procedure domonadpre;
begin //adict:=etop;
      if (infix[etop]<>xact) then raise exception.create('domonad isno _act');//provi-test
      mstack:=prop(etop,xcons,mstack);//etop auf den astack legen ...
      mdict:=cell[etop].rest;
      etop:=cell[etop].first;
      repeat einf:=infix[etop];
             if (einf=xinteger)    then begin
                aindex:=cell[etop].inum;
                if (aindex>0) then begin if (aindex<=maxproc) then proc[aindex]
                                         else provisorium('domonad first >maxproc');
                                         break
                                   end
                else provisorium('domonad first neg_int')
             end
             else if (einf=xident) then begin;provisorium('domonad infirst _ident');end
             //ifxindex?
             else if (einf=xact)   then begin;provisorium('domonad infirst _act');end
             else if (einf=xnull)  then begin;provisorium('domonad infirst _null');end//position?
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit//???
             else begin;provisorium('domonad infirst <else>');end//se break//???
      until false;
      //bind... in servreaction?
end;}

procedure domonad;
begin if (infix[etop]=xact) then begin
         //_bind,mstack?
         //mstack:=prop(etop,xcons,mstack);//for test
         //
         with cell[etop] do begin mdict:=rest; etop:=first end;
         //mstack:=prop(prop(xnil,xact,mdict),xcons,mstack);
         einf:=infix[etop];
         if      (einf=xinteger) then begin
            aindex:=cell[etop].inum;
            if      (aindex<=0)       then begin provisorium('int<=0 in _act')end
            else if (aindex<=maxproc) then begin
               proc[aindex];
               mdict:=etop;
               apiget(idxreact,mdict,xbind);//wird mdict verändert? //ifxundef?
               //ifxundef...
               if (etop=xundef) then begin etop:=newerror(idxreact,ereactnobind);
                                           exit
                                     end;
               //ifxerror...
               efun:=etop;
               etop:=mdict;
               repeat eval;  if (ecall<>0) then proc[ecall]
               until equit;
            end
            else begin provisorium('int>maxproc in _act')end
         end
         else if (einf=xindex)   then begin
            mstack:=prop(mdict,xcons,mstack);//(prop(,xact,))?  ,=continuation
            epush(etop);//besser anders...
            apiget(idxreact,mdict,xeff);//iferror? //ifxundef? ,idxreact?
            if (etop=xundef) then provisorium('keine effektgruppe gefunden in _act');//find effect
            //ifxerror... ,dec(eptr)
            efun:=estack[eptr];  dec(eptr);
            apiget(idxreact,etop,efun);//ifxerrror ,ifxundef ,idxreact?
            if (etop=xundef) then provisorium('keinen einzeleffekt gefunden in _act');
            if(infix[etop]=xerror)then provisorium('einzeleffekt fehler in _act='+tovalue(etop));
            //serveprint('mdict='+tovalue(mdict));
            efun:=etop;
            etop:=mdict;
            repeat eval;  if (ecall<>0) then proc[ecall]
            until equit;
            //serveprint('eval='+tovalue(etop));etop:=mdict;
            //nt();//endeget();//
         end
         else if (einf=xact)     then begin
            // Verschachtelung der Monaden für rekursive Abläufe
            mstack:=prop(mdict,xcons,mstack);//kommt da noch was? noch mal durchdenken
            //etop...
         end//provisorium('_act(box) in _act')
         else if (einf=xnull)    then begin provisorium('xnil in _act')end
         //elseif()thenbeginend//ifxerror? ,ifxident?wiexindex ,ifxnull?
         else if (einf=xerror)   then begin provisorium('_error im _act')end//oder in _bind umleiten?
         else begin provisorium('provi: unable type in _act');//provi???
         end;
         einf:=xnil
      end
      else provisorium('domonad isno _act')//provi???
      //wo _bind bearbeiten?
end;

//[0] ? backtrack --> xnil _act ...
//[1] error
//[2] return
//[3] define
//[4] redefine
// etc.

// ---------------------------- act initialization -----------------------------

procedure initactprims;
var i: longint;
begin for i:=0 to maxproc do proc[i]:=@mundef;
      idxreact:=newindex('react');//position?
      idxdefine:=newindex('define');
      idxredefine:=newindex('redefine');
      idxshowgraph:=newindex('showgraph');
      idxshowinfo:=newindex('showinfo');
      idxprint:=newindex('print');
      idxinput:=newindex('input');
      idxloadtext:=newindex('loadtext');
      idxsavetext:=newindex('savetext');
      //
      idxrun:=newindex('run');
      idxquit:=newindex('quit');
      idxtime:=newindex('time');
      idxdate:=newindex('date');
      idxbeep:=newindex('beep');
      //
      idxhttpget:=newindex('httpget');
      //
      proc[3] :=@mdefine;
      proc[4] :=@mredefine;
      proc[5] :=@mshowgraph;
      proc[6] :=@mshowinfo;
      proc[7] :=@mprint;
      proc[8] :=@minput;
      proc[9] :=@mloadtext;
      proc[10]:=@msavetext;
      proc[11]:=@mrun;
      proc[12]:=@mquit;
      proc[13]:=@mtime;
      proc[14]:=@mdate;
      proc[15]:=@mbeep;
      proc[16]:=@mhttpget;
      //
end;

end.


// GNU Lesser General Public License v2.1

