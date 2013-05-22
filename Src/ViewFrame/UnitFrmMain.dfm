object frmMain: TfrmMain
  Left = 209
  Top = 98
  Width = 1024
  Height = 738
  Caption = #20998#24418#39118#26292'2'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  Menu = MainfrmMenu
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 733
    Top = 147
    Height = 527
    Align = alRight
    Visible = False
  end
  object Splitter2: TSplitter
    Left = 1005
    Top = 147
    Height = 527
    Align = alRight
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1008
    Height = 147
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object GroupBoxColorChange: TGroupBox
      Left = 249
      Top = 2
      Width = 504
      Height = 143
      Align = alLeft
      TabOrder = 0
      object GroupBox5: TGroupBox
        Left = 376
        Top = 16
        Width = 113
        Height = 121
        Caption = #39068#33394#28176#21464#24378#24230
        TabOrder = 0
        object Label23: TLabel
          Left = 9
          Top = 73
          Width = 36
          Height = 12
          Caption = #31995#25968'2:'
        end
        object Label22: TLabel
          Left = 9
          Top = 49
          Width = 36
          Height = 12
          Caption = #31995#25968'1:'
        end
        object Label21: TLabel
          Left = 9
          Top = 25
          Width = 36
          Height = 12
          Caption = #31995#25968'0:'
        end
        object editRun_RandColorK0: TEdit
          Left = 48
          Top = 20
          Width = 57
          Height = 20
          TabOrder = 0
          Text = '1'
          OnChange = editRun_RandColorChange
          OnKeyPress = editRun_RandColorKeyPress
        end
        object editRun_RandColorK1: TEdit
          Left = 48
          Top = 44
          Width = 57
          Height = 20
          TabOrder = 1
          Text = '1'
          OnKeyPress = editRun_RandColorKeyPress
        end
        object editRun_RandColorK2: TEdit
          Left = 48
          Top = 68
          Width = 57
          Height = 20
          TabOrder = 2
          Text = '1'
          OnKeyPress = editRun_RandColorKeyPress
        end
        object btnRun_RandColorK_Up: TButton
          Left = 16
          Top = 92
          Width = 41
          Height = 22
          Caption = #22686#24378
          TabOrder = 3
          OnClick = btnRun_RandColorK_UpClick
        end
        object btnRun_RandColorK_Down: TButton
          Left = 60
          Top = 92
          Width = 41
          Height = 22
          Caption = #20943#24369
          TabOrder = 4
          OnClick = btnRun_RandColorK_DownClick
        end
      end
      object GroupBox7: TGroupBox
        Left = 8
        Top = 16
        Width = 361
        Height = 121
        Caption = #39068#33394#20559#31227
        TabOrder = 1
        object Label16: TLabel
          Left = 9
          Top = 25
          Width = 36
          Height = 12
          Caption = #20559#31227'0:'
        end
        object Label17: TLabel
          Left = 9
          Top = 49
          Width = 36
          Height = 12
          Caption = #20559#31227'1:'
        end
        object Label18: TLabel
          Left = 9
          Top = 73
          Width = 36
          Height = 12
          Caption = #20559#31227'2:'
        end
        object btnSetRandColoring: TButton
          Left = 128
          Top = 87
          Width = 65
          Height = 25
          Caption = #38543#26426#20559#31227
          TabOrder = 0
          OnClick = btnSetRandColoringClick
        end
        object TrackBarColor0: TTrackBar
          Left = 99
          Top = 20
          Width = 256
          Height = 17
          LineSize = 20
          Max = 256
          PageSize = 20
          TabOrder = 1
          ThumbLength = 15
          TickStyle = tsNone
          OnChange = TrackBarColorChange
        end
        object TrackBarColor1: TTrackBar
          Left = 99
          Top = 44
          Width = 256
          Height = 17
          LineSize = 20
          Max = 256
          PageSize = 20
          TabOrder = 2
          ThumbLength = 15
          TickStyle = tsNone
          OnChange = TrackBarColorChange
        end
        object TrackBarColor2: TTrackBar
          Left = 99
          Top = 68
          Width = 256
          Height = 17
          LineSize = 20
          Max = 256
          PageSize = 20
          TabOrder = 3
          ThumbLength = 15
          TickStyle = tsNone
          OnChange = TrackBarColorChange
        end
        object editRun_RandColor2: TEdit
          Left = 48
          Top = 68
          Width = 57
          Height = 20
          TabOrder = 4
          Text = '0'
          OnChange = editRun_RandColorChange
          OnKeyPress = editRun_RandColorKeyPress
        end
        object editRun_RandColor1: TEdit
          Left = 48
          Top = 44
          Width = 57
          Height = 20
          TabOrder = 5
          Text = '0'
          OnChange = editRun_RandColorChange
          OnKeyPress = editRun_RandColorKeyPress
        end
        object editRun_RandColor0: TEdit
          Left = 48
          Top = 20
          Width = 57
          Height = 20
          TabOrder = 6
          Text = '0'
          OnChange = editRun_RandColorChange
          OnKeyPress = editRun_RandColorKeyPress
        end
        object btnColoringUpdate: TButton
          Left = 216
          Top = 87
          Width = 65
          Height = 25
          Caption = #20445#23384#35774#32622
          Enabled = False
          TabOrder = 7
          OnClick = btnColoringUpdateClick
        end
      end
    end
    object Panel6: TPanel
      Left = 2
      Top = 2
      Width = 247
      Height = 143
      Align = alLeft
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 1
      object Label19: TLabel
        Left = 83
        Top = 25
        Width = 18
        Height = 12
        Caption = #23485':'
      end
      object Label20: TLabel
        Left = 163
        Top = 25
        Width = 18
        Height = 12
        Caption = #39640':'
      end
      object Label10: TLabel
        Left = 83
        Top = 72
        Width = 18
        Height = 12
        Caption = #23485':'
      end
      object Label11: TLabel
        Left = 163
        Top = 72
        Width = 18
        Height = 12
        Caption = #39640':'
      end
      object btnStop: TButton
        Left = 8
        Top = 106
        Width = 67
        Height = 25
        Caption = #20572#27490#32472#21046
        TabOrder = 0
        OnClick = btnStopClick
      end
      object editColoringWidth: TEdit
        Left = 104
        Top = 21
        Width = 57
        Height = 20
        TabOrder = 1
        Text = '640'
      end
      object editColoringHeight: TEdit
        Left = 184
        Top = 21
        Width = 57
        Height = 20
        TabOrder = 2
        Text = '480'
      end
      object btnRunAsColoring: TButton
        Left = 10
        Top = 19
        Width = 65
        Height = 25
        Caption = #29983#25104#39044#35272#22270
        TabOrder = 3
        OnClick = btnRunAsColoringClick
      end
      object btnRunAsPic: TButton
        Left = 8
        Top = 66
        Width = 67
        Height = 25
        Caption = #29983#25104#22270#29255
        TabOrder = 4
        OnClick = btnRunAsPicClick
      end
      object editPicWidth: TEdit
        Left = 104
        Top = 68
        Width = 57
        Height = 20
        TabOrder = 5
        Text = '2000'
      end
      object editPicHeight: TEdit
        Left = 184
        Top = 68
        Width = 57
        Height = 20
        TabOrder = 6
        Text = '1500'
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 147
    Width = 733
    Height = 527
    Align = alClient
    TabOrder = 1
    object ScrollBox: TScrollBox
      Left = 1
      Top = 1
      Width = 731
      Height = 525
      HorzScrollBar.Tracking = True
      VertScrollBar.Tracking = True
      Align = alClient
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      OnResize = ScrollBoxResize
      object PaintBox: TPaintBox
        Left = 25
        Top = 18
        Width = 432
        Height = 327
        Cursor = crCross
        Color = clBlack
        ParentColor = False
        OnMouseDown = PaintBoxMouseDown
        OnMouseMove = PaintBoxMouseMove
        OnMouseUp = PaintBoxMouseUp
        OnPaint = PaintBoxPaint
      end
      object ShapeSelectRect: TShape
        Left = 192
        Top = 136
        Width = 153
        Height = 97
        Enabled = False
        Pen.Mode = pmMask
        Pen.Style = psDot
        Visible = False
        OnMouseDown = ShapeSelectRectMouseDown
      end
    end
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 674
    Width = 1008
    Height = 8
    Align = alBottom
    Max = 1000
    Smooth = True
    TabOrder = 2
  end
  object Panel7: TPanel
    Left = 736
    Top = 147
    Width = 269
    Height = 527
    Align = alRight
    TabOrder = 3
    object MemoOutInfo: TMemo
      Left = 1
      Top = 452
      Width = 267
      Height = 74
      Align = alBottom
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object PageControl1: TPageControl
      Left = -1
      Top = 1
      Width = 269
      Height = 451
      ActivePage = TabSheet1
      Align = alRight
      TabOrder = 1
      object TabSheet1: TTabSheet
        Caption = #20998#24418#26041#31243
        object ScrollBoxK: TScrollBox
          Left = 0
          Top = 0
          Width = 262
          Height = 424
          HorzScrollBar.Tracking = True
          VertScrollBar.Position = 213
          VertScrollBar.Tracking = True
          Align = alLeft
          TabOrder = 0
          object Panel2: TPanel
            Left = 0
            Top = -215
            Width = 238
            Height = 635
            BevelOuter = bvNone
            Font.Charset = GB2312_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #23435#20307
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object Label3: TLabel
              Left = 8
              Top = 206
              Width = 126
              Height = 12
              Caption = #25552#21069#32456#27490#36845#20195#26465#20214#26041#31243':'
            end
            object Label4: TLabel
              Left = 8
              Top = 186
              Width = 78
              Height = 12
              Caption = #26368#22823#36845#20195#27425#25968':'
            end
            object Label1: TLabel
              Left = 8
              Top = 16
              Width = 78
              Height = 12
              Caption = #20998#24418#26041#31243#21517#31216':'
            end
            object Label2: TLabel
              Left = 8
              Top = 35
              Width = 78
              Height = 12
              Caption = #26041#31243' next x:='
            end
            object Label15: TLabel
              Left = 8
              Top = 108
              Width = 78
              Height = 12
              Caption = #26041#31243' next y:='
            end
            object memoStopFunction: TMemo
              Left = 8
              Top = 220
              Width = 225
              Height = 42
              ScrollBars = ssVertical
              TabOrder = 4
            end
            object editMaxi: TEdit
              Left = 88
              Top = 182
              Width = 145
              Height = 20
              TabOrder = 3
              Text = '1000'
            end
            object GroupBox1: TGroupBox
              Left = 8
              Top = 267
              Width = 227
              Height = 118
              Caption = #33539#22260'('#20013#24515' '#21322#24452' '#35282#24230'):'
              TabOrder = 5
              object Label5: TLabel
                Left = 9
                Top = 24
                Width = 18
                Height = 12
                Caption = 'x0:'
              end
              object Label7: TLabel
                Left = 9
                Top = 48
                Width = 18
                Height = 12
                Caption = 'y0:'
              end
              object Label8: TLabel
                Left = 9
                Top = 72
                Width = 12
                Height = 12
                Caption = 'r:'
              end
              object Label9: TLabel
                Left = 8
                Top = 96
                Width = 54
                Height = 12
                Caption = #26059#36716#35282#24230':'
              end
              object Label12: TLabel
                Left = 184
                Top = 80
                Width = 20
                Height = 20
                Caption = #12290
                Font.Charset = GB2312_CHARSET
                Font.Color = clWindowText
                Font.Height = -20
                Font.Name = #23435#20307
                Font.Style = []
                ParentFont = False
              end
              object Label13: TLabel
                Left = 194
                Top = 96
                Width = 12
                Height = 12
                Caption = #24230
              end
              object editX0: TEdit
                Left = 32
                Top = 19
                Width = 185
                Height = 20
                TabOrder = 0
              end
              object editY0: TEdit
                Left = 32
                Top = 43
                Width = 185
                Height = 20
                TabOrder = 1
              end
              object editR: TEdit
                Left = 32
                Top = 67
                Width = 185
                Height = 20
                TabOrder = 2
              end
              object editSeta: TEdit
                Left = 64
                Top = 91
                Width = 121
                Height = 20
                TabOrder = 3
                Text = '0'
              end
            end
            object GroupBox2: TGroupBox
              Left = 8
              Top = 392
              Width = 227
              Height = 233
              Caption = #39068#33394#26041#26696':'
              TabOrder = 6
              object lbColor0: TLabel
                Left = 8
                Top = 49
                Width = 96
                Height = 12
                Caption = #26041#31243' '#39068#33394#20998#37327'0:='
              end
              object lbColor1: TLabel
                Left = 8
                Top = 109
                Width = 96
                Height = 12
                Caption = #26041#31243' '#39068#33394#20998#37327'1:='
              end
              object lbColor2: TLabel
                Left = 8
                Top = 169
                Width = 96
                Height = 12
                Caption = #26041#31243' '#39068#33394#20998#37327'2:='
              end
              object memoColorFunction0: TMemo
                Left = 10
                Top = 63
                Width = 207
                Height = 42
                ScrollBars = ssVertical
                TabOrder = 1
              end
              object Panel3: TPanel
                Left = 2
                Top = 14
                Width = 223
                Height = 28
                Align = alTop
                BevelInner = bvRaised
                BevelOuter = bvLowered
                TabOrder = 0
                object rbtnRGB: TRadioButton
                  Left = 14
                  Top = 6
                  Width = 51
                  Height = 17
                  Caption = 'RGB'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  OnClick = rbtnColorTypeClick
                end
                object rbtnHLS: TRadioButton
                  Left = 78
                  Top = 6
                  Width = 51
                  Height = 17
                  Caption = 'HLS'
                  TabOrder = 1
                  OnClick = rbtnColorTypeClick
                end
                object rbtnYUV: TRadioButton
                  Left = 137
                  Top = 7
                  Width = 51
                  Height = 17
                  Caption = 'YUV'
                  TabOrder = 2
                  OnClick = rbtnColorTypeClick
                end
              end
              object memoColorFunction1: TMemo
                Left = 10
                Top = 123
                Width = 207
                Height = 42
                ScrollBars = ssVertical
                TabOrder = 2
              end
              object memoColorFunction2: TMemo
                Left = 10
                Top = 183
                Width = 207
                Height = 42
                ScrollBars = ssVertical
                TabOrder = 3
              end
            end
            object editFractalName: TEdit
              Left = 88
              Top = 8
              Width = 145
              Height = 20
              TabOrder = 0
            end
            object memoLoopXFanction: TMemo
              Left = 8
              Top = 49
              Width = 225
              Height = 54
              ScrollBars = ssVertical
              TabOrder = 1
            end
            object memoLoopYFanction: TMemo
              Left = 8
              Top = 122
              Width = 225
              Height = 54
              ScrollBars = ssVertical
              TabOrder = 2
            end
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = #21382#21490#35760#24405
        ImageIndex = 1
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 261
          Height = 424
          Align = alClient
          TabOrder = 0
          object ImageHistoryWiew: TImage
            Left = 1
            Top = 1
            Width = 259
            Height = 100
            Align = alTop
            Center = True
          end
          object GroupBox3: TGroupBox
            Left = 1
            Top = 101
            Width = 259
            Height = 322
            Align = alClient
            Caption = #21382#21490
            TabOrder = 0
            object listBoxHistory: TListBox
              Left = 2
              Top = 14
              Width = 255
              Height = 306
              Align = alClient
              ItemHeight = 12
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
              OnClick = listBoxHistoryClick
              OnDblClick = listBoxHistoryDblClick
            end
          end
        end
      end
    end
  end
  object SavePictureDialog: TSaveDialog
    DefaultExt = '*.bmp'
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 952
  end
  object MainfrmMenu: TMainMenu
    Left = 952
    Top = 32
    object M_File: TMenuItem
      Caption = #25991#20214'(&F)'
      object M_OpenFractal: TMenuItem
        Caption = #25171#24320#20998#24418'(&O)...'
        ShortCut = 16463
        OnClick = M_OpenFractalClick
      end
      object M_SaveFractalAs: TMenuItem
        Caption = #20445#23384#20998#24418'(&S)...'
        ShortCut = 16467
        OnClick = M_SaveFractalAsExecute
      end
      object M_Space34789579: TMenuItem
        Caption = '-'
      end
      object M_SavePictureAs: TMenuItem
        Caption = #20445#23384#22270#29255'(&D)...'
        OnClick = M_SavePictureAsExecute
      end
      object M_Line2: TMenuItem
        Caption = '-'
      end
      object M_Exit1: TMenuItem
        Caption = #36864#20986'(&X)'
        OnClick = M_ExitExecute
      end
    end
    object M_Help: TMenuItem
      Caption = #24110#21161'(&H)'
      object About1: TMenuItem
        Caption = #20851#20110'(&A)...'
        ShortCut = 16449
        OnClick = M_AboutExecute
      end
    end
  end
  object OpenFractalDialog: TOpenDialog
    DefaultExt = '*.frc'
    Filter = 'Fractal (*.frc)|*.frc'
    Left = 984
    Top = 24
  end
  object SaveFractalDialog: TSaveDialog
    DefaultExt = '*.frc'
    Filter = 'Fractal (*.frc)|*.frc'
    Left = 976
  end
end
