unit mathunit;//ok

{$mode objfpc}{$H+}

interface

uses //Classes,//?
     SysUtils,//exception
     Math;//power,etc...;

procedure initmathprims;

implementation

uses apiunit, primunit;

var idxadd: cardinal = xnil;
    idxsub: cardinal = xnil;
    idxmul: cardinal = xnil;
    idxdiv: cardinal = xnil;
    idxpow: cardinal = xnil;
    idxidiv: cardinal = xnil;
    idximod: cardinal = xnil;
    idxpred: cardinal = xnil;
    idxsucc: cardinal = xnil;
    idxsign: cardinal = xnil;
    idxabs: cardinal = xnil;
    idxneg: cardinal = xnil;
    idxround: cardinal = xnil;
    idxtrunc: cardinal = xnil;
    idxint: cardinal = xnil;
    idxfrac: cardinal = xnil;
    idxfloat: cardinal = xnil;
    idxroundto: cardinal = xnil;
    idxexp: cardinal = xnil;
    idxln: cardinal = xnil;
    idxlg: cardinal = xnil;
    idxld: cardinal = xnil;
    idxsq: cardinal = xnil;
    idxsqrt: cardinal = xnil;
    idxsin: cardinal = xnil;
    idxcos: cardinal = xnil;
    idxtan: cardinal = xnil;
    idxcot: cardinal = xnil;
    idxsec: cardinal = xnil;
    idxcsc: cardinal = xnil;
    idxarcsin: cardinal = xnil;
    idxarccos: cardinal = xnil;
    idxarctan: cardinal = xnil;
    idxarctan2: cardinal = xnil;
    idxarccot: cardinal = xnil;
    idxarcsec: cardinal = xnil;
    idxarccsc: cardinal = xnil;
    idxsinh: cardinal = xnil;
    idxcosh: cardinal = xnil;
    idxtanh: cardinal = xnil;
    idxcoth: cardinal = xnil;
    idxsech: cardinal = xnil;
    idxcsch: cardinal = xnil;
    idxarsinh: cardinal = xnil;
    idxarcosh: cardinal = xnil;
    idxartanh: cardinal = xnil;
    idxdeg: cardinal = xnil;
    idxrad: cardinal = xnil;
    idxhex: cardinal = xnil;
    //
    idneg: cardinal = xnil;

// ------- arithmetic operators -------

//muster:
procedure fadd;//ifprefix?
begin ee(idxadd);
      //einf2:=infix[etop];
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xreal)    then begin
            if (infix[etop]<>xreal) then etop:=newerror(idxadd,eopnoreal2)
            else try etop:=newreal(cell[efun].fnum + cell[etop].fnum)
                 except on ematherror do etop:=newerror(idxadd,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idxadd,eopnoint2)
            else try etop:=newinteger(cell[efun].inum + cell[etop].inum)
                 except on EIntError do etop:=newerror(idxadd,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idxadd) {;exit}
         //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
         //   iop(idxadd) {;exit}
         //ifxerror?
         else etop:=newerror(idxadd,eopnonum1);
         einf:=xnil
      end//else exit
end;

//procedure froundto;

procedure fsub;//ifprefix?
begin ee(idxsub);
      //einf2:=infix[etop];
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xreal)    then begin
            if (infix[etop]<>xreal) then etop:=newerror(idxsub,eopnoreal2)
            else try etop:=newreal(cell[efun].fnum - cell[etop].fnum)
                 except on ematherror do etop:=newerror(idxsub,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idxsub,eopnoint2)
            else try etop:=newinteger(cell[efun].inum - cell[etop].inum)
                 except on EIntError do etop:=newerror(idxsub,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idxsub) {;exit}
         //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
         //   iop(idxsub) {;exit}
         //ifxerror?
         else etop:=newerror(idxsub,eopnonum1);
         einf:=xnil
      end//else exit
end;

procedure fmul;//ifprefix?
begin ee(idxmul);
      //einf2:=infix[etop];
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xreal)    then begin
            if (infix[etop]<>xreal) then etop:=newerror(idxmul,eopnoreal2)
            else try etop:=newreal(cell[efun].fnum * cell[etop].fnum)
                 except on ematherror do etop:=newerror(idxmul,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idxmul,eopnoint2)
            else try etop:=newinteger(cell[efun].inum * cell[etop].inum)
                 except on EIntError do etop:=newerror(idxmul,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idxmul) {;exit}
         //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
         //   iop(idxmul) {;exit}
         //ifxerror?
         else etop:=newerror(idxmul,eopnonum1);
         einf:=xnil
      end//else exit
end;

// ------------------
// ----- legacy -----
// ------------------
procedure fdiv;  // 0/0=undefined
var num1,num2: extended;//in double speichern? oder extended?
begin ee(idxdiv);  if (infix[etop]=xerror) then exit;
      einf:=infix[efun];
      if (einf=xobject) then begin op(idxdiv); exit end;
      if      (einf=xreal)    then num1:=cell[efun].fnum
      else if (einf=xinteger) then num1:=cell[efun].inum
      else begin etop:=newerror(idxdiv,eopnonum1); exit end;
      einf:=infix[etop];
      if      (einf=xreal)    then num2:=cell[etop].fnum
      else if (einf=xinteger) then num2:=cell[etop].inum
      else begin etop:=newerror(idxdiv,eopnonum2); exit end;
      try etop:=newreal(num1 / num2)
      except on EZeroDivide do etop:=newerror(idxdiv,efdivbyzero);//div by zero
             on ematherror  do etop:=newerror(idxdiv,eopmatherror)
             else raise
      end;
      efun:=xnil;//?
      einf:=xnil
end;

procedure fpow;//ifprefix?
begin ee(idxpow);
      //einf2:=infix[etop];
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xreal)    then begin
            if (infix[etop]<>xreal) then etop:=newerror(idxpow,eopnoreal2)
            else try etop:=newreal(power(cell[efun].fnum,cell[etop].fnum))
                 except on ematherror do etop:=newerror(idxpow,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idxpow,eopnoint2)
            else try etop:=newinteger(round(power( cell[efun].inum,
                                                   cell[etop].inum )))
                 except on ematherror do etop:=newerror(idxpow,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idxpow) {;exit}
         //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
         //   iop(idxpow) {;exit}
         //ifxerror?
         else etop:=newerror(idxpow,eopnonum1);
         einf:=xnil
      end//else exit
end;

procedure fidiv;//ifprefix?  // '[0]idiv'[0]=undefined
begin ee(idxidiv);
      //einf2...
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idxidiv,eopnoint2)
            else try etop:=newinteger(cell[efun].inum div cell[etop].inum)
                 except on EDivByZero do etop:=newerror(idxidiv,eidivbyzero);//div by null(?);
                        on EIntError  do etop:=newerror(idxidiv,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idxidiv)
         //else if (einf=xerror) then //(exit)
         else etop:=newerror(idxidiv,eopnoint1);
         einf:=xnil
      end//
end;

procedure fimod;//name?   ,ifprefix?
begin ee(idximod);
      //einf2...
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xinteger) then begin
            if (infix[etop]<>xinteger) then etop:=newerror(idximod,eopnoint2)
            else try etop:=newinteger(cell[efun].inum mod cell[etop].inum)
                 except on EDivByZero do etop:=newerror(idximod,eidivbyzero);//div by null(?);
                        on EIntError  do etop:=newerror(idximod,eopmatherror)
                        else raise
                 end
         end
         else if (einf=xobject)  then op(idximod)
         //else if (einf=xerror) then //(exit)
         else etop:=newerror(idximod,eopnoint1);
         einf:=xnil
      end//
end;

//idiv
//imod
//pow

//muster:
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
}

// ------- arithmetical functions -------

procedure fpred;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then etop:=newreal(cell[etop].fnum - 1)
      else if (einf=xinteger) then etop:=newinteger(cell[etop].inum - 1)
      else if (einf=xobject)  then fn(idxpred)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxpred,efnnonum);//? idxname
      einf:=xnil
end;

procedure fsucc;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then etop:=newreal(cell[etop].fnum + 1)
      else if (einf=xinteger) then etop:=newinteger(cell[etop].inum + 1)
      else if (einf=xobject)  then fn(idxsucc)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsucc,efnnonum);//? idxname
      einf:=xnil
end;

procedure fsign;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then etop:=newreal(sign(cell[etop].fnum))
      else if (einf=xinteger) then etop:=newinteger(sign(cell[etop].inum))
      else if (einf=xobject)  then fn(idxsign)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsign,efnnonum);//? idxname
      einf:=xnil
end;

procedure fabs;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then etop:=newreal(abs(cell[etop].fnum))
      else if (einf=xinteger) then etop:=newinteger(abs(cell[etop].inum))
      else if (einf=xobject)  then fn(idxabs)
      else if (einf=xerror)   then {exit}
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idxabs)
      else etop:=newerror(idxabs,efnnonum);//? idxabs
      einf:=xnil
end;

procedure fneg;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then etop:=newreal(-cell[etop].fnum)
      else if (einf=xinteger) then etop:=newinteger(-cell[etop].inum)
      else if (einf=xobject)  then fn(idxneg)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idxneg)
      else etop:=newerror(idxneg,efnnonum);//? idxname
      einf:=xnil
end;

procedure fround;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newinteger(round(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxround,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then //(exit)
      else if (einf=xobject)  then fn(idxround)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxround,efnnonum);//? idxname
      einf:=xnil
end;

procedure ftrunc;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newinteger(trunc(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxtrunc,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then //(exit)
      else if (einf=xobject)  then fn(idxtrunc)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtrunc,efnnonum);//? idxname
      einf:=xnil
end;

//trunc
//int
//frac?

procedure fint;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(int(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxint,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then etop:=newreal(cell[etop].inum)
      else if (einf=xobject)  then fn(idxint)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxint,efnnonum);//? idxname
      einf:=xnil
end;

procedure ffrac;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(frac(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxfrac,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then etop:=newreal(0)
      else if (einf=xobject)  then fn(idxfrac)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxfrac,efnnonum);//? idxname
      einf:=xnil
end;

procedure ffloat;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xinteger) then etop:=newreal(cell[etop].inum)
      else if (einf=xreal)    then //(exit)
      else if (einf=xobject)  then fn(idxfloat)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxfloat,efnnonum);//? idxname
      einf:=xnil
end;

procedure froundto;
var num1,num2: extended; n: int64;
begin ee(idxroundto);  if (infix[etop]=xerror) then exit;
      einf:=infix[efun];
      if (einf=xobject) then begin op(idxroundto); exit end;
      if      (einf=xreal)    then num1:=cell[efun].fnum
      else if (einf=xinteger) then num1:=cell[efun].inum
      else begin etop:=newerror(idxroundto,eopnonum1); exit end;
      einf:=infix[etop];
      if      (einf=xreal)    then num2:=cell[etop].fnum
      else if (einf=xinteger) then num2:=cell[etop].inum
      else begin etop:=newerror(idxroundto,eopnonum2); exit end;
      try n:=round(num2)
      except etop:=newerror(idxroundto,eop2rounderror);//?
             exit
      end;
      if ((n < -20) or (n > 20)) then begin
         etop:=newerror(idxroundto,eop2notinrange);//?
         exit
      end;
      try etop:=newreal(roundto(num1,n))//round extra?
      except on ematherror do etop:=newerror(idxroundto,eopmatherror)
             else raise
      end;
      efun:=xnil;//?
      einf:=xnil
end;

// ------- [real] -------

procedure fexp;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(exp(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxexp,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxexp)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxexp,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fln;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(ln(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxln,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxln)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxln,efnnoreal);//? idxname
      einf:=xnil
end;

procedure flg;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(log10(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxlg,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxlg)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxlg,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fld;//log2 //ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(log2(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxld,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!?
      else if (einf=xobject)  then fn(idxld)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxld,efnnoreal);//? idxname
      einf:=xnil
end;

//log2?

procedure fsq;//ifprefix?
var f: double;  i: int64;
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try f:=cell[etop].fnum;
             etop:=newreal(f*f)
         except on ematherror do etop:=newerror(idxsq,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then
         try i:=cell[etop].inum;
             etop:=newinteger(i*i)
         except on ematherror do etop:=newerror(idxsq,efnmatherror)
                else raise
         end
      else if (einf=xobject)  then fn(idxsq)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsq,efnnonum);//? idxname
      einf:=xnil
end;

procedure fsqrt;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(sqrt(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxsqrt,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then
         try etop:=newreal(sqrt(cell[etop].inum))
         except on ematherror do etop:=newerror(idxsqrt,efnmatherror)
                else raise
         end
      else if (einf=xobject)  then fn(idxsqrt)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsqrt,efnnonum);//? idxname
      einf:=xnil
end;

// ------- trigonometric functions -------

procedure fpi;
begin if (infix[etop]=xerror) then exit;// provi
      etop:=newreal(pi)
end;

procedure f2pi;
begin if (infix[etop]=xerror) then exit;// provi
      etop:=newreal(pi+pi)
end;

procedure fsin;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(sin(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxsin,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxsin)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsin,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcos;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(cos(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcos,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcos)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcos,efnnoreal);//? idxname
      einf:=xnil
end;

procedure ftan;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(tan(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxtan,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxtan)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtan,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcot;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(cot(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcot,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcot)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcot,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fsec;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(sec(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxsec,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxsec)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsec,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcsc;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(csc(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcsc,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcsc)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcsc,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farcsin;
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arcsin(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarcsin,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarcsin)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarcsin,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farccos;
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arccos(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarccos,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarccos)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarccos,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farctan;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arctan(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarctan,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarctan)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarctan,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farctan2;
var num1,num2: double;
begin ee(idxarctan2);  if (infix[etop]=xerror) then exit;
      einf:=infix[efun];
      if (einf=xobject) then begin op(idxarctan2); exit end;// y als xobject ?
      if      (einf=xreal)    then num1:=cell[efun].fnum
      else if (einf=xinteger) then num1:=cell[efun].inum
      else begin etop:=newerror(idxarctan2,eopnonum1); exit end;
      einf:=infix[etop];
      if      (einf=xreal)    then num2:=cell[etop].fnum
      else if (einf=xinteger) then num2:=cell[etop].inum
      else begin etop:=newerror(idxarctan2,eopnonum2); exit end;
      try etop:=newreal(arctan2(num1,num2))
      except on EZeroDivide do etop:=newerror(idxarctan2,efdivbyzero);//???nötig
             on ematherror  do etop:=newerror(idxarctan2,eopmatherror)
             else raise
      end;
      efun:=xnil;//? ,position?
      einf:=xnil
end;
{
procedure farctan2;
begin ee(idxarctan2);
      //einf2:=infix[etop];
      if (infix[etop]<>xerror) then begin
         einf:=infix[efun];
         if      (einf=xreal)    then begin
            if (infix[etop]<>xreal) then etop:=newerror(idxarctan2,eopnoreal2)
            else try etop:=newreal(arctan2(cell[efun].fnum,cell[etop].fnum))
                 except on ematherror do etop:=newerror(idxarctan2,eopmatherror)
                        else raise
                 end
         end
       //else if (einf=xinteger) then begin ... end// oder wie bei fdiv machen?
         else if (einf=xobject)  then op(idxarctan2)
         //else if typeclass
         //ifxerror?
         else etop:=newerror(idxarctan2,eopnoreal1);
         einf:=xnil//
      end//else exit
end;
}
procedure farccot;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(0.5*pi-arctan(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarccot,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarccot)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarccot,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farcsec;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arccos(1/cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarcsec,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarcsec)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarcsec,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farccsc;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arcsin(1/cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarccsc,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarccsc)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarccsc,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fsinh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(sinh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxsinh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxsinh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsinh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcosh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(cosh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcosh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcosh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcosh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure ftanh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(tanh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxtanh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxtanh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxtanh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcoth;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(1/tanh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcoth,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcoth)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcoth,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fsech;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(1/cosh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxsech,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxsech)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxsech,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fcsch;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(1/sinh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxcsch,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxcsch)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxcsch,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farsinh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arcsinh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarsinh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarsinh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarsinh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure farcosh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arccosh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxarcosh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxarcosh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxarcosh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fartanh;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(arctanh(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxartanh,efnmatherror)
                else raise
         end
      //else if (einf=xinteger) thenbeginend
      else if (einf=xobject)  then fn(idxartanh)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxartanh,efnnoreal);//? idxname
      einf:=xnil
end;

procedure fdeg;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(radtodeg(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxdeg,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then
         try etop:=newreal(radtodeg(cell[etop].inum))
         except on ematherror do etop:=newerror(idxdeg,efnmatherror)
                else raise
         end
      else if (einf=xobject)  then fn(idxdeg)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxdeg,efnnonum);//? idxname
      einf:=xnil
end;

procedure frad;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newreal(degtorad(cell[etop].fnum))
         except on ematherror do etop:=newerror(idxrad,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then
         try etop:=newreal(degtorad(cell[etop].inum))
         except on ematherror do etop:=newerror(idxrad,efnmatherror)
                else raise
         end
      else if (einf=xobject)  then fn(idxrad)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxrad,efnnonum);//? idxname ,num?
      einf:=xnil
end;

procedure frgb;//?
begin//
end;

procedure fhex;//ifprefix?
begin einf:=infix[etop];
      if      (einf=xreal)    then
         try etop:=newstring(inttohex(round(cell[etop].fnum),0))
         except on ematherror do etop:=newerror(idxhex,efnmatherror)
                else raise
         end
      else if (einf=xinteger) then etop:=newstring(inttohex(cell[etop].inum,0))
      else if (einf=xobject)  then fn(idxhex)
      else if (einf=xerror)   then //(exit)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idx)
      else etop:=newerror(idxhex,efnnonum);//? idxname
      einf:=xnil
end;

// ------- math initialization -------

procedure initmathidents;
begin //
      idxadd:=newindex('add');
      idxsub:=newindex('sub');
      idxmul:=newindex('mul');
      idxdiv:=newindex('div');
      idxpow:=newindex('pow');
      idxidiv:=newindex('idiv');
      idximod:=newindex('imod');
      idxpred:=newindex('pred');
      idxsucc:=newindex('succ');
      idxsign:=newindex('sign');
      idxabs:=newindex('abs');
      idxneg:=newindex('neg');
      idxround:=newindex('round');
      idxtrunc:=newindex('trunc');
      idxint:=newindex('int');
      idxfrac:=newindex('frac');
      idxfloat:=newindex('float');
      idxroundto:=newindex('roundto');// --> float
      idxexp:=newindex('exp');
      idxln:=newindex('ln');
      idxlg:=newindex('lg');
      idxld:=newindex('ld');
      idxsq:=newindex('sq');
      idxsqrt:=newindex('sqrt');
      idxsin:=newindex('sin');
      idxcos:=newindex('cos');
      idxtan:=newindex('tan');
      idxcot:=newindex('cot');
      idxsec:=newindex('sec');
      idxcsc:=newindex('csc');
      idxarcsin:=newindex('arcsin');
      idxarccos:=newindex('arccos');
      idxarctan:=newindex('arctan');
      idxarctan2:=newindex('arctan2');
      idxarccot:=newindex('arccot');
      idxarcsec:=newindex('arcsec');
      idxarccsc:=newindex('arccsc');
      idxsinh:=newindex('sinh');
      idxcosh:=newindex('cosh');
      idxtanh:=newindex('tanh');
      idxcoth:=newindex('coth');
      idxsech:=newindex('sech');
      idxcsch:=newindex('csch');
      idxarsinh:=newindex('arsinh');
      idxarcosh:=newindex('arcosh');
      idxartanh:=newindex('artanh');
      idxdeg:=newindex('deg');
      idxrad:=newindex('rad');
      idxhex:=newindex('hex');
      //
end;

procedure initmathprims;
begin //
      initmathidents;
      //
      newidentproc('+',@fadd);
      newidentproc('-',@fsub);
      newidentproc('*',@fmul);
      newidentproc('/',@fdiv);
      newidentproc('^',@fpow);//power
      newidentproc('idiv',@fidiv);
      newidentproc('imod',@fimod);
      newidentproc('pred',@fpred);
      newidentproc('succ',@fsucc);
      newidentproc('sign',@fsign);
      //newidentproc(,f);
      newidentproc('abs',@fabs);
      idneg:=newidentproc('neg',@fneg);
      cell[xneg].value:=cell[idneg].value;
      newidentproc('round',@fround);
      newidentproc('trunc',@ftrunc);
      newidentproc('int',@fint);
      newidentproc('frac',@ffrac);
      newidentproc('float',@ffloat);
      newidentproc('roundto',@froundto);//position?
      newidentproc('exp',@fexp);
      newidentproc('ln',@fln);
      newidentproc('lg',@flg);
      newidentproc('ld',@fld);
      newidentproc('sq',@fsq);
      newidentproc('sqrt',@fsqrt);
      newidentproc('pi',@fpi);
      newidentproc('2pi',@f2pi);
      newidentproc('sin',@fsin);
      newidentproc('cos',@fcos);
      newidentproc('tan',@ftan);
      newidentproc('cot',@fcot);
      newidentproc('sec',@fsec);
      newidentproc('csc',@fcsc);
      newidentproc('arcsin',@farcsin);
      newidentproc('arccos',@farccos);
      newidentproc('arctan',@farctan);
      newidentproc('arctan2',@farctan2);
      newidentproc('arccot',@farccot);
      newidentproc('arcsec',@farcsec);
      newidentproc('arccsc',@farccsc);
      newidentproc('sinh',@fsinh);
      newidentproc('cosh',@fcosh);
      newidentproc('tanh',@ftanh);
      newidentproc('coth',@fcoth);
      newidentproc('sech',@fsech);
      newidentproc('csch',@fcsch);
      newidentproc('arsinh',@farsinh);
      newidentproc('arcosh',@farcosh);
      newidentproc('artanh',@fartanh);
      newidentproc('deg',@fdeg);
      newidentproc('rad',@frad);
      newidentproc('hex',@fhex);
      //
end;

end.

