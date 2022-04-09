unit combiunit;//ok

{$mode objfpc}{$H+}

interface

uses //Classes,//?
     SysUtils;//exception wieder raus nehmen!
     //typeunit;

procedure initcombiprims;

implementation

uses apiunit, vmunit, primunit;

var //
    idxquote: cardinal = xnil;
    idxapplic: cardinal = xnil;
    idxcompose: cardinal = xnil;
    idxassign: cardinal = xnil;
    idxtry: cardinal = xnil;
    idxcond: cardinal = xnil;
    //
    idk: cardinal = xnil;
    ido: cardinal = xnil;

// ------- legacy -------
//const einfnoprop: es         = 'infix is no prop-syntax.';//???;doppelt

// ------- infix-combinators -------
//
// higher-order Funktionen (Bezug auf eval)
//

// bitte noch testen!!!!!!!!!!!!!!!!!!!!!!!!!
//ungeprüft übernommen von femtoproject // noch mal neu machen!
procedure fquote;//constant
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         efun:=cell[etop].arg;
         if (infix[efun]=xerror) then begin etop:=efun; exit end;
         etop:=cell[etop].term;
         //ifxerror?
         if (infix[etop]<xlimit) then begin etop:=newerror(idxquote,einfnoprop);
                                            exit
                                      end;
         etop:=cell[etop].first
      end
      else if (einf=xerror)   then //(exit)
      else provisorium('provisorium bei fquote');//
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
{procedure fquotepre;//constant   // (xx _combi aa quote bb cc dd _s)
begin repeat einf:=infix[etop];
             if (einf=xcombine)    then begin
                efun:=cell[etop].arg;
                if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer?
                etop:=cell[etop].term;
                //einf:=infix[etop];
                //if (einf<xlimit) then//in der repeat-loop abfragen?
                repeat einf:=infix[etop];
                       if (einf>=xlimit) then break
                       //else if (einf=xlink)  then etop:=cell[etop].value
                       //else if (einf=xlazy)  then delazy
                       else if (einf=xerror) then exit
                       else begin etop:=newerror(idxquote,einfnoprop); exit end
                until false;
                etop:=cell[etop].first;
                exit
             end
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit
             else provisorium('provisorium in fquote')
      until false
end;}

procedure fapplicdepr;//application --> ptype(?)
begin {provisorium('provisorium für fapplic (deprecation)')}
end;

// applic für closed-Fall doch zu gebrauchen und für lift
// femto project applic?

//bitte noch testen!!!!!!!!!!!!!!!!!!!!!!
//ungeprüft übernommen von FemtoProjekt // bitte noch mal neu machen!
procedure fapplic;//application
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         efun:=cell[etop].arg;
         if (infix[efun]=xerror) then begin etop:=efun; exit end;
         etop:=cell[etop].term;
         //ifxerror?
         if (infix[etop]<xlimit) then begin etop:=newerror(idxapplic,einfnoprop);
                                            exit
                                      end;
         efun:=cell[etop].first;
         //ifxerror?
         etop:=cell[etop].rest;
         //ifxerror?
         if (infix[etop]<xlimit) then begin etop:=newerror(idxapplic,einfnoprop);
                                            exit
                                      end;
         etop:=cell[etop].first;
         equit:=false
      end
      else if (einf=xerror)   then //(exit)
      else provisorium('provisorium bei fapplic');//xexc+etc
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
{procedure fapplicpre;//application   // ifprefix?
begin repeat einf:=infix[etop];
             if (einf=xcombine)    then begin
                efun:=cell[etop].arg;
                if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer?
                etop:=cell[etop].term;
                //einf:=infix[etop];
                //if (einf<xlimit) then//in der repeat-loop abfragen?
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then break
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then exit
                       else begin etop:=newerror(idxapplic,einfnoprop); exit end
                until false;
                epush(cell[etop].first);
                //ifxexc?
                etop:=cell[etop].rest;
                //einf:=infix[etop];
                //if (einf<xlimit) then//in der repeat-loop abfragen?
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then break
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then begin dec(eptr); exit end
                       //ifxnull
                       else begin dec(eptr);
                                  etop:=newerror(idxapplic,einfnoprop);
                                  exit
                            end
                until false;
                etop:=cell[etop].first;
                //ifxexc???   //zum testen der anderen Funcs erstmal so lassen
                efun:=estack[eptr];  dec(eptr);
                equit:=false;
                exit
             end
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit
             else provisorium('provisorium in fapplic')
      until false
end;}

// bitte noch testen!!!!!!!!!!!!!!!!!!!!!!!!!
//ungeprüft übernommen von femtoproject // noch mal neu machen!
procedure fcompose;//xcompose ,kettenregel ,(a)symetrisch ,seriell
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         einf:=cell[etop].arg;//eref? ,einf(?)
         if (infix[einf]=xerror) then begin etop:=einf; exit end;
         etop:=cell[etop].term;
         if (infix[etop]<xlimit) then begin etop:=newerror(idxcompose,einfnoprop);
                                            exit
                                      end;
         epush(cell[etop].first);//ausbreiten!!!
         efun:=cell[etop].rest;
         etop:=einf;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;
         //wie bei raise exc... ?//
         if (infix[etop]=xerror) then begin dec(eptr); exit end;
         efun:=estack[eptr];  dec(eptr);
         equit:=false
      end
      else if (einf=xerror)   then //(exit)
      else provisorium('provisorium bei fcompose.');//
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
// mal bei folge-projekt von el parso oder projit gucken (?)
{procedure fcomposepre;//xcompose ,kettenregel ,(a)symetrisch ,seriell
begin repeat einf:=infix[etop];
             if (einf=xcombine)    then begin
                efun:=cell[etop].arg;
                if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer?
                epush(efun);
                etop:=cell[etop].term;
                //einf:=infix[etop];
                //if (einf<xlimit) then//in der repeat-loop abfragen?
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then break
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then begin dec(eptr); exit end
                       else begin dec(eptr);
                                  etop:=newerror(idxcompose,einfnoprop);
                                  exit
                            end
                until false;
                einf:=estack[eptr];
                estack[eptr]:=cell[etop].first;
                efun:=cell[etop].rest;
                etop:=einf;
                repeat eval;  if (ecall<>0) then proc[ecall]
                until equit;
                //wie bei raise exc... ?
                //ifxlazy??? , _link ...     <-- equit->eval
                if (infix[etop]=xerror) then begin dec(eptr); exit end;
                efun:=estack[eptr];  dec(eptr);
                equit:=false;
                exit//
             end
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit
             else provisorium('provisorium in fcompose.')
      until false
end;}

// ----------------------
// ------- legacy -------
// ----------------------
// _error-Typ verwenden statt raise exception...
//
//besser auf xcons in den actual parametern achten?
//fehlerbereiche achten (!)
procedure fassign;// ((10 ; 20 ; 30 ;) _combi ff <- aa ; bb ; cc ;)

    procedure assignraise;
    begin raise exception.create(tovalue(etop))
    end;

    //procedure raiselambdatypemismatchx;
    //begin raise exception.create(etypemismatch)//näher ausführen
    //end;

begin repeat einf:=infix[etop];
         if (einf=xcombine)    then begin
            efun:=cell[etop].arg;
            if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer? ,assignraise?
            epush(efun);//xx
            etop:=cell[etop].term;
            repeat einf:=infix[etop];
                   if      (einf>=xlimit) then break
                   //else if (einf=xlink)   then etop:=cell[etop].value
                   //else if (einf=xlazy)   then delazy
                   else if (einf=xerror)  then begin dec(eptr); exit end//assignraise?
                   else begin dec(eptr);
                              etop:=newerror(idxassign,etermnoprop);
                              exit//assignraise?
                        end
            until false;
            efun:=estack[eptr];
            estack[eptr]:=cell[etop].first;//ff
            epush(efun);//xx
            etop:=cell[etop].rest;
            epush(etop);//vars
            epush(xnil);//propseg(dict)
            repeat einf:=infix[etop];
               if      (einf=xnull)   then break
               else if (einf=xcons)   then begin
                  estack[eptr-1]:=etop;
                  etop:=estack[eptr-2];
                  repeat einf:=infix[etop];
                     {if      (einf=xcons)   then begin
                        estack[eptr]:=prop( cell[etop].first,
                                            cell[estack[eptr-1]].first,
                                            estack[eptr] );
                        break
                     end
                     else } //auf xcons testen!
                     if (einf>=xlimit)     then begin
                        estack[eptr]:=prop( cell[etop].first,
                                            cell[estack[eptr-1]].first,
                                            estack[eptr] );//nach unten schieben? um begin end einzusparen
                        break
                     end
                     //else if (einf=xlink)  then etop:=cell[etop].value
                     //else if (einf=xlazy)  then delazy
                     else if (einf=xerror) then begin dec(eptr,4); exit end//assignraise?
                     else begin dec(eptr,4);
                                etop:=newerror(idxassign,eactualnoformal);
                                assignraise//exit
                          end//
                  until false;
                  estack[eptr-2]:=cell[etop].rest;
                  etop:=cell[estack[eptr-1]].rest
               end
               else if (einf>=xlimit) then begin
                  estack[eptr-1]:=etop;
                  etop:=estack[eptr-2];
                  repeat einf:=infix[etop];
                     {if      (einf=xcons)   then begin
                        estack[eptr-2]:=cell[etop].rest;
                        etop:=cell[etop].first;
                        einf:=estack[eptr-1];
                        efun:=infix[einf];
                        estack[eptr]:=prop(etop,cell[einf].first,estack[eptr]);
                        repeat eval;  if (ecall<>0) then proc[ecall]
                        until equit;
                        if      (etop=xtrue) then break//etop:=estack[eptr-2]?
                        else if (etop=xfalse) then begin
                           dec(eptr,4);
                           etop:=newexc(ideassign,etypemismatch);//genauer!
                           assignraise
                        end
                        //en assignlambdatypemismatch
                        else if (infix[etop]=xexc) then begin dec(eptr,4);
                                                              assignraise//exit//?
                                                        end
                        else begin dec(eptr,4);
                                   etop:=newexc(ideassign,eformalinfnobool);
                                   assignraise//exit //???
                             end
                     end
                     else } // auf xcons testen!
                     if (einf>=xlimit)     then begin
                        estack[eptr-2]:=cell[etop].rest;
                        etop:=cell[etop].first;
                        einf:=estack[eptr-1];
                        efun:=infix[einf];
                        estack[eptr]:=prop(etop,cell[einf].first,estack[eptr]);
                        repeat eval;  if (ecall<>0) then proc[ecall]
                        until equit;
                        if      (etop=xtrue)  then break//etop:=estack[eptr-2]?
                        else if (etop=xfalse) then begin
                           dec(eptr,4);
                           etop:=newerror(idxassign,etypemismatch);//genauer!
                           assignraise
                        end
                        //en assignlambdatypemismatch
                        else if (infix[etop]=xerror) then begin dec(eptr,4);
                                                                assignraise//exit//?
                                                          end
                        else begin dec(eptr,4);
                                   etop:=newerror(idxassign,eformalinfnobool);
                                   assignraise//exit //???
                             end
                     end
                     //else if (einf=xlink)  then etop:=cell[etop].value
                     //else if (einf=xlazy)  then delazy
                     else if (einf=xerror) then begin dec(eptr,4); exit end//assignraise?
                     else begin dec(eptr,4);
                                etop:=newerror(idxassign,eactualnoformal);
                                assignraise//exit
                          end//
                  until false;
                  etop:=cell[estack[eptr-1]].rest
                  //top;
                  //restor - rest ,bitte exception
               end
               //else if (einf=xlink)   then etop:=cell[etop].value
               //else if (einf=xlazy)   then delazy
               else if (einf=xerror)  then begin dec(eptr,4); exit end//assignraise?
               else begin estack[eptr]:=prop(estack[eptr-2],etop,estack[eptr]);
                          break
                    end//
            until false;
            ;
            //servprint(tovalue(estack[eptr-3]));
            //servprint(tovalue(estack[eptr-2]));
            //servprint(tovalue(estack[eptr-1]));
            //servprint(tovalue(estack[eptr-0]));
            //servprint('-------');
            //efun:=estack[eptr-3];//for test
            //nreverse:
            //etop:=estack[eptr];dec(eptr,4);//];
            //equit:=false;//for test
            //;
            //equit...   //nolambdaraise       -->testen
            etop:=estack[eptr];
            nreverse(etop);// ausführlich! (?) //efun:=...;etop:=xnil;while()dobeginend;
            //
            //servprint(tovalue(etop));
            //
            efun:=estack[eptr-3];
            dec(eptr,4);
            equit:=false;
            exit
         end
         //else if (einf=xlink)  then etop:=cell[etop].value
         //else if (einf=xlazy)  then delazy
         else if (einf=xerror) then exit//assignraise?
         else provisorium('provisorium in fassign.')//se break
      until false//
end;

procedure ftry;
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         einf:=cell[etop].arg;//eref?
         if (infix[einf]=xerror) then begin etop:=einf; exit end;
         epush(etop);
         etop:=cell[etop].term;//ifxerror???... (inxlimit)
         if (infix[etop]<xlimit) then begin dec(eptr);
                                            etop:=newerror(idxtry,einfnoprop);
                                            exit
                                      end;
         efun:=cell[etop].first;
         etop:=einf;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;
         // (infix[etop]=xerror)-->
         einf:=estack[eptr];
         epush(etop);
         etop:=cell[einf].arg;
         estack[eptr-1]:=etop;//ist nur noch arg/xx
         efun:=cell[cell[einf].term].rest;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;//einf:=infix[...]?
         einf:=infix[etop];
         if      (einf=xalter) then
         else if (einf=xcons)  then
         else if (einf=xerror) then begin dec(eptr,2); exit end
         else begin dec(eptr,2);
                    etop:=newerror(idxtry,eopaltexpect);//eopconsexpect2?
                    exit
              end;
         //in etop das alternal
         einf:=estack[eptr];  //dec(eptr)?
         if (infix[einf]=xerror) then begin// hier noch mal umbauen?!
            epush(etop);
            apiget(idxtry,xerror,cell[einf].first);//besser wert von xerror
            //ifxundef? ,etc?  ,auf Fehler reagieren...
            etop:=prop(etop,xobject,cell[estack[eptr-1]].rest);//?cell[einf].rest
            etop:=prop(etop,xcons,prop(estack[eptr-2],xcons,xnil));
            efun:=cell[estack[eptr]].first;
            dec(eptr,3)//
         end
         else begin efun:=cell[etop].rest;
                    etop:=prop(einf,xcons,prop(estack[eptr-1],xcons,xnil));
                    dec(eptr,2)
              end;
         equit:=false//
      end
      else if (einf=xerror) then //(exit)
      else provisorium('provisorium bei ftry.');
      einf:=xnil
end;

// bitte noch testen!!!!!!!!!!!!!!!!!!!!!!!!!
//ungeprüft übernommen von femtoproject // noch mal neu machen!
procedure fcond;//condition
begin einf:=infix[etop];
      if      (einf=xcombine) then begin
         einf:=cell[etop].arg;//eref?
         if (infix[einf]=xerror) then begin etop:=einf; exit end;
         epush(etop);
         etop:=cell[etop].term;//ifxerror???... (in xlimit)
         if (infix[etop]<xlimit) then begin dec(eptr);
                                            etop:=newerror(idxcond,einfnoprop);
                                            exit
                                      end;
         efun:=cell[etop].first;
         etop:=einf;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;
         if (infix[etop]=xerror) then begin dec(eptr); exit end;
         einf:=estack[eptr];
         epush(etop);
         etop:=cell[einf].arg;
         estack[eptr-1]:=etop;//ist nur noch arg/xx
         efun:=cell[cell[einf].term].rest;
         repeat eval;  if (ecall<>0) then proc[ecall]
         until equit;//einf:=infix[...]?
         einf:=infix[etop];
         //if (einf=xerror) then begin dec(eptr,2); exit end;
         //ifxcons?
         //serveprint('['+tovalue(etop)+']');
         if      (einf=xalter) then
         else if (einf=xcons)  then
         else if (einf=xerror) then begin dec(eptr,2); exit end
         else begin dec(eptr,2);
                    etop:=newerror(idxcond,eopaltexpect);//eopconsexpect2?
                    exit
              end;
         einf:=estack[eptr];  dec(eptr);
         if      (einf=xtrue)  then efun:=cell[etop].first
         else if (einf=xfalse) then efun:=cell[etop].rest
         else begin dec(eptr);
                    etop:=newerror(idxcond,eopnobool1);
                    //efun:=xnil; einf:=xnil; //...
                    exit
              end;
         etop:=estack[eptr];  dec(eptr);// einf:=xnil, macht eval...
         equit:=false//
      end
      //ifxerror? ,einf?
      else if (einf=xerror)   then //(exit)
      else provisorium('provisorium bei fcond.');//
      einf:=xnil
end;

// ----------------------
// ------- legacy -------
// ----------------------
{procedure fcondpre;//condition   // (xx _combi tt -> aa ; bb cc dd _s)
begin repeat einf:=infix[etop];
             if (einf=xcombine)    then begin
                efun:=cell[etop].arg;
                if (infix[efun]=xerror) then begin etop:=efun; exit end;//genauer?
                epush(efun);
                etop:=cell[etop].term;
                repeat einf:=infix[etop];
                       if      (einf>=xlimit) then break
                       //else if (einf=xlink)   then etop:=cell[etop].value
                       //else if (einf=xlazy)   then delazy
                       else if (einf=xerror)  then begin dec(eptr); exit end
                       else begin dec(eptr);
                                  etop:=newerror(idxcond,einfnoprop);
                                  exit
                            end
                until false;
                epush(cell[etop].rest);
                efun:=cell[etop].first;
                etop:=estack[eptr-1];
                repeat eval;  if (ecall<>0) then proc[ecall]
                until equit;
                //
                repeat einf:=infix[etop];
                       if      (einf=xident) then break
                       //else if (einf=xlink)  then etop:=cell[etop].value
                       //else if (einf=xlazy)  then delazy
                       else if (einf=xerror) then begin dec(eptr,2); exit end
                       else begin dec(eptr,2);
                                  etop:=newerror(idxcond,eopnobool1);
                                  exit
                            end
                until false;//sparen? ,scalar?
                efun:=estack[eptr];
                estack[eptr]:=etop;
                etop:=estack[eptr-1];
                repeat eval;  if (ecall<>0) then proc[ecall]
                until equit;
                repeat einf:=infix[etop];
                       if      (einf=xalter) then break// ,idelse?
                       else if (einf=xcons)  then break//???
                       //else if (einf=xlink)  then etop:=cell[etop].value
                       //else if (einf=xlazy)  then delazy
                       else if (einf=xerror) then begin dec(eptr,2); exit end
                       else begin dec(eptr,2);
                                  etop:=newerror(idxcond,eopconsexpect2);//was anderes!!!
                                  exit
                            end
                until false;
                //
                //ifxlazy? , _link
                //if (infix[etop]=xexc) then begin dec(eptr,2); exit end;
                einf:=estack[eptr];  dec(eptr);
                if      (einf=xtrue)  then efun:=cell[etop].first
                else if (einf=xfalse) then efun:=cell[etop].rest
                else begin dec(eptr);
                           etop:=newerror(idxcond,eopnobool1);
                           exit
                     end;
                etop:=estack[eptr];  dec(eptr);
                equit:=false;
                exit//
             end
             //else if (einf=xlink)  then etop:=cell[etop].value
             //else if (einf=xlazy)  then delazy
             else if (einf=xerror) then exit
             else provisorium('provisorium in fif')//se break
      until false//
end;}

procedure falternal;//???
begin//
end;

procedure fwhile;
begin//
end;

procedure floopif;//?
begin//
end;

// ------- combinator initialization -------

procedure initcombiidents;
begin //
      idxquote:=newindex('quote');//noch relevant?
      idxapplic:=newindex('applic');
      idxcompose:=newindex('compose');
      //
      idxassign:=newindex('assign');
      idxtry:=newindex('try');
      idxcond:=newindex('cond');
      //
end;

procedure initcombiprims;
begin //
      initcombiidents;
      //
      idk:=newidentproc('k',@fquote);
      cell[xquote].value:=cell[idk].value;
      newidentproc(':',@fapplic);
      ido:=newidentproc('o',@fcompose);
      cell[xcompose].value:=cell[ido].value;
      newidentproc('<-',@fassign);
      newidentproc('try',@ftry);
      newidentproc('->',@fcond);
      //
end;

end.

