# cad-sample-models

可 3D 打印的小玩具 + 样例零件。所有模型由 CadQuery（OpenCascade 内核）参数化生成。

## 一、3D 打印小玩具（2026-10）

| 文件 | 尺寸 (mm) | 实体体积 | 预估打印\* | 说明 |
|---|---|---|---|---|
| `toys/gear_top.stl` | 38 × 38 × 26 | 10 208 mm³ | ~12 min | 齿轮外缘陀螺，锥尖朝下打印 |
| `toys/fidget_spinner.stl` | 66 × 60 × 7 | 8 445 mm³ | ~13 min | 三叶指尖陀螺，中心 608 轴承孔 Ø22.2 |
| `toys/rocket.stl` | 32 × 36 × 54 | 6 270 mm³ | ~17 min | 中空小火箭，头锥建议开支撑 |
| `toys/gear_a.stl` | 44 × 44 × 8 | 9 497 mm³ | ~12 min | 20 齿主动齿轮，m=2，Ø7 轴孔 |
| `toys/gear_b.stl` | 24 × 23 × 8 | 2 074 mm³ | ~4 min | 10 齿从动齿轮，中心距 30 mm |

\* 预估基于 0.4 mm 喷嘴 / 0.2 mm 层高 / 20% 填充 / 约 7 mm³/s 有效挤出速率，实际以切片软件为准。

### 打印建议

- STL 单位是毫米，导入切片软件不要缩放。
- **齿轮陀螺**：锥尖朝下直接打，锥面约 40° 悬垂，一般无需支撑；底面加 3–5 mm brim 更稳。
- **火箭**：竖直打印，头锥尖端悬垂较大，建议开"仅支撑悬垂"或把锥角改平缓。
- **齿轮对**：两件分开打，中心距 30 mm 装底板即可啮合。
- **指尖陀螺**：三叶配重孔可塞 M8 螺母，或直接实心打配重。

### 齿轮参数（可复现）

齿廓为标准渐开线（压力角 20°，齿顶高系数 1.0，齿根高系数 1.25）。
生成器 `gearlib.py` 在私有仓库 agentSpace 的 `_cad/scripts/` 下。

## 二、CATIA 验证零件

| 文件 | 协议 / 格式 | 用途 |
|---|---|---|
| `flange_ap203.step` | STEP AP203 (CONFIG_CONTROL_DESIGN, 1994) | **首选**，兼容性最好 |
| `flange_ap214.step` | STEP AP214 (AUTOMOTIVE_DESIGN, 2000) | 次选 |
| `flange.step` | STEP AP214 | 同上（默认导出） |
| `flange.iges` | IGES 5.3 | 最后兜底 |
| `bushing.step` | STEP AP214 | 第二个零件（轴套） |

零件参数：法兰外径 Ø80 × 厚 12，中心通孔 Ø30，4 × Ø8 均布 PCD 60，外缘 R2；
轴套外径 Ø40 / 内孔 Ø20 × 长 50，两端 1.5 倒角。

校验：`MANIFOLD_SOLID_BREP` 实体、毫米单位、回读 `isValid = true`。

## 三、在 CATIA 里打开

`File > Open` → 选 `.step` → 打开后是 Part 文档 → `File > Save As` → `CATPart`。

**关于 CATPart**：CATPart 是达索私有二进制格式，没有公开规范，无法直接生成；
只能由 CATIA 自己从 STEP/IGES 转存。本仓库提供的就是这个"中转原料"。
