#!/usr/bin/env bash
#
# render.sh — produce a clean product render (PNG) from a .scad or .stl file.
#
# Renders with OpenSCAD's full CGAL geometry (smooth, final-quality), frames the
# model automatically, and supersamples for anti-aliasing. Per-model view
# settings can be pinned in a `render.conf` sidecar next to the model so that
# regenerating every render is a single, repeatable command.
#
#   ./render.sh "Caterham Door Hanger"            # render a product folder
#   ./render.sh path/to/model.scad               # render a specific file
#   ./render.sh --rotate 90,0,0 model.stl        # override the view inline
#
# Settings precedence (lowest to highest): built-in defaults < render.conf < CLI flags.
#
# render.conf format (KEY=value, one per line; # comments allowed):
#   ROTATE=90,0,0          # degrees to pre-rotate the model (X,Y,Z)
#   CAMERA=62,0,22         # camera gimbal rotation (rotX,rotY,rotZ)
#   INSET_CAMERA=65,0,215  # optional 2nd angle, composited as a framed corner panel
#   COLORSCHEME=Metallic   # built-in OpenSCAD scheme, or a tint palette:
#                          #   "Catppuccin Mocha" (default) / "Catppuccin Latte"
#   EDGE_COLOR=#cdd6f4     # ink geometry edges in this colour ("none" to disable;
#                          #   tint palettes set their own default)
#   EDGE_THRESHOLD=10      # edge sensitivity (lower = more edges)
#   EDGE_WIDTH=1.5         # outline thickness (0 = hairline; 1.5 ≈ bold)
#   SIZE=1600x1200         # output image size (WxH)
#   SUPERSAMPLE=2          # render at Nx then downscale for anti-aliasing

set -euo pipefail

# ---------------------------------------------------------------- defaults ---
ROTATE="0,0,0"
CAMERA="55,0,25"
INSET_CAMERA=""          # optional second camera angle, composited as a corner panel
INSET_POS="NorthWest"    # corner for the inset: North/South × West/East
COLORSCHEME="Catppuccin Mocha"   # built-in OpenSCAD scheme, or a tint palette (below)
DEFINE=""                # optional OpenSCAD -D override, e.g. MODE="assembled"
EDGE_COLOR=""            # outline colour for geometry edges ("none" to disable)
EDGE_THRESHOLD="10"      # edge sensitivity (lower = more edges)
EDGE_WIDTH="1.5"         # outline thickness (0 = hairline; 1.5 ≈ bold)
SIZE="1600x1200"
SUPERSAMPLE="2"
OUTPUT=""

die() { echo "render.sh: $*" >&2; exit 1; }

command -v openscad >/dev/null || die "openscad not found on PATH"
command -v magick   >/dev/null || die "ImageMagick (magick) not found on PATH"

# ---------------------------------------------------------- resolve target ---
TARGET=""
CLI_ROTATE="" CLI_CAMERA="" CLI_INSET_CAMERA="" CLI_COLORSCHEME="" CLI_DEFINE="" CLI_EDGE_COLOR="" CLI_EDGE_THRESHOLD="" CLI_EDGE_WIDTH="" CLI_SIZE="" CLI_SUPERSAMPLE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)      OUTPUT="$2"; shift 2 ;;
        -r|--rotate)      CLI_ROTATE="$2"; shift 2 ;;
        -c|--camera)      CLI_CAMERA="$2"; shift 2 ;;
        --inset)          CLI_INSET_CAMERA="$2"; shift 2 ;;
        --colorscheme)    CLI_COLORSCHEME="$2"; shift 2 ;;
        --define)         CLI_DEFINE="$2"; shift 2 ;;
        --edge-color)     CLI_EDGE_COLOR="$2"; shift 2 ;;
        --edge-threshold) CLI_EDGE_THRESHOLD="$2"; shift 2 ;;
        --edge-width)     CLI_EDGE_WIDTH="$2"; shift 2 ;;
        -s|--size)        CLI_SIZE="$2"; shift 2 ;;
        --supersample)    CLI_SUPERSAMPLE="$2"; shift 2 ;;
        -h|--help)        sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)               die "unknown option: $1" ;;
        *)                [[ -n "$TARGET" ]] && die "multiple targets given"; TARGET="$1"; shift ;;
    esac
done

[[ -n "$TARGET" ]] || die "no model given (pass a .scad, .stl, or a product folder)"

# A directory means "find the model inside it" — prefer a .scad source (so
# parametric overrides apply), falling back to an .stl. LC_ALL=C keeps the
# ordering deterministic regardless of the caller's locale.
if [[ -d "$TARGET" ]]; then
    MODEL="$(find "$TARGET" -maxdepth 1 -type f -iname '*.scad' | LC_ALL=C sort | head -1)"
    [[ -z "$MODEL" ]] && MODEL="$(find "$TARGET" -maxdepth 1 -type f -iname '*.stl' | LC_ALL=C sort | head -1)"
    [[ -n "$MODEL" ]] || die "no .scad or .stl found in directory: $TARGET"
else
    MODEL="$TARGET"
fi
[[ -f "$MODEL" ]] || die "model file not found: $MODEL"

MODEL="$(realpath "$MODEL")"
MODEL_DIR="$(dirname "$MODEL")"
EXT="${MODEL##*.}"; EXT="${EXT,,}"

# ---------------------------------------------------- load render.conf sidecar
CONF="$MODEL_DIR/render.conf"
if [[ -f "$CONF" ]]; then
    while IFS='=' read -r key val; do
        key="${key// /}"; val="${val%%#*}"; val="${val// /}"
        [[ -z "$key" || "$key" == \#* ]] && continue
        case "$key" in
            ROTATE)       ROTATE="$val" ;;
            CAMERA)       CAMERA="$val" ;;
            INSET_CAMERA) INSET_CAMERA="$val" ;;
            INSET_POS)      INSET_POS="$val" ;;
            COLORSCHEME)    COLORSCHEME="$val" ;;
            DEFINE)         DEFINE="$val" ;;
            EDGE_COLOR)     EDGE_COLOR="$val" ;;
            EDGE_THRESHOLD) EDGE_THRESHOLD="$val" ;;
            EDGE_WIDTH)     EDGE_WIDTH="$val" ;;
            SIZE)           SIZE="$val" ;;
            SUPERSAMPLE)    SUPERSAMPLE="$val" ;;
        esac
    done < "$CONF"
fi

# CLI flags win over the sidecar.
[[ -n "$CLI_ROTATE"       ]] && ROTATE="$CLI_ROTATE"
[[ -n "$CLI_CAMERA"       ]] && CAMERA="$CLI_CAMERA"
[[ -n "$CLI_INSET_CAMERA" ]] && INSET_CAMERA="$CLI_INSET_CAMERA"
[[ -n "$CLI_COLORSCHEME"  ]] && COLORSCHEME="$CLI_COLORSCHEME"
[[ -n "$CLI_DEFINE"       ]] && DEFINE="$CLI_DEFINE"
[[ -n "$CLI_EDGE_COLOR"     ]] && EDGE_COLOR="$CLI_EDGE_COLOR"
[[ -n "$CLI_EDGE_THRESHOLD" ]] && EDGE_THRESHOLD="$CLI_EDGE_THRESHOLD"
[[ -n "$CLI_EDGE_WIDTH"     ]] && EDGE_WIDTH="$CLI_EDGE_WIDTH"
[[ -n "$CLI_SIZE"         ]] && SIZE="$CLI_SIZE"
[[ -n "$CLI_SUPERSAMPLE"  ]] && SUPERSAMPLE="$CLI_SUPERSAMPLE"

# ------------------------------------------------------- resolve tint palette
# OpenSCAD 2021.01 can't load custom colour schemes, so palettes it has no
# built-in for (e.g. Catppuccin) are produced by rendering in a neutral scheme,
# keying out the background, mapping the part's tonal range between two colours
# (TINT_LO -> TINT_HI, shading preserved), then dropping it on TINT_BG.
NEUTRAL_SCHEME="Metallic"
TINT_LO=""; TINT_HI=""; TINT_BG=""; PALETTE_EDGE=""
case "${COLORSCHEME,,}" in
    "catppuccin mocha"|catppuccin-mocha)
        TINT_LO="#585094"; TINT_HI="#cba6f7"; TINT_BG="#1e1e2e"; PALETTE_EDGE="#cdd6f4" ;;
    "catppuccin latte"|catppuccin-latte)
        TINT_LO="#5a2d9c"; TINT_HI="#b39ae8"; TINT_BG="#eff1f5"; PALETTE_EDGE="#5a2d9c" ;;
esac
# A tint palette brings a default edge colour; an explicit EDGE_COLOR still wins.
[[ -z "$EDGE_COLOR" && -n "$PALETTE_EDGE" ]] && EDGE_COLOR="$PALETTE_EDGE"

[[ -z "$OUTPUT" ]] && OUTPUT="$MODEL_DIR/render.png"

# ------------------------------------------------- compile to a mesh, then wrap
# Compiling .scad to a temp STL first lets us apply the pre-rotation uniformly
# (via import()) and sidesteps include-scoping rules. STL inputs are used as-is.
WRAP="$(mktemp --suffix=.scad)"
RAW="$(mktemp --suffix=.png)"
TMP_MESH=""
trap 'rm -f "$WRAP" "$RAW" "$TMP_MESH"' EXIT

if [[ "$EXT" == "stl" ]]; then
    MESH="$MODEL"
else
    TMP_MESH="$(mktemp --suffix=.stl)"
    MESH="$TMP_MESH"
    DEFINE_ARGS=()
    [[ -n "$DEFINE" ]] && DEFINE_ARGS=(-D "$DEFINE")
    openscad -o "$MESH" "${DEFINE_ARGS[@]}" "$MODEL" >/dev/null 2>&1 \
        || die "openscad failed to compile $MODEL"
fi

printf 'rotate([%s]) import("%s");\n' "$ROTATE" "$MESH" > "$WRAP"

# ------------------------------------------------------------------- render
IMG_W="${SIZE%x*}"; IMG_H="${SIZE#*x}"

# Render one camera angle to a PNG, supersampled then downscaled for clean edges.
render_view() {
    local camera="$1" out="$2" w="$3" h="$4"
    local rw=$(( w * SUPERSAMPLE )) rh=$(( h * SUPERSAMPLE ))
    local scheme="$COLORSCHEME"
    [[ -n "$TINT_HI" ]] && scheme="$NEUTRAL_SCHEME"

    openscad -o "$RAW" \
        --render \
        --colorscheme="$scheme" \
        --imgsize="${rw},${rh}" \
        --autocenter --viewall \
        --camera="0,0,0,${camera},0" \
        "$WRAP" >/dev/null 2>&1 \
        || die "openscad render failed (camera $camera)"

    # Build the full-resolution frame, then optionally ink the edges, then
    # downscale once (keeps anti-aliasing clean).
    local full; full="$(mktemp --suffix=.png)"

    if [[ -n "$TINT_HI" ]]; then
        # Tint palette: key the uniform background, remap the part's tones onto
        # the palette range, and drop it on the palette background.
        # Low fuzz: the background is a flat solid colour (keys cleanly even at a
        # few %), while curved highlights can sit within ~12% of it — too high a
        # fuzz keys those out and they composite to the base as dark speckles.
        local key; key=$(magick "$RAW" -format '%[pixel:p{2,2}]' info:)
        magick -size "${rw}x${rh}" xc:"$TINT_BG" \
            \( "$RAW" -fuzz 6% -transparent "$key" \
                      -channel RGB +level-colors "${TINT_LO}","${TINT_HI}" +channel \) \
            -composite "$full"
    else
        magick "$RAW" "$full"
    fi

    # Edge outline: detect geometry edges in the shaded pass (creases and
    # silhouette show as shading gradients), thicken by EDGE_WIDTH, then ink
    # them in EDGE_COLOR.
    if [[ -n "$EDGE_COLOR" && "$EDGE_COLOR" != "none" ]]; then
        local dilate=""
        [[ -n "$EDGE_WIDTH" && "$EDGE_WIDTH" != "0" ]] && dilate="-morphology Dilate Disk:${EDGE_WIDTH}"
        local emask; emask="$(mktemp --suffix=.png)"
        magick "$RAW" -colorspace Gray -edge 1 -threshold "${EDGE_THRESHOLD}%" $dilate -blur 0x0.6 "$emask"
        magick "$full" \
            \( -size "${rw}x${rh}" xc:"$EDGE_COLOR" "$emask" \
               -alpha off -compose CopyOpacity -composite \) \
            -compose over -composite "$full"
        rm -f "$emask"
    fi

    magick "$full" -resize "${w}x${h}" "$out"
    rm -f "$full"
}

echo "render.sh: $MODEL"
echo "           rotate=[$ROTATE] camera=[$CAMERA]${INSET_CAMERA:+ inset=[$INSET_CAMERA]} colorscheme=$COLORSCHEME${EDGE_COLOR:+ edge=$EDGE_COLOR} size=${SIZE} (${SUPERSAMPLE}x)"

if [[ -z "$INSET_CAMERA" ]]; then
    render_view "$CAMERA" "$OUTPUT" "$IMG_W" "$IMG_H"
else
    # Main hero, plus a framed corner panel from a second angle.
    MAIN_PNG="$(mktemp --suffix=.png)"
    INSET_PNG="$(mktemp --suffix=.png)"
    trap 'rm -f "$WRAP" "$RAW" "$TMP_MESH" "$MAIN_PNG" "$INSET_PNG"' EXIT

    render_view "$CAMERA"       "$MAIN_PNG"  "$IMG_W" "$IMG_H"
    render_view "$INSET_CAMERA" "$INSET_PNG" "$(( IMG_W * 36 / 100 ))" "$(( IMG_H * 36 / 100 ))"

    local_margin=$(( IMG_W * 2 / 100 ))
    magick "$MAIN_PNG" \
        \( "$INSET_PNG" -bordercolor white -border 6 -bordercolor '#5b5ba8' -border 1 \) \
        -gravity "$INSET_POS" -geometry "+${local_margin}+${local_margin}" -composite \
        "$OUTPUT"
fi

echo "render.sh: wrote $OUTPUT (${SIZE})"
