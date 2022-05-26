unit errorunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TerrorForm }

  TerrorForm = class(TForm)
    errorimage: TImage;
    errormemo: TMemo;
    okbutton: TButton;
    errorbevel: TBevel;
    errorpanel: TPanel;
    buttonpanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure okbuttonClick(Sender: TObject);
  private

  public

  end;

var
  errorForm: TerrorForm;

implementation

{$R *.lfm}

{ TerrorForm }

procedure TerrorForm.okbuttonClick(Sender: TObject);
begin hide
end;

procedure TerrorForm.FormCreate(Sender: TObject);
begin

end;

end.


// GNU Lesser General Public License v2.1

