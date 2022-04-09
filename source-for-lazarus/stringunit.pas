unit stringunit;//ok

{$mode objfpc}{$H+}

interface

uses //Classes,//?
     SysUtils,//trimleft,etc;
     typeunit;

procedure initstringprims;

implementation

uses apiunit,
primunit,vmunit;//noch mal neu!

var //
    idxsubstring: cardinal = xnil;
    idxconcat: cardinal = xnil;
    idxindexof: cardinal = xnil;
    idxchar: cardinal = xnil;
    idxunicode: cardinal = xnil;
    idxtrim: cardinal = xnil;
    idxtriml: cardinal = xnil;
    idxtrimr: cardinal = xnil;
    idxupper: cardinal = xnil;
    idxlower: cardinal = xnil;
    idxparse: cardinal = xnil;
    idxvalue: cardinal = xnil;
    idxtimetostring: cardinal = xnil;
    idxdatetostring: cardinal = xnil;
    idxweekday: cardinal = xnil;
    //

procedure fsubstring;//ifprefix? ,ifxobject
var i,k: int64; ps: pustring;
begin if (infix[etop]<>xcons) then begin
         if (infix[etop]<>xerror) then etop:=newerror(idxsubstring,efnnocons);
         exit
      end;
      with cell[etop] do begin efun:=first; etop:=rest end;
      if (infix[etop]<>xcons) then begin//ifxerror?
         etop:=newerror(idxsubstring,efnnocons); exit
      end;
      with cell[etop] do begin einf:=first; etop:=rest end;
      if (infix[etop]<>xcons) then begin//ifxerror?
         etop:=newerror(idxsubstring,efnnocons); exit
      end;
      etop:=cell[etop].first;
      //
      //ifxobject? ....................
      //
      if (infix[efun]=xstring) then ps:=cell[efun].pstr
      else begin//?
         etop:=newerror(idxsubstring,efnnostring1); exit
      end;
      if      (infix[einf]=xreal)    then i:=round(cell[einf].fnum)
      else if (infix[einf]=xinteger) then i:=cell[einf].inum
      else begin etop:=newerror(idxsubstring,efnnonum2); exit end;
      if      (infix[etop]=xreal)    then k:=round(cell[etop].fnum)
      else if (infix[etop]=xinteger) then k:=cell[etop].inum
      else begin etop:=newerror(idxsubstring,efnnonum3); exit end;
      if (ps=nil) then begin//=nil?
         etop:=newerror(idxsubstring,efnstringnoval); exit
      end;
      etop:=newstring(copy(ps^,i,k))//?
end;

// bitte substring noch testen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//bitte vergleichen!
procedure fconcat;
begin ee(idxconcat);
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xstring) then begin
            if (infix[etop]=xstring) then begin // was bei nils?
             //try?
               etop:=newstring(cell[efun].pstr^ + cell[etop].pstr^)
            end
            else etop:=newerror(idxconcat,eopnostring2)
         end
         else if (einf=xobject) then op(idxconcat)
       //else if (einf=xerror)  then //exit
         else etop:=newerror(idxconcat,eopnostring1);
         einf:=xnil
      end//else exit
end;

procedure findexof;
begin ee(idxindexof);
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xstring) then begin
            if (infix[etop]=xstring) then begin // was bei nils?
             //try?
               etop:=newreal(pos(cell[etop].pstr^,cell[efun].pstr^))
            end
            else etop:=newerror(idxindexof,eopnostring2)
         end
         else if (einf=xobject) then op(idxindexof)
       //else if (einf=xerror)  then //exit
         else etop:=newerror(idxindexof,eopnostring1);
         einf:=xnil
      end//else exit
end;

//mit precode vergleichen!!!
procedure fchar;//ifprefix?
var n: int64;
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         try n:=round(cell[etop].fnum)
         except on e: ematherror do begin etop:=newerror(idxchar,efnrounderror);
                                          exit//einf?
                                    end
                else raise
         end;
         if ((0<=n) and (n<=65535)) then etop:=newstring(unicodechar(n))//unicodechar?chr
         else etop:=newerror(idxchar,echarnotinrange)
      end
      else if (einf=xinteger) then begin
         n:=cell[etop].inum;
         if ((0<=n) and (n<=65535)) then etop:=newstring(unicodechar(n))//unicodechar?chr
         else etop:=newerror(idxchar,echarnotinrange)
      end
      else if (einf=xobject)  then fn(idxchar)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxchar,efnnonum);//? idxname
      einf:=xnil
end;

//mit precode vergleichen!!!
procedure funicode;//ifprefix?
var p: pustring;
begin einf:=infix[etop];
      if      (einf=xstring) then begin
         p:=cell[etop].pstr;//if nil?
         if (length(p^)>0) then etop:=newreal(ord(p^[1]))
         else etop:=newerror(idxunicode,efnstringnull)//??? unicode
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxunicode)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxunicode,efnnostring);//? idxname
      einf:=xnil
end;

procedure ftrim;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xstring) then begin // was bei nil?
       //try?
         etop:=newstring(trim(cell[etop].pstr^))
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxtrim)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtrim,efnnostring);//? idxname
      einf:=xnil
end;

procedure ftriml;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xstring) then begin // was bei nil?
       //try?
         etop:=newstring(trimleft(cell[etop].pstr^))
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxtriml)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtriml,efnnostring);//? idxname
      einf:=xnil
end;

procedure ftrimr;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xstring) then begin // was bei nil?
       //try?
         etop:=newstring(trimright(cell[etop].pstr^))
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxtrimr)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtrimr,efnnostring);//? idxname
      einf:=xnil
end;

procedure fupper;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xstring) then begin // was bei nil?
       //try?
         etop:=newstring(ansiuppercase(cell[etop].pstr^))
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxupper)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxupper,efnnostring);//? idxname
      einf:=xnil
end;

procedure flower;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xstring) then begin // was bei nil?
       //try?
         etop:=newstring(ansilowercase(cell[etop].pstr^))
      end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxlower)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxlower,efnnostring);//? idxname
      einf:=xnil
end;

procedure ftimetostring;
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         etop:=newstring(timetostr(cell[etop].fnum,fpformatsettings))
      end
      //else if (einf=xinteger) then beginend
      else if (einf=xobject)  then fn(idxtimetostring)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtimetostring,efnnoreal);
      einf:=xnil
end;

procedure fdatetostring;
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         etop:=newstring(datetostr(cell[etop].fnum,fpformatsettings))
      end
      else if (einf=xinteger) then begin
         etop:=newstring(datetostr(cell[etop].inum,fpformatsettings))
      end
      else if (einf=xobject)  then fn(idxdatetostring)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxdatetostring,efnnonum);
      einf:=xnil
end;

procedure fweekday;
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         etop:=newreal(dayofweek(cell[etop].fnum))
      end
      else if (einf=xinteger) then begin
         etop:=newinteger(dayofweek(cell[etop].inum))
      end
      else if (einf=xobject)  then fn(idxweekday)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxweekday,efnnonum);
      einf:=xnil
end;

procedure fparse;//ifprefix?
var txt: ustring;
begin einf:=infix[etop];
      if      (einf=xstring) then
         try txt:=cell[etop].pstr^;//if nil?
             precom(txt);
             etop:=cstack;
             cstack:=xnil
         except on e: fpexception do etop:=newerror(idxparse,e.message)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxparse)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxparse,efnnostring);//? idxname
      einf:=xnil
end;

procedure fvalue;//ifprefix?
var txt: ustring;
begin einf:=infix[etop];
      if      (einf=xstring) then
         try txt:=cell[etop].pstr^;//if nil?
             precom(txt);
             if (infix[cstack]=xcons) then etop:=cell[cstack].first
                                      else etop:=xundef;//??? ,xnil?
             cstack:=xnil
         except on e: fpexception do etop:=newerror(idxvalue,e.message)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject) then fn(idxvalue)
      else if (einf=xerror)  then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxvalue,efnnostring);//? idxname
      einf:=xnil
end;

procedure fstring;//ifxerror?...
begin if (infix[etop]=xerror) then exit;// provi
      etop:=newstring(tovalue(etop));//xerror? ,xobject? ,etc?
end;

//copy (?) substring?
//concat
//pos(?)
//char
//(uni)code
//triml
//trimr
//upper
//lower
//parse
//value
//string
//

// ------- initialization -------

procedure initstringidents;
begin //
      idxsubstring:=newindex('substring');
      idxconcat:=newindex('concat');
      idxindexof:=newindex('indexof');//pos
      idxchar:=newindex('char');
      idxunicode:=newindex('unicode');
      idxtrim:=newindex('trim');
      idxtriml:=newindex('triml');
      idxtrimr:=newindex('trimr');
      idxupper:=newindex('upper');
      idxlower:=newindex('lower');
      idxparse:=newindex('parse');
      idxvalue:=newindex('value');
      idxtimetostring:=newindex('timetostring');
      idxdatetostring:=newindex('datetostring');
      idxweekday:=newindex('weekday');// numerisch position?
      //
end;

procedure initstringprims;
begin //
      initstringidents;
      //
      newidentproc('substring',@fsubstring);
      newidentproc('concat',@fconcat);// conc?
      newidentproc('&',@fconcat);//cc = & (?)
      newidentproc('indexof',@findexof);//pos ,(index)of?
      newidentproc('char',@fchar);
      newidentproc('unicode',@funicode);
      newidentproc('trim',@ftrim);
      newidentproc('triml',@ftriml);
      newidentproc('trimr',@ftrimr);
      newidentproc('upper',@fupper);
      newidentproc('lower',@flower);
      newidentproc('parse',@fparse);
      newidentproc('value',@fvalue);
      newidentproc('string',@fstring);
      newidentproc('timetostring',@ftimetostring);
      newidentproc('datetostring',@fdatetostring);
      newidentproc('weekday',@fweekday);
      //
      //concat
      //cc == &  (?)
      //
end;

end.

