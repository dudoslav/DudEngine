unit DudEngineunit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls
  , LCLType, Math;

type
  TPoint3D = record
    X, Y, Z: real;
  end;

  TPointR = record
    X, Y: real;
  end;
  renderFN = array of TPointR;

  Face = record
    v1, v2, v3: integer;
  end;

  Model = record
    Origin: TPoint3D;
    Vertices: array of TPoint3D;
    Faces: array of Face;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  keys: array [word] of boolean;
  models: array of model;
  modelsNum: integer;
  camera: Tpoint3D;
  lng: integer;
  relativeX: real;

implementation

{$R *.lfm}

{ TForm1 }
procedure loadModel(s: string; xt, yt, zt: real);
var
  f: TextFile;
  c, c1: char;
  n: string;
  x, y, z: real;
  v1, v2, v3: string;
  lv, lf: integer;
begin
  lv := 0;
  lf := 0;
  modelsNum := modelsNum + 1;
  SetLength(Models, modelsNum);
  models[modelsNum - 1].Origin.x := xt;
  models[modelsNum - 1].Origin.y := yt;
  models[modelsNum - 1].Origin.z := zt;
  Assignfile(f, s);
  reset(f);
  while not EOF(f) do
  begin
    Read(f, c, c1);
    if (c = 'v') and (c1 = ' ') then
    begin
      lv := lv + 1;
      SetLength(models[modelsNum - 1].vertices, lv);
      readln(f, x, c, y, c, z);
      models[modelsNum - 1].Vertices[lv - 1].x := x + xt;
      models[modelsNum - 1].Vertices[lv - 1].y := y + yt;
      models[modelsNum - 1].Vertices[lv - 1].z := z + zt;
    end
    else if c = 'f' then
    begin
      lf := lf + 1;
      SetLength(models[modelsNum - 1].Faces, lf);
      Read(f, c);
      v1 := c;
      while c <> '/' do
      begin
        Read(f, c);
        if c <> '/' then
          v1 := v1 + c;
      end;
      models[modelsNum - 1].Faces[lf - 1].v1 := StrToInt(v1);
      while c <> ' ' do
      begin
        Read(f, c);
      end;
      Read(f, c);
      v2 := c;
      while c <> '/' do
      begin
        Read(f, c);
        if c <> '/' then
          v2 := v2 + c;
      end;
      models[modelsNum - 1].Faces[lf - 1].v2 := StrToInt(v2);
      while c <> ' ' do
      begin
        Read(f, c);
      end;
      Read(f, c);
      v3 := c;
      while c <> '/' do
      begin
        Read(f, c);
        if c <> '/' then
          v3 := v3 + c;
      end;
      models[modelsNum - 1].Faces[lf - 1].v3 := StrToInt(v3);
      readln(f);
    end
    else
      readln(f);
  end;
  closeFile(f);
end;

procedure modelTranslate(x, y, z: real);
var
  i: integer;
begin
  //for i := 1 to ()
end;

function Render(point: array of TPoint3D): renderFn;
var
  i: integer;
  k, wd, owdx1, owdy1, owdx2, owdy2: real;
begin
  for i := 0 to length(point) - 1 do
  begin
    lng := lng + 1;
    setLength(Result, lng);
    wd := (camera.z - point[i].Z);
    owdx1 := wd / 2 - point[i].X + camera.x;
    k := wd / (Form1.image1.height);
    if k < 0 then
    begin
      owdx2 := owdx1 / k;
      Result[i].X := owdx2+relativeX;
    end;
    owdy1 := wd / 2 - point[i].Y + camera.Y;
    k := wd / (Form1.image1.Height);
    if k < 0 then
    begin
      owdy2 := owdy1 / k;
      Result[i].Y := owdy2;
    end;
  end;
end;

procedure RenderModel(model: Model);
var
  i, vl: integer;
  renderPoint: array of TPointR;
  p1, p2, p3: TPoint;
  p: array [1..3] of TPoint;
begin
  vl := length(model.Vertices);
  lng := 0;
  setLength(renderPoint, vl);
  renderPoint := Render(model.Vertices);
  for i := 0 to (length(model.Faces) - 1) do
  begin
    form1.image1.canvas.brush.color := clblue;
    form1.image1.canvas.pen.color := clblue;
    p1.x := round(renderPoint[model.Faces[i].v1 - 1].x);
    p1.y := round(renderPoint[model.Faces[i].v1 - 1].y);
    p2.x := round(renderPoint[model.Faces[i].v2 - 1].x);
    p2.y := round(renderPoint[model.Faces[i].v2 - 1].y);
    p3.x := round(renderPoint[model.Faces[i].v3 - 1].x);
    p3.y := round(renderPoint[model.Faces[i].v3 - 1].y);
    p[1] := p1;
    p[2] := p2;
    p[3] := p3;
    Form1.image1.canvas.Polygon(p);

    {form1.image1.canvas.pen.color := clblack;
    Form1.image1.canvas.moveto(round(renderPoint[model.Faces[i].v1 - 1].x),
      round(renderPoint[model.Faces[i].v1 - 1].y));
    Form1.image1.canvas.lineto(round(renderPoint[model.Faces[i].v2 - 1].x),
      round(renderPoint[model.Faces[i].v2 - 1].y));
    Form1.image1.canvas.lineto(round(renderPoint[model.Faces[i].v3 - 1].x),
      round(renderPoint[model.Faces[i].v3 - 1].y));
    Form1.image1.canvas.lineto(round(renderPoint[model.Faces[i].v1 - 1].x),
      round(renderPoint[model.Faces[i].v1 - 1].y));}
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  randomize;
  DoubleBuffered := True;

  form1.Top := 0;
  form1.left := 0;
  image1.Top := 0;
  image1.left := 0;
  form1.BorderStyle := bsnone;
  form1.Width := screen.Width;
  form1.Height := screen.Height;
  image1.Width := screen.Width;
  image1.Height := screen.Height;

  relativeX := (image1.Width-image1.height)/2;
  lng := 0;
  modelsNum := 0;
  camera.x := 0;
  camera.y := 0;
  camera.z := 0;

  loadModel('res/Portal Gun.obj', 0, 0, 1);
  loadModel('res/sword.obj', 10,10,100);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  keys[Key] := True;
  if key = vk_escape then
    application.terminate;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  keys[Key] := False;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i, n: integer;
  xFn,yFn,zFn : real;
begin
  image1.canvas.Brush.color := clwhite;
  image1.canvas.pen.color := clblack;
  image1.canvas.rectangle(0, 0, image1.Width, image1.Height);
  image1.canvas.pen.color := clblack;
  image1.canvas.pen.Width := 1;

  renderModel(Models[0]);
  renderModel(Models[1]);

  if keys[VK_W] then
    camera.Z := camera.Z + 1;
  if keys[VK_S] then
    camera.Z := camera.Z - 1;

  if keys[VK_Q] then
    camera.Y := camera.Y + 1;
  if keys[VK_E] then
    camera.Y := camera.Y - 1;

  if keys[VK_D] then
    camera.X := camera.X + 0.5;
  if keys[VK_A] then
    camera.X := camera.X - 0.5;

  if keys[VK_R] then
  begin
    for i := 0 to Length(models[0].Vertices)-1 do
    begin
      xFN := models[0].Origin.X + (models[0].Vertices[i].X - models[0].Origin.X) * cos(0.017) -
        (models[0].Vertices[i].Y - models[0].Origin.Y) * sin(0.017);
      yFN := models[0].Origin.Y + (models[0].Vertices[i].X - models[0].Origin.X) * sin(0.017) +
        (models[0].Vertices[i].Y - models[0].Origin.Y) * cos(0.017);
      models[0].Vertices[i].X := xFn;
      models[0].Vertices[i].Y := yFn;

      {xFN := cube1Origin.X + (cube1[i].X - cube1Origin.X) * cos(0.09) -
        (cube1[i].Z - cube1Origin.Z) * sin(0.09);
      zFN := cube1Origin.Z + (cube1[i].X - cube1Origin.X) * Sin(0.09) +
        (cube1[i].Z - cube1Origin.Z) * Cos(0.09);
      cube1[i].X := xFn;
      cube1[i].Z := zFn;}
    end;
  end;

  {image1.canvas.Brush.color := clwhite;
  image1.canvas.pen.color := clblack;
  image1.canvas.Font.Color:= clwhite;}

  {n := 15;
  for i := 0 to length(models[0].Vertices)-1 do
  begin
    image1.canvas.textout(image1.Width - 300, n, 'x' + IntToStr(i) +
      ' ' + IntToStr(round(models[0].Vertices[i].x)));
    image1.canvas.textout(image1.Width - 300, n + 15, 'y' + IntToStr(i) +
      ' ' + IntToStr(round(models[0].Vertices[i].y)));
    image1.canvas.textout(image1.Width - 300, n + 30, 'z' + IntToStr(i) +
      ' ' + IntToStr(round(models[0].Vertices[i].z)));
    n := n + 45;
  end;
  n := 15;
  for i := 0 to length(models[0].Faces)-1 do
  begin
    image1.canvas.textout(image1.Width - 500, n, 'v1' + ' ' + IntToStr(i) +
      ' ' + IntToStr(round(models[0].Faces[i].v1)));
    image1.canvas.textout(image1.Width - 500, n + 15, 'v2' + ' ' +
      IntToStr(i) + ' ' + IntToStr(round(models[0].Faces[i].v2)));
    image1.canvas.textout(image1.Width - 500, n + 30, 'v3' + ' ' +
      IntToStr(i) + ' ' + IntToStr(round(models[0].Faces[i].v3)));
    n := n + 45;
  end;
  image1.canvas.textout(image1.Width - 600, 15,'v = '+ inttostr(length(models[0].Vertices)));}
end;

end.
