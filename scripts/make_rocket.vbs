' ============================================================
'  make_rocket.vbs  —  在装有 CATIA V5 的机器上重建小火箭
'  用法：cscript //nologo make_rocket.vbs      （或双击）
'  说明：不依赖 Python，VBScript 直接驱动 CATIA COM。
'        跑完得到一个带特征树的 .CATPart。
'  注意：本脚本在无 CATIA 的机器上编写，未实测。若某一步
'        报错，脚本会打印「! [步骤名]」并继续，不会中断。
'        箭头锥和尾翼环形阵列有意留手做——这两步用旋转体
'        和阵列工具比写代码可靠得多，文档里有说明。
' ============================================================
Option Explicit

Dim CATIA, docPart, part, body, SF, HSF
Dim sk, f2d, pad, pocket
Dim outPath
Dim gFail

gFail = 0
outPath = "C:\Users\ursa\Desktop\rocket.CATPart"

' ---------- 出错检查 ----------
Sub Chk(tag)
    If Err.Number <> 0 Then
        WScript.Echo "  ! [" & tag & "] " & Err.Description
        gFail = gFail + 1
        Err.Clear
    End If
End Sub

' ---------- 连接 CATIA ----------
On Error Resume Next
Set CATIA = GetObject(, "CATIA.Application")
If Err.Number <> 0 Then
    Err.Clear
    Set CATIA = CreateObject("CATIA.Application")
End If
If Err.Number <> 0 Or CATIA Is Nothing Then
    WScript.Echo "找不到 CATIA。请先启动 CATIA V5 再运行本脚本。"
    WScript.Quit 1
End If
On Error GoTo 0

CATIA.Visible = True
CATIA.DisplayFileAlerts = False

' ---------- 新建零件 ----------
Set docPart = CATIA.Documents.Add("Part")
Set part = docPart.Part
Set body = part.Bodies.Item(1)
part.InWorkObject = body
Set SF = part.ShapeFactory
Set HSF = part.HybridShapeFactory

Dim r, wall, bodyH
r = 10.5
wall = 1.6
bodyH = 40#

On Error Resume Next

' ========== 1. 箭体：Ø21 × 40 ==========
Set sk = body.Sketches.Add(part.OriginElements.PlaneXY)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, r
sk.CloseEdition()
part.Update
Set pad = SF.AddNewPad(sk, bodyH)
part.Update
Chk "1 箭体"
WScript.Echo "[1/8] 箭体 Ø21 x 40"

' ========== 2. 内腔：Ø17.8 深 37，从顶面切 ==========
Dim plTop
Set plTop = HSF.AddNewPlaneOffset(part.CreateReferenceFromObject(part.OriginElements.PlaneXY), bodyH, 0)
body.InsertHybridShape plTop
part.Update
Set sk = body.Sketches.Add(plTop)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, r - wall
sk.CloseEdition()
part.Update
Set pocket = SF.AddNewPocket(sk, bodyH - 3#)
pocket.ReverseSide = True
part.Update
Chk "2 内腔"
WScript.Echo "[2/8] 内腔 Ø17.8 深 37"

' ========== 3. 喷口：Ø11.2 深 3 + Ø5.2 打通 ==========
Set sk = body.Sketches.Add(part.OriginElements.PlaneXY)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, 5.6
sk.CloseEdition()
part.Update
Set pocket = SF.AddNewPocket(sk, 3#)
pocket.ReverseSide = True
part.Update
Chk "3a 喷口外扩"

Set sk = body.Sketches.Add(part.OriginElements.PlaneXY)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, 2.6
sk.CloseEdition()
part.Update
Set pocket = SF.AddNewPocket(sk, bodyH)
pocket.ReverseSide = True
part.Update
Chk "3b 喷口打通"
WScript.Echo "[3/8] 喷口 Ø11.2 / Ø5.2（锥口请在 CATIA 里加 3mm 45度倒角）"

' ========== 4. 分界槽：环形凹槽 ==========
' 在 z=40.5 平面上画圆环，向下切 1.0
Dim plSeam
Set plSeam = HSF.AddNewPlaneOffset(part.CreateReferenceFromObject(part.OriginElements.PlaneXY), bodyH + 0.5, 0)
body.InsertHybridShape plSeam
part.Update
Set sk = body.Sketches.Add(plSeam)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, r + 0.2
f2d.CreateCircle 0, 0, r - 0.55
sk.CloseEdition()
part.Update
Set pocket = SF.AddNewPocket(sk, 1#)
pocket.ReverseSide = True
part.Update
Chk "4 分界槽"
WScript.Echo "[4/8] 分界槽"

' ========== 5. 加强环：z=13.6 起，凸 0.75 ==========
Dim plRib
Set plRib = HSF.AddNewPlaneOffset(part.CreateReferenceFromObject(part.OriginElements.PlaneXY), 13.6, 0)
body.InsertHybridShape plRib
part.Update
Set sk = body.Sketches.Add(plRib)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 0, r + 0.75
f2d.CreateCircle 0, 0, r - 0.3
sk.CloseEdition()
part.Update
Set pad = SF.AddNewPad(sk, 1.6)
part.Update
Chk "5 加强环"
WScript.Echo "[5/8] 加强环"

' ========== 6. 舷窗：PlaneZX 上，朝 -Y ==========
Set sk = body.Sketches.Add(part.OriginElements.PlaneZX)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 24.8, 4.3
sk.CloseEdition()
part.Update
Set pad = SF.AddNewPad(sk, 0.9)
part.Update
Chk "6a 舷窗框"

Set sk = body.Sketches.Add(part.OriginElements.PlaneZX)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateCircle 0, 24.8, 3.5
sk.CloseEdition()
part.Update
Set pocket = SF.AddNewPocket(sk, 1.1)
part.Update
Chk "6b 舷窗孔"
WScript.Echo "[6/8] 舷窗 Ø8.6 / Ø7.0"

' ========== 7. 尾翼：先做 1 片 ==========
Set sk = body.Sketches.Add(part.OriginElements.PlaneZX)
sk.OpenEdition()
Set f2d = sk.Factory2D
f2d.CreateLine 9.5, 0, 19.5, 0
f2d.CreateLine 19.5, 0, 12, 16
f2d.CreateLine 12, 16, 9.5, 13.1
f2d.CreateLine 9.5, 13.1, 9.5, 0
sk.CloseEdition()
part.Update
Set pad = SF.AddNewPad(sk, 2#)
pad.MirroredExtent = True
part.Update
Chk "7 尾翼"
WScript.Echo "[7/8] 尾翼（1 片）"

' ========== 8. 保存 ==========
On Error Resume Next
docPart.SaveAs outPath
Chk "8 保存"

WScript.Echo ""
WScript.Echo "------------------------------------------------"
WScript.Echo "已保存: " & outPath
WScript.Echo "未完成步骤数: " & gFail
WScript.Echo ""
WScript.Echo "还剩两步手动做（特征树里已有箭体/内腔/喷口/分界槽/"
WScript.Echo "加强环/舷窗/1片尾翼）："
WScript.Echo "  A. 头锥：ZX 平面画三角形 (0,40)-(10.5,40)-(0,57)，"
WScript.Echo "     旋转体 360 度，轴选 Z。"
WScript.Echo "  B. 尾翼阵列：选中最后的尾翼凸台 - 环形阵列 -"
WScript.Echo "     参考方向 Z 轴 - 实例 3 - 总角度 360。"
WScript.Echo "  C. 锥形喷口：选中 Ø5.2 孔的圆边 - 倒角 3mm 45度。"
WScript.Echo "------------------------------------------------"
