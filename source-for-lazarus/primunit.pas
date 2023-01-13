unit primunit;

{$mode objfpc}{$H+}

interface

uses //Classes,//?
     SysUtils,//exception
     typeunit;//newidentproc ,für legacy code;

procedure initprimitives;
function newidentproc(s: ustring;p: fproc): cardinal;
procedure op(idx: cardinal);
procedure fn(idx: cardinal);
//procedure iop(idx: cardinal);
//procedure ifn(idx: cardinal);
procedure ee(eid: cardinal);

implementation

uses apiunit, vmunit,
serveunit,combiunit,boolunit,mathunit,stringunit,jsonunit,sequnit;//noch mal neu

var idxundef: cardinal = xnil;
    idxhead: cardinal = xnil;
    idxtail: cardinal = xnil;
    idxinfix: cardinal = xnil;
    idxprop: cardinal = xnil;
    idxterm: cardinal = xnil;
    idxarg: cardinal = xnil;
    idxapp: cardinal = xnil;
    idxee: cardinal = xnil;
    idxswee: cardinal = xnil;
    idxcomma: cardinal = xnil;
    idxiget: cardinal = xnil;
    idxiput: cardinal = xnil;
    idxop: cardinal = xnil;
    idxname: cardinal = xnil;
    idxbody: cardinal = xnil;
    idxit: cardinal = xnil;
    //
    //ididy: cardinal = xnil;
    idterm: cardinal = xnil;

// ------------------
// ----- legacy -----
// ------------------
{
procedure iop(idx: cardinal);//wenn itype...
begin epush(prop(efun,xcons,prop(etop,xcons,xnil)));
      iget(idx,infix[efun],idx);
      //ifexc? (eptr)
      if (etop=xundef) then begin dec(eptr); etop:=newerror(idx,eoselnotfound+tovalue(idx));exit end;//eoselnotfound?
      efun:=etop;
      //...
      etop:=estack[eptr];  dec(eptr);
      equit:=false//
end;
}

// --------------------------- oop service functions ---------------------------

// ------------------
// ----- legacy -----
// ------------------
procedure op(idx: cardinal);//wenn xobject    //für ee und strictee
begin epush(prop(efun,xcons,prop(etop,xcons,xnil)));
      apiget(idx,cell[efun].cap,idx);
      //ifxexc? (eptr)
      if (etop=xundef) then begin dec(eptr); etop:=newerror(idx,eselnotfound+tovalue(idx));exit end;
      efun:=etop;
      //etop:=prop(efun,xcons,prop(etop,xcons,xnil));
      //etop:=cref;
      etop:=estack[eptr];  dec(eptr);
      equit:=false//
end;

// ------------------
// ----- legacy -----
// ------------------
procedure swop(idx: cardinal);
begin epush(prop(etop,xcons,prop(efun,xcons,xnil)));
      apiget(idx,cell[etop].cap,idx);
      //ifexc? (...)
      if (etop=xundef) then begin dec(eptr); etop:=newerror(idx,eselnotfound+tovalue(idx));exit end;
      efun:=etop;
      //...
      etop:=estack[eptr];  dec(eptr);
      equit:=false
      //
end;

// ------------------
// ----- legacy -----
// ------------------
procedure fn(idx: cardinal);//wenn xobject
begin epush(etop);//
      apiget(idx,cell[etop].cap,idx);
      //ifxexc? (eptr)
      if (etop=xundef) then begin dec(eptr); etop:=newerror(idx,eselnotfound+tovalue(idx)); exit end;
      efun:=etop;
      //...
      //...
      etop:=estack[eptr];  dec(eptr);
      equit:=false//
end;

// ------------------
// ----- legacy -----
// ------------------
{
procedure ifn(idx: cardinal);//...
begin epush(etop);
      iget(idx,infix[etop],idx);
      //ifexc? (eptr)
      if (etop=xundef) then begin dec(eptr); etop:=newerror(idx,eoselnotfound+tovalue(idx));exit end;//eosel???
      efun:=etop;
      //...
      //...
      etop:=estack[eptr];  dec(eptr);
      equit:=false//
end;
}

// --------------------- eval-eval: infix operator support ---------------------

// bitte noch testen!!!!!!!!!!!!!!!!!!!!!!!!!
//ungeprüft übernommen von femtoproject // noch mal neu machen!
procedure ee(eid: cardinal);//((aa ee bb cc dd _s) _combine .. xx)//function ee?
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         einf:=cell[etop].arg;//eref?
         if (infix[einf]=xerror) then begin etop:=einf; exit end;
         epush(etop);
         etop:=cell[etop].term;
         //ifxerror?
         if (infix[etop]<xlimit) then begin dec(eptr);
                                            etop:=newerror(eid,einfnoprop);
                                            exit
                                      end;
         efun:=cell[etop].first;
         etop:=einf;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;
         if (infix[etop]=xerror) then begin dec(eptr); exit end;
         einf:=estack[eptr];
         estack[eptr]:=etop;
         etop:=cell[einf].arg;
         efun:=cell[cell[einf].term].rest;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;
         if (infix[etop]=xerror) then begin dec(eptr); exit end;
         efun:=estack[eptr];  dec(eptr)
      end// efun & etop(xerror)
      // so lassen oder besser ohne xcons-Abfragung?
      else if (einf=xcons)    then begin
         efun:=cell[etop].first;
         etop:=cell[etop].rest;
         if (infix[etop]<>xcons) then begin etop:=newerror(eid,efnconsexpect);
                                            exit
                                      end;
         etop:=cell[etop].first
      end// efun & etop(xerror)
      else if (einf=xerror)   then //(exit)
      else etop:=newerror(eid,'provisorium in ee');//??? ,ifxexc&newexc//
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
{procedure eepre(eid: cardinal);// (xx _combi aa ee bb cc dd _s)
begin repeat einf:=infix[etop];
             if (einf=xcombine)    then begin
                efun:=cell[etop].arg;
                if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer?
                epush(efun);//xx
                etop:=cell[etop].term;
                //einf:=infix[etop];
                //if (einf<xlimit) then//in der repeat-loop abfragen?
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then break
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then begin dec(eptr); exit end
                       else begin dec(eptr);
                                  etop:=newerror(eid,einfnoprop);
                                  exit
                            end
                until false;
                efun:=cell[etop].first;//opd1
                epush(cell[etop].rest);//opd2
                etop:=estack[eptr-1];  //xx
                repeat eval;  if (ecall<>0) then proc[ecall]
                until equit;//ifxlazy? , _link...
                if (infix[etop]=xerror) then begin dec(eptr,2); exit end;
                efun:=estack[eptr];  dec(eptr);
                einf:=estack[eptr];
                estack[eptr]:=etop;
                etop:=einf;
                repeat eval;  if (ecall<>0) then proc[ecall]
                until equit;//ifxlazy? , _link...
                if (infix[etop]=xerror) then begin dec(eptr); exit end;
                efun:=estack[eptr];  dec(eptr);
                exit// efun & etop(xexc)
             end
             else if (einf=xcons) then begin
                epush(cell[etop].first);
                etop:=cell[etop].rest;
                //einf:=infix[etop];
                //if (einf<xlimit) then
                repeat einf:=infix[etop];
                       if      (einf=xcons)  then break
                       //else if (einf=xlink)  then etop:=cell[etop].value
                       //else if (einf=xlazy)  then delazy
                       else if (einf=xerror) then begin dec(eptr); exit end
                       geschweifteauf else if (einf<=xmaxatom) then begin
                               dec(eptr);
                               etop:=newexc(eid,einfnoprop);
                               exit
                            end geschweiftezu
                       else begin dec(eptr);
                                  etop:=newerror(eid,efnconsexpect);
                                  exit
                            end
                until false;
                //if (einf<>xcons) then ;// in der repeat-loop abfragen?
                etop:=cell[etop].first;
                efun:=estack[eptr];  dec(eptr);
                exit// efun & etop(xexc)
             end
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit
             else provisorium('provisorium in ee.')//??? newexc?+exit // _combi oder xcons expected
      until false
end;}

// ----------------------- strict-by-default primitives ------------------------

procedure fundef;
begin if (infix[etop]=xerror) then //(exit)
      else etop:=newerror(idxundef,efuncundef)
end;

procedure fid;
begin //etop:=etop
end;

// bei head, tail, top, pop wenn etop<xlimit dann xnil (außer xerror)

// keine typklassen, zu langsam
procedure fhead;
begin einf:=infix[etop];
      if (einf<xlimit) then begin if (einf<>xerror) then etop:=xnil end
      else if (einf=xobject) then fn(idxhead)
      //else if ((infix[einf]=xident) and (cell[einf].value<>xreserve)) then
      //   ifn(idxhead) {;exit}
      //else etop:=newerror(idxhead,efnnonum1)el
      else etop:=cell[etop].first;
      einf:=xnil
end;

procedure ftail;
begin einf:=infix[etop];
      if (einf<xlimit) then begin if (einf<>xerror) then etop:=xnil end
      else if (einf=xobject) then fn(idxtail)
      else etop:=cell[etop].rest;
      einf:=xnil
end;

procedure finfix;
begin einf:=infix[etop];
      if (einf=xobject) then fn(idxinfix)
      else if (einf<>xerror) then etop:=einf;
      einf:=xnil
end;

procedure fprop;//ifxobject...............................
begin if (infix[etop]<>xcons) then begin
         if (infix[etop]<>xerror) then etop:=newerror(idxprop,efnconsexpect);
         exit
      end;
      with cell[etop] do begin efun:=first; etop:=rest end;
      if (infix[etop]<>xcons) then begin//ifxerror?
         etop:=newerror(idxprop,efnconsexpect); exit
      end;
      with cell[etop] do begin einf:=first; etop:=rest end;
      //infixsafetest! (_xerror?)
      if (infix[etop]<>xcons) then begin//ifxerror?
         etop:=newerror(idxprop,efnconsexpect); exit
      end;
      etop:=cell[etop].first;
      if (einf<xlimit) then if (einf<>xerror) then begin// <-xerror?
    //if ((einf=xstring) or (einf=xarray)) then begin
         etop:=newerror(idxprop,efnnosafeinfix); exit
      end;
      //ifxobject?
      etop:=prop(efun,einf,etop)
      //efun:=xnil; einf:=xnil
end;

procedure ftop;
begin if (infix[etop]<xlimit) then begin
         if (infix[etop]<>xerror) then etop:=xnil
      end
      else etop:=cell[etop].first
end;

procedure fpop;
begin if (infix[etop]<xlimit) then begin
         if (infix[etop]<>xerror) then etop:=xnil
      end
      else etop:=cell[etop].rest
end;

procedure ftag;//typeof?
begin einf:=infix[etop];
      if (einf<>xerror) then etop:=einf;
      einf:=xnil
end;

procedure fterm;
begin if (infix[etop]=xcombine) then etop:=cell[etop].term
      else if (infix[etop]<>xerror) then etop:=newerror(idxterm,efnnocombine)
end;

procedure farg;
begin if (infix[etop]=xcombine) then etop:=cell[etop].arg
      else if (infix[etop]<>xerror) then etop:=newerror(idxarg,efnnocombine)
end;

procedure fbox;
begin//
end;

procedure funbox;
begin//
end;

procedure fcap;//?
begin//
end;

//actbox;

procedure fapply;
begin ee(idxapp);
      if (infix[etop]<>xerror) then//efun,etop,
         equit:=false
end;

procedure fee;
begin ee(idxee);
      if (infix[etop]<>xerror) then begin
         //ifxobject?
         etop:=prop(efun,xcons,prop(etop,xcons,xnil));
         efun:=xnil
      end
end;

procedure fswee;// ,swap?
begin ee(idxswee);
      if (infix[etop]<>xerror) then begin
         //ifxobject?
         etop:=prop(etop,xcons,prop(efun,xcons,xnil));
         efun:=xnil
      end//else error
end;

// ----------------------
// ------- legacy -------
// ----------------------
procedure fcomma;//strictes comma (objects)
begin ee(idxcomma);  if (infix[etop]=xerror) then exit;//strictee???
      if (infix[etop]=xobject) then begin swop(idxcomma); exit end;//ifxobject  ,swoop
      //if liste?
      etop:=prop(efun,xcons,etop);
      efun:=xnil//
end;

procedure figet;//ifprefix
begin ee(idxiget);// efun & etop(xerror)
      if (infix[etop]<>xerror) then begin
         if (infix[efun]=xobject) then op(idxiget)
         else apiget(idxiget,efun,etop);//ifundef ,ifxerror   // bitte apiget
      end//else exit
end;

// test: '(10 aa 20 bb 30 cc 40 dd) iput 'x,'y,
procedure fiput;//ifprefix
begin ee(idxiput);
      if (infix[etop]=xerror) then exit;// ?...
      if (infix[efun]=xobject) then op(idxiput)
      else begin
         if (infix[etop]<>xcons) then begin
            if (infix[etop]<>xerror) then etop:=newerror(idxiput,eopnocons);
            exit
         end;
         with cell[etop] do begin einf:=first; etop:=rest end;
         if (infix[etop]<>xcons) then begin//ifxerror?
            etop:=newerror(idxiput,eopnocons); exit
         end;
         etop:=cell[etop].first;
         apiput(efun,einf,etop)//? noch mal untersuchen
      end//
end;

// ----------------------
// ------- legacy -------
// ----------------------
procedure fop;// ((aaarg _combi oabc get xx yy zz _s) _combi sel eeop aa bb cc _s)
begin repeat einf:=infix[etop];
         if (einf=xcombine)    then begin
            epush(cell[etop].term);// (sel eeop aa bb cc _s)
            etop:=cell[etop].arg;
            //ifxexc?
            ee(idxop);// efun & etop(xexc) // ee oder strictee???
            if (infix[etop]=xerror)  then begin dec(eptr); exit end;
            if (infix[efun]=xobject) then begin
               einf:=estack[eptr];
               estack[eptr]:=prop(efun,xcons,prop(etop,xcons,xnil));
               epush(cell[efun].cap);
               etop:=einf;
               repeat einf:=infix[etop];
                      if      (einf>=xlimit) then break
                      //else if (einf=xlink)   then etop:=cell[etop].value
                      //else if (einf=xlazy)   then delazy
                      else if (einf=xerror)  then begin dec(eptr,2); exit end//exit
                      else begin dec(eptr,2); etop:=newerror(idxop,einfnoprop); exit end
               until false;
               etop:=cell[etop].first;//etop von einf
               efun:=estack[eptr];
               //servprint(tovalue(efun)+' // efun');//for test
               estack[eptr]:=etop;
               apiget(idxop,efun,etop);
               if (etop=xundef) then begin etop:=newerror(idxop,eselnotfound+tovalue(estack[eptr])); dec(eptr,2); exit end;
               efun:=etop;
               etop:=estack[eptr-1];
               //etop:=prop(efun,xcons,prop(etop,xcons,xnil));//for test
               //provisorium('feeop object: noch nicht bearbeitet...');
               dec(eptr,2);
               equit:=false;  exit
            end
            else begin
               einf:=estack[eptr];
               estack[eptr]:=prop(efun,xcons,prop(etop,xcons,xnil));
               etop:=einf;
               repeat einf:=infix[etop];
                      if      (einf>=xlimit) then break
                      //else if (einf=xlink)   then etop:=cell[etop].value
                      //else if (einf=xlazy)   then delazy
                      else if (einf=xerror)  then begin dec(eptr); exit end//exit
                      else begin dec(eptr); etop:=newerror(idxop,einfnoprop); exit end
               until false;
               efun:=cell[etop].rest;
               etop:=estack[eptr];  dec(eptr);
               //etop:=prop(efun,xcons,prop(etop,xcons,xnil));//for test
               equit:=false;  exit
            end
            //d;
            //
            {efun:=cell[etop].arg;
            if (infix[efun]=xexc) then begin etop:=efun; exit end;//genauer?
            etop:=cell[etop].term;
            //einf:=infix[etop];
            //if (einf<xlimit) then//in der repeat-loop abfragen?
            repeat einf:=infix[etop];
                   if (einf>=xlimit) then break
                   else if (einf=xlink) then etop:=cell[etop].value
                   else if (einf=xlazy) then delazy
                   else if (einf=xexc)  then exit
                   else begin etop:=newexc(idequote,einfnoprop); exit end
            until false;
            etop:=cell[etop].first;}
            //dec(eptr);
            //exit
         end
         //else if (einf=xlink)  then etop:=cell[etop].value
         //else if (einf=xlazy)  then delazy
         else if (einf=xerror) then exit
         else provisorium('provisorium in feeop')
      until false//
end;

procedure fswop;
begin;end;

procedure ffn;
begin;end;

procedure fcb;//combinator
begin;end;

procedure fdg;//delegate
begin;end;

procedure fname;
begin einf:=infix[etop];
      if      (einf>=xlimit) then etop:=cell[etop].first
      else if (einf=xident)  then etop:=cell[etop].pname
      else if (einf=xindex)  then etop:=cell[etop].rname
      else if (einf=xprefix) then etop:=cell[etop].pname
      else if (einf=xnull)   then etop:=cell[etop].first
      else if (einf=xerror)  then //exit
      else etop:=newerror(idxname,efnunabletype);
      einf:=xnil
end;

procedure fbody;//vergleichen!
begin einf:=infix[etop];
      if      (einf>=xlimit) then etop:=cell[etop].rest
      else if (einf=xident)  then etop:=cell[etop].value
      else if (einf=xindex)  then etop:=newinteger(cell[etop].rnum)
      else if (einf=xprefix) then etop:=cell[etop].value
      else if (einf=xnull)   then etop:=cell[etop].rest
      else if (einf=xerror)  then //exit
      else etop:=newerror(idxbody,efnunabletype);
      einf:=xnil
end;

procedure faddress;//provi(?)
begin if (infix[etop]=xerror) then exit;
      etop:=newreal(etop)//newint?
end;

procedure fout;//für debugging: _error auch ausgeben
begin serveprint(tovalue(etop))//
end;

procedure fidentlist;//provi(?)
begin if (infix[etop]=xerror) then exit;
      etop:=identlist//
end;

procedure findexdict;//provi(?)
begin if (infix[etop]=xerror) then exit;
      etop:=indexdict//
end;

procedure fmaxcell;//provi(?)
begin if (infix[etop]=xerror) then exit;
      etop:=newinteger(maxcell)
end;

procedure fraise;
begin raise exception.create(tovalue(etop))
end;

procedure fgc;
begin gc(xnil,xnil,xnil)// etop:=etop
end;

procedure ftermoarg;// provi
begin farg;
      fterm
end;

procedure fit;
begin apiget(idxit,etop,xit)// if_undef?
end;

procedure fpointersize;//provi(?)
begin if (infix[etop]=xerror) then exit;
      etop:=newinteger(sizeof(pcardmem)*8)
end;

// ----------------- initialization of the runtime primitives ------------------

var pcounter: int64;

function newidentproc(s: ustring;p: fproc): cardinal;
begin pcounter:=pcounter-1;
      if (pcounter<minproc) then raise exception.create(enoprocmemerror);//ename?
      newidentproc:=newident(s,newinteger(pcounter));
      proc[pcounter]:=p
end;

procedure initprimidents;
begin //
      idxundef:=newindex('undef');
      idxhead:=newindex('head');
      idxtail:=newindex('tail');
      idxinfix:=newindex('infix');
      idxprop:=newindex('prop');
      idxterm:=newindex('term');
      idxarg:=newindex('arg');
      idxapp:=newindex('app');
      idxee:=newindex('ee');
      idxswee:=newindex('swee');
      idxcomma:=newindex('comma');
      idxiget:=newindex('iget');
      idxiput:=newindex('iput');
      idxop:=newindex('op');
      idxname:=newindex('name');
      idxbody:=newindex('body');
      idxit:=newindex('it');
      //
end;

procedure initprimitives;
var i: longint;
begin for i:=minproc to -1 do proc[i]:=@fundef;// to -1 (?)
      pcounter:=0;
      //
      initprimidents;
      //
      newidentproc('undef',@fundef);
      //ididy:=
      newidentproc('id',@fid);//identity
      //cell[xid].value:=cell[ididy].value;
      newidentproc('head',@fhead);
      newidentproc('tail',@ftail);
      newidentproc('infix',@finfix);
      newidentproc('prop',@fprop);
      newidentproc('top',@ftop);
      newidentproc('pop',@fpop);
      newidentproc('tag',@ftag);//tag?
      //newidentproc('typeof',ftag);//ftypeof?
      idterm:=newidentproc('term',@fterm);
      //cell[xcons].value:=cell[idterm].value;// der klasse vorrang gelassen.
      cell[xalter].value:=cell[idterm].value;//alternal?
      cell[xobject].value:=cell[idterm].value;
      newidentproc('arg',@farg);
      newidentproc('app',@fapply);
      newidentproc('ee',@fee);
      newidentproc('swee',@fswee);
      //
      newidentproc(',',@fcomma);
      //
      initcombiprims;
      initboolprims;
      initmathprims;
      initstringprims;//position?
      initjsonprims;
      initseqprims;
      //
      //
      //fis
      //
      newidentproc('iget',@figet);
      newidentproc('iput',@fiput);
      newidentproc('op',@fop);
      newidentproc('name',@fname);
      newidentproc('body',@fbody);
      newidentproc('address',@faddress);
      newidentproc('out',@fout);//für debugging
      newidentproc('identlist',@fidentlist);
      newidentproc('indexdict',@findexdict);
      newidentproc('maxcell',@fmaxcell);
      newidentproc('raise',@fraise);// name?
      newidentproc('gc',@fgc);
      newidentproc('termoarg',@ftermoarg);         // nicht mehr nötig!
      newidentproc('it',@fit);//system-result
      newidentproc('pointersize',@fpointersize);
      //
end;

end.


// GNU Lesser General Public License v2.1

