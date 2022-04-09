unit vmunit;

{$mode objfpc}{$H+}

interface

uses //Classes,//?
     SysUtils,//ansiqoutedstr,stringreplace,exception,tformatsettings
     typeunit;//ustring;

type //
     boolset = array [0..255] of boolean;
     fpexception = class(exception);//???genauer gucken;

var ecall: longint = 0;//typ?
    equit: boolean = true;
    fpformatsettings: tformatsettings;

procedure initvm(mc,ms: int64);
procedure finalvm;
procedure precom(var txt: ustring);
procedure postcom(redef: boolean;var txt: ustring);
procedure eval;
procedure run;
function tovalue(i: cardinal): ustring;
function totable(i: cardinal): ustring;//name?
procedure nreverse(var n: cardinal);
{
procedure nreverse(var n: cardinal);
procedure precom(var txt: ustring);
procedure postcom(redef: boolean;var txt: ustring);// position von txt ???
procedure eval;
//procedure delazy;
procedure run;
}

implementation

uses apiunit, primunit, actunit;

const normalset: ansistring = '_.0123456789' +                    //ansistring?
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                  'abcdefghijklmnopqrstuvwxyz' +
                  'ÁÀÂÃÄÇÉÈÊÍÌÎÏÑÓÒÔÕÖÚÙÛÜÝ' +
                  'áàâãäçéèêíìîïñóòôõöúùûüý' +
                  'ÅÆÐËŒØŠŸŽßþ' +
                  'åæðëœøšÿžµÞ';
      specialset: ansistring = '()[]{}»«,;°'+qot1+qot2+sharp+prefix+compose;// idy special? , ; special?; ?type...//;

var eproc: array [0..xlimit] of fproc;
    normal,special: boolset;

// ----- table-to-string-output -----

const propformat = ffGeneral;
      maxdigits = 16;
      maxpointdigits = 15;

function totable(i: cardinal): ustring;
var s,sp: ustring; //sp: string[1];
begin s:='';
      sp:='';
      while (infix[i]>xmaxatom) do begin
            s:=s+sp+tovalue(cell[i].first)+' '+tovalue(infix[i]);
            sp:=' ';
            i:=cell[i].rest
      end;
      if (infix[i]=xnull) then begin
         if (s<>'') then totable:=s
         else if (i=xnil) then totable:=ddot+' '+'( )'
                          else totable:=ddot+' '+'()'
      end
      else totable:=s+sp+ddot+' '+tovalue(i)
end;

function toint(i: cardinal): ustring;
begin toint:='['+stringreplace(inttostr(cell[i].inum),'-','_',[rfReplaceAll])+']'
end;

function toreal(i: cardinal): ustring;
begin toreal:=stringreplace(stringreplace(
              floattostrF(cell[i].fnum,propformat,maxdigits,maxpointdigits,
              fpformatsettings),',','.',[rfReplaceAll]),'-','_',[rfReplaceAll])
end;

function toident(i: cardinal): ustring;
var p: cardinal;
begin p:=cell[i].pname;
      if (infix[p]=xstring) then toident:=cell[p].pstr^
                            else toident:='[=ident<>xstring]'
end;

function toprefix(i: cardinal): ustring;//noch mal überprüfen!
var p: cardinal;
begin p:=cell[i].pname;
      if (infix[p]=xstring) then toprefix:=prefix+cell[p].pstr^
                            else toprefix:=prefix+inttostr(i)//'[=prefix<>xstring]'
end;

function toindex(i: cardinal): ustring;
var p: cardinal;
begin p:=cell[i].rname;
      if (infix[p]=xstring) then toindex:='['+cell[p].pstr^+']'//+'='+inttostr(cell[i].rnum)
                            else toindex:='[=index<>xstring]'
end;

function toarray(p: cardinal): ustring;
var s,sp: ustring; i,q: cardinal;//sp: string[1];
begin s:='';
      sp:='';
      if (cell[p].aref^=nil) then s:=' '
      else for i:=0 to pred(length(cell[p].aref^)) do begin
               q:=cell[p].aref^[i];
               {if (q<>xundef) then begin}
                  s:=s+sp+{'['+inttostr(i)+']'+' '+def+' '+}tovalue(q);//space
                  sp:=' '
               {end}
           end;
      toarray:='{'+s+'}'
end;

function tovalue(i: cardinal): ustring;
begin if (i=xnil) then tovalue:='( )'
      else if (infix[i]>xmaxatom) then tovalue:='('+totable(i)+')'
      else case infix[i] of
                xnull   : tovalue:='()';//zur unterscheidung zu xnil
                xinteger: tovalue:=toint(i);
                xreal   : tovalue:=toreal(i);
                xstring : tovalue:=ansiquotedstr(cell[i].pstr^,qot2);
                xident  : tovalue:=toident(i);
                xprefix : tovalue:=toprefix(i);
                xindex  : tovalue:=toindex(i);
                xarray  : tovalue:=toarray(i);
                //xlazy???: tovalue:='('+tovalue(cell[i].arg)+' '+tovalue(xlazy)+' '
                //                 +topropseq(cell[i].term)+')';
           else tovalue:='[=error]'
           end
end;

// ----- scanner -----

{function item(var s: ustring;var i: int64): ustring; //longint?
// i entspricht selstart
var k: int64; //longint?
    quit: boolean;
    ch: ustring;//string[1] (?)
begin inc(i);
      ch:=copy(s,i,1);
      while ((length(ch)=1) and (ch[1]<=#32)) do begin
            inc(i);
            ch:=copy(s,i,1)
      end;
      k:=i;
      quit:=false;
      if (ch<>'') then begin
         if charinset(s[i],special) then inc(i)
         else repeat inc(i);
                     if (i>length(s)) then quit:=true
                     else quit:=(charinset(s[i],special) or (s[i]<=#32))
              until quit
      end;
      item:=copy(s,k,i-k);
      dec(i)
end}

function isnormal(x: unicodechar): boolean;
begin if (ord(x)>255) then isnormal:=false
      else isnormal:=normal[ord(x)]
end;

function isspecial(x: unicodechar): boolean;
begin if (ord(x)>255) then isspecial:=false
      else isspecial:=special[ord(x)]
end;

function item(var s: ustring;var i: int64): ustring; //i cardinal?
// i ~~ selstart
var k: int64;//cardinal;// k cardinal?
    ch: ustring;
    quit: boolean;
    //ch: string[1];
begin inc(i);
      ch:=copy(s,i,1);
      while ((length(ch)=1) and (ch[1]<=#32)) do begin
            inc(i);
            ch:=copy(s,i,1)
      end;
      k:=i;
      //quit:=false;
      if (ch<>'') then begin
         if isspecial(s[i]) then inc(i)
         else if isnormal(s[i]) then //charinset
              repeat inc(i);
                     if (i>length(s)) then quit:=true
                     else quit:=not(isnormal(s[i]))//charinset()
                                //or charinset(s[i],special)
              until quit
         else repeat inc(i);
                     if (i>length(s)) then quit:=true
                     else quit:=( isnormal(s[i])
                                  or isspecial(s[i])
                                  or (s[i]<=#32) )
              until quit
      end;
      item:=copy(s,k,i-k);
      dec(i)
end;

// ----- precompiler -----

procedure nreverse(var n: cardinal);
var p,reseq: cardinal;
begin reseq:=xnil;
      while (n<>xnil) do begin
         p:=n;
         n:=cell[n].rest;
         cell[p].rest:=reseq;
         reseq:=p//
      end;
      n:=reseq//
end;

procedure precom(var txt: ustring);
var it: ustring;
    ix: int64;

    procedure precomraise(s: ustring);
    begin txt:=copy(txt,1,ix);//??? + ' ...' ?
          raise fpexception.create(s)//
    end;

    procedure safeinfix;
    var p,q: cardinal;
    begin if (infix[cstack]<>xcons) then precomraise(ecomnosafestack);
          with cell[cstack] do begin p:=first; q:=rest end;
          if (infix[q]<>xcons) then precomraise(ecomnosafestack);//?
          if (cell[q].first=xddot) then exit;
          //if (p=xerror) then exit;
          if (p<xlimit) then if (p<>xerror) then precomraise(ecomnosafetype);// ^ xerror?
        //if (p=xstring) then precomraise(ecomnosafestring);//enamen löschen?
        //if (p=xarray)  then precomraise(ecomnosafearray); //enamen löschen?
          //wie bei ddot? ,etc ?
    end;

    {procedure comment;
    begin while (it=qot2) do begin
             repeat it:=item(txt,ix);//=    inc(ix);it:=copy(txt,ix,1)
                    if (it='') then precomraise(ecomnocommentend)//fpraise(iderrornocommentend,copy(txt,1,ix))
             until (it=qot2);
             it:=item(txt,ix)
          end
    end;}

    //auch comment-klammer implementieren
    procedure comment;
    begin while (it='//') do begin
             repeat inc(ix);it:=copy(txt,ix,1)
                    //if (it='') then precomraise(ecomnocommentend)//fpraise(iderrornocommentend,copy(txt,1,ix))
             until ((it=#13) or (it=''));
             it:=item(txt,ix)
          end
    end;

    function findindex(it: ustring): cardinal;
    var seq,found: cardinal;
    begin seq:=indexdict;
          found:=xnil;
          while ((seq<>xnil) and (found=xnil)) do
                if (cell[cell[infix[seq]].rname].pstr^ = it) then
                   found:=infix[seq]
                else seq:=cell[seq].rest;
          findindex:=found
    end;

    function index(it: ustring): cardinal;
    var idx: cardinal;
    begin idx:=findindex(it);
          if (idx=xnil) then index:=newindex(it)
                        else index:=idx
    end;

    // comindt nochmal ganz überarbeiten!!!
	  procedure comindt;// syntax nochmal durchgehen...
    var inum: int64;
        errcode: longint;// cardinal???
        numstr: ustring;
    begin it:=item(txt,ix);
          if (it=']') then precomraise(ecomnoint);
          if (it='-') then begin
             it:=item(txt,ix);
             if (it=']') then precomraise(ecomnoint);
             it:='-'+it
          end;//auf '-' reagieren!
          numstr:=stringreplace(it,'_','-',[rfReplaceAll]);//anders!
          val(numstr,inum,errcode);
          //err-ausnahmen
          //ablegen
          if (errcode=0) then cstack:=prop(newinteger(inum),xcons,cstack)
                         else cstack:=prop(index(it),xcons,cstack);//nachbessern mit fehlern
          //precomraise(ecomnoint);//direkt nach err-ausnahmen ?
          it:=item(txt,ix);
          if (it<>']') then precomraise(ecomnopostbracket)
    end;

    {procedure comstring;
    var k: int64;//k:longint;//???
    begin k:=ix;
          repeat inc(ix);
                 it:=copy(txt,ix,1);
                 if (it='') then precomraise(ecomnostringend);
                 if (it=qot1) then begin
                    if (copy(txt,ix+1,1)<>qot1) then break;
                    inc(ix);
                 end;
          until false;
          it:=copy(txt,k,ix-k+1);
          cstack:=prop(newstring(AnsiDequotedStr(it,qot1)),xcons,cstack)//
    end;}

    procedure comstring;
    var k: int64;//longint;//???
    begin k:=ix;
          repeat inc(ix);
                 it:=copy(txt,ix,1);
                 if (it='') then precomraise(ecomnostringend);
                 if (it=qot2) then begin
                    if (copy(txt,ix+1,1)<>qot2) then break;
                    inc(ix);
                 end;
          until false;
          it:=copy(txt,k,ix-k+1);
          cstack:=prop(newstring(AnsiDequotedStr(it,qot2)),xcons,cstack)//
    end;

    function findident(it: ustring): cardinal;
    var seq,found: cardinal;
    begin seq:=identlist;
          found:=xnil;
          while ((seq<>xnil) and (found=xnil)) do
                if (cell[cell[cell[seq].first].pname].pstr^ = it) then
                   found:=cell[seq].first
                else seq:=cell[seq].rest;
          findident:=found
    end;

    function ident(it: ustring): cardinal;
    var id: cardinal;
    begin id:=findident(it);
          if (id=xnil) then ident:=newident(it,xreserve)
                       else ident:=id
    end;

    procedure atom(var it: ustring);
    var numstr: ustring;
        errcode: longint;
        num: double;
    begin numstr:=stringreplace(stringreplace(it,'_','-',[rfReplaceAll]),
                                ',','.',[rfReplaceAll]);
          val(numstr,num,errcode);
          if (numstr[1]='.')         then errcode:=1;
          if (copy(numstr,1,2)='-.') then errcode:=1;
          if (upcase(numstr[1])='E') then errcode:=1;
          if (errcode=0) then cstack:=prop(newreal(num),xcons,cstack)
                         else cstack:=prop(ident(it),xcons,cstack)
    end;

    {
    procedure comjit;
    begin it:=item(txt,ix);
          comment;
          if      (it='')  then precomraise(ecomjitunexpend)
          else if (it='(') then propseq
          else if (it=')') then precomraise(ecomparentend)//(?)
          else if (it='[') then comindt
          else if (it=']') then precomraise(ecomnoprebracket)
          else if (it='swauf') then comarray
          else if (it='swzu') then precomraise(ecomarrayend)
          else if (it=qot1)  then comquote
          else if (it=qot2)  then comstring
          else if (it=sharp) then comivar
          else if (it=jit)   then comjit
          else if ((it=idy) or (it=def)) then cstack:=prop(xdef,xcons,cstack)//(?) //???
          else if (it=ddot) then precomraise(ecomjitunexpddot)//???
          else atom(it);
          (...)
          cell[cstack].first:=prop(xnil,xlazy,cell[cstack].first)//
    end;
    }

    //muss noch definiert werden...
    procedure comprefix;
    begin cstack:=prop(prop(xnil,xprefix,xnil),xcons,cstack)//provi!!! nur dafür-->kein Absturz...
    end;

    procedure comarray;
    forward;

    procedure comquote;
    forward;

    procedure comivar;
    forward;

    procedure cbackcons;
    var p,q,ref: cardinal;
    begin ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
             q:=cstack;
             cstack:=cell[cstack].rest;
             p:=cstack;
             cstack:=cell[cstack].rest;
             if (cell[p].first=xddot) then begin
                if (ref<>xnil) then precomraise(ecomforddotnoend);//xnull?
                ref:=cell[q].first//
             end
             else begin //cell[p].first:=cell[p].first;
                        cell[p].rest:=ref;
                        infix[p]:=cell[q].first;
                        ref:=p
                  end//
          end;
          cell[cstack].first:=ref//
    end;

    procedure comtable;//ehemals propseq;// ehemals twinseq
    begin cstack:=prop(xmark,xcons,cstack);
          it:=item(txt,ix);
          comment;
          while (it<>')') do begin
             if      (it='')     then precomraise(ecomtableunexpend)
             else if (it='(')    then comtable
             else if (it='[')    then comindt
             else if (it=']')    then precomraise(ecomnoprebracket)
             else if (it='{')    then comarray
             else if (it='}')    then precomraise(ecomarrayend)
             else if (it=qot1)   then comquote
             else if (it=qot2)   then comstring
             else if (it=sharp)  then comivar
             else if (it=prefix) then comprefix
             //idy,def
             else if (it=ddot)   then cstack:=prop(xddot,xcons,cstack)
             else atom(it);
             it:=item(txt,ix);
             comment;
             if      (it='')     then precomraise(ecomtableunexpend)
             else if (it='(')    then comtable
             else if (it=')')    then begin cstack:=prop(xsingle,xcons,cstack);
                                            break
                                      end
             else if (it='[')    then comindt
             else if (it=']')    then precomraise(ecomnoprebracket)
             else if (it='{')    then comarray
             else if (it='}')    then precomraise(ecomarrayend)
             else if (it=qot1)   then comquote
             else if (it=qot2)   then comstring
             else if (it=sharp)  then comivar
             else if (it=prefix) then comprefix
             //idy,def
             else if (it=ddot)   then precomraise(ecomddotnotoinfix)
             else atom(it);
             safeinfix;
             it:=item(txt,ix);
             comment
          end;
          cbackcons//
    end;

    {procedure postcom(redef: boolean);// wenn xdef xdef dann fehler...
var ref,p,q,obj,id: cardinal;

    procedure postcomraise(s: ustring);
    begin raise exception.create(s)
    end;

begin try nreverse(cstack);
          ref:=xnil;
          while (cstack<>xnil) do begin
             obj:=cell[cstack].first;
             if (obj=xdef) then begin
                cstack:=cell[cstack].rest;
                id:=cell[cstack].first;
                if (id=xdef) then postcomraise(ecomdoubledef);
                if (infix[id]<>xident) then postcomraise(ecomconstnoident);
                if (not(redef) and (cell[id].value<>xundef)) then
                   postcomraise(ecomconsttaken+' - '+tovalue(id));
                cell[id].value:=ref;
                ref:=xnil;
                cstack:=cell[cstack].rest//
             end
             else begin q:=cstack;
                        cstack:=cell[cstack].rest;
                        p:=cstack;
                        cstack:=cell[cstack].rest;
                        //cell[p].first:=cell[p].first;
                        cell[p].rest:=ref;
                        infix[p]:=cell[q].first;
                        ref:=p//
                  end
          end;
          cstack:=ref;
          //
      except raise
      end//
end}
{begin try nreverse(cstack);
          ref:=xnil;
          while (cstack<>xnil) do begin
             obj:=cell[cstack].first;
             if (obj=xdef) then begin
                cstack:=cell[cstack].rest;
                id:=cell[cstack].first;
                if (id=xdef) then postcomraise(ecomdoubledef);
                if (infix[id]<>xident) then postcomraise(ecomconstnoident);
                if (not(redef) and (cell[id].value<>xreserve)) then
                   postcomraise(ecomconsttaken+' - '+tovalue(id));
                cell[id].value:=ref;
                ref:=xnil;
                cstack:=cell[cstack].rest//
             end
             else begin
                q:=cstack;
                cstack:=cell[cstack].rest;
                p:=cstack;
                cstack:=cell[cstack].rest;
                if (cell[p].first=xddot) then begin
                   if (ref<>xnil) then postcomraise(epostcomforddotnoend);//xnull?
                   ref:=cell[q].first//
                end
                else begin //cell[p].first:=cell[p].first;
                           cell[p].rest:=ref;
                           infix[p]:=cell[q].first;
                           ref:=p
                     end//
             end
          end;
          cstack:=ref;
          //
      except raise
      end//
end}
    procedure cpostarray;
    var ref,obj,idx,n,p,q: cardinal;
    begin //try... (?)
          ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
             obj:=cell[cstack].first;
             if (obj=xdef) then begin
                cstack:=cell[cstack].rest;
                idx:=cell[cstack].first;
                if (idx=xdef) then precomraise(ecomdoubleardef);
                if (infix[idx]<>xindex) then precomraise(ecomconstnoindex);
                n:=cell[idx].rnum;
                if (cell[cref].aref^[n]<>xundef) then
                   precomraise(ecomarconsttaken+' - '+tovalue(idx));
                cell[cref].aref^[n]:=ref;
                ref:=xnil;
                cstack:=cell[cstack].rest//;
             end
             else begin q:=cstack;
                        cstack:=cell[cstack].rest;
                        p:=cstack;
                        cstack:=cell[cstack].rest;
                        if (cell[p].first=xddot) then begin
                           if (ref<>xnil) then precomraise(ecomfordotnoend);//xnull?
                           ref:=cell[q].first
                        end
                        else begin //cell[p].first:=cell[p].first;
                                   cell[p].rest:=ref;
                                   infix[p]:=cell[q].first;
                                   ref:=p
                             end//
                  end
          end;
          if (ref<>xnil) then precomraise(ecomnorestexpect);//cbackcons;
          cstack:=cell[cstack].rest//cell[cstack].first:=ref;//löschen
    end;

    {procedure cpostarray;// xcons und xsingle beachten
    var ref,obj,idx: cardinal;
    begin ref:=xnil;
          while () do begin
             obj:=cell[cstack].first;
             if (obj=xdef) then begin
                cstack:=cell[cstack].rest;
                idx:=cell[cstack].first;
                if (idx=xdef) then precomraise(ecomdoubleardef);
                if (infix[idx]<>xindex) then;
                end
             else begin;end
             //
          end;
          cell[cstack].first:=ref
          //
    end;}

    procedure abackcons;
    var ref,p: cardinal;
    begin ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
             p:=cstack;
             cstack:=cell[cstack].rest;
             cell[p].rest:=ref;
             ref:=p
          end;
          cell[cstack].first:=ref//
    end;

    procedure cplacearray;//name??? cplacearray?
    var p,c: cardinal;
    begin p:=cell[cstack].first;
          c:=0;
          while (p<>xnil) do begin
             //prüfen ob schon belegt !!!
             if (cell[cref].aref^[c]<>xundef) then
                precomraise(ecomarplacetaken+' - ['+inttostr(c)+']');
             cell[cref].aref^[c]:=cell[p].first;
             inc(c);
             p:=cell[p].rest
          end;
          //
    end;

    function max(a,b: int64): int64;
    begin if (a>b) then max:=a
                   else max:=b
    end;

    var obj: cardinal;

    procedure comarray;          // mit comquote !!!   (?)
    var maxi: int64; ondef: boolean;

        procedure insmarkswapcons;
        var p,q,ref: cardinal;
        begin if (cell[cstack].first=xmark) then precomraise(ecomdefnoindex);
              p:=cstack;
              cstack:=prop(xmark,xcons,cstack);
              q:=cstack;
              ref:=cell[p].first;
              cell[p].first:=cell[q].first;
              cell[q].first:=ref;
              obj:=cell[cstack].first;
              if (obj=xdef) then precomraise(ecomdoubleardef);
              if (infix[obj]<>xindex) then precomraise(ecomtypenoindex+' - '+tovalue(obj));
              maxi:=max(maxi,cell[obj].rnum);
              cstack:=prop(xdef,xcons,cstack)//
        end;

        procedure arrayinssingleswapcons;
        var p,q,ref: cardinal;
        begin if (cell[cstack].first=xmark) then precomraise(ecomdefnoindex);
              p:=cstack;
              cstack:=prop(xsingle,xcons,cstack);
              q:=cstack;
              ref:=cell[p].first;
              cell[p].first:=cell[q].first;
              cell[q].first:=ref;
              obj:=cell[cstack].first;
              if (obj=xdef) then precomraise(ecomdoubleardef);
              if (infix[obj]<>xindex) then precomraise(ecomtypenoindex+' - '+tovalue(obj));
              maxi:=max(maxi,cell[obj].rnum);
              cstack:=prop(xdef,xcons,cstack)//
        end;

        {procedure csetarray;//name??? cplacearray?
        var p,c: cardinal;
        begin p:=cell[cstack].first;
              c:=0;
              while (p<>xnil) do begin
                 //prüfen ob schon belegt !!!
                 if (cell[cref].aref^[c]<>xundef) then
                    precomraise(ecomarplacetaken+' - ['+inttostr(c)+']');
                 cell[cref].aref^[c]:=cell[p].first;
                 inc(c);
                 p:=cell[p].rest
              end;
              //
        end;}

    begin cstack:=prop(xmark,xcons,cstack);
          ondef:=false;
          maxi:= -1;
          it:=item(txt,ix);
          comment;
          while (it<>'}') do begin
             if      (it='')     then precomraise(ecomarrayunexpend)
             else if (it='(')    then comtable
             else if (it=')')    then precomraise(ecomparentend)
             else if (it='[')    then comindt
             else if (it=']')    then precomraise(ecomnoprebracket)
             else if (it='{')    then comarray
             else if (it=qot1)   then comquote
             else if (it=qot2)   then comstring
             else if (it=sharp)  then comivar
             else if (it=prefix) then comprefix
             else if ((it=idy) or (it=def)) then begin ondef:=true; break end
             else if (it=ddot)   then precomraise(ecomddotnotinarray)//dot
             else atom(it);
             inc(maxi);
             it:=item(txt,ix);
             comment
          end;
          if ondef then begin
             dec(maxi);//nötig?
             insmarkswapcons;
             it:=item(txt,ix);
             comment;
             while (it<>'}') do begin
                if      (it='')     then precomraise(ecomarrayunexpend)
                else if (it='(')    then comtable
                else if (it=')')    then precomraise(ecomparentend)
                else if (it='[')    then comindt
                else if (it=']')    then precomraise(ecomnoprebracket)
                else if (it='{')    then comarray
                else if (it=qot1)   then comquote
                else if (it=qot2)   then comstring
                else if (it=sharp)  then comivar
                else if (it=prefix) then comprefix
                else if ((it=idy) or (it=def)) then begin ondef:=true;
                                                          arrayinssingleswapcons;
                                                          it:=item(txt,ix);
                                                          comment;
                                                          continue
                                                    end
                else if (it=ddot)   then cstack:=prop(xddot,xcons,cstack)//dot
                else atom(it);
                it:=item(txt,ix);
                comment;
                if      (it='')     then precomraise(ecomarrayunexpend)
                else if (it='(')    then comtable
                else if (it=')')    then precomraise(ecomparentend)
                else if (it='[')    then comindt
                else if (it=']')    then precomraise(ecomnoprebracket)
                else if (it='{')    then comarray
                else if (it='}')    then begin cstack:=prop(xsingle,xcons,cstack);
                                               break
                                         end
                else if (it=qot1)   then comquote
                else if (it=qot2)   then comstring
                else if (it=sharp)  then comivar
                else if (it=prefix) then comprefix
                else if ((it=idy) or (it=def)) then begin
                   obj:=cell[cstack].first;
                   if (infix[obj]<>xindex) then precomraise(ecomtypenoindex+' - '+tovalue(obj));
                   maxi:=max(maxi,cell[obj].rnum);
                   cstack:=prop(xdef,xcons,cstack)
                end
                else if (it=ddot)   then precomraise(ecomddotnotoinfix)//???//dot
                else atom(it);
                safeinfix;
                it:=item(txt,ix);
                comment;
                //
             end;
             //cstack:=prop(newint(maxi),xcons,cstack);
             //cstack:=prop(newstring('maxi'),xcons,cstack);
             //cbackcons//test
          end;
          cref:=newarray(maxi+1);//            das zweite '+1' rückgängig !!!
          if ondef then cpostarray;
          //cstack:=prop(newint(maxi),xcons,cstack);
          //cstack:=prop(cref,xcons,cstack);//als test oben drauf
          abackcons;
          cplacearray;
          cell[cstack].first:=cref;  cref:=xnil
    end;

    procedure comquote;
    begin it:=item(txt,ix);
          comment;
          if      (it='')     then precomraise(ecomquoteunexpend)
          else if (it='(')    then comtable
          else if (it=')')    then precomraise(ecomparentend)//(?)
          else if (it='[')    then comindt
          else if (it=']')    then precomraise(ecomnoprebracket)
          else if (it='{')    then comarray
          else if (it='}')    then precomraise(ecomarrayend)
          else if (it=qot1)   then comquote
          else if (it=qot2)   then comstring
          else if (it=sharp)  then comivar
          else if (it=prefix) then comprefix
          else if ((it=idy) or (it=def)) then cstack:=prop(xdef,xcons,cstack)//(?) //???
          else if (it=ddot)   then precomraise(ecomquoteunexpddot)//???
          else atom(it);
          {cref:=cell[cstack].first;
          cstack:=cell[cstack].rest;
          cref:=prop(cref,xquote,xnil);//kompakter!
          cstack:=prop(cref,xcons,cstack);
          cref:=xnil;}
          cell[cstack].first:=prop(cell[cstack].first,xquote,xnil)//
    end;

    procedure comivar;
    begin it:=item(txt,ix);
          comment;
          if      (it='')     then precomraise(ecomvarunexpend)
          else if (it='(')    then comtable
          else if (it=')')    then precomraise(ecomparentend)//(?)
          else if (it='[')    then comindt
          else if (it=']')    then precomraise(ecomnoprebracket)
          else if (it='{')    then comarray
          else if (it='}')    then precomraise(ecomarrayend)
          else if (it=qot1)   then comquote
          else if (it=qot2)   then comstring
          else if (it=sharp)  then comivar
          else if (it=prefix) then comprefix
          else if ((it=idy) or (it=def)) then cstack:=prop(xdef,xcons,cstack)//(?) //???
          else if (it=ddot)   then precomraise(ecomivarunexpddot)//???
          else atom(it);
          {cref:=cell[cstack].first;
          cstack:=cell[cstack].rest;
          cref:=prop(cref,xquote,xnil);//kompakter!
          cstack:=prop(cref,xcons,cstack);
          cref:=xnil;}
          cell[cstack].first:=prop(cell[cstack].first,xivar,xnil)
    end;

    {procedure inssingleswapcons;
    var p,q,ref: cardinal;
    begin if (cstack=xnil) then precomraise(ecomdefnoident);//nur für idents...
          p:=cstack;
          cstack:=prop(xsingle,xcons,cstack);
          q:=cstack;
          ref:=cell[p].first;
          cell[p].first:=cell[q].first;
          cell[q].first:=ref;
          cstack:=prop(xdef,xcons,cstack)//
    end}
    procedure inssingleswapcons;
    var p,q,ref: cardinal;
    begin if (cstack=xnil) then precomraise(ecomdefnoident);//nur für idents...
          p:=cstack;
          cstack:=prop(xsingle,xcons,cstack);
          q:=cstack;
          ref:=cell[p].first;
          cell[p].first:=cell[q].first;
          cell[q].first:=ref;
          cstack:=prop(xdef,xcons,cstack)//
    end;

begin try ix:=0;
          cstack:=xnil;
          it:=item(txt,ix);
          comment;
          while (it<>'') do begin
             if      (it='(')    then comtable
             else if (it=')')    then precomraise(ecomparentend)
             else if (it='[')    then comindt
             else if (it=']')    then precomraise(ecomnoprebracket)
             else if (it='{')    then comarray
             else if (it='}')    then precomraise(ecomarrayend)
             else if (it=qot1)   then comquote
             else if (it=qot2)   then comstring
             else if (it=sharp)  then comivar
             else if (it=prefix) then comprefix
             else if ((it=idy) or (it=def)) then begin inssingleswapcons;
                                                       it:=item(txt,ix);
                                                       comment;
                                                       continue
                                                 end//prüfen auf richtigen typ vom pre-wert auf dem cstack (?)
             else if (it=ddot)   then cstack:=prop(xddot,xcons,cstack)
             else atom(it);
             it:=item(txt,ix);
             comment;
             if      (it='')     then begin cstack:=prop(xsingle,xcons,cstack);
                                            break
                                      end
             else if (it='(')    then comtable
             else if (it=')')    then precomraise(ecomparentend)//(?)
             else if (it='[')    then comindt
             else if (it=']')    then precomraise(ecomnoprebracket)
             else if (it='{')    then comarray
             else if (it='}')    then precomraise(ecomarrayend)
             else if (it=qot1)   then comquote
             else if (it=qot2)   then comstring
             else if (it=sharp)  then comivar
             else if (it=prefix) then comprefix
             else if ((it=idy) or (it=def)) then cstack:=prop(xdef,xcons,cstack)//prüfen auf richtigen typ vom pre-wert auf dem cstack (?)
             else if (it=ddot)   then precomraise(ecomddotnotoinfix)
             else atom(it);
             safeinfix;
             it:=item(txt,ix);
             comment
          end;
          nreverse(cstack);
          //raise: txt für exception berechnen
      except raise//? try verwenden?
      end
end;

//----- postcompiler -----

function reverselisttostring(i: cardinal): ustring;//name???
var s,sp: ustring; //sp: string[1];
begin s:='';
      sp:='';
      while (infix[i]=xcons) do begin
         s:=tovalue(cell[i].first)+sp+s;
         sp:=' ';
         i:=cell[i].rest
         //
      end;
      if (infix[i]<>xnull) then s:='...no-list';//provi
      reverselisttostring:=s
      //
end;

procedure postcom(redef: boolean;var txt: ustring);// wenn xdef xdef dann fehler...
var ref,p,q,obj,id: cardinal;

    {procedure backrollup;
    begin nreverse(cstack);//... provi!!!
          //while (cstack<>xnil) do beginend
    end;}

    procedure postcomraise(s: ustring);
    begin //backrollup;//?name
          txt:=reverselisttostring(cstack);//tovalue(cstack);//
          raise exception.create(s)
    end;

begin try nreverse(cstack);
          ref:=xnil;
          while (cstack<>xnil) do begin
             obj:=cell[cstack].first;
             if (obj=xdef) then begin
                cstack:=cell[cstack].rest;
                id:=cell[cstack].first;
                if (id=xdef) then postcomraise(ecomdoubledef);
                if (infix[id]<>xident) then postcomraise(ecomconstnoident);
                if (not(redef) and (cell[id].value<>xreserve)) then
                   postcomraise(ecomconsttaken+' - '+tovalue(id));
                cell[id].value:=ref;
                ref:=xnil;
                cstack:=cell[cstack].rest//
             end
             else begin
                q:=cstack;
                cstack:=cell[cstack].rest;
                p:=cstack;
                cstack:=cell[cstack].rest;
                if (cell[p].first=xddot) then begin
                   if (ref<>xnil) then postcomraise(epostcomforddotnoend);//xnull?
                   ref:=cell[q].first//
                end
                else begin //cell[p].first:=cell[p].first;
                           cell[p].rest:=ref;
                           infix[p]:=cell[q].first;
                           ref:=p
                     end//
             end
          end;
          cstack:=ref;
          //
      except raise
      end//
end;

{procedure cbackcons;
    var p,q,ref: cardinal;
    begin ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
             q:=cstack;
             cstack:=cell[cstack].rest;
             p:=cstack;
             cstack:=cell[cstack].rest;
             if (cell[p].first=xdot) then begin
                if (ref<>xnil) then precomraise(ecomfordotnoend);//xnull?
                ref:=cell[q].first//
             end
             else begin //cell[p].first:=cell[p].first;
                        cell[p].rest:=ref;
                        infix[p]:=cell[q].first;
                        ref:=p
                  end//
          end;
          cell[cstack].first:=ref//
    end}//

{
procedure dequote;
begin repeat equit:=true
         einf:=infix[efun];
         if (einf>xlimit) then begin
            etop:=cons(etop,xdot,efun);
            efun:=einf;
            equit:=false
         end
         else if (einf=xident) then begin
            eid:=einf;
            eref:=cell[einf].value;
            if(eref=xnil)thenbeginend
            elseif(infix[eref]=xproc)thencell[eref]proc//tauschen?
            elsebeginefun:=eref;equit:=falseend
         end
         elseif(einf=xnull)thenbeginetop:=xnilend//???
         elsebeginend
      eunitl equit;
//
end;
}

// ----- AST-interpreter -----
//von Phi kopiert + infix
//
// für eine schachtelbare Sprache (strukturierte Programmierung)
//
// Algebraische ...
//
// typen-orientierter Interpreter
// type-level
// function-level
//
// FP mit Kombinatoren (_combine)
//

var ep: pcardmem;
    eid: cardinal;
    eindex: int64;   //eint(?);

// ------- basic integer selector -------

//ifprefix?
procedure select(n: int64);//bitte ohne parameter (?) - nein!
label re;
begin {if (infix[etop]=xarray) then begin//ep^ verwenden (?)
         if (eindex<length(cell[etop].aref^)) then
            etop:=cell[etop].aref^[eindex]
         else etop:=newexc(xeinterp,eintpidxoutofrange);
         exit
      end;}
      //re:   !!!
  re: einf:=infix[etop];
      if (einf>=xlimit)     then begin
         if (n>0) then begin dec(n);
                             etop:=cell[etop].rest;
                             goto re//continue
                       end
                  else etop:=cell[etop].first
      end
      else if (einf=xarray) then begin
         ep:=cell[etop].aref;
         if (n<length(ep^)) then etop:=ep^[n]
         else etop:=newerror(idxipr,eiproutofarray+' - ['+inttostr(eindex)+']')
      end
      else if (einf=xnull)  then
         etop:=newerror(idxipr,eiprnotinrange+' - ['+inttostr(eindex)+']')
      //else if (einf=xlink)  then etop:=cell[etop].value
      //else if (einf=xlazy)  then delazy
      else if (einf=xerror) then //(exit)   //???
      else etop:=newerror(idxipr,eiprnotable+' - '+tovalue(etop))
           //? ,atome(?) (<=xmaxatom)
      //if (infix[etop]<=xmaxatom) then break
           // and(infix[etop]<>xnil)</<= ,tempo? ,läuft es noch correct???
      //if <xlimit ... xlink,xlazy,xexc !!!    baustelle !!!
      //dec(eindex);
      //etop:=cell[etop].rest
    //until false//;end; //goto re
      {if (infix[etop]>=xlimit) then etop:=cell[etop].first   //mit xnil
      else if (etop=xnil) then etop:=newexc(xeinterp,eintpnotinrange)
      else etop:=newexc(xeinterp,eintpnopropseq) }
end;

procedure eunquoted;
begin etop:=newerror(idxipr,eiprunquoted+': '+tovalue(efun)+' ')
end;

procedure efuncundef;
begin etop:=newerror(idxipr,eiprfuncundef)
end;

procedure eidentunbound;
begin etop:=newerror(idxipr,eipridentunbound+': '+tovalue(eid)+' ')
end;

// ----- typen-orientierter Automat (higher-order)
procedure eval;
begin ecall:=0;
      repeat equit:=true;
         einf:=infix[efun];
         if (einf <= xlimit) then eproc[einf]
         else begin if (einf=xsingle) then efun:=cell[efun].first
                    else begin etop:=prop(efun,xcombine,etop); efun:=einf end;
                    equit:=false
              end
      until equit
end;// term und arg sind jetzt vertauscht

procedure exnull;
begin etop:=efun  //xnil
end;

procedure exinteger;
begin eindex:=cell[efun].inum;
      if      (eindex>=0)       then select(eindex)
      else if (eindex>=minproc) then ecall:=eindex//exit:equit:=true-->proc[eindex]
      else efuncundef
end;

procedure enonquote;//anderswo auch auf _error im argument achten ???
begin if (infix[etop]<>xerror) then etop:=efun//??? // auf infix_error im argument achten!
end;

procedure exstring;
begin;end;

procedure exident;
begin eid:=efun;
      efun:=cell[efun].value;
      if (infix[efun]=xinteger) then begin
         eindex:=cell[efun].inum;
         if      (eindex>=0)       then select(eindex)
         else if (eindex>=minproc) then ecall:=eindex//exit:equit:=true-->proc[eindex]
         else efuncundef
      end
      else if (efun=xreserve) then eidentunbound  //if einsparen
      else equit:=false
end;

procedure exprefix;
begin;end;

procedure exindex;
begin eindex:=cell[efun].rnum;
      select(eindex)//für fehler nummer angeben! wie bei eid
end;

procedure exarray;
begin;end;

procedure exerror;
begin etop:=efun//exit:equit:=true //wenn in etop ne _exc, dann vorlassen?
end;

procedure exnil;
begin etop:=xnil//?
end;
//etop:=newerror(idxintp,'provi: xnil in infixposition...');end;//etop:=einf(?)//

// ------- (e)interpreter initialization -------

procedure initeproc;
var i: longint;
begin for i:=0 to xlimit do eproc[i]:=@eunquoted;
      eproc[xnull]   :=@exnull;
      eproc[xinteger]:=@exinteger;
      eproc[xreal]   :=@enonquote;//?
      eproc[xstring] :=@enonquote;//?
      eproc[xident]  :=@exident;
    //eproc[xprefix] :=exprefix;
      eproc[xindex]  :=@exindex;
    //xchar
      eproc[xarray]  :=@enonquote;//?
      eproc[xerror]  :=@exerror;
      eproc[xnil]    :=@exnil;      //xlimit
    //x_type?...e_type
end;

procedure run;
begin efun:=cstack;
      cstack:=xnil;
      etop:=xnil;//xundef
      einf:=xnil;
      eptr:=0;//estack:=xnil;     //maxcell?      // estack[eptr]:=xnil;
      mstack:=xnil;//???
      //iodict
      mdict:=xnil;
      repeat eval;  if (ecall<>0) then proc[ecall]   // continuations...
      until equit;
end;

{procedure dequote;
begin //...
      estack:=cons(,estack);
      try while (...<>xnil) do begin
             if (infix... <>xident) then begin ... end
             else begin
                efun:=...value;
                if (infix efun...=xint) then proc[...inum]
                else if () then ?...dequote
                else raise ex...
             end
             //...
          end
          //
      except estack:=...rest
             raise
      end
end}

// ------------------
// ----- legacy -----
// ------------------

procedure exlink;
begin efun:=cell[efun].value;//wenn link unbound?
      equit:=false
end;

procedure exlazy;
begin epush(etop);
      epush(efun);
      etop:=cell[efun].arg;
      efun:=cell[efun].term;
      repeat eval;  if (ecall<>0) then proc[ecall]
      until equit;  ecall:=0;
      //if (infix[etop]=xexc) then begin dec(eptr,2); exit end;//nochmal drübergucken! oder ohne dies (?)
      efun:=estack[eptr];  dec(eptr);
//    infix[efun]:=xlink;            //test, ob noch xlazy etc...
      with cell[efun] do begin pname:=xundef;
                               value:=etop
                         end;
      //efun:=efun;
      etop:=estack[eptr];  dec(eptr);
      equit:=false//
end;

// nochmal überprüfen!!!
// ----- typen-orientierter Automat (higher-order)
{procedure teval;// arg: etop & efun // result: etop/ecall
label re;
begin ecall:=0;  equit:=true;//extra in die Loops setzen!?;
  re: einf:=infix[efun];// wie repeat einrücken...!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if (einf>xlimit)        then begin// >= ???
         if (einf=xsingle) then efun:=cell[efun].first
         else begin etop:=prop(etop,xcombine,efun); efun:=einf end;
         goto re
      end
      else if (einf=xident)   then begin
         eid:=efun;
         efun:=cell[efun].value;
         if (infix[efun]=xinteger) then begin
            eindex:=cell[efun].inum;
            if      (eindex>=0)       then select(eindex)
            else if (eindex>=minproc) then begin ecall:=eindex; exit end//proc[eindex]
            else efuncundef
         end
         else if (efun=xreserve)   then eidentunbound
         else goto re
      end
      else if (einf=xinteger) then begin
         eindex:=cell[efun].inum;
         if      (eindex>=0)       then select(eindex)
         else if (eindex>=minproc) then begin ecall:=eindex; exit end//proc[eindex]
         else efuncundef
      end
      //else if (einf=xreal)    then etop:=efun//xreal unquoted???????????????????
      else if (einf=xnull)    then etop:=efun//xnil
      else if (einf=xindex)   then begin //eindex:=cell[efun].rnum;
                                         select(cell[efun].rnum)
                                   end
//    else if (einf=xlink)    then begin efun:=cell[efun].value;//wenn link unbound?
//                                       goto re
//                                 end
//    else if (einf=xlazy)    then begin
//       epush(etop);
//       epush(efun);
//       etop:=cell[efun].arg;
//       efun:=cell[efun].term;
//       repeat eval;  if (ecall<>0) then proc[ecall]
//       until equit;  ecall:=0;
//       //if (infix[etop]=xexc) then begin dec(eptr,2); exit end;//nochmal drübergucken! oder ohne dies (?)
//       efun:=estack[eptr];  dec(eptr);
//       infix[efun]:=xlink;            //test, ob noch xlazy etc...
//       with cell[efun] do begin pname:=xundef;
//                                value:=etop
//                          end;
//       //efun:=efun;
//       etop:=estack[eptr];  dec(eptr);
//       goto re
//    end
      else if (einf=xerror)   then begin etop:=efun; exit end//wenn in etop ne _exc, dann vorlassen?
      else eunquoted
      //goto re?
      //einf:=xnil?
end;}  //schachtelbare Sprache

{procedure xeval;
begin ecall:=0;
      repeat equit:=true;
         //auf ab hier zurückrücken (3 spaces);
             einf:=infix[efun];
             geschweifeauf repeat einf:=infix[efun];//vorbau, wenn einf>xlimit
                    if (einf=xlink) then efun:=cell[efun].value
                    else if (einf=xlazy) then begin
                       epush(etop);
                       epush(efun);
                       etop:=cell[efun].arg;
                       efun:=cell[efun].term;
                       repeat eval;  if (ecall<>0) then proc[ecall]
                       until equit;  ecall:=0;
                       //if (infix[etop]=xexc) then begin dec(eptr,2); exit end;//nochmal drübergucken! oder ohne dies (?)
                       efun:=estack[eptr];
                       dec(eptr);
                       infix[efun]:=xlink;
                       with cell[efun] do begin pname:=xundef;
                                                value:=etop
                                          end;
                       //efun:=efun;
                       etop:=estack[eptr];
                       dec(eptr)//
                    end
                    else if (einf=xexc) then begin etop:=efun; exit end//if einf=xexc
                    else break
             until false; geschweifezu
             //auf etop=xexc achten ???
             if (einf>xlimit)        then begin// >= ???
                if (einf=xsingle) then efun:=cell[efun].first
                else begin etop:=prop(etop,xcombine,efun); efun:=einf end;
                equit:=false
             end
             else if (einf=xident)   then begin
                eid:=efun;
                efun:=cell[efun].value;
                if (infix[efun]=xinteger) then begin
                   eindex:=cell[efun].inum;
                   if      (eindex>=0)       then select(eindex)
                   else if (eindex>=minproc) then begin ecall:=eindex; exit end//proc[eindex]
                   else efuncundef
                end
                else if (efun=xreserve)   then eidentunbound
                else equit:=false
             end
             else if (einf=xinteger) then begin
                eindex:=cell[efun].inum;
                if      (eindex>=0)       then select(eindex)
                else if (eindex>=minproc) then begin ecall:=eindex; exit end//proc[eindex]
                else efuncundef
             end
             //else if (einf=xfloat) then etop:=efun
             else if (einf=xnull)    then etop:=efun//xnil
             else if (einf=xindex)   then begin
                //eindex:=cell[efun].rnum;
                select(cell[efun].rnum)
             end
//           else if (einf=xlink)    then begin efun:=cell[efun].value;//wenn link unbound?
//                                              equit:=false
//                                        end
//           else if (einf=xlazy)    then begin
//              epush(etop);
//              epush(efun);
//              etop:=cell[efun].arg;
//              efun:=cell[efun].term;
//              repeat eval;  if (ecall<>0) then proc[ecall]
//              until equit;  ecall:=0;
//              //if (infix[etop]=xexc) then begin dec(eptr,2); exit end;//nochmal drübergucken! oder ohne dies (?)
//              efun:=estack[eptr];  dec(eptr);
//              infix[efun]:=xlink;            //test, ob noch xlazy etc...
//              with cell[efun] do begin pname:=xundef;
//                                       value:=etop
//                                 end;
//              //efun:=efun;
//              etop:=estack[eptr];  dec(eptr);
//              equit:=false//
//           end
             else if (einf=xerror)   then begin etop:=efun; exit end//wenn in etop ne _exc, dann vorlassen?
             //elseif(einf=xexc)thenbeginend
             //xlink position?
             //xlazy position?
             //else   etop:=newexc(ideintp,'nicht programmiert'); //exit//  etop:=efun
             //else if (einf=xsubst) then esubstitution//eforce
             else eunquoted//etop:=efun//? Fehleranfällig
      until equit
      //einf:=xnil?
end;}

procedure xdelazy;// Leibnizsches Prinzip ...
begin epush(etop);
//    if (infix[etop]<>xlazy) then
//       raise exception.create('delazy has no _lazy.');//for test //ifinfix=xlazy?
      efun:=cell[etop].term;
      etop:=cell[etop].arg;
      repeat eval;  if (ecall<>0) then proc[ecall]
      until equit;  ecall:=0;
      //if (infix[etop]=xexc) then begin dec(eptr); exit end;//nochmal drübergucken! oder ohne dies (?)
      efun:=estack[eptr];  dec(eptr);
//    infix[efun]:=xlink;                      //test, ob noch xlazy etc...
      with cell[efun] do begin pname:=xundef;
                               value:=etop
                         end;
      etop:=efun//so richtig?
end;

// ------- vm initialization -------

procedure initcharset(var tab: boolset; s: unicodestring);//--> charinset
var i: cardinal;
begin //tab:=[];
      for i:=0 to 255 do tab[i]:=false;//chr(i)
      for i:=1 to length(s) do tab[ord(s[i])]:=true
end;

procedure initvm(mc,ms: int64);
begin fpformatsettings:=DefaultFormatSettings;//TFormatSettings.Create;//(Locale);
      initapi(mc,ms);
      initcharset(normal,normalset);
      initcharset(special,specialset);
      //
      initeproc;
      //
      initapiprims;
      initactprims;
      initprimitives;
      //
end;

procedure finalvm;
begin finalapi;
//fpformatsettings.free//?
end;

end.


