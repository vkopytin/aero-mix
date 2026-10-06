"""Build Fenix 6 tiled artwork and polygon hand resources from Aero Mix assets."""
from pathlib import Path
from PIL import Image, ImageChops
import json, re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "resources-fenix6"
OUT.mkdir(exist_ok=True)
SRC = ROOT / "resources-fenix7"
declarations = []
tile_map = []

def bitmap(name, image):
    image.save(OUT / (name + ".png"), optimize=True)
    declarations.append(f'    <bitmap id="{name}" filename="{name}.png" />')

with Image.open(ROOT / "resources-fenix7/background.png") as background:
    rebuilt = Image.new("RGB", background.size)
    for row in range(4):
        for col in range(4):
            box = (col*65, row*65, (col+1)*65, (row+1)*65)
            tile = background.crop(box)
            bitmap(f"bg_{row}_{col}", tile)
            rebuilt.paste(tile, box[:2])
    assert ImageChops.difference(background.convert("RGB"), rebuilt).getbbox() is None

for kind, file, module, width, height in [
    ("weather","weather-conditions.png","srv.weather.mc",44,41),
    ("moon","moon-phases-40x40.png","srv.moonPhase.mc",40,40),
    ("twilight","day-night-phases.png","srv.twilight.mc",50,50),
]:
    text = (ROOT / "source" / module).read_text()
    pattern = r'(?:tileCoordinates|phaseTile)\s*=\s*\[(\d+),\s*(\d+)\]'
    coords = set(tuple(map(int, m)) for m in re.findall(pattern,text))
    if kind == "weather":
        coords.add((10,24))
    with Image.open(SRC/file) as atlas:
        for x,y in sorted(coords):
            w,h = (40,40) if kind == "weather" and (x,y)==(10,24) else (width,height)
            tile = atlas.crop((x,y,x+w,y+h))
            name = f"{kind}_{x}_{y}"
            bitmap(name,tile)
            tile_map.append(f'        "{kind}_{x}_{y}" => Rez.Drawables.{name}')

geometry = []
for kind,file in [("hour","hourHand.png"),("minute","minuteHand.png"),
                  ("seconds","secondsHand.png"),("indicator","indicator-arrow.png")]:
    with Image.open(SRC/file) as image:
        rgba = image.convert("RGBA")
        pixels = rgba.load()
        active = {}
        rectangles = []
        for y in range(rgba.height+1):
            runs = []
            if y < rgba.height:
                x=0
                while x < rgba.width:
                    r,g,b,a = pixels[x,y]
                    if a < 128:
                        x+=1
                        continue
                    color = tuple(round(v/85)*85 for v in (r,g,b))
                    end=x+1
                    while end < rgba.width:
                        rr,gg,bb,aa=pixels[end,y]
                        if aa<128 or tuple(round(v/85)*85 for v in (rr,gg,bb)) != color:
                            break
                        end+=1
                    runs.append((x,end,color))
                    x=end
            next_active={}
            for run in runs:
                next_active[run]=active.pop(run,y)
            for (x,end,color), start in active.items():
                rgb=(color[0]<<16)|(color[1]<<8)|color[2]
                rectangles.append([rgb,[[x,start],[end,start],[end,y],[x,y]]])
            active=next_active
        # Verify polygon strips cover exactly the opaque, 64-color source mask.
        expected = Image.new("RGBA", rgba.size)
        reconstructed = Image.new("RGBA", rgba.size)
        for yy in range(rgba.height):
            for xx in range(rgba.width):
                r,g,b,a = pixels[xx,yy]
                if a >= 128:
                    expected.putpixel((xx,yy), tuple(round(v/85)*85 for v in (r,g,b))+(255,))
        for color,points in rectangles:
            x0,y0=points[0]
            x1,y1=points[2]
            rgb=((color>>16)&255,(color>>8)&255,color&255,255)
            for yy in range(y0,y1):
                for xx in range(x0,x1):
                    reconstructed.putpixel((xx,yy),rgb)
        assert reconstructed.tobytes() == expected.tobytes()
        data=json.dumps(rectangles,separators=(",",":"))
        geometry.append(f'    <jsonData id="{kind}Geometry">{data}</jsonData>')
        print(kind, "polygon strips:", len(rectangles))

(OUT/"drawables.xml").write_text("<drawables>\n"+"\n".join(declarations)+"\n</drawables>\n")
(OUT/"geometry.xml").write_text("<resources>\n"+"\n".join(geometry)+"\n</resources>\n")
pieces = ", ".join(f"Rez.Drawables.bg_{r}_{c}" for r in range(4) for c in range(4))
lib = """import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
module lib {
    const pieces = [PIECES];
    const tiles = {
TILES
    };
    function drawBackground(dc as Graphics.Dc, dx as Lang.Number, dy as Lang.Number) as Void {
        for (var i = 0; i < 16; i++) {
            dc.drawBitmap((i % 4) * 65 - dx, (i / 4).toNumber() * 65 - dy,
                          WatchUi.loadResource(self.pieces[i]));
        }
    }
}
"""
lib=lib.replace("PIECES",pieces).replace("TILES",",\n".join(tile_map))
for path in [OUT/"drawables.xml", OUT/"geometry.xml"]:
    path.write_text(path.read_text().replace(chr(92)+"n", chr(10)))
(ROOT/"source-fenix6-260x260/lib.mc").write_text(lib.replace(chr(92)+"n", chr(10)))
print("Verified background tile reconstruction; generated",len(tile_map),"sprite tiles.")
