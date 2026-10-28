# cad-sample-models

样例零件，用于验证 CATIA V5R20（P3）能否导入。

## 文件

| 文件 | 协议 / 格式 | 用途 |
|---|---|---|
| `flange_ap203.step` | STEP AP203 (CONFIG_CONTROL_DESIGN, 1994) | **首选**，兼容性最好 |
| `flange_ap214.step` | STEP AP214 (AUTOMOTIVE_DESIGN, 2000) | 次选 |
| `flange.step` | STEP AP214 | 同上（默认导出） |
| `flange.iges` | IGES 5.3 | 最后兜底 |
| `bushing.step` | STEP AP214 | 第二个零件（轴套） |
| `flange.png` / `bushing.png` | PNG | 渲染预览 |

## 零件参数

**法兰**：外径 Ø80 × 厚 12 mm，中心通孔 Ø30，4 × Ø8 均布于 PCD 60，外缘 R2 圆角。
**轴套**：外径 Ø40 / 内孔 Ø20 × 长 50 mm，两端 1.5 倒角。

## 校验结果

- 实体：`MANIFOLD_SOLID_BREP`（真·实体，不是曲面片）
- 单位：`SI_UNIT(.MILLI.,.METRE.)`（毫米）
- 体积：法兰 48996.87 mm³，轴套 46699.78 mm³
- 回读校验：`isValid = true`

## 在 CATIA 里打开

`File > Open` → 选 `.step` → 打开后是 Part 文档，树里 PartBody 下有实体
→ `File > Save As` → 类型选 `CATPart` → 保存。
