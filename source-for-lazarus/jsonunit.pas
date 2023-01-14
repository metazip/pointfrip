unit jsonunit;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils,
     typeunit;

procedure initjsonprims;

implementation

uses apiunit,primunit,vmunit;

const specialset: ansistring = '[]{}:,"'; // \ ?

var idxparsejson: cardinal = xnil;
    special: boolset;

const ejsonstringunexpend: es  = 'in json string unexpected end.';
      ejsonstringnoescchar: es = 'in json string no escape char.';
      ejsonlistunexpend: es    = 'in json list unexpected end.';
      //
      ejsonlistnotable: es     = 'in json list unexpected } .';
      ejsonlistunexpcolon: es  = 'in json list unexpected : .';
      ejsonlistunexpcomma: es  = 'in json list unexpected , .';
      ejsonlistnotag: es       = 'in json list , or ] expected.';
      //
      ejsontableunexpend: es   = 'in json table unexpected end.';
      ejsontablenolist: es     = 'in json table unexpected ] .';
      ejsontableunexpclose: es = 'in json table unexpected close.';
      ejsontablenostring: es   = 'in json table string expected.';
      ejsontablenocolon: es    = 'in json table : expected.';
      ejsontabledupcolon: es   = 'in json table double : .';
      ejsontableunexpcomma: es = 'in json table unexpected , .';
      ejsontablenotag: es      = 'in json table , or } expected.';
      ejsonnonumorval: es      = 'in json number or value expected';
      //
      ejsonparsenolist: es     = 'in json parse unexpected ] .';
      ejsonparsenotable: es    = 'in json parse unexpected } .';
      ejsonparseunexpcolon: es = 'in json parse unexpected : .';
      ejsonparseunexpcomma: es = 'in json parse unexpected , .';

function isspecial(x: unicodechar): boolean;
begin if (ord(x)>255) then isspecial:=false
      else isspecial:=special[ord(x)]
end;

function item(var s: ustring; var i: int64): ustring;
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
      //quit:=false
      if (ch<>'') then begin
         if isspecial(s[i]) then inc(i)
         else repeat inc(i);
                     if (i>length(s)) then quit:=true
                     else quit:=(isspecial(s[i]) or (s[i]<=#32))
              until quit
      end;
      item:=copy(s,k,i-k);
      dec(i)
end;

// idnull,'null' nochmal prüfen

procedure parsejson(var txt: ustring);
var it: ustring;
    ix: int64;

    procedure parserraise(s: ustring);
    begin raise fpexception.create(s)
    end;

    procedure comnumber(var it: ustring);
    forward;

    procedure comtable;
    forward;

    procedure comstring;//provi!
    var ch: ustring;
    begin it:='';
          inc(ix);
          ch:=copy(txt,ix,1);
          while (ch<>'"') do begin
             if (ch='')   then parserraise(ejsonstringunexpend);
             if (ch<>'\') then it:=it+ch
             else begin
                inc(ix);
                ch:=copy(txt,ix,1);
                if (ch='') then parserraise(ejsonstringnoescchar);
                case ch[1] of
                   '"': it:=it+ch;
                   '\': it:=it+ch;
                   '/': it:=it+ch;
                   'b': it:=it+#8;
                   'f': it:=it+#12;
                   'n': it:=it+#10;
                   'r': it:=it+#13;
                   't': it:=it+#9;
                   'u': begin it:=it+unicodechar(strtoint('$'+copy(txt,ix+1,4)));
                              inc(ix,4)
                        end;
                end
             end;
             inc(ix);
             ch:=copy(txt,ix,1);
          end;
          cstack:=prop(newstring(it),xcons,cstack);
    end;

    procedure cbacklistcons;
    var ref,p: cardinal;
    begin ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
                p:=cstack;
                cstack:=cell[cstack].rest;
                cell[p].rest:=ref;
                ref:=p
          end;
          cell[cstack].first:=ref
    end;

    procedure comlist;
    begin cstack:=prop(xmark,xcons,cstack);
          it:=item(txt,ix);
          while (it<>']') do begin
                if      (it='')  then parserraise(ejsonlistunexpend)
                else if (it='[') then comlist
                else if (it='{') then comtable
                else if (it='}') then parserraise(ejsonlistnotable)
                else if (it='"') then comstring
                else if (it=':') then parserraise(ejsonlistunexpcolon)
                else if (it=',') then parserraise(ejsonlistunexpcomma)
                else if (it='null')  then cstack:=prop(xnil,  xcons,cstack)
                else if (it='false') then cstack:=prop(xfalse,xcons,cstack)
                else if (it='true')  then cstack:=prop(xtrue, xcons,cstack)
                else comnumber(it);
                it:=item(txt,ix);
                if      (it=',') then it:=item(txt,ix)
                else if (it=']') then break
                else parserraise(ejsonlistnotag)
          end;
          cbacklistcons//
    end;

    procedure cbacktablecons;
    var ref,p,q: cardinal;
    begin ref:=xnil;
          while (cell[cstack].first<>xmark) do begin
                q:=cstack;
                cstack:=cell[cstack].rest;
                p:=cstack;
                cstack:=cell[cstack].rest;
                cell[q].rest:=ref;
                infix[q]:=cell[p].first;
                ref:=q//
          end;
          cell[cstack].first:=ref//
    end;

    procedure comtable;
    begin cstack:=prop(xmark,xcons,cstack);
          it:=item(txt,ix);
          while (it<>'}') do begin
                if      (it='')  then parserraise(ejsontableunexpend)
                else if (it='"') then comstring
                else parserraise(ejsontablenostring);
                it:=item(txt,ix);
                if (it<>':') then parserraise(ejsontablenocolon);
                it:=item(txt,ix);
                if      (it='')  then parserraise(ejsontableunexpend)
                else if (it='[') then comlist
                else if (it=']') then parserraise(ejsontablenolist)
                else if (it='{') then comtable
                else if (it='}') then parserraise(ejsontableunexpclose)
                else if (it='"') then comstring
                else if (it=':') then parserraise(ejsontabledupcolon)
                else if (it=',') then parserraise(ejsontableunexpcomma)
                else if (it='null')  then cstack:=prop(xnil,  xcons,cstack)
                else if (it='false') then cstack:=prop(xfalse,xcons,cstack)
                else if (it='true')  then cstack:=prop(xtrue, xcons,cstack)
                else comnumber(it);
                it:=item(txt,ix);
                if      (it=',') then it:=item(txt,ix)
                else if (it='}') then break
                else parserraise(ejsontablenotag)
          end;
          cbacktablecons
    end;

    procedure comnumber(var it: ustring);
    var inum: int64; fnum: double; errcode: longint;
    begin val(it,inum,errcode);
          if (errcode=0) then cstack:=prop(newinteger(inum),xcons,cstack)
          else begin
             val(it,fnum,errcode);
             if (errcode=0) then cstack:=prop(newreal(fnum),xcons,cstack)
             else parserraise(ejsonnonumorval+' - '+it)
          end
    end;

begin try ix:=0;
          cstack:=xnil;
          it:=item(txt,ix);
          while (it<>'') do begin
                if      (it='[') then comlist
                else if (it=']') then parserraise(ejsonparsenolist)
                else if (it='{') then comtable
                else if (it='}') then parserraise(ejsonparsenotable)
                else if (it='"') then comstring
                else if (it=':') then parserraise(ejsonparseunexpcolon)
                else if (it=',') then parserraise(ejsonparseunexpcomma)
                else if (it='null')  then cstack:=prop(xnil,  xcons,cstack)
                else if (it='false') then cstack:=prop(xfalse,xcons,cstack)
                else if (it='true')  then cstack:=prop(xtrue, xcons,cstack)
                else comnumber(it);
                it:=item(txt,ix)
          end;
          nreverse(cstack);
      except raise // test
      end
end;

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON#full_json_grammar
// https://datatracker.ietf.org/doc/html/rfc8259

procedure fparsejson; // oder jsonvalue?
var txt: ustring;
begin einf:=infix[etop];
      if      (einf=xstring) then begin
         try txt:=cell[etop].pstr^; // if nil?
             parsejson(txt);
             if (infix[cstack]=xnull) then etop:=xundef
             else begin etop:=cell[cstack].first;
                        cstack:=xnil
                  end
         except on e: fpexception do etop:=newerror(idxparsejson,e.message)
                else raise
         end
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxparsejson)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxparsejson,efnnostring); // ? idxname
      einf:=xnil
end;

procedure initcharset(var tab: boolset; s: unicodestring);//--> charinset
var i: cardinal;
begin //tab:=[];
      for i:=0 to 255 do tab[i]:=false;//chr(i)
      for i:=1 to length(s) do tab[ord(s[i])]:=true
end;

procedure initjsonprims;
begin initcharset(special,specialset);
      idxparsejson:=newindex('parsejson');
      newidentproc('parsejson',@fparsejson);
end;

end.

