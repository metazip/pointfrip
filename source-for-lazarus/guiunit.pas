unit guiunit;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
     Menus, Buttons,
     IniFiles,
     clipbrd
     ;

type

  { TguiForm }

  TguiForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    finddialog: TFindDialog;
    fontdialog: TFontDialog;
    mdiImageList: TImageList;
    logoimage: TImage;
    backpanel: TPanel;
    banner: TPanel;
    iopanel: TPanel;
    doititem: TMenuItem;
    dumpitem: TMenuItem;
    cutitem: TMenuItem;
    copyitem: TMenuItem;
    delitem: TMenuItem;
    inititem: TMenuItem;
    finditem: TMenuItem;
    fontitem: TMenuItem;
    docuitem: TMenuItem;
    helpitem: TMenuItem;
    favoritem: TMenuItem;
    iopaintbox: TPaintBox;
    iomemo: TMemo;
    getmemo: TMemo;
    helpbutton: TSpeedButton;
    splitpanel: TPanel;
    quititem: TMenuItem;
    N3item: TMenuItem;
    iosplitter: TSplitter;
    toolitem: TMenuItem;
    testitem: TMenuItem;
    websiteitem: TMenuItem;
    quickitem: TMenuItem;
    saveitem: TMenuItem;
    reloaditem: TMenuItem;
    openitem: TMenuItem;
    N2item: TMenuItem;
    selallitem: TMenuItem;
    pasteitem: TMenuItem;
    undoitem: TMenuItem;
    N1item: TMenuItem;
    stopactitem: TMenuItem;
    opendialog: TOpenDialog;
    iopopupmenu: TPopupMenu;
    savedialog: TSaveDialog;
    guitimer: TTimer;
    reloadbutton: TSpeedButton;
    doitbutton: TSpeedButton;
    dumpbutton: TSpeedButton;
    openbutton: TSpeedButton;
    cutbutton: TSpeedButton;
    copybutton: TSpeedButton;
    pastebutton: TSpeedButton;
    delbutton: TSpeedButton;
    favorbutton: TSpeedButton;
    toolpanel: TPanel;
    procedure copyitemClick(Sender: TObject);
    procedure cutitemClick(Sender: TObject);
    procedure delitemClick(Sender: TObject);
    procedure docuitemClick(Sender: TObject);
    procedure doititemClick(Sender: TObject);
    procedure dumpitemClick(Sender: TObject);
    procedure favoritemClick(Sender: TObject);
    procedure finditemClick(Sender: TObject);
    procedure fontitemClick(Sender: TObject);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: TConstraintSize);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure guitimerTimer(Sender: TObject);
    procedure helpbuttonClick(Sender: TObject);
    procedure helpitemClick(Sender: TObject);
    procedure inititemClick(Sender: TObject);
    procedure iomemoChange(Sender: TObject);
    procedure iomemoDblClick(Sender: TObject);
    procedure iomemoKeyPress(Sender: TObject; var Key: char);
    procedure iopaintboxPaint(Sender: TObject);
    procedure logoimageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure logoimageMouseEnter(Sender: TObject);
    procedure logoimageMouseLeave(Sender: TObject);
    procedure openitemClick(Sender: TObject);
    procedure pasteitemClick(Sender: TObject);
    procedure iopopupmenuPopup(Sender: TObject);
    procedure quickitemClick(Sender: TObject);
    procedure quititemClick(Sender: TObject);
    //procedure reloadbuttonClick(Sender: TObject);
    procedure reloaditemClick(Sender: TObject);
    procedure saveitemClick(Sender: TObject);
    procedure selallitemClick(Sender: TObject);
    procedure stopactitemClick(Sender: TObject);
    procedure testitemClick(Sender: TObject);
    procedure toolitemClick(Sender: TObject);
    procedure undoitemClick(Sender: TObject);
    procedure websiteitemClick(Sender: TObject);
    procedure FormIdle(Sender: TObject; var Done: Boolean);
    //procedure wikibuttonClick(Sender: TObject);
  private

  public

  end;

var guiForm: TguiForm;

implementation

{$R *.lfm}

{ TguiForm }

uses serveunit, errorunit, initunit, typeunit;

const pixelinpopupmenu = 12;//14;//in servunit;//0=linux?
      documents: es = 'documents\';
      inifiledef : es = 'pointfrip.ini';//name?
      corefiledef: es = 'prelude.txt';                 // namen flexibler machen
      memofiledef: es = 'Document.txt';
      infofiledef: es = 'quickinfo.pdf';//bitte .pdf
      docufiledef: es = 'documentation.pdf';//bitte .pdf
      helpfiledef: es = 'reference.pdf';//bitte .pdf
      website_url: es = 'https://pf-system.github.io';//?
      //webwiki_url: es = 'http://162.248.51.100/~pointfre/fp';
      testfiledef: es = 'test.txt';
      redefine: es = 'redefine';
      filenotfound: es = 'File not found.';
      noparamfilename: es ='No parameter file.';//param?
      noinifilename: es = 'No inifile name.';
      guisection = 'PFForm';//?;
      x0 = 'x0';
      y0 = 'y0';
      dx = 'dx';
      dy = 'dy';
      x0def = 80;
      y0def = 9;
      dxdef = 390;
      dydef = 340;
      tbdef = true;
      toolbar = 'toolbar';
      mcs = 'maxcell';
      fontname    = 'fontname';
      fontcharset = 'fontcharset';
      fontcolor   = 'fontcolor';
      fontheight  = 'fontheight';
      fontpitch   = 'fontpitch';
      fontsize    = 'fontsize';

var formcaption,
    inifilename,exefilename,corefilename,paramfilename,memofilename: ustring;
    intxtfile: tstringlist = nil;//oder getmemo?;
    inifile: tinifile;//tinifile;

//errorquit (!?)
procedure errordialog(s: ustring);
begin with errorForm do begin
           beep;
           show;
           errormemo.SetFocus;
           errormemo.lines.append(s);
           okButton.SetFocus
      end
end;

procedure readinifile(var mc: int64);
var fname: ustring;
begin if (inifilename='') then exit;
      try inifile:=tinifile.create(inifilename);
          with inifile,guiForm do begin
               left:=readinteger(guisection,x0,x0def);
               top:=readinteger(guisection,y0,y0def);
               width:=readinteger(guisection,dx,dxdef);
               height:=readinteger(guisection,dy,dydef);
               //guiForm.iomemo.lines.append('ReadIniFile="'+inifilename+'"');//for test
               toolpanel.visible:=readbool(guisection,toolbar,tbdef);
               toolitem.checked:=toolpanel.visible;//tauschen?
               mc:=readinteger(guisection,mcs,mc);
               fname:=readstring(guisection,fontname,'');
               if (fname<>'') then with iomemo.font do begin
                  charset:=readinteger(guisection,fontcharset,charset);
                  color:=readinteger(guisection,fontcolor,color);
                  //fontadapter
                  //handle
                  height:=readinteger(guisection,fontheight,height);
                  name:=readstring(guisection,fontname,name);
                  //orientation
                  //ownercriticalsection
                  pitch:=tfontpitch(readinteger(guisection,fontpitch,ord(pitch)));
                  //pixelsperinch
                  //quality
                  size:=readinteger(guisection,fontsize,size);
                  //style;
               end;
          end;
          inifile.free;
      except on e: exception do begin inifile.free;
                                      inifilename:='';
                                      errordialog(e.message);
                                end
      end//
end;

procedure writeinifile;
begin if (inifilename='') then exit;
      try inifile:=tinifile.create(inifilename);
          with inifile,guiForm do begin
               writeinteger(guisection,x0,left);
               writeinteger(guisection,y0,top);
               writeinteger(guisection,dx,width);
               writeinteger(guisection,dy,height);
               writebool(guisection,toolbar,toolpanel.visible);
               with iomemo.font do begin
                    writeinteger(guisection,fontcharset,charset);
                    writeinteger(guisection,fontcolor,color);
                    //fontadapter
                    //handle
                    writeinteger(guisection,fontheight,height);
                    writestring (guisection,fontname,name);
                    //orientation
                    //ownercriticalsection
                    writeinteger(guisection,fontpitch,ord(pitch));
                    //pixelsperinch
                    //quality
                    writeinteger(guisection,fontsize,size);
                    //style;
               end;
               updatefile
          end;
          inifile.free;
      except inifile.free;
             //errordialog?
      end//
end;

// ------- FP scriptor -------

procedure initgui;
var mc,ms: int64; txt: ustring;
begin with guiForm do
      try toolpanel.visible:=toolitem.checked;
          iopaintbox.height:=0;
          //iosplitter.height:=guiformheightsub;  //splitter geht nicht?
          banner.color:=RGBToColor(240,240,240);
          toolpanel.color:=RGBToColor(240,240,240);
          iosplitter.color:=RGBToColor(240,240,240);
          iomemo.text:=prompt;
          iomemo.selstart:=length(iomemo.text);
          iomemo.setfocus;
          formcaption:=caption;
          exefilename:=paramstr(0);
          corefilename:=extractslashpath(exefilename)+corefiledef;
          paramfilename:=paramstr(1);
          memofilename:=extractslashpath(exefilename)+memofiledef;
          //mc:=servemaxcell;
          //ms:=mc;//provi;
          inifilename:=extractslashpath(exefilename)+inifiledef;
          mc:=servemaxcell;
          readinifile(mc);
          if (mc<servemincell) then mc:=servemincell;
          ms:=mc;//provi;
          initserve(mc,ms,iomemo,iopaintbox,toolpanel,guiForm);//mp?
          redef:=false;
          Application.OnIdle:=@FormIdle;   //hier??? oder in onshow;
          //
          intxtfile:=tstringlist.create;
          setservecorepath(extractslashpath(corefilename));
          if fileexists(corefilename) then begin
             intxtfile.loadfromfile(corefilename);
             txt:=intxtfile.text;
             intxtfile.clear;
             tellserve(txt);
             caption:=' '+extractslashname(corefilename)+' - '+formcaption
          end;
          if (paramfilename<>'') then if fileexists(paramfilename) then begin
             setserveuserpath(extractslashpath(paramfilename));
             intxtfile.loadfromfile(paramfilename);
             txt:=intxtfile.text;
             intxtfile.clear;
             tellserve(txt);
             caption:=' '+extractslashname(paramfilename)+' - '+formcaption
          end;//else raise...;
          //
      except on e: exception do begin
                // quelltext ausgeben ...
                errordialog(e.message)
             end//
      end//
end;

procedure finalgui;
begin intxtfile.free;
      finalserve;
      writeinifile
end;

procedure ddoit;
var txt: ustring;//?
begin with guiForm do begin
           if (iomemo.sellength>0) then txt:=iomemo.seltext
           else txt:=selectline(iomemo.text,iomemo.selstart);
           tellserve(txt);//mjform.iomemo.lines.append(prompt);
           redef:=true;
           caption:=' '+redefine+' - '+formcaption// (?)
           //adpanel.caption:='';
      end
end;

procedure doit;
var txt: ustring;//?
begin with guiForm do begin
           if (iomemo.sellength>0) then txt:=iomemo.seltext
           else txt:=selectline(unicodestring(iomemo.text),iomemo.selstart);//
           redef:=true;
           tellserve(txt);//iomemo.lines.add('['+txt+']');
           caption:=' '+redefine+' - '+formcaption// (?)
           //;Application.OnIdle:=@FormIdle//
      end
end;

procedure initmaxcell;
var max: int64;
begin if (inifilename='') then begin errordialog(noinifilename); exit end;
      try inifile:=tinifile.create(inifilename);
          max:=inifile.readinteger(guisection,mcs,servemaxcell);
          initForm.celledit.text:=inttostr(max);
          if (initForm.showmodal=mrok) then begin
             inifile.writestring(guisection,mcs,initForm.celledit.text);
             inifile.updatefile
          end;
          inifile.free
      except on e: exception do begin
                inifile.free;
                inifilename:='';//???
                errordialog(e.message)
             end//
      end//
end;

// ----------------------- Fundamental Loop -----------------------------------

procedure TguiForm.FormIdle(Sender: TObject; var Done: Boolean);
//FormIdle: servreaction ,Fundamental Loop ,(Event-Loop)
begin try servereact; Done:=serveidledone;
          if servequit then guiForm.close;//??? im komplexen zusammenspiel?...
      except //quelltexte ausgeben?
             on e: exception do begin
                {if onquit then mjform.close
                else }errordialog(e.message)
                //
             end//
      end// fios mit idle//
end;

{
procedure TguiForm.wikibuttonClick(Sender: TObject);
begin try serverun(webwiki_url)
      except on e: exception do errordialog(e.message)
      end//
end;
}

{
procedure TuiForm.FormIdle(Sender: TObject; var Done: Boolean);
//FormIdle: servreaction ,Fundamental Loop ,(Event-Loop)
begin try servreaction; Done:=servidledone;
          if servquit then uiForm.close;//??? im komplexen zusammenspiel?...
      except //quelltexte ausgeben?
             on e: exception do begin
                {if onquit then mjform.close
                else }errordialog(e.message)
                //
             end//
      end// fios mit idle//
end;
}

// ----------------------- Service Functions ----------------------------------

procedure TguiForm.iomemoChange(Sender: TObject);
begin

      //
end;

procedure TguiForm.iomemoDblClick(Sender: TObject);
begin iomemo.lines.add('')
end;

procedure TguiForm.iomemoKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#13) then begin doit;
                              key:=#27;
                              exit
                        end
end;

procedure TguiForm.iopaintboxPaint(Sender: TObject);
begin try if (iopaintbox.height>1) then servedrawtrail// 1,2,oder was? ,auch bei togglefavor
      except on e: exception do begin
                //ausgeben...
                errordialog(e.message)
                //
             end
      end
end;

procedure TguiForm.logoimageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var t: tpoint;
begin t:=logoimage.clienttoscreen(point(x,y));
      iopopupmenu.Popup(t.x-pixelinpopupmenu,t.y{-pixelinpopupmenu})
end;

procedure TguiForm.logoimageMouseEnter(Sender: TObject);
begin banner.color:=RGBToColor(255,170,0);//=origin//,180,//rgb(248,185,22)//rgb(255,202,20)
end;//mint:=rgb(128,177,122);//lightbend:=rgb(253,153,41);

procedure TguiForm.logoimageMouseLeave(Sender: TObject);
begin banner.color:=RGBToColor(240,240,240)
end;

procedure TguiForm.openitemClick(Sender: TObject);
var txt: ustring;
begin //imports müssen erst (?)
      try opendialog.initialdir:=extractslashpath(paramfilename);
          opendialog.filename:=extractslashname(paramfilename);
          if not(opendialog.execute) then exit;
          paramfilename:=opendialog.filename;
          if not(fileexists(paramfilename)) then
             raise exception.create('"'+paramfilename+'" - '+filenotfound);
          setserveuserpath(extractslashpath(paramfilename));
          intxtfile.loadfromfile(paramfilename);
          txt:=intxtfile.text;
          intxtfile.clear;
          tellserve(txt);
          //redef:=true;//? ,wird per Button erstmalig geladen (cr für redefine)
          caption:=' '+extractslashname(paramfilename)+' - '+formcaption//
      except on e: exception do begin
                //ausgeben?...
                errordialog(e.message)
             end
      end//
end;

procedure TguiForm.pasteitemClick(Sender: TObject);
begin iomemo.pastefromclipboard
end;

procedure TguiForm.iopopupmenuPopup(Sender: TObject);
begin undoitem.enabled:=iomemo.canundo;
      cutitem.enabled :=(iomemo.sellength>0);
      copyitem.enabled:=(iomemo.sellength>0);
      pasteitem.enabled:=clipboard.hasformat(CF_TEXT);
      delitem.enabled:=(iomemo.sellength>0);
      //
      reloaditem.enabled:=(paramfilename<>'');
end;

procedure TguiForm.quickitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+documents+infofiledef)
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TguiForm.quititemClick(Sender: TObject);
begin guiForm.close
end;

{
procedure TguiForm.reloadbuttonClick(Sender: TObject);
begin

end;
}

procedure TguiForm.reloaditemClick(Sender: TObject);
var txt: ustring;
begin //imports müssen erst (?)
      try if (paramfilename='') then raise exception.create(noparamfilename);
          if not(fileexists(paramfilename)) then
             raise exception.create('"'+paramfilename+'" - '+filenotfound);
          setserveuserpath(extractslashpath(paramfilename));
          intxtfile.loadfromfile(paramfilename);
          txt:=intxtfile.text;
          intxtfile.clear;
          tellserve(txt);
          redef:=true;//? ,war schon im Speicher
          caption:=' '+extractslashname(paramfilename)+' - '+formcaption//
      except on e: exception do begin
                //ausgeben?...
                errordialog(e.message)
             end
      end//
end;

procedure TguiForm.saveitemClick(Sender: TObject);
begin try savedialog.initialdir:=extractslashpath(memofilename);
          savedialog.filename:=extractslashname(memofilename);
          if not(savedialog.execute) then exit;
          memofilename:=savedialog.filename;
          //if fileexists... //bei save wird auch ohne nachfragen gespeichert
          //encoding einstellen...
          iomemo.lines.WriteBOM:=true;
          iomemo.lines.savetofile(memofilename,TEncoding.UTF8);// gerne UTF8BOM
          caption:=' '+extractslashname(memofilename)+' - '+formcaption
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TguiForm.selallitemClick(Sender: TObject);
begin iomemo.selectall
end;

procedure TguiForm.stopactitemClick(Sender: TObject);
begin servestopact
end;

procedure TguiForm.testitemClick(Sender: TObject);
var fname,txt: ustring;
begin if (paramfilename='') then
         fname:=extractslashpath(corefilename)+testfiledef
      else fname:=extractslashpath(paramfilename)+testfiledef;
      try if not(fileexists(fname)) then
             raise exception.create('"'+fname+'" - '+filenotfound);
          setserveuserpath(extractslashpath(fname));//?
          intxtfile.loadfromfile(fname);
          txt:=intxtfile.text;
          intxtfile.clear;
          //redef:=true;//? besser nicht - erst cr für redefine
          tellserve(txt);
          caption:=' '+extractslashname(fname)+' - '+formcaption//
      except on e: exception do begin
                // quelltext ausgeben? ...
                errordialog(e.message)
             end
      end//
end;

procedure TguiForm.toolitemClick(Sender: TObject);
begin toolitem.checked:=not(toolitem.checked);
      toolpanel.visible:=toolitem.checked;
      // splitter anpassen !
end;

procedure TguiForm.undoitemClick(Sender: TObject);
begin if iomemo.canundo then iomemo.undo
end;

procedure TguiForm.websiteitemClick(Sender: TObject);
begin try serverun(website_url)
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TguiForm.FormCreate(Sender: TObject);
begin
  //
end;

procedure TguiForm.FormResize(Sender: TObject);
begin
  //
end;

procedure TguiForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin finalgui
end;

procedure TguiForm.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: TConstraintSize);
begin
  //
end;

procedure TguiForm.FormChangeBounds(Sender: TObject);
begin
  //
end;

procedure TguiForm.doititemClick(Sender: TObject);
begin doit
end;

procedure TguiForm.cutitemClick(Sender: TObject);
begin iomemo.cuttoclipboard
end;

procedure TguiForm.delitemClick(Sender: TObject);
begin iomemo.clearselection
end;

procedure TguiForm.docuitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+documents+docufiledef)
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TguiForm.copyitemClick(Sender: TObject);
begin iomemo.copytoclipboard
end;

procedure TguiForm.dumpitemClick(Sender: TObject);
begin serveidentdump
end;

procedure TguiForm.favoritemClick(Sender: TObject);
begin servetogglepaintbox
end;

procedure TguiForm.finditemClick(Sender: TObject);
begin
  //
end;

procedure TguiForm.fontitemClick(Sender: TObject);
begin fontdialog.font:=iomemo.font;
      if fontdialog.execute then iomemo.font:=fontdialog.font
end;

procedure TguiForm.FormShow(Sender: TObject);
begin initgui//in FormCreate?
end;

procedure TguiForm.FormWindowStateChange(Sender: TObject);
begin
  //
end;

procedure TguiForm.guitimerTimer(Sender: TObject);
begin
  //
end;

procedure TguiForm.helpbuttonClick(Sender: TObject);
begin

end;

procedure TguiForm.helpitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+documents+helpfiledef)
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TguiForm.inititemClick(Sender: TObject);
begin initmaxcell
end;

end.

