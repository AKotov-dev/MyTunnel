unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Process, DefaultTranslator, Buttons, IniFiles;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Shape1: TShape;
    HidePassBtn: TSpeedButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RunCommandASync(const CmdLine: string);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure SaveConnection;
    procedure HidePassBtnClick(Sender: TObject);

  private

  public
    SERVER_IP_PREV, SERVER_PORT_PREV, CONF: string;

  end;

 { resourcestring
  SAppRunning = 'The program is already running!';
  }

var
  MainForm: TMainForm;

implementation

uses StatusTRD;

  {$R *.lfm}

  { TMainForm }


//Сохранение настроек формы
procedure TMainForm.SaveSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(CONF);
  try
    Ini.WriteInteger('MainForm', 'Top', MainForm.Top);
    Ini.WriteInteger('MainForm', 'Left', MainForm.Left);
    Ini.WriteInteger('MainForm', 'Width', MainForm.Width);
    Ini.WriteInteger('MainForm', 'Height', MainForm.Height);
  finally
    Ini.Free;
  end;
end;

//Загрузка настроек формы
procedure TMainForm.LoadSettings;
var
  Ini: TIniFile;
begin
  //  if not FileExists(CONF) then Exit;
  Ini := TIniFile.Create(CONF);
  try
    MainForm.Top := Ini.ReadInteger('MainForm', 'Top', MainForm.Top);
    MainForm.Left := Ini.ReadInteger('MainForm', 'Left', MainForm.Left);
    MainForm.Width := Ini.ReadInteger('MainForm', 'Width', MainForm.Width);
    MainForm.Height := Ini.ReadInteger('MainForm', 'Height', MainForm.Height);

    //Данные соединения
    Edit1.Text := Ini.ReadString('Connection', 'Edit1', Edit1.Text);
    Edit2.Text := Ini.ReadString('Connection', 'Edit2', Edit2.Text);
    Edit3.Text := Ini.ReadString('Connection', 'Edit3', Edit3.Text);
    Edit4.Text := Ini.ReadString('Connection', 'Edit4', Edit4.Text);
    Edit5.Text := Ini.ReadString('Connection', 'Edit5', Edit5.Text);
    Edit6.Text := Ini.ReadString('Connection', 'Edit6', Edit6.Text);

  finally
    Ini.Free;
  end;
end;

//Сохранение данных соединения только по нажатию Start
procedure TMainForm.SaveConnection;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(CONF);
  try
    Ini.WriteString('Connection', 'Edit1', Edit1.Text);
    Ini.WriteString('Connection', 'Edit2', Edit2.Text);
    Ini.WriteString('Connection', 'Edit3', Edit3.Text);
    Ini.WriteString('Connection', 'Edit4', Edit4.Text);
    Ini.WriteString('Connection', 'Edit5', Edit5.Text);
    Ini.WriteString('Connection', 'Edit6', Edit6.Text);
  finally
    Ini.Free;
  end;
end;

//Скрытие / Показ пароля
procedure TMainForm.HidePassBtnClick(Sender: TObject);
begin
  if Edit4.PasswordChar = #0 then Edit4.PasswordChar := '*'
  else
    Edit4.PasswordChar := #0;
end;

//Cинхронное выполнение команд
procedure TMainForm.RunCommandASync(const CmdLine: string);
var
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'bash';
    AProcess.Parameters.Add('-c');
    AProcess.Parameters.Add(CmdLine);

    // Асинхронный запуск
    //   AProcess.Options := [poWaitOnExit];
    AProcess.Execute; // сразу возвращается

  finally
    AProcess.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32bit;
    bmp.Assign(Image1.Picture.Graphic);
    Application.Icon.Assign(bmp);
  finally
    bmp.Free;
  end;

  if not DirectoryExists(GetUserDir + '.config/mytunnel') then
    ForceDirectories(GetUserDir + '.config/mytunnel');

  //Конфигурация
  CONF := GetUserDir + '.config/mytunnel/mytunnel.conf';
end;

//Старт
procedure TMainForm.Button1Click(Sender: TObject);
var
  S: TStringList;
begin
  try
    S := TStringList.Create;

    if (Trim(Edit1.Text) = '') or (Trim(Edit2.Text) = '') or
      (Trim(Edit3.Text) = '') or (Trim(Edit4.Text) = '') or
      (Trim(Edit5.Text) = '') or (Trim(Edit6.Text) = '') then Exit;

    //Создаём пускач
    S.Add('#!/bin/bash');
    S.Add('');

    //Если это не первый запуск
    if (SERVER_IP_PREV <> '') and (SERVER_PORT_PREV <> '') then
    begin
      //Очищаем старые ключи (переменные уже в памяти после загрузки формы)
      if SERVER_PORT_PREV = '22' then
        S.Add('ssh-keygen -R "' + SERVER_IP_PREV + '" 2>/dev/null')
      else
        S.Add('ssh-keygen -R "[' + SERVER_IP_PREV + ']:' + SERVER_PORT_PREV +
          '" 2>/dev/null');

      S.Add('');
    end;

    //Получаем ключи с сервера (если сервер переустанавливался и сменил ip)
    S.Add('ssh-keyscan -q -p "' + Edit2.Text + '" "' + Edit1.Text +
      '" >> ~/.ssh/known_hosts');

    S.Add('');

    //-o StrictHostKeyChecking=accept-new или -o StrictHostKeyChecking=no
    S.Add('sshpass -p ''' + Edit4.Text +
      ''' ssh -o StrictHostKeyChecking=accept-new -o ExitOnForwardFailure=yes -N -p ' +
      Edit2.Text + ' -L ' + Edit6.Text + ':127.0.0.1:' + Edit5.Text +
      ' root@' + Edit1.Text);

    S.SaveToFile(GetUserDir + '.config/mytunnel/start.sh');

    //Запоминаем новые данные переменных для последующей чистки
    SERVER_IP_PREV := Edit1.Text;
    SERVER_PORT_PREV := Edit2.Text;

    //Сохраняем данные подключения
    SaveConnection;

    // killall -9 sshpass mytunnel.sh; - уже в mytunnel.service
    RunCommandASync(
      'chmod 700 ~/.config/mytunnel ~/.config/mytunnel/start.sh; chmod 600 ~/.config/mytunnel/mytunnel.conf; '
      + 'systemctl --user restart mytunnel && systemctl --user enable mytunnel');

  finally
    S.Free;
  end;
end;

//Останов
procedure TMainForm.Button2Click(Sender: TObject);
begin
  RunCommandASync(
    'killall -9 sshpass mytunnel.sh; systemctl --user stop mytunnel.service; systemctl --user disable mytunnel');
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Сохраняем размеры и позицию формы
  SaveSettings;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  //Загружаем размеры и позицию формы
  LoadSettings;

  //Запоминаем рабочие данные для очистки ключей из ~/.ssh/known_hosts
  SERVER_IP_PREV := Edit1.Text;
  SERVER_PORT_PREV := Edit2.Text;

  MainForm.Caption := Application.Title;

  HidePassBtn.Width := HidePassBtn.Height;

  TStatusTRD.Create;
end;

end.
