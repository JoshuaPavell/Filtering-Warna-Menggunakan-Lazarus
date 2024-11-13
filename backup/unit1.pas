unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, ExtDlgs, Menus, LCLType, FileUtil;

type

  { TForm1 }

  TForm1 = class(TForm)
    Biner: TMenuItem;
    BinerBar: TTrackBar;
    BinerButton: TButton;
    Brightness: TMenuItem;
    BrightnessBar: TTrackBar;
    BrightnessButton: TButton;
    Contras: TMenuItem;
    ContrasBar: TTrackBar;
    ContrasButton: TButton;
    Filter: TLabel;
    GBar: TTrackBar;
    Gray: TMenuItem;
    HPF0: TMenuItem;
    HPF1: TMenuItem;
    ImageAsli: TImage;
    ImageHasil: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelBiner: TLabel;
    LabelBrightness: TLabel;
    LabelContras: TLabel;
    LabelG: TLabel;
    LPF: TMenuItem;
    Memo1: TMemo;
    Proses: TMenuItem;
    MenuKompleks: TLabel;
    Open: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    PopupMenu4: TPopupMenu;
    Quit: TMenuItem;
    Save: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    procedure BinerBarChange(Sender: TObject);
    procedure BinerButtonClick(Sender: TObject);
    procedure BinerClick(Sender: TObject);
    procedure BrightnessBarChange(Sender: TObject);
    procedure BrightnessButtonClick(Sender: TObject);
    procedure BrightnessClick(Sender: TObject);
    procedure ContrasBarChange(Sender: TObject);
    procedure ContrasButtonClick(Sender: TObject);
    procedure ContrasClick(Sender: TObject);
    procedure FilterClick(Sender: TObject);
    procedure GBarChange(Sender: TObject);
    procedure GrayClick(Sender: TObject);
    procedure HPF0Click(Sender: TObject);
    procedure HPF1Click(Sender: TObject);
    procedure ImageHasilClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure LPFClick(Sender: TObject);
    procedure MenuKompleksClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure ProsesClick(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ScrollBox1Click(Sender: TObject);
    procedure DetectEdgesManually;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses windows;
var
bitmapGray                   : array[0..1000, 0..1000] of integer;
bitmapP                      : array[0..1000, 0..1000] of integer;
bitmapPR, BitmapPG, bitmapPB : array[0..1000, 0..1000] of integer;
bitmapPGray                  : array[0..1000, 0..1000] of integer;
bitmapR, bitmapG, bitmapB    : array[0..1000, 0..1000] of integer;
bitmapBiner                  : array[0..1000, 0..1000] of boolean;
BrightR, BrightG, BrightB    : array[0..1000, 0..1000] of Integer;
ContrasR, ContrasG, ContrasB : array[0..1000, 0..1000] of Integer;
Toggle                       : boolean;




procedure TForm1.Label2Click(Sender: TObject);
var
  pt, pt2: TPoint;
begin
  pt.x:=Label2.Left;
  pt.y:=Label2.Top+Label2.Height;

  pt2:=ClientToScreen(pt);

  PopupMenu2.PopUp(pt2.x, pt2.y);
end;

procedure TForm1.LPFClick(Sender: TObject);
var
  x, y, i, j: integer;
  SumR, SumG, SumB: Integer;
  FilterSize: Integer;
  TempPixel: TColor;
  PopulationMatrix: array of array of TPixelInfo;
  TotalPixels: Integer;
begin
  FilterSize := 3; // Ukuran filter (misalnya, 3x3)

  SetLength(PopulationMatrix, ImageHasil.Width, ImageHasil.Height);

  if toggle then
  begin
    // Inisialisasi matriks populasi pixel
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        PopulationMatrix[x, y].Exist := False; // Default: Piksel tidak ada
        PopulationMatrix[x, y].Color := clNone; // Default: Warna tidak ditentukan
      end;
    end;

    TotalPixels := 0; // Inisialisasi total piksel

    for y := FilterSize div 2 to ImageHasil.Height - FilterSize div 2 - 1 do
    begin
      for x := FilterSize div 2 to ImageHasil.Width - FilterSize div 2 - 1 do
      begin
        SumR := 0;
        SumG := 0;
        SumB := 0;

        // Terapkan filter LPF dengan ukuran FilterSize x FilterSize
        for j := -FilterSize div 2 to FilterSize div 2 do
        begin
          for i := -FilterSize div 2 to FilterSize div 2 do
          begin
            TempPixel := ImageHasil.Canvas.Pixels[x + i, y + j];

            // Tandai bahwa piksel ini ada
            PopulationMatrix[x + i, y + j].Exist := True;

            // Simpan warna piksel
            PopulationMatrix[x + i, y + j].Color := TempPixel;

            SumR := SumR + GetRValue(TempPixel);
            SumG := SumG + GetGValue(TempPixel);
            SumB := SumB + GetBValue(TempPixel);
          end;
        end;

        // Hitung nilai rata-rata dan terapkan pada gambar hasil
        ImageHasil.Canvas.Pixels[x, y] := RGB(SumR div (FilterSize * FilterSize), SumG div (FilterSize * FilterSize), SumB div (FilterSize * FilterSize));
      end;
    end;

    // Tampilkan nilai matriks populasi pixel di Memo1
    Memo1.Clear;
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        // Tampilkan informasi tentang piksel
        Memo1.Lines.Add(Format('[%d,%d]: Exist=%s, Color=%s', [x, y, BoolToStr(PopulationMatrix[x, y].Exist, True), ColorToString(PopulationMatrix[x, y].Color)]));

        // Tambahkan total piksel jika piksel ada
        if PopulationMatrix[x, y].Exist then
          Inc(TotalPixels);
      end;
    end;

    // Tampilkan total piksel yang ada
    Memo1.Lines.Add(Format('Total Pixels: %d', [TotalPixels]));
  end;

  toggle := not toggle; // Toggle mode
end;

procedure TForm1.MenuKompleksClick(Sender: TObject);
var
  pt, pt2: TPoint;
begin
  pt.x:=MenuKompleks.Left;
  pt.y:=MenuKompleks.Top+MenuKompleks.Height;

  pt2:=ClientToScreen(pt);

  PopupMenu3.PopUp(pt2.x, pt2.y);
end;

procedure TForm1.OpenClick(Sender: TObject);
var
x, y : integer;
begin
    if (OpenPictureDialog1.Execute) then
    begin
      ImageAsli.Picture.LoadFromFile(OpenPictureDialog1.FileName);
      for y:=0 to imageAsli.Height-1 do
      begin
           for x:=0 to imageAsli.Width-1 do
             begin
             bitmapR[x,y] := GetRValue(imageAsli.Canvas.Pixels[x,y]);
             bitmapG[x,y] := GetGValue(imageAsli.Canvas.Pixels[x,y]);
             bitmapB[x,y] := GetBValue(imageAsli.Canvas.Pixels[x,y]);
             bitmapGray[x,y] := (BitmapR[x,y] + BitmapG[x,y] + BitmapB[x,y]) div 3;
            end;
        end;
    end;
      ImageHasil.Width:=ImageAsli.Width;
      ImageHasil.Height:=ImageAsli.Height;
      ImageHasil.Top:=ImageAsli.Top;
      ImageHasil.Left:=ImageAsli.Left;
      Toggle := false;

      //ExtractEdges; // Ekstraksi tepi
      //FindCircles; // Pengenalan lingkaran
end;

procedure TForm1.DetectEdgesManually;
var
  x, y: Integer;
  Gx, Gy: Integer;
  Gradient: Integer;
  Threshold: Integer;
begin
  for y := 1 to ImageAsli.Height - 2 do
  begin
    for x := 1 to ImageAsli.Width - 2 do
    begin
      // Manual: Sobel operator untuk deteksi tepi horizontal dan vertikal
      Gx :=
        (-1 * bitmapGray[x - 1, y - 1]) + (0 * bitmapGray[x, y - 1]) + (1 * bitmapGray[x + 1, y - 1]) +
        (-2 * bitmapGray[x - 1, y]) + (0 * bitmapGray[x, y]) + (2 * bitmapGray[x + 1, y]) +
        (-1 * bitmapGray[x - 1, y + 1]) + (0 * bitmapGray[x, y + 1]) + (1 * bitmapGray[x + 1, y + 1]);

      Gy :=
        (-1 * bitmapGray[x - 1, y - 1]) + (-2 * bitmapGray[x, y - 1]) + (-1 * bitmapGray[x + 1, y - 1]) +
        (0 * bitmapGray[x - 1, y]) + (0 * bitmapGray[x, y]) + (0 * bitmapGray[x + 1, y]) +
        (1 * bitmapGray[x - 1, y + 1]) + (2 * bitmapGray[x, y + 1]) + (1 * bitmapGray[x + 1, y + 1]);

      // Magnitude gradien
      Gradient := Round(Sqrt(Gx * Gx + Gy * Gy));

      // Ambang batas untuk menentukan piksel tepi
      Threshold := 128;

      if Gradient > Threshold then
        ImageHasil.Canvas.Pixels[x, y] := clBlack
      else
        ImageHasil.Canvas.Pixels[x, y] := clWhite;
    end;
  end;

  //ImageHasil.Picture.Assign(ImageAsli);
end;



procedure TForm1.ProsesClick(Sender: TObject);
Begin
  DetectEdgesManually;
end;




procedure TForm1.QuitClick(Sender: TObject);
begin
    close;
end;


procedure TForm1.SaveClick(Sender: TObject);
begin
  if (SavePictureDialog1.Execute) then
  begin
    ImageHasil.Picture.SaveToFile (SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.ScrollBox1Click(Sender: TObject);
begin

end;

procedure TForm1.Label1Click(Sender: TObject);
var
  pt, pt2: TPoint;
begin
  pt.x:=Label1.Left;
  pt.y:=Label1.Top+Label1.Height;

  pt2:=ClientToScreen(pt);

  PopupMenu1.PopUp(pt2.x, pt2.y);
end;

procedure TForm1.FilterClick(Sender: TObject);
var
  pt, pt2: TPoint;
begin
  pt.x:=Filter.Left;
  pt.y:=Filter.Top+Filter.Height;

  pt2:=ClientToScreen(pt);

  PopupMenu4.PopUp(pt2.x, pt2.y);
end;

procedure TForm1.GBarChange(Sender: TObject);
begin
  LabelG.Caption:=('G:'+IntToStr(Gbar.Position));
end;

procedure TForm1.GrayClick(Sender: TObject);
var
  x, y: integer;
begin
  // Sembunyikan kontrol UI yang tidak diperlukan
  LabelBrightness.Visible := False;
  BrightnessBar.Visible := False;
  LabelBiner.Visible := False;
  BinerBar.Visible := False;
  LabelContras.Visible := False;
  ContrasBar.Visible := False;
  LabelG.Visible := False;
  GBar.Visible := False;
  BrightnessButton.Visible := False;
  BinerButton.Visible := False;
  ContrasButton.Visible := False;

  // Konversi citra ke grayscale
  for y := 0 to ImageAsli.Height - 1 do
  begin
    for x := 0 to ImageAsli.Width - 1 do
    begin
      ImageHasil.Canvas.Pixels[x, y] := RGB(bitmapGray[x, y], bitmapGray[x, y], bitmapGray[x, y]);

      // Perbarui nilai grayscale
      bitmapR[x, y] := GetRValue(ImageHasil.Canvas.Pixels[x, y]);
      bitmapG[x, y] := GetGValue(ImageHasil.Canvas.Pixels[x, y]);
      bitmapB[x, y] := GetBValue(ImageHasil.Canvas.Pixels[x, y]);
      bitmapGray[x, y] := (bitmapR[x, y] + bitmapG[x, y] + bitmapB[x, y]) div 3;
    end;
  end;

  // Tampilkan kembali kontrol UI jika diperlukan
  // Misalnya: Anda ingin menampilkannya setelah operasi grayscale selesai
  // LabelBrightness.Visible := True;
  // BrightnessBar.Visible := True;
  // ...
end;


procedure TForm1.HPF0Click(Sender: TObject);
var
  i, j: integer;
begin
  if toggle = true then
  begin
    for j := 1 to ImageHasil.Height - 2 do
    begin
      for i := 1 to ImageHasil.Width - 2 do
      begin
        bitmapP[i, j] := (
          (-1 * BitmapPGray[i - 1, j - 1]) + (-1 * BitmapPGray[i, j - 1]) + (-1 * BitmapPGray[i + 1, j - 1]) +
          (-1 * BitmapPGray[i - 1, j]) + (8 * BitmapPGray[i, j]) + (-1 * BitmapPGray[i + 1, j]) +
          (-1 * BitmapPGray[i - 1, j + 1]) + (-1 * BitmapPGray[i, j + 1]) + (-1 * BitmapPGray[i + 1, j + 1])
        );

        if bitmapP[i, j] < 0 then
          bitmapP[i, j] := 0;
        if bitmapP[i, j] > 255 then
          bitmapP[i, j] := 255;

        ImageHasil.Canvas.Pixels[i, j] := RGB(bitmapP[i, j], bitmapP[i, j], bitmapP[i, j]);
      end;
    end;
  end;

  if toggle = false then
  begin
    for j := 1 to ImageHasil.Height - 2 do
    begin
      for i := 1 to ImageHasil.Width - 2 do
      begin
        bitmapP[i, j] := (
          (-1 * BitmapGray[i - 1, j - 1]) + (-1 * BitmapGray[i, j - 1]) + (-1 * BitmapGray[i + 1, j - 1]) +
          (-1 * BitmapGray[i - 1, j]) + (8 * BitmapGray[i, j]) + (-1 * BitmapGray[i + 1, j]) +
          (-1 * BitmapGray[i - 1, j + 1]) + (-1 * BitmapGray[i, j + 1]) + (-1 * BitmapGray[i + 1, j + 1])
        );

        if bitmapP[i, j] < 0 then
          bitmapP[i, j] := 0;
        if bitmapP[i, j] > 255 then
          bitmapP[i, j] := 255;

        ImageHasil.Canvas.Pixels[i, j] := RGB(bitmapP[i, j], bitmapP[i, j], bitmapP[i, j]);
      end;
    end;
  end;
end;



procedure TForm1.HPF1Click(Sender: TObject);
var
  i, j: integer;
begin
  if toggle = true then
  begin
    for j := 1 to ImageHasil.Height - 2 do
    begin
      for i := 1 to ImageHasil.Width - 2 do
      begin
        bitmapP[i, j] := (
          (1 * BitmapPGray[i - 1, j - 1]) + (1 * BitmapPGray[i, j - 1]) + (1 * BitmapPGray[i + 1, j - 1]) +
          (1 * BitmapPGray[i - 1, j]) + (-8 * BitmapPGray[i, j]) + (1 * BitmapPGray[i + 1, j]) +
          (1 * BitmapPGray[i - 1, j + 1]) + (1 * BitmapPGray[i, j + 1]) + (1 * BitmapPGray[i + 1, j + 1])
        );

        if bitmapP[i, j] < 0 then
          bitmapP[i, j] := 0;
        if bitmapP[i, j] > 255 then
          bitmapP[i, j] := 255;

        ImageHasil.Canvas.Pixels[i, j] := RGB(bitmapP[i, j], bitmapP[i, j], bitmapP[i, j]);
      end;
    end;
  end;

  if toggle = false then
  begin
    for j := 1 to ImageHasil.Height - 2 do
    begin
      for i := 1 to ImageHasil.Width - 2 do
      begin
        bitmapP[i, j] := (
          (1 * BitmapGray[i - 1, j - 1]) + (1 * BitmapGray[i, j - 1]) + (1 * BitmapGray[i + 1, j - 1]) +
          (1 * BitmapGray[i - 1, j]) + (-8 * BitmapGray[i, j]) + (1 * BitmapGray[i + 1, j]) +
          (1 * BitmapGray[i - 1, j + 1]) + (1 * BitmapGray[i, j + 1]) + (1 * BitmapGray[i + 1, j + 1])
        );

        if bitmapP[i, j] < 0 then
          bitmapP[i, j] := 0;
        if bitmapP[i, j] > 255 then
          bitmapP[i, j] := 255;

        ImageHasil.Canvas.Pixels[i, j] := RGB(bitmapP[i, j], bitmapP[i, j], bitmapP[i, j]);
      end;
    end;
  end;
end;

procedure TForm1.ImageHasilClick(Sender: TObject);
begin

end;


procedure TForm1.BrightnessBarChange(Sender: TObject);
begin
   LabelBrightness.Caption:=IntToStr(BrightnessBar.Position);
end;

procedure TForm1.BrightnessButtonClick(Sender: TObject);
var
  x, y: integer;
begin
  if toggle = true then
  begin
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        BrightR[x, y] := bitmapPR[x, y] + BrightnessBar.Position;
        if BrightR[x, y] > 255 then BrightR[x, y] := 255;
        if BrightR[x, y] < 0 then BrightR[x, y] := 0;
        BrightG[x, y] := bitmapPG[x, y] + BrightnessBar.Position;
        if BrightG[x, y] > 255 then BrightG[x, y] := 255;
        if BrightG[x, y] < 0 then BrightG[x, y] := 0;
        BrightB[x, y] := bitmapPB[x, y] + BrightnessBar.Position;
        if BrightB[x, y] > 255 then BrightB[x, y] := 255;
        if BrightB[x, y] < 0 then BrightB[x, y] := 0;

        ImageHasil.Canvas.Pixels[x, y] := RGB(BrightR[x, y], BrightG[x, y], BrightB[x, y]);

        // Perbarui nilai grayscale di sini jika Anda ingin citra tetap grayscale
        bitmapPGray[x, y] := (BitmapPR[x, y] + BitmapPG[x, y] + BitmapPB[x, y]) div 3;
      end;
    end;
  end
  else
  begin
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        BrightR[x, y] := bitmapR[x, y] + BrightnessBar.Position;
        if BrightR[x, y] > 255 then BrightR[x, y] := 255;
        if BrightR[x, y] < 0 then BrightR[x, y] := 0;
        BrightG[x, y] := bitmapG[x, y] + BrightnessBar.Position;
        if BrightG[x, y] > 255 then BrightG[x, y] := 255;
        if BrightG[x, y] < 0 then BrightG[x, y] := 0;
        BrightB[x, y] := bitmapB[x, y] + BrightnessBar.Position;
        if BrightB[x, y] > 255 then BrightB[x, y] := 255;
        if BrightB[x, y] < 0 then BrightB[x, y] := 0;

        ImageHasil.Canvas.Pixels[x, y] := RGB(BrightR[x, y], BrightG[x, y], BrightB[x, y]);
      end;
    end;

    // Perbarui nilai grayscale di sini jika Anda ingin citra tetap grayscale
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        bitmapPR[x, y] := GetRValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPG[x, y] := GetGValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPB[x, y] := GetBValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPGray[x, y] := (BitmapPR[x, y] + BitmapPG[x, y] + BitmapPB[x, y]) div 3;
      end;
    end;

    toggle := true;
  end;
end;


procedure TForm1.BrightnessClick(Sender: TObject);
begin
  LabelBrightness.Visible := False;
  BrightnessBar.Visible := False;
  LabelBiner.Visible := False;
  BinerBar.Visible := False;
  LabelContras.Visible := False;
  ContrasBar.Visible := False;
  LabelG.Visible := False;
  GBar.Visible := False;
  BrightnessButton.Visible := False;
  BinerButton.Visible := False;
  ContrasButton.Visible := False;
  LabelBrightness.Visible := True;
  BrightnessBar.Visible := True;
  BrightnessButton.Visible := True;
end;

procedure TForm1.ContrasBarChange(Sender: TObject);
begin
    LabelContras.Caption:=IntToStr(ContrasBar.Position);
end;

procedure TForm1.ContrasButtonClick(Sender: TObject);
var
 x,y : integer;
begin
if toggle = true then
   begin
      for y:=0 to ImageHasil.Height-1 do
    begin
       for x:=0 to ImageHasil.Width-1 do
       begin
            ContrasR[x,y] := GBar.Position * (BitmapPR[x,y]-ContrasBar.Position) + ContrasBar.Position;
            if ContrasR[x,y] > 255 then ContrasR[x,y] := 255;
            if ContrasR[x,y] < 0   then ContrasR[x,y] := 0;
            ContrasG[x,y] := GBar.Position * (BitmapPG[x,y]-ContrasBar.Position) + ContrasBar.Position;
            if ContrasG[x,y] > 255 then ContrasG[x,y] := 255;
            if ContrasG[x,y] < 0   then ContrasG[x,y] := 0;
            ContrasB[x,y] := GBar.Position * (BitmapPB[x,y]-ContrasBar.Position) + ContrasBar.Position;
            if ContrasB[x,y] > 255 then ContrasB[x,y] := 255;
            if ContrasB[x,y] < 0   then ContrasB[x,y] := 0;
            ImageHasil.Canvas.Pixels[x,y] := RGB(ContrasR[x,y],ContrasG[x,y],ContrasB[x,y]);
       end;
    end;
    for y:=0 to ImageHasil.Height-1 do
    begin
       for x:=0 to ImageHasil.Width-1 do
       begin
        bitmapPR[x,y] := GetRValue(ImageHasil.Canvas.Pixels[x,y]);
        bitmapPG[x,y] := GetGValue(ImageHasil.Canvas.Pixels[x,y]);
        bitmapPB[x,y] := GetBValue(ImageHasil.Canvas.Pixels[x,y]);
        bitmapPGray[x,y] := (BitmapPR[x,y] + BitmapPG[x,y] + BitmapPB[x,y]) div 3;
       end;
    end;
   end;
if toggle = false then
  begin
    for y:=0 to ImageHasil.Height-1 do
      begin
         for x:=0 to ImageHasil.Width-1 do
         begin
              ContrasR[x,y] := GBar.Position * (BitmapR[x,y]-ContrasBar.Position) + ContrasBar.Position;
              if ContrasR[x,y] > 255 then ContrasR[x,y] := 255;
              if ContrasR[x,y] < 0   then ContrasR[x,y] := 0;
              ContrasG[x,y] := GBar.Position * (BitmapG[x,y]-ContrasBar.Position) + ContrasBar.Position;
              if ContrasG[x,y] > 255 then ContrasG[x,y] := 255;
              if ContrasG[x,y] < 0   then ContrasG[x,y] := 0;
              ContrasB[x,y] := GBar.Position * (BitmapB[x,y]-ContrasBar.Position) + ContrasBar.Position;
              if ContrasB[x,y] > 255 then ContrasB[x,y] := 255;
              if ContrasB[x,y] < 0   then ContrasB[x,y] := 0;
              ImageHasil.Canvas.Pixels[x,y] := RGB(ContrasR[x,y],ContrasG[x,y],ContrasB[x,y]);
         end;
      end;
      for y:=0 to ImageHasil.Height-1 do
      begin
         for x:=0 to ImageHasil.Width-1 do
         begin
          bitmapPR[x,y] := GetRValue(ImageHasil.Canvas.Pixels[x,y]);
          bitmapPG[x,y] := GetGValue(ImageHasil.Canvas.Pixels[x,y]);
          bitmapPB[x,y] := GetBValue(ImageHasil.Canvas.Pixels[x,y]);
          bitmapPGray[x,y] := (BitmapPR[x,y] + BitmapPG[x,y] + BitmapPB[x,y]) div 3;
         end;
      end;
     toggle := true;
  end;
end;


procedure TForm1.ContrasClick(Sender: TObject);
begin
  LabelBrightness.Visible := False;
  BrightnessBar.Visible := False;
  LabelBiner.Visible := False;
  BinerBar.Visible := False;
  LabelContras.Visible := False;
  ContrasBar.Visible := False;
  LabelG.Visible := False;
  GBar.Visible := False;
  BrightnessButton.Visible := False;
  BinerButton.Visible := False;
  ContrasButton.Visible := False;
  ContrasBar.Top:=BrightnessBar.Top;
  ContrasBar.Left:=BrightnessBar.Left;
  LabelContras.Top:=LabelBrightness.Top;
  LabelContras.Left:=LabelBrightness.Left;
  LabelContras.Visible := True;
  ContrasBar.Visible := True;
  LabelG.Visible := True;
  GBar.Visible := True;
  ContrasButton.Visible := True;
  GBar.Top:=BrightnessBar.Top + 5 + BrightnessBar.Height;;
  GBar.Left:=BrightnessBar.Left;
  LabelG.Top:=labelBrightness.Top + 5 + LabelBrightness.Height;;
  LabelG.Left:=LabelBrightness.Left;
  ContrasButton.Top:=BrightnessButton.Top;
  ContrasButton.Left:=BrightnessButton.Left;

end;

procedure TForm1.BinerBarChange(Sender: TObject);
begin
    LabelBiner.Caption:=IntToStr(BinerBar.Position);
end;

procedure TForm1.BinerButtonClick(Sender: TObject);
var
  x, y: integer;
  R, G, B: Byte;
  GrayValue: Byte;
begin
  if toggle = true then
  begin
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        ImageHasil.Canvas.Pixels[x, y] := RGB(BitmapPGray[x, y], BitmapPGray[x, y], BitmapPGray[x, y]);
        if BinerBar.Position <= BitmapPGray[x, y] then
          bitmapBiner[x, y] := True
        else
          bitmapBiner[x, y] := False;
        if bitmapBiner[x, y] = True then
          ImageHasil.Canvas.Pixels[x, y] := RGB(255, 255, 255)
        else
          ImageHasil.Canvas.Pixels[x, y] := RGB(0, 0, 0);

        // Perbarui array grayscale
        bitmapPR[x, y] := GetRValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPG[x, y] := GetGValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPB[x, y] := GetBValue(ImageHasil.Canvas.Pixels[x, y]);
        bitmapPGray[x, y] := (bitmapPR[x, y] + bitmapPG[x, y] + bitmapPB[x, y]) div 3;
      end;
    end;
  end
  else
  begin
    for y := 0 to ImageHasil.Height - 1 do
    begin
      for x := 0 to ImageHasil.Width - 1 do
      begin
        ImageHasil.Canvas.Pixels[x, y] := RGB(BitmapGray[x, y], BitmapGray[x, y], BitmapGray[x, y]);
        if BinerBar.Position <= BitmapGray[x, y] then
          bitmapBiner[x, y] := True
        else
          bitmapBiner[x, y] := False;
        if bitmapBiner[x, y] = True then
          ImageHasil.Canvas.Pixels[x, y] := RGB(255, 255, 255)
        else
          ImageHasil.Canvas.Pixels[x, y] := RGB(0, 0, 0);

        // Perbarui array grayscale
        R := GetRValue(ImageHasil.Canvas.Pixels[x, y]);
        G := GetGValue(ImageHasil.Canvas.Pixels[x, y]);
        B := GetBValue(ImageHasil.Canvas.Pixels[x, y]);
        GrayValue := (R + G + B) div 3;
        bitmapGray[x, y] := GrayValue;
      end;
    end;
    BinerButton.Top := BrightnessButton.Top;
    BinerButton.Left := BrightnessButton.Left;
    toggle := true;
  end;
end;


procedure TForm1.BinerClick(Sender: TObject);
begin
  LabelBrightness.Visible := False;
  BrightnessBar.Visible := False;
  LabelBiner.Visible := False;
  BinerBar.Visible := False;
  LabelContras.Visible := False;
  ContrasBar.Visible := False;
  LabelG.Visible := False;
  GBar.Visible := False;
  BrightnessButton.Visible := False;
  BinerButton.Visible := False;
  ContrasButton.Visible := False;
  BinerBar.Top:=BrightnessBar.Top;
  BinerBar.Left:=BrightnessBar.Left;
  LabelBiner.Top:=LabelBrightness.Top;
  LabelBiner.Left:=LabelBrightness.Left;
  BinerButton.Top:=BrightnessButton.Top;
  BinerButton.Left:=BrightnessButton.Left;
  LabelBiner.Visible := True;
  BinerBar.Visible := True;
  BinerButton.Visible := True;
end;

end.

