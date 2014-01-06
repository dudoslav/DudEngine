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

  CameraCoor = record
    X, Y, Z, rX, rY, rZ: real;
  end;

  renderFN = array of TPoint;

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
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
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
  ZBuffer: array of array of real;
  modelsNum: integer;
  camera: CameraCoor;
  lng, DisplayD, xM1, yM1, xM2, yM2: integer;
  relativeX, relativeY, timeThen, timeNow, time1, time2: real;
  mov, isMousePressed: boolean;
  mouseOrigin: TPoint;

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

procedure modelTranslate(modelOrder: integer; x, y, z: real);
var
  i: integer;
begin
  for i := 0 to length(models[modelOrder].Vertices) - 1 do
  begin
    models[modelOrder].Vertices[i].x := models[modelOrder].Vertices[i].x + x;
    models[modelOrder].Vertices[i].y := models[modelOrder].Vertices[i].y + y;
    models[modelOrder].Vertices[i].z := models[modelOrder].Vertices[i].z + z;
  end;
end;

procedure modelRotate(modelOrder: integer; xr, yr, zr: real);
var
  i: integer;
  xFn, yFn, zFn: real;
begin
  for i := 0 to length(models[modelOrder].Vertices) - 1 do
  begin
    yFn :=
      models[modelOrder].Origin.Y + (models[modelOrder].Vertices[i].Y -
      models[modelOrder].Origin.Y) * cos(DegtoRad(xr)) -
      (models[modelOrder].Vertices[i].Z - models[modelOrder].Origin.Z) *
      sin(DegtoRad(xr));
    zFn :=
      models[modelOrder].Origin.Z + (models[modelOrder].Vertices[i].Y -
      models[modelOrder].Origin.Y) * sin(DegtoRad(xr)) +
      (models[modelOrder].Vertices[i].Z - models[modelOrder].Origin.Z) *
      cos(DegtoRad(xr));
    models[modelOrder].Vertices[i].Y := yFn;
    models[modelOrder].Vertices[i].Z := zFn;

    xFn :=
      models[modelOrder].Origin.X + (models[modelOrder].Vertices[i].X -
      models[modelOrder].Origin.X) * cos(DegtoRad(yr)) -
      (models[modelOrder].Vertices[i].Z - models[modelOrder].Origin.Z) *
      sin(DegtoRad(yr));
    zFn :=
      models[modelOrder].Origin.Z + (models[modelOrder].Vertices[i].X -
      models[modelOrder].Origin.X) * sin(DegtoRad(yr)) +
      (models[modelOrder].Vertices[i].Z - models[modelOrder].Origin.Z) *
      cos(DegtoRad(yr));
    models[modelOrder].Vertices[i].X := xFn;
    models[modelOrder].Vertices[i].Z := zFn;

    xFn :=
      models[modelOrder].Origin.X + (models[modelOrder].Vertices[i].X -
      models[modelOrder].Origin.X) * cos(DegtoRad(zr)) -
      (models[modelOrder].Vertices[i].Y - models[modelOrder].Origin.Y) *
      sin(DegtoRad(zr));
    yFn :=
      models[modelOrder].Origin.Y + (models[modelOrder].Vertices[i].X -
      models[modelOrder].Origin.X) * sin(DegtoRad(zr)) +
      (models[modelOrder].Vertices[i].Y - models[modelOrder].Origin.Y) *
      cos(DegtoRad(zr));
    models[modelOrder].Vertices[i].X := xFn;
    models[modelOrder].Vertices[i].Y := yFn;
  end;
end;

function dudTan(alpha: real): real;
begin
  try
    Result := tan(DegtoRad(alpha));
  except
    Result := 1;
  end;
end;

function Render(point: array of TPoint3D): renderFn;
var
  i: integer;
  k, wd, owdx1, owdy1, owdx2, owdy2: real;
begin

  {for i := 0 to length(point) - 1 do
  begin
    lng := lng + 1;
    setLength(Result, lng);
    wd := (camera.z - point[i].Z);
    owdx1 := wd / 2 - point[i].X + camera.x;
    k := wd / (Form1.image1.Height);
    if k < 0 then
    begin
      owdx2 := owdx1 / k;
      Result[i].X := owdx2 + relativeX;
    end;
    owdy1 := wd / 2 + point[i].Y + camera.Y;
    k := wd / (Form1.image1.Height);
    if k < 0 then
    begin
      owdy2 := owdy1 / k;
      Result[i].Y := owdy2;
    end;
  end;}

  {timeThen := Time;
  for i := 0 to length(point) - 1 do
  begin
    lng := lng + 1;
    setLength(Result, lng);
    if (point[i].Z - camera.z) > 0 then
    begin
      owdx1 := Dudtan(camera.rY) * (point[i].Z - camera.Z) + (point[i].X - camera.X) *
        cos(DegtoRad(camera.rY));
      //TODO: doladit
      Result[i].X :=
        (DisplayD * (owdx1) / (point[i].Z - camera.z)) + relativeX;
      Result[i].Y :=
        (DisplayD * (point[i].Y - camera.y) / (point[i].Z - camera.z)) + relativeY;
    end;
  end;
  timeNow := Time;
  time2 := timeNow - Timethen;}

  timeThen := Time;
  for i := 0 to length(point) - 1 do
  begin
    lng := lng + 1;
    setLength(Result, lng);
    if ((point[i].Z - camera.z) > 0) then
    begin
      Result[i].X := round((DisplayD * (point[i].X - camera.x) /
        (point[i].Z - camera.z)) + relativeX);
      Result[i].Y := round((DisplayD * (point[i].Y - camera.y) /
        (point[i].Z - camera.z)) + relativeY);
    end;
  end;
  timeNow := Time;
  time2 := timeNow - Timethen;
end;

procedure RenderModel(model: Model);
var
  i, vl: integer;
  renderPoint: array of TPoint;
  p1, p2, p3: TPoint;
  p: array [1..3] of TPoint;
begin
  vl := length(model.Vertices);
  lng := 0;
  setLength(renderPoint, vl);
  renderPoint := Render(model.Vertices);
  for i := 0 to (length(model.Faces) - 1) do
  begin
    {if (renderPoint[model.Faces[i].v1 - 1].X > 1) and
      (renderPoint[model.Faces[i].v1 - 1].Y > 1) and
      (renderPoint[model.Faces[i].v2 - 1].X > 1) and
      (renderPoint[model.Faces[i].v2 - 1].Y > 1) and
      (renderPoint[model.Faces[i].v3 - 1].X > 1) and
      (renderPoint[model.Faces[i].v3 - 1].Y > 1) then
    begin
      form1.image1.canvas.brush.color := clred;
      form1.image1.canvas.pen.color := clred;
      p[1] := renderPoint[model.Faces[i].v1 - 1];
      p[2] := renderPoint[model.Faces[i].v2 - 1];
      p[3] := renderPoint[model.Faces[i].v3 - 1];
      Form1.image1.canvas.Polygon(p);
    end;}


    form1.image1.canvas.pen.color := clblack;

    if (((renderPoint[model.Faces[i].v1 - 1].x)) <> 0) or
      (((renderPoint[model.Faces[i].v1 - 1].y)) <> 0) then
      Form1.image1.canvas.moveto((renderPoint[model.Faces[i].v1 - 1].x),
        (renderPoint[model.Faces[i].v1 - 1].y));
    if (((renderPoint[model.Faces[i].v2 - 1].x)) <> 0) or
      (((renderPoint[model.Faces[i].v2 - 1].y)) <> 0) then
      Form1.image1.canvas.lineto((renderPoint[model.Faces[i].v2 - 1].x),
        (renderPoint[model.Faces[i].v2 - 1].y));
    if (((renderPoint[model.Faces[i].v3 - 1].x)) <> 0) or
      (((renderPoint[model.Faces[i].v3 - 1].y)) <> 0) then
      Form1.image1.canvas.lineto((renderPoint[model.Faces[i].v3 - 1].x),
        (renderPoint[model.Faces[i].v3 - 1].y));
    if (((renderPoint[model.Faces[i].v1 - 1].x)) <> 0) or
      (((renderPoint[model.Faces[i].v1 - 1].y)) <> 0) then
      Form1.image1.canvas.lineto((renderPoint[model.Faces[i].v1 - 1].x),
        (renderPoint[model.Faces[i].v1 - 1].y));
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, j: integer;
  xFn, yFn, zFn: real;
begin
  randomize;
  DoubleBuffered := True;

  //gdk_window_fullscreen(PGtkWidget(Handle)^.window);
  form1.Top := 0;
  form1.left := 0;
  image1.Top := 0;
  image1.left := 0;
  form1.BorderStyle := bsnone;
  form1.Width := screen.Width;
  form1.Height := screen.Height;
  image1.Width := screen.Width;
  image1.Height := screen.Height;

  relativeX := ((image1.Width - image1.Height) / 2) + (image1.Height / 2);
  relativeY := image1.Height / 2;
  mov := False;
  isMousePressed := False;
  lng := 0;
  modelsNum := 0;
  Mouse.CursorPos := mouseorigin;
  MouseOrigin.x := image1.Width div 2;
  MouseOrigin.y := image1.Height div 2;
  xM1 := mouseorigin.x;
  yM1 := mouseorigin.y;
  xM2 := mouseorigin.x;
  yM2 := mouseorigin.y;
  Mouse.CursorPos := mouseorigin;
  displayD := image1.Width;
  camera.x := 0;
  camera.y := 0;
  camera.z := 0;
  camera.rx := 0;
  camera.ry := pi;
  camera.rz := 0;

  setLength(ZBuffer, image1.Width, image1.Height);

  for i := 0 to image1.Width - 1 do
  begin
    for j := 0 to image1.Height - 1 do
    begin
      ZBuffer[i][j] := 100;
    end;
  end;

  loadModel('res/alduin.obj', 0, 0, 300);
  modelRotate(0,0,0,180);

  for i := 1 to 100 do
  begin
    loadModel('res/cube.obj', 10, 4 * sin(i * 0.17), 1 * i);
  end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  keys[Key] := True;
  if key = vk_escape then
  begin
    timer1.Enabled := False;
    application.terminate;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  keys[Key] := False;
  if key = vk_escape then
    application.terminate;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if shift = [ssleft] then
  begin
    isMousePressed := True;
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
var
  dx, dy, i, j: integer;
  xFn, yFn, zFn: real;
begin
  //xm2 := xm1;
  //ym2 := ym1;
  mov := True;
  xm1 := x;
  ym1 := y;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin

  IsMousePressed := False;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i, n, j: integer;
  xFn, yFn, zFn, dx, dy: real;
begin
  timeThen := Time;
  image1.canvas.Brush.color := clwhite;
  image1.canvas.pen.color := clblack;
  image1.canvas.rectangle(0, 0, image1.Width, image1.Height);
  image1.canvas.pen.color := clblack;
  image1.canvas.pen.Width := 1;

  for i := 0 to image1.Width - 1 do
  begin
    for j := 0 to image1.Height - 1 do
    begin
      ZBuffer[i][j] := 100;
    end;
  end;

  for i := 0 to length(models) - 1 do
  begin
    renderModel(Models[i]);
  end;

  if isMousePressed then
    loadModel('res/cube.obj', camera.x, camera.y, camera.z);

  if keys[VK_W] then
  begin
    camera.Z := camera.Z + 1;
    {camera.Z := camera.Z + sin(DegToRad(camera.ry + 90));
    camera.X := camera.X + cos(DegToRad(camera.ry + 90));}
  end;
  if keys[VK_S] then
  begin
    camera.Z := camera.Z - 1;
    {camera.Z := camera.Z - sin(DegToRad(camera.ry + 90));
    camera.X := camera.X - cos(DegToRad(camera.ry + 90));}
  end;
  if keys[VK_Q] then
    camera.Y := camera.Y + 1;
  if keys[VK_E] then
    camera.Y := camera.Y - 1;

  if keys[VK_D] then
  begin
    camera.X := camera.X + 1;
    {camera.Z := camera.Z + sin(DegToRad(camera.ry));
    camera.X := camera.X + cos(DegToRad(camera.ry));}
  end;
  if keys[VK_A] then
  begin
    camera.X := camera.X - 1;
    {camera.Z := camera.Z - sin(DegToRad(camera.ry));
    camera.X := camera.X - cos(DegToRad(camera.ry));}
  end;

  if keys[vk_left] then
  begin
    //camera.rY := camera.rY + 0.5;
    for i := 0 to length(Models) - 1 do
    begin
      for j := 0 to length(Models[i].Vertices) - 1 do
      begin
        camera.ry := camera.ry - 0.017;
        xFN := camera.X + (models[i].Vertices[j].X - camera.X) *
          cos(-0.017) - (models[i].Vertices[j].Z - camera.Z) * sin(-0.017);
        zFN := camera.Z + (models[i].Vertices[j].X - camera.X) *
          sin(-0.017) + (models[i].Vertices[j].Z - camera.Z) * cos(-0.017);
        models[i].Vertices[j].X := xFn;
        models[i].Vertices[j].Z := zFn;
      end;
    end;
  end;

  if keys[vk_right] then
  begin
    //camera.rY := camera.rY - 0.5;
    for i := 0 to length(Models) - 1 do
    begin
      for j := 0 to length(Models[i].Vertices) - 1 do
      begin
        camera.ry := camera.ry + 0.017;
        xFN := camera.X + (models[i].Vertices[j].X - camera.X) *
          cos(+0.017) - (models[i].Vertices[j].Z - camera.Z) * sin(+0.017);
        zFN := camera.Z + (models[i].Vertices[j].X - camera.X) *
          sin(+0.017) + (models[i].Vertices[j].Z - camera.Z) * cos(+0.017);
        models[i].Vertices[j].X := xFn;
        models[i].Vertices[j].Z := zFn;
      end;
    end;
  end;

  if keys[VK_B] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      xFN := models[0].Origin.X + (models[0].Vertices[i].X - models[0].Origin.X) *
        cos(0.017) - (models[0].Vertices[i].Y - models[0].Origin.Y) * sin(0.017);
      yFN := models[0].Origin.Y + (models[0].Vertices[i].X - models[0].Origin.X) *
        sin(0.017) + (models[0].Vertices[i].Y - models[0].Origin.Y) * cos(0.017);
      models[0].Vertices[i].X := xFn;
      models[0].Vertices[i].Y := yFn;
    end;
  end;

  if keys[VK_H] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      xFN := models[0].Origin.X + (models[0].Vertices[i].X - models[0].Origin.X) *
        cos(-0.017) - (models[0].Vertices[i].Y - models[0].Origin.Y) * sin(-0.017);
      yFN := models[0].Origin.Y + (models[0].Vertices[i].X - models[0].Origin.X) *
        sin(-0.017) + (models[0].Vertices[i].Y - models[0].Origin.Y) * cos(-0.017);
      models[0].Vertices[i].X := xFn;
      models[0].Vertices[i].Y := yFn;
    end;
  end;

  if keys[VK_N] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      xFN := models[0].Origin.X + (models[0].Vertices[i].X - models[0].Origin.X) *
        cos(0.017) - (models[0].Vertices[i].Z - models[0].Origin.Z) * sin(0.017);
      zFN := models[0].Origin.Z + (models[0].Vertices[i].X - models[0].Origin.X) *
        sin(0.017) + (models[0].Vertices[i].Z - models[0].Origin.Z) * cos(0.017);
      models[0].Vertices[i].X := xFn;
      models[0].Vertices[i].Z := zFn;
    end;
  end;

  if keys[VK_J] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      xFN := models[0].Origin.X + (models[0].Vertices[i].X - models[0].Origin.X) *
        cos(-0.017) - (models[0].Vertices[i].Z - models[0].Origin.Z) * sin(-0.017);
      zFN := models[0].Origin.Z + (models[0].Vertices[i].X - models[0].Origin.X) *
        sin(-0.017) + (models[0].Vertices[i].Z - models[0].Origin.Z) * cos(-0.017);
      models[0].Vertices[i].X := xFn;
      models[0].Vertices[i].Z := zFn;
    end;
  end;

  if keys[VK_M] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      yFN := models[0].Origin.Y + (models[0].Vertices[i].Y - models[0].Origin.Y) *
        cos(0.017) - (models[0].Vertices[i].Z - models[0].Origin.Z) * sin(0.017);
      zFN := models[0].Origin.Z + (models[0].Vertices[i].Y - models[0].Origin.Y) *
        sin(0.017) + (models[0].Vertices[i].Z - models[0].Origin.Z) * cos(0.017);
      models[0].Vertices[i].Y := yFn;
      models[0].Vertices[i].Z := zFn;
    end;
  end;

  if keys[VK_K] then
  begin
    for i := 0 to Length(models[0].Vertices) - 1 do
    begin
      yFN := models[0].Origin.Y + (models[0].Vertices[i].Y - models[0].Origin.Y) *
        cos(-0.017) - (models[0].Vertices[i].Z - models[0].Origin.Z) * sin(-0.017);
      zFN := models[0].Origin.Z + (models[0].Vertices[i].Y - models[0].Origin.Y) *
        sin(-0.017) + (models[0].Vertices[i].Z - models[0].Origin.Z) * cos(-0.017);
      models[0].Vertices[i].Y := yFn;
      models[0].Vertices[i].Z := zFn;
    end;
  end;

  if mov then
  begin
    dx := xm1 - mouseOrigin.x;
    dy := ym1 - mouseOrigin.y;
    Mouse.CursorPos := mouseorigin;

    camera.ry := camera.ry - (dx * 0.0030);
    camera.rx := camera.rx - (dy * 0.0030);

    for i := 0 to length(Models) - 1 do
    begin
      xFN := camera.X + (models[i].Origin.X - camera.X) * cos(dx * 0.0030) -
        (models[i].Origin.Z - camera.Z) * sin(dx * 0.0030);
      zFN := camera.Z + (models[i].Origin.X - camera.X) * sin(dx * 0.0030) +
        (models[i].Origin.Z - camera.Z) * cos(dx * 0.0030);
      models[i].Origin.X := xFn;
      models[i].Origin.Z := zFn;

      yFN := camera.Y + (models[i].Origin.Y - camera.Y) * cos(dy * 0.0030) -
        (models[i].Origin.Z - camera.Z) * sin(dy * 0.0030);
      zFN := camera.Z + (models[i].Origin.Y - camera.Y) * sin(dy * 0.0030) +
        (models[i].Origin.Z - camera.Z) * cos(dy * 0.0030);
      models[i].Origin.Y := yFn;
      models[i].Origin.Z := zFn;
      for j := 0 to length(Models[i].Vertices) - 1 do
      begin

        xFN := camera.X + (models[i].Vertices[j].X - camera.X) *
          cos(dx * 0.0030) - (models[i].Vertices[j].Z - camera.Z) * sin(dx * 0.0030);
        zFN := camera.Z + (models[i].Vertices[j].X - camera.X) *
          sin(dx * 0.0030) + (models[i].Vertices[j].Z - camera.Z) * cos(dx * 0.0030);
        models[i].Vertices[j].X := xFn;
        models[i].Vertices[j].Z := zFn;


        yFN := camera.Y + (models[i].Vertices[j].Y - camera.Y) *
          cos(dy * 0.0030) - (models[i].Vertices[j].Z - camera.Z) * sin(dy * 0.0030);
        zFN := camera.Z + (models[i].Vertices[j].Y - camera.Y) *
          sin(dy * 0.0030) + (models[i].Vertices[j].Z - camera.Z) * cos(dy * 0.0030);
        models[i].Vertices[j].Y := yFn;
        models[i].Vertices[j].Z := zFn;
      end;
    end;
  end;

  image1.canvas.textout(image1.width-200,image1.height-30,'Rendered with DudEngine v1.2');


  timeNow := Time;
  time1 := timeNow - timeThen;

  //image1.canvas.textout(1500, 15, floattostr(camera.ry));
  //image1.canvas.textout(1500, 30, floattostr(Time2 * 62.5));
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
