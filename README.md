# 3D Prints

Parametric, print-ready 3D models. Each product lives in its own folder with
its OpenSCAD source, slice-ready STL exports, and a render.

---

<!-- ══════════════════════════════════════════════════════════════════════
  TO ADD A NEW PRODUCT
  1. Create a folder:  <Product Name>/
  2. Drop in the source (.scad), the STL export(s), and a render.png
  3. Copy the PRODUCT TEMPLATE block below, paste a filled-in copy above
     this comment, and encode spaces in image/link paths as %20.
═══════════════════════════════════════════════════════════════════════ -->

<!-- ▶▶▶ PRODUCT TEMPLATE — copy me ▶▶▶

## <Product Name>

![<Product Name>](<Folder>/render.png)

*<One-line tagline.>*

<A short paragraph on what it is and how it works.>

| | |
| --- | --- |
| **Source** | [`<file>.scad`](<Folder>/<file>.scad) |
| **STLs** | [`<part>.stl`](<Folder>/<part>.stl) |
| **Material** | ASA / PETG |
| **Print notes** | <orientation, supports, walls, infill> |

---

◀◀◀ END TEMPLATE ◀◀◀ -->

## Volvo Headrest Cupholder

![Volvo Headrest Cupholder](Volvo%20Headrest%20Cupholder/render.png)

*A two-piece clamshell that clamps the non-removable rear headrest neck and
carries two water bottles.*

> **Materials:** these are functional parts — print in **ASA** (best) or
> **PETG**. Avoid **PLA**, which creeps and sags under heat and load.

The rear headrest support on modern Volvo XC seats doesn't pull out, and its
neck is a thick rounded-rectangle (58.75 × 50 mm), not a pair of thin rods.
This part wraps that neck in two halves that slide together with a
chess-pawn keyhole joint — locking front-to-back on their own — and are then
pinned by M4 bolts seated in captive nut traps. Internal grip ridges bite the
smooth plastic. A uniform-diameter gooseneck arm meets the clamp flat-faced
and carries a pill-shaped twin holder sized for 72 mm bottle bodies with
80 mm flared tops.

| | |
| --- | --- |
| **Source** | [`cupholder.scad`](Volvo%20Headrest%20Cupholder/cupholder.scad) |
| **STLs** | [`cupholder_back.stl`](Volvo%20Headrest%20Cupholder/cupholder_back.stl) · [`cupholder_front.stl`](Volvo%20Headrest%20Cupholder/cupholder_front.stl) |
| **Hardware** | 2× M4 nuts + 2× M4×20 bolts |
| **Material** | ASA (preferred) or PETG — never PLA |
| **Print notes** | ≥4 walls, 30–40% infill. Supports under the arm/web on the back half. |

---

## License

[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

All designs in this repository are licensed under
[Creative Commons Attribution-NonCommercial 4.0 International](LICENSE)
(CC BY-NC 4.0). You are free to share and adapt them, provided you give
credit and do **not** use them — or any derivatives — commercially.
