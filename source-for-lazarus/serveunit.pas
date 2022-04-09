unit serveunit;//ok

{$mode objfpc}{$H+}

interface

uses Classes,//tstringlist
     SysUtils,//exception
     StdCtrls,//tmemo
     ExtCtrls,//tpaintbox
     Forms,//tform
     Windows,//sw_shownormal;...;
     Types,//trect;
     Graphics,//clblack;
     ShellAPI,//run...
     typeunit;//ustring

const servemincell =  100000;
      servemaxcell = 5000000;//(<-20MB/17MB->)//1000000;
      prompt = '';
      splitterheight = 6;//=6

var redef: boolean = false;
    //
    serveidledone: boolean = true;
    //uimemo;
    uipaintbox: tpaintbox=nil;
    uipanel: tpanel=nil;
    uiform: tform;
    servequit: boolean = false;
    serveinput: boolean = false;//richtige Lösung?;

procedure initserve(mc,ms: int64;memo: tmemo;paintbox: tpaintbox;
                                 panel: tpanel;form: tform);
procedure finalserve;
procedure servereact;
procedure servestopact;//position?
procedure servedrawtrail;//position?
procedure servetogglepaintbox;//position?
procedure tellserve(txt: ustring);
procedure serveprint(txt: ustring);
procedure serveidentdump;
procedure serverun(fname: ustring);//position?
procedure setservecorepath(fpath: ustring);//position?
procedure setserveuserpath(fpath: ustring);//position?
function extractslashpath(s: ustring): ustring;
function extractslashname(s: ustring): ustring;
//
function selectline(txt: ustring; i: int64): ustring;

implementation

uses apiunit, vmunit, actunit;

var inqueue: tstringlist = nil;
    intxtfile: tstringlist = nil;

// ------- -------
//;

// ------------------
// ----- legacy -----
// ------------------
procedure servedrawtrail;
var i,p,q: cardinal;
    p1x,p1y,p2x,p2y,r: double;
    pendown: boolean;
    rct: trect;

    procedure raiseexc(s: ustring);
    begin //etop:=...; restore
          raise exception.create(s)
    end;

begin if (uipaintbox=nil) then raiseexc(eservedrawtrailexc);
      with uipaintbox.canvas do begin
         i:=trail;// ,wenn trail <> xnil -> ... //epush, etop ,epull
         p1x:=0;   p2x:=p1x;
         p1y:=0;   p2y:=p1y;
         moveto(round(p1x),round(-p1y));
         //penpos
         pen.color:=clblack;
         pen.width:=1;
         brush.color:=clwhite;
         pendown:=true;
         //prüfen i,trail ...
         while (infix[i]>=xlimit) do begin
            //etop ,strict...
            p:=cell[i].first;
            q:=infix[i];
            i:=cell[i].rest;
            if (infix[q]=xreal) then begin
               if (infix[p]<>xreal) then raiseexc(eservedrawxynoreal);
               p2x:=p1x;   p1x:=cell[p].fnum;
               p2y:=p1y;   p1y:=cell[q].fnum;
               if pendown then lineto(round(p1x),round(-p1y))
                          else moveto(round(p1x),round(-p1y))
            end
            else if (q=xpen) then begin
               if      (p=xtrue)  then pendown:=true
               else if (p=xfalse) then pendown:=false
               else raiseexc(eservedrawpennobool)
               //
            end
            else if (q=xcolor) then begin
               if (infix[p]<>xinteger) then raiseexc(eservedrawcolornoint);
               pen.color:=cell[p].inum
            end
            else if (q=xsize) then begin
               if (infix[p]<>xinteger) then raiseexc(eservedrawsizenoint);
               pen.width:=cell[p].inum
            end
            else if (q=xbrush) then begin
               if (infix[p]<>xinteger) then raiseexc(eservedrawbrushnoint);
               brush.color:=cell[p].inum
            end
            else if (q=xcircle) then begin
               if (infix[p]<>xreal) then raiseexc(eservedrawcirclenoreal);
               r:=cell[p].fnum;
               try if pendown then
                      ellipse(round(p1x-r),round(-p1y-r),round(p1x+r),round(-p1y+r))
               except on ematherror do
                         raiseexc(eservedrawcirclematherror)
                      else raiseexc(eservedrawcircledrawerror)
               end
            end
            else if (q=xrect) then begin
               if pendown then
                  try rct:=rect(round(p2x),round(-p2y),round(p1x),round(-p1y));
                      fillrect(rct);
                      moveto(rct.right,rct.bottom);
                      lineto(rct.left,rct.bottom);
                      lineto(rct.left,rct.top);
                      lineto(rct.right,rct.top);
                      lineto(rct.right,rct.bottom)
                  except raiseexc(eservedrawrectdrawerror)
                  end
            end
            else raiseexc(eservedrawprotocolerror)
            //
         end;
         //serveprint(tovalue(i));
         if (infix[i]<>xnull) then raiseexc(eservedrawunexpect);
         //
      end//
end;

procedure servetogglepaintbox;
var delta: longint;
begin if ((uipaintbox<>nil) and (uipanel<>nil) and (uiform<>nil)) then begin
         if uipanel.visible then delta:=uipanel.height
                            else delta:=0;
         if (uipaintbox.height>1) then uipaintbox.height:=1
         else uipaintbox.height:=uiform.clientheight-delta-splitterheight;
         //
      end
      else raise exception.create('device is not installed (favorite)...')// provi
end;

// ------- service functions -------

function extractslashpath(s: ustring): ustring;
var i: int64;//longint;//cardinal (?)
    found: boolean;
begin i:=length(s);
      found:=false;
      while ((i>0) and not(found)) do begin
            found:=((s[i]='\') or (s[i]='/') or (s[i]=':'));
            if not(found) then dec(i)
      end;
      extractslashpath:=copy(s,1,i)
end;

function extractslashname(s: ustring): ustring;
var i: int64;//longint;// cardinal (?)
    found: boolean;
begin i:=length(s);
      found:=false;
      while ((i>0) and not(found)) do begin
            found:=((s[i]='\') or (s[i]='/') or (s[i]=':'));
            if not(found) then dec(i)
      end;
      extractslashname:=copy(s,i+1,length(s)-i)
end;

function selectline(txt: ustring; i: int64): ustring;//longint?
var k: int64;//longint;//longint?
    quit: boolean;
begin k:=i+1;
      quit:=false;
      repeat if (i=0) then quit:=true
             else if (txt[i]=#10) then quit:=true
             else dec(i)
      until quit;
      quit:=false;
      repeat if (k>length(txt)) then quit:=true
             else if (txt[k]=#13) then quit:=true
             else inc(k)
      until quit;
      selectline:=copy(txt,i+1,k-i-1)
end;

procedure tellserve(txt: ustring);
begin inqueue.add(txt);
//servprint(txt);//for testing
end;

procedure serveprint(txt: ustring);//txt ist pointer
begin if (uimemo <> nil) then uimemo.lines.append(txt)
      else raise exception.create(eserveprintexc);
end;

procedure serveidentdump;
var p,q,id,len: cardinal;
    s,crlf: ustring;
begin p:=identlist;
      s:='';
      crlf:='';
      while (infix[p]<>xnull) do begin
         id:=cell[p].first;
         q:=cell[id].value;
         if (q=xreserve) then s:='// '+tovalue(id)+crlf+s
         {else if (infix[q]<xlimit) then
              s:=tovalue(id)+' '+def+' '+tovalue(q)+crlf+s}
         else s:=tovalue(id)+' '+tovalue(xdef)+' '+totable(q)+crlf+s;//topropseq... ,doppelt
         crlf:=#13#10;
         p:=cell[p].rest
      end;
      //s:=s+#13#10+prompt;
      //len:=0;
      if (uimemo<>nil) then len:=length(unicodestring(uimemo.text))
                       else len:=0;
      serveprint(s);//markieren?
      if (uimemo<>nil) then begin uimemo.selstart:=len;
                                  uimemo.sellength:=length(s)+length(#13#10)
                            end
      //serveprint(prompt);
end;

procedure serverun(fname: ustring);//name bitte in try except verwenden!
const errorcode = 'ERRORCODE';
var res: longint;
begin //panelbar nullstring
      if (uiform=nil) then raise exception.create('uiformular is nil...')//provi
      else with uiform do begin
         res:=shellexecute(handle,'open'#0,pWideChar(fname),#0,#0,sw_shownormal);//???
         if (res<=32) then
            case res of
                 ERROR_FILE_NOT_FOUND: raise exception.create('"'+fname+'" - '+efilenotfound);
            else raise exception.create('"'+fname+'" - '+errorcode+' #'+inttostr(res))
            end
      end
end;

procedure setservecorepath(fpath: ustring);
begin cell[xcorepath].value:=newstring(fpath)
end;

procedure setserveuserpath(fpath: ustring);
begin cell[xuserpath].value:=newstring(fpath)
end;

var txt:ustring;//for test

// ------------------
// ----- legacy -----
// ------------------
procedure serveimport(i,p: cardinal);//implistid,pathstrid
var obj: cardinal;fpath,fname: ustring; //txt: ustring;// oder ebene höher?
begin impref:=cell[i].value;
      cell[i].value:=xreserve;
      obj:=cell[p].value;
      //if (infix[obj]<>xstring) then raise exception.create('path ist kein string???');
      fpath:=AnsiDequotedStr(tovalue(obj),qot2);//cell[obj].pstr^;
      //servprint('PATH:'+fpath);
      while (infix[impref]=xcons) do begin
         obj:=cell[impref].first;
         //if (infix[obj]<>xstring) then raise exception.create('file ist kein string???');
         fname:=AnsiDequotedStr(tovalue(obj),qot2);//cell[obj].pstr^;
         //servprint('FILE:'+fname);
         fname:=fpath+fname;//provi
         if fileexists(fname) then begin
            intxtfile.loadfromfile(fname);
            txt:=intxtfile.text;
            intxtfile.clear;
            precom(txt);
            postcom(redef,txt);
            txt:=''//tellserv(txt)?
         end
         else raise exception.create(eimportnoexist+' "'+fname+'"');//???
         impref:=cell[impref].rest//
      end;
      if (infix[impref]<>xnull) then raise exception.create('list has no right end???');// if_s ?
      //servprint('loading completet')//
end;

// ----- legacy -----
//stopact die monade quotieren?
procedure servestopact;// auch item ändern!
begin mstack:=xnil;
      etop:=prop(etop,xquote,xnil)//xnil;
      //
end;

procedure servereact;  // Fundamental-Loop (react onidle)
begin //servidledone...
      try if serveinput then //exit
          else if (infix[etop]=xact) then begin
             domonad;
             serveidledone:=false
          end
          else if (mstack<>xnil) then begin//backtracking
             with cell[mstack] do begin mdict:=first; mstack:=rest end;
             apiput(mdict,xit,etop);//ifxerror?...
             mdict:=etop;
             apiget(idxreact,mdict,xbind);
             if (etop=xundef) then begin//if nötig? (kompakter?, bessere Lösung?, im stackgefüge?)
                etop:=newerror(idxreact,ereactnobind);//name?
                serveidledone:=false;//?
                exit
             end;//ifxundef...
             //ifxerror...
             efun:=etop;
             etop:=mdict;
             repeat eval;  if (ecall<>0) then proc[ecall]
             until equit;
             serveidledone:=false//
          end
          else if not(serveidledone) then begin
             serveprint(tovalue(etop));//+#13#10+prompt);
             etop:=xnil;//testen !!!
             serveidledone:=true
          end
          else if (inqueue.count>0) then begin
             txt:=inqueue.strings[0];//auf nils achten
             inqueue.delete(0);
             //
             precom(txt);
             postcom(redef,txt);
             etop:=cstack;
             if (cell[xcoreimport].value<>xreserve) then
                serveimport(xcoreimport,xcorepath);
             if (cell[xuserimport].value<>xreserve) then
                serveimport(xuserimport,xuserpath);
             txt:='';//:=''?
             cstack:=etop;
             run;//vielleicht über einen stack...
             serveidledone:=false
          end
          else serveidledone:=true//
      except if (txt<>'') then begin serveprint(txt+' ...');
                                     //serveprint(prompt)
                               end;//if txt<>'' ?
             servestopact;//?
             etop:=xnil;cstack:=xnil;inqueue.clear;
             raise//
      end//gibt es noch den import(txt)fehler?
end;

procedure servereactfledder;
//var txt: ustring;// oder ebene höher?
begin
      if serveinput then exit;
      try if (infix[etop]=xact) then begin
             ;
             exit
          end;
          if (mstack<>xnil) then begin
             //ifxundef:
             ;//test
             exit////ec();
          end;
          if not(serveidledone) then begin
             ;
             exit
          end;
          if (inqueue.count>0) then begin
             ;
             exit
          end;
          //
      except
      end
end;

// ------------------
// ----- legacy -----
// ------------------
//
// ------- fundamental loop (react onidle) -------
//
// Monade auf algebraische Effekte umbauen (FP + OOP)
//

procedure servereactpre;   // Fundamental-Loop (react onidle)
//var txt: ustring;// oder ebene höher?
begin //servidledone...
      if serveinput then exit;
      try if (infix[etop]=xact) then begin
             domonad;
             serveidledone:=false;
             exit
          end;
             //servidledone:=(infix[cell[etop].first]<>xnull);
             //if servidledone then doact
             //
             //if (infix[cell[etop].first]=xnull) then servidledone:=false
             //else begin doact; servidledone:=true end
             //end;
          if (mstack<>xnil) then begin//backtracking
          // epush(etop);
             //servprint(tovalue(etop)+' //etop');
             mdict:=cell[mstack].first;
             mstack:=cell[mstack].rest;
             apiput(mdict,xit,etop);
             //iferror...
             mdict:=etop;
             apiget(idxreact,mdict,xbind);
             if (etop=xundef) then begin//if nötig? (kompakter?, bessere Lösung?, im stackgefüge?)
                etop:=newerror(idxreact,ereactnobind);//name?
                serveidledone:=false;//?
                exit
             end;//ifxundef?
             //ifetop=xerror?
             efun:=etop;
             //servprint(tovalue(efun)+' //iget ''bind');
          // etop:=estack[eptr];  dec(eptr);
             etop:=mdict;
             repeat eval;  if (ecall<>0) then proc[ecall]
             until equit;
             //mout:=etop;
             serveidledone:=false;//test
             exit////ec();
          end;
          //if servidledone then begin         //bind bearbeiten... ,effects?
          //end;
          if not(serveidledone) then begin
             //
             serveprint(tovalue(etop)+#13#10+prompt);//;//servprint(tovalue(cstack));//test
             //serveprint(prompt);//wenn onidledone?
             //etop:=xnil?
             etop:=xnil;//testen !!!
             serveidledone:=true;
             exit
          end;
          if (inqueue.count>0) then begin
             txt:=inqueue.strings[0];//auf nils achten
             inqueue.delete(0);
             //
             precom(txt);
             postcom(redef,txt);
             etop:=cstack;
             if (cell[xcoreimport].value<>xreserve) then
                serveimport(xcoreimport,xcorepath);
             if (cell[xuserimport].value<>xreserve) then
                serveimport(xuserimport,xuserpath);
             txt:='';//:=''?
             cstack:=etop;
             run;//vielleicht über einen stack...
             serveidledone:=false;
             exit
          end;
          serveidledone:=true//
      except if (txt<>'') then begin serveprint(txt+' ...');
                                     serveprint(prompt)
                               end;//if txt<>'' ?
             servestopact;//?
             etop:=xnil;cstack:=xnil;inqueue.clear;
             raise
      end//gibt es noch den import(txt)fehler?
end;

// ------- service initialization -------

procedure initserve(mc,ms: int64;memo: tmemo;paintbox: tpaintbox;
                                 panel: tpanel;form: tform);
begin redef:=false;
      serveidledone:=true;
      servequit:=false;
      serveinput:=false;
      inqueue:=tstringlist.create;
      intxtfile:=tstringlist.create;
      //
      txt:='';//txt:=?
      //
      uimemo:=memo;
      uipaintbox:=paintbox;
      uipanel:=panel;
      uiform:=form;
      //
      initvm(mc,ms);//...int64
      //
end;

procedure finalserve;
begin //redef:=?
      //serveidledone:=?
      //servquit:=?
      serveinput:=false;
      finalvm;
      inqueue.free;
      intxtfile.free;
      uimemo:=nil;
      uipaintbox:=nil;
      uipanel:=nil;
      uiform:=nil;
      //
end;

end.

