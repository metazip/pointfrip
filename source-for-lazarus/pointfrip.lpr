program pointfrip;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, guiunit, errorunit, initunit, serveunit, apiunit, vmunit, actunit,
  primunit, combiunit, boolunit, mathunit, stringunit, sequnit, typeunit,
  jsonunit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TguiForm, guiForm);
  Application.CreateForm(TerrorForm, errorForm);
  Application.CreateForm(TinitForm, initForm);
  Application.Run;
end.


// GNU Lesser General Public License v2.1

