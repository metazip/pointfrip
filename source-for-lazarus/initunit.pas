unit initunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

{uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;}

type
  TinitForm = class(TForm)
    questlabel: TLabel;
    celledit: TEdit;
    okbutton: TButton;
    cancelbutton: TButton;
    infopanel: TPanel;
    infobevel: TBevel;
    infoimage: TImage;
    infolabel1: TLabel;
    infolabel2: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  initForm: TinitForm;

implementation

{$R *.lfm}

end.

