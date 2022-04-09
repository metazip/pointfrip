unit sequnit;//ok

{$mode objfpc}{$H+}

interface

//uses Classes, SysUtils;

procedure initseqprims;

implementation

uses apiunit,
primunit;//noch mal neu!

{
procedure f;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    thenbeginend
      else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idx)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idx,efnnonum);//? idxname
      einf:=xnil
end;
} //

var idxlength: cardinal = xnil;

procedure flength;//ifxnull? ,ifxprefix? komplett?
label re;
var n: cardinal;
begin einf:=infix[etop];
      if      (einf=xobject) then fn(idxlength)//position?
      else if (einf>=xlimit) then begin
          n:=1;
          etop:=cell[etop].rest;
      re: einf:=infix[etop];
          if      (einf>=xlimit) then begin inc(n);
                                            etop:=cell[etop].rest;
                                            goto re
                                      end
        //else ifxnull?
          else if (einf=xerror)  then //exit
          else etop:=newreal(n) //exit // () ,atome
      end
    //else ifxnull? // =0
      else if (einf=xstring) then etop:=newreal(length(cell[etop].pstr^))//ifnil?
      else if (einf=xarray)  then etop:=newreal(length(cell[etop].aref^))//ifnil?
    //else if () thenbeginend
      else if (einf=xerror) then //(exit)
      else etop:=newreal(0);//atom-länge=1 oder 0 oder error ???
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
procedure flengthpre;//komplett? ,ifxprefix? ,ifxobject? ,etc
var n: cardinal;
begin repeat einf:=infix[etop];
             //ifxobject? ,position
             if      (einf>=xlimit) then begin
                n:=1;
                etop:=cell[etop].rest;
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then begin inc(n);
                                                         etop:=cell[etop].rest;
                                                         continue
                                                   end
                       //ifxnull?
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then exit
                       else begin etop:=newreal(n); exit end//() ,atome
                until false//
             end
             else if (einf=xstring) then begin
                ;
                exit
             end
             else if (einf=xarray)  then begin
                ;
                exit
             end
             //elseifxobject?
             //
             //else if (einf=xlink)   then etop:=cell[etop].value
             //else if (einf=xlazy)   then delazy
             else if (einf=xerror)  then exit
             //ifxnull?
             else begin etop:=newreal(0); exit end//() ,atom-länge???
      until false//
end;

// ------- initialization -------

procedure initseqidents;
begin idxlength:=newindex('length');
//
end;

procedure initseqprims;
begin //
      initseqidents;
      //
      newidentproc('length',@flength);
      //
end;

end.

