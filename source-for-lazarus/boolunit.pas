unit boolunit;//ok

{$mode objfpc}{$H+}

interface

//uses Classes, SysUtils;

procedure initboolprims;

implementation

uses apiunit, primunit;

var idxeq: cardinal = xnil;
    idxlt: cardinal = xnil;
    idxislist: cardinal = xnil;
    idxisbool: cardinal = xnil;
    idxisnum: cardinal = xnil;
    idxiszero: cardinal = xnil;
    idxispos: cardinal = xnil;
    idxisneg: cardinal = xnil;
    idxisbound: cardinal = xnil;
    idxnot: cardinal = xnil;
    idxand: cardinal = xnil;
    idx_or: cardinal = xnil;
    idxxor: cardinal = xnil;

// ------- compare operators -------

// ------------------
// ----- legacy -----
// ------------------
//ungeprüft übernommen von femtoproject // ifxobject? //ifxerror(?)
procedure feq;
begin ee(idxeq); if (infix[etop]=xerror) then exit;
      einf:=infix[efun];// efun & etop
      if (einf=xobject) then begin op(idxeq); exit end;//ifxobject(efun)
      if      (einf=xnull)   then begin if (infix[etop]=xnull) then etop:=xtrue
                                                               else etop:=xfalse
                                  end
      else if (einf=xident)  then begin if (efun = etop) then etop:=xtrue
                                                         else etop:=xfalse
                                  end
      else if (einf=xindex)  then begin if (efun = etop) then etop:=xtrue
                                                         else etop:=xfalse
                                  end
      else if (einf=xinteger) then begin
         if (infix[etop]<>xinteger) then etop:=xfalse
         else if (cell[efun].inum = cell[etop].inum) then etop:=xtrue
                                                     else etop:=xfalse
      end
      else if (einf=xreal)    then begin
         if (infix[etop]<>xreal) then etop:=xfalse
         else if (cell[efun].fnum = cell[etop].fnum) then etop:=xtrue
                                                     else etop:=xfalse
      end
      else if (einf=xstring)  then begin
         if (infix[etop]<>xstring) then etop:=xfalse
         else if (cell[efun].pstr^ = cell[etop].pstr^) then etop:=xtrue
                                                       else etop:=xfalse
      end
      else if (einf=xarray)   then begin
         if (infix[etop]<>xarray) then etop:=xfalse
         else if (efun=etop) then etop:=xtrue
         else provisorium('Provisorium in feq (array-type).')// provi!!!
      end
      else begin if (efun = etop) then etop:=xtrue  //
                                  else etop:=xfalse //??? provi...
           end;
      efun:=xnil//einfxnil
end;

// ------------------
// ----- legacy -----
// ------------------
//ungeprüft übernommen von femtoproject //ifxobject? //ifxerror(?)
procedure flt;
begin ee(idxlt); if (infix[etop]=xerror) then exit;
      einf:=infix[efun];// efun & etop
      if (einf=xobject) then begin op(idxlt); exit end;//ifxobject(efun)
      if      (einf=xnull)   then etop:=newerror(idxlt,eltnocompare)
      else if (einf=xident)  then begin
         if (infix[etop]<>xident) then etop:=newerror(idxlt,eltnocompare)
         else begin
            efun:=cell[efun].pname;
            etop:=cell[etop].pname;
            if not((infix[efun]=xstring) and (infix[etop]=xstring)) then
               etop:=newerror(idxlt,eltnostring)
            else if (cell[efun].pstr^ < cell[etop].pstr^) then etop:=xtrue
                                                          else etop:=xfalse
         end
      end
      else if (einf=xindex)   then begin
         if (infix[etop]<>xindex) then etop:=newerror(idxlt,eltnocompare)
         else if (cell[efun].rnum < cell[etop].rnum) then etop:=xtrue
                                                     else etop:=xfalse
      end
      else if (einf=xinteger) then begin
         if (infix[etop]<>xinteger) then etop:=newerror(idxlt,eltnocompare)
         else if (cell[efun].inum < cell[etop].inum) then etop:=xtrue
                                                     else etop:=xfalse
      end
      else if (einf=xreal)    then begin
         if (infix[etop]<>xreal) then etop:=newerror(idxlt,eltnocompare)
         else if (cell[efun].fnum < cell[etop].fnum) then etop:=xtrue
                                                     else etop:=xfalse
      end
      else if (einf=xstring)  then begin
         if (infix[etop]<>xstring) then etop:=newerror(idxlt,eltnocompare)
         else if (cell[efun].pstr^ < cell[etop].pstr^) then etop:=xtrue
                                                       else etop:=xfalse
      end
      else if (einf=xarray)   then begin
         if (infix[etop]<>xarray) then etop:=newerror(idxlt,eltnocompare)
         else provisorium('Provisorium in flt (array-type).')// provi!!!
      end
      else etop:=newerror(idxlt,eltnocompare);//??? provi...
      efun:=xnil//einfxnil
end;

//same? (ptr)
//lt
//is...

// ------- predicate functions -------

procedure fisatom;//  provi!
begin einf:=infix[etop];
      //ifxobject?
      if      (einf=xerror) then //(exit)
      else if (einf<xlimit) then etop:=xtrue
                            else etop:=xfalse;
      einf:=xnil
end;

procedure fisprop;//  provi! ,fn()?
begin einf:=infix[etop];
      //ifxobject?... for test (und isprop anders als isatom)
      if      (einf=xobject) then begin // for test ifxobject
         if (infix[cell[etop].inst]>=xlimit) then etop:=xtrue
                                             else etop:=xfalse
      end
      else if (einf=xerror)  then //(exit)
      else if (einf>=xlimit) then etop:=xtrue
                             else etop:=xfalse;
      einf:=xnil
end;

procedure fislist;// provi
begin einf:=infix[etop];
      if ((einf=xnull) or (einf=xcons)) then etop:=xtrue
      else if (einf=xobject) then fn(idxislist)
      else if (einf=xerror)  then //(exit)
      else etop:=xfalse;                                //???
      einf:=xnil
end;

procedure fisbool;// provi
begin if ((etop=xtrue) or (etop=xfalse)) then etop:=xtrue
      else begin einf:=infix[etop];                              //???
         if      (einf=xobject) then fn(idxisbool)
         else if (einf=xerror)  then //(exit)
         else etop:=xfalse;
         einf:=xnil
      end//
end;

procedure fisnum;// provi
begin einf:=infix[etop];
      if ((einf=xreal) or (einf=xinteger)) then etop:=xtrue
      else if (einf=xobject) then fn(idxisnum)
      else if (einf=xerror)  then //(exit)
      else etop:=xfalse;                               //???
      einf:=xnil
end;

//bei legacy gucken!
procedure fiszero;
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         if (cell[etop].fnum = 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xinteger) then begin
         if (cell[etop].inum = 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xobject)  then fn(idxiszero)
      else if (einf=xerror)   then //(exit)
      else etop:=xfalse;//? ,newerror?
      einf:=xnil//
end;

procedure fispos;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         if (cell[etop].fnum > 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xinteger) then begin
         if (cell[etop].inum > 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xobject)  then fn(idxispos)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxispos,efnnonum);//? idxname ,xfalse oder ???
      einf:=xnil
end;

procedure fisneg;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then begin
         if (cell[etop].fnum < 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xinteger) then begin
         if (cell[etop].inum < 0) then etop:=xtrue
                                  else etop:=xfalse
      end
      else if (einf=xobject)  then fn(idxisneg)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxisneg,efnnonum);//? idxname ,xfalse oder ???
      einf:=xnil
end;

//testen: ((not°isnil)->*tail)°'(a b c d e f g h) mit leer

procedure fisnil;
begin einf:=infix[etop];
      if      (einf>=xlimit) then begin
         if (infix[cell[etop].rest]=xnull) then etop:=xtrue
                                           else etop:=xfalse
      end
      else if (einf=xerror)  then //exit
      else etop:=xfalse;//???
      einf:=xnil
end;

procedure fispreg;
begin einf:=infix[etop];
      if      (einf>=xlimit) then begin
         if (infix[cell[etop].rest]<>xnull) then etop:=xtrue
                                            else etop:=xfalse
      end
      else if (einf=xerror)  then //exit
      else etop:=xfalse;//???
      einf:=xnil
end;

//bei legacy gucken!
procedure istypeof(id: cardinal);//position?
begin einf:=infix[etop];
      //ifxobject?
      if      (einf=xerror) then //(exit)
      else if (einf=id)     then etop:=xtrue
                            else etop:=xfalse;
      einf:=xnil//
end;

//istypeof position? ,isobj position?

procedure fisnull;//position? ,ifisnil
begin istypeof(xnull)
end;

procedure fisinteger;
begin istypeof(xinteger)
end;

procedure fisreal;
begin istypeof(xreal)
end;

procedure fisstring;
begin istypeof(xstring)
end;

procedure fisident;
begin istypeof(xident)
end;

procedure fisprefix;
begin istypeof(xprefix)
end;

procedure fisindex;
begin istypeof(xindex)
end;

procedure fisarray;
begin istypeof(xarray)
end;

procedure fiscons;
begin istypeof(xcons)
end;

procedure fiscombi;
begin istypeof(xcombine)
end;

procedure fisalternal;
begin istypeof(xalter)
end;

procedure fisobj;//position? ,isnil ,ispreg
begin istypeof(xobject)
end;

procedure fisquote;
begin istypeof(xquote)//ifk?
end;

procedure fisivar;
begin istypeof(xivar)
end;

procedure fisact;
begin istypeof(xact)
end;

procedure fisbound;
begin einf:=infix[etop];
      if      (einf=xident)  then begin
         if (cell[etop].value<>xreserve) then etop:=xtrue
                                         else etop:=xfalse
      end
      else if (einf=xprefix) then begin
         if (cell[etop].value<>xreserve) then etop:=xtrue
                                         else etop:=xfalse
      end
      else if (einf=xobject) then fn(idxisbound)
      else if (einf=xerror)  then //exit
      else etop:=newerror(idxisbound,efnnobound);//??? name?
      einf:=xnil
end;

procedure fisundef;//ifxobject? ,ifxprefix?
begin if (infix[etop]=xerror) then //(exit)
      else if (etop=xundef) then etop:=xtrue
                            else etop:=xfalse
end;

//

procedure fis;//oop
begin//
end;

//ftry;

// ------- boolean functions/operators -------

procedure fnot;
begin if      (etop=xtrue)  then etop:=xfalse
      else if (etop=xfalse) then etop:=xtrue
      else begin
         einf:=infix[etop];
         if      (einf=xobject)  then fn(idxnot)
         else if (einf=xinteger) then etop:=newinteger(not(cell[etop].inum))
         else if (einf=xerror)   then //(exit)
         else etop:=newerror(idxnot,efnnobool);
         einf:=xnil
      end//
end;

// ------------------
// ----- legacy -----
// ------------------
//fnot kleiner gebaut        ,wie bei isbool gemacht      ,
procedure fnotpre;
begin repeat if      (etop=xtrue)  then begin etop:=xfalse; exit end
             else if (etop=xfalse) then begin etop:=xtrue;  exit end
             else begin
                einf:=infix[etop];
                if (einf=xobject) then begin fn(idxnot); exit end;//else? ifxobject
                //if      (einf=xlink)  then etop:=cell[etop].value
                //else if (einf=xlazy)  then delazy
                if (einf=xerror) then exit
                else begin etop:=newerror(idxnot,efnnobool); exit end
             end//?
      until false
end;
{begin repeat einf:=infix[etop];
             if      (einf=xident) then break
             else if (einf=xlink)  then etop:=cell[etop].value
             else if (einf=xlazy)  then delazy
             else if (einf=xexc)   then exit
             //ifxobject position?
             else begin etop:=newexc(idenot,efunnobool); exit end
      until false;
      if      (etop=xtrue)  then etop:=xfalse
      else if (etop=xfalse) then etop:=xtrue
      else etop:=newexc(idenot,efunnobool)
end;}//;

procedure fand;//ifprefix?
begin ee(idxand);
      if (infix[etop]<>xerror) then begin
         if      (efun=xtrue)  then begin
            if      (etop=xtrue)  then etop:=xtrue
            else if (etop=xfalse) then etop:=xfalse
            else etop:=newerror(idxand,eopnobool2)
         end
         else if (efun=xfalse) then begin
            if ((etop=xtrue) or (etop=xfalse)) then etop:=xfalse
            else etop:=newerror(idxand,eopnobool2)
         end
         else begin einf:=infix[efun];
            if      (einf=xobject)  then op(idxand)
            else if (einf=xinteger) then begin
               if (infix[etop]<>xinteger) then etop:=newerror(idxand,eopnoint2)
               else etop:=newinteger(cell[efun].inum and cell[etop].inum)
            end
            //else ifxerror?
            else etop:=newerror(idxand,eopnobool1);
            einf:=xnil
         end
      end//else exit
end;

procedure f_or;//ifprefix?
begin ee(idx_or);
      if (infix[etop]<>xerror) then begin
         if      (efun=xtrue)  then begin
            if ((etop=xtrue) or (etop=xfalse)) then etop:=xtrue
            else etop:=newerror(idx_or,eopnobool2)
         end
         else if (efun=xfalse) then begin
            if      (etop=xtrue)  then etop:=xtrue
            else if (etop=xfalse) then etop:=xfalse
            else etop:=newerror(idx_or,eopnobool2)
         end
         else begin einf:=infix[efun];
            if      (einf=xobject)  then op(idx_or)
            else if (einf=xinteger) then begin
               if (infix[etop]<>xinteger) then etop:=newerror(idx_or,eopnoint2)
               else etop:=newinteger(cell[efun].inum or cell[etop].inum)
            end
            //elseifxerror?
            else etop:=newerror(idx_or,eopnobool1);
            einf:=xnil
         end
      end//else exit
end;

procedure fxor;//ifprefix?
begin ee(idxxor);
      if (infix[etop]<>xerror) then begin
         if (efun=xtrue) then begin
            if      (etop=xtrue)  then etop:=xfalse
            else if (etop=xfalse) then etop:=xtrue
            else etop:=newerror(idxxor,eopnobool2)
         end
         else if (efun=xfalse) then begin
            if      (etop=xtrue)  then etop:=xtrue
            else if (etop=xfalse) then etop:=xfalse
            else etop:=newerror(idxxor,eopnobool2)
         end
         else begin einf:=infix[efun];
            if      (einf=xobject)  then op(idxxor)
            else if (einf=xinteger) then begin
               if (infix[etop]<>xinteger) then etop:=newerror(idxxor,eopnoint2)
               else etop:=newinteger(cell[efun].inum xor cell[etop].inum)
            end
            //elseifxerror?
            else etop:=newerror(idxxor,eopnobool1);
            einf:=xnil
         end
      end//else exit
end;

// ------- bool initialization -------

procedure initboolidents;
begin //
      idxeq:=newindex('eq');
      idxlt:=newindex('lt');
      idxislist:=newindex('islist');
      idxisbool:=newindex('isbool');
      idxisnum:=newindex('isnum');
      idxiszero:=newindex('iszero');
      idxispos:=newindex('ispos');
      idxisneg:=newindex('isneg');
      idxisbound:=newindex('isbound');
      idxnot:=newindex('not');
      idxand:=newindex('and');
      idx_or:=newindex('or');
      idxxor:=newindex('xor');
      //
end;

procedure initboolprims;
begin //
      initboolidents;
      newidentproc('=',@feq);
      newidentproc('<',@flt);
      newidentproc('isatom',@fisatom);
      newidentproc('isprop',@fisprop);
      newidentproc('islist',@fislist);
      newidentproc('isbool',@fisbool);
      newidentproc('isnum',@fisnum);
      newidentproc('iszero',@fiszero);
      newidentproc('ispos',@fispos);
      newidentproc('isneg',@fisneg);
      newidentproc('isnil',@fisnil);
      newidentproc('ispreg',@fispreg);
      newidentproc('isnull',@fisnull);
      newidentproc('isint',@fisinteger);//isint?
      newidentproc('isreal',@fisreal);
      newidentproc('isstring',@fisstring);
      newidentproc('isident',@fisident);
      newidentproc('isprefix',@fisprefix);
      newidentproc('isindex',@fisindex);
      newidentproc('isarray',@fisarray);
      newidentproc('iscons',@fiscons);
      newidentproc('iscombi',@fiscombi);
      newidentproc('isalt',@fisalternal);//...
      newidentproc('isobj',@fisobj);//position?
      newidentproc('isquote',@fisquote);
      newidentproc('isivar',@fisivar);
      newidentproc('isact',@fisact);
      newidentproc('isbound',@fisbound);//position?
      newidentproc('isundef',@fisundef);
      //newidentproc(,f);
      newidentproc('not',@fnot);
      newidentproc('and',@fand);
      newidentproc('or',@f_or);
      newidentproc('xor',@fxor);
      //
end;

end.

