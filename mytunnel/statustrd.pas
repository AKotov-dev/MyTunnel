unit StatusTRD;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process, Graphics;

type
  TStatusTRD = class(TThread)
  private
    S: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
    procedure ShowRunningStatus;
  end;

implementation

uses unit1;

  { TStatusTRD }

constructor TStatusTRD.Create;
begin
 { inherited Create(False); // сразу запускаем поток
  FreeOnTerminate := True; // уничтожаем поток автоматически
  S := TStringList.Create;}

  inherited Create(True);
  FreeOnTerminate := True;
  S := TStringList.Create;
  Start;
end;

destructor TStatusTRD.Destroy;
begin
  S.Free;
  inherited Destroy;
end;

procedure TStatusTRD.Execute;
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';
    ExProcess.Options := [poUsePipes, poWaitOnExit];

    while not Terminated do
    begin
      // --- autossh ---
      ExProcess.Parameters.Clear;
      ExProcess.Parameters.Add('-c');
      ExProcess.Parameters.Add(
        'systemctl --user is-active mytunnel.service 2>/dev/null');

      ExProcess.Execute;

      S.Clear;
      S.LoadFromStream(ExProcess.Output);
      Synchronize(@ShowRunningStatus);

      Sleep(1000); // чуть реже опрашиваем
    end;
  finally
    ExProcess.Free;
  end;
end;

procedure TStatusTRD.ShowRunningStatus;
begin
  if (S.Count > 0) and (Trim(S[0]) = 'active') then
    MainForm.Shape1.Brush.Color := clLime
  else
    MainForm.Shape1.Brush.Color := clYellow;

  MainForm.Shape1.Repaint;
end;

end.
