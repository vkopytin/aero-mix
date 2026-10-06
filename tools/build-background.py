"""Build the Fenix 7 background from the original Aero Mix drawable layers."""
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
DRAWABLES = ROOT / "assets" / "source"
OUTPUT = ROOT / "resources-fenix7" / "background.png"

with Image.open(DRAWABLES / "background-alt.png") as bottom:
    with Image.open(DRAWABLES / "background1.png") as top:
        assert bottom.size == top.size == (260, 260)
        combined = Image.alpha_composite(bottom.convert("RGBA"), top.convert("RGBA"))
        assert combined.getchannel("A").getextrema() == (255, 255)
        OUTPUT.parent.mkdir(exist_ok=True)
        combined.convert("RGB").save(OUTPUT, optimize=True)

with Image.open(OUTPUT) as result:
    assert result.size == combined.size
    assert ImageChops.difference(combined.convert("RGB"), result.convert("RGB")).getbbox() is None
print("Verified 260 x 260 background matches the original two-layer composition pixel for pixel.")
