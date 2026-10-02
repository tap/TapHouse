#!/usr/bin/env python3
"""Generate the Tap family icons.

Every icon is drawn on a 64x64 grid from one motif: the stem plot of a
filter tap (a line ending in a dot). Each repo owns one accent color from
the palette below; everything else is shared.

Writes, per repo, into brand/icons/<Repo>/:
  <Repo>-light.svg   mark in piñon, tap in the repo accent, on adobe
  <Repo>-dark.svg    mark in cream, tap in the repo accent, on piñon
  <Repo>-ground.svg  cream mark on a tile filled with the repo accent
and, when cairosvg is installed (pip install cairosvg), PNGs rendered from
the ground version:
  <Repo>-16.png, -32.png, -180.png   favicons / touch icon
  <Repo>-avatar-512.png              full-bleed square (GitHub rounds it)

Run from anywhere:  python3 brand/make_icons.py
"""

import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "icons")

# --- palette -----------------------------------------------------------------
ADOBE = "#FBF6EE"   # light tile
PINON = "#2B211C"   # ink / dark tile
CREAM = "#F3E9DA"   # ink on dark tile
EDGE = "#DCCDB6"    # hairline around the light tile
RADIUS = 14         # tile corner radius on the 64 grid

INK = "@INK@"
ACC = "@ACC@"
SW = 3.2


def f(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def line(x1, y1, x2, y2, c=INK, w=SW, extra=""):
    return (f'<line x1="{f(x1)}" y1="{f(y1)}" x2="{f(x2)}" y2="{f(y2)}" stroke="{c}" '
            f'stroke-width="{w}" stroke-linecap="round"{extra}/>')


def dot(x, y, c=INK, r=3.4):
    return f'<circle cx="{f(x)}" cy="{f(y)}" r="{f(r)}" fill="{c}"/>'


def stem(x, y0, y1, c=INK, r=3.4):
    return line(x, y0, x, y1, c) + dot(x, y1, c, r)


def path(d, c=INK, w=SW, fill="none", extra=""):
    return (f'<path d="{d}" stroke="{c}" stroke-width="{w}" fill="{fill}" '
            f'stroke-linecap="round" stroke-linejoin="round"{extra}/>')


# --- marks -------------------------------------------------------------------
def ambitap():
    """Stem ring: taps radiating like a speaker array; one leads."""
    s = ""
    for k in range(8):
        a = math.radians(k * 45 - 90)
        x0, y0 = 32 + 8 * math.cos(a), 32 + 8 * math.sin(a)
        x1, y1 = 32 + 20 * math.cos(a), 32 + 20 * math.sin(a)
        c = ACC if k == 0 else INK
        s += line(x0, y0, x1, y1, c) + dot(x1, y1, c)
    return s + dot(32, 32, INK, 2.6)


def samplerate_tap():
    """Two clocks: one sample train above the axis, another rate below."""
    s = line(8, 32, 56, 32, INK, 2.2)
    for i in range(7):
        s += stem(10 + 8 * i, 30, 16, INK, 2.8)
    for i in range(6):
        s += stem(10 + 9.6 * i, 34, 48, ACC, 2.8)
    return s


def mutap():
    """The letter mu, its descender ending in a tap."""
    return (path("M21 14 V49", INK, 4.6) + dot(21, 52, ACC, 4.6)
            + path("M21 31 Q21 42 30.5 42 Q40 42 40 31 V14", INK, 4.6)
            + path("M40 33 Q40 42 47 42", INK, 4.6))


def soundfiletap():
    """Read head on its side: a play triangle at the sample being read."""
    s = line(24, 9, 24, 55, INK, 2)
    rows = [14, 23, 32, 41, 50]
    lens = [20, 28, 30, 24, 16]
    for i, (y, length) in enumerate(zip(rows, lens)):
        x1 = 24 + length
        if i == 2:
            s += line(24, y, x1, y, ACC, 3.2) + dot(x1, y, ACC, 3.4)
        else:
            op = "" if i < 2 else ' opacity="0.4"'
            s += f"<g{op}>" + line(24, y, x1, y, INK, 3) + dot(x1, y, INK, 3.2) + "</g>"
    return s + path("M8 25 V39 L17 32 Z", ACC, 2.4, fill=ACC)


def taptools():
    """Lowercase t with a stroke-weight period sitting on the baseline."""
    r = 3.6
    return (path("M25 10 V45 Q25 54 34 54", INK, 6) + line(15, 24, 36, 24, INK, 6)
            + dot(47, 57 - r, ACC, r))


def osctap():
    """An OSC address: // followed by one tap."""
    return (line(9, 48, 20, 16, INK, 4.2) + line(21, 48, 32, 16, INK, 4.2)
            + line(38, 48, 56, 48, INK, 2) + stem(47, 48, 19, ACC, 4.4))


def pythontap():
    """Serpent: taps standing on a sinuous baseline, with a head."""
    def yb(x):
        return 40 + 5 * math.sin(2 * math.pi * (x - 8) / 24)
    pts = [(8 + i * 0.5, yb(8 + i * 0.5)) for i in range(89)]
    d = "M" + " L".join(f"{f(a)} {f(b)}" for a, b in pts)
    s = path(d, INK, 3)
    for x in (14, 23, 32, 41):
        s += stem(x, yb(x), yb(x) - 18, INK, 3)
    return s + dot(52, yb(52), ACC, 4.8)


# repo name -> (accent name, accent hex, mark)
REPOS = {
    "AmbiTap": ("Turquoise", "#14786F", ambitap),
    "SampleRateTap": ("Taos sky", "#2C5F8A", samplerate_tap),
    "MuTap": ("Chile", "#A8331F", mutap),
    "SoundFileTap": ("Mesa dusk", "#6E4566", soundfiletap),
    "TapTools": ("Terracotta", "#B85A2E", taptools),
    "OscTap": ("Ochre", "#A06A10", osctap),
    "PythonTap": ("Juniper", "#4F6B3E", pythontap),
}


def svg(mark, bg, ink, acc, rx=RADIUS, edge=False, title=""):
    body = mark.replace(INK, ink).replace(ACC, acc)
    hair = (f'<rect x="0.5" y="0.5" width="63" height="63" rx="{rx}" fill="none" '
            f'stroke="{EDGE}" stroke-width="1"/>') if edge else ""
    t = f"<title>{title}</title>" if title else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64" '
            f'role="img">{t}<rect width="64" height="64" rx="{rx}" fill="{bg}"/>{hair}{body}</svg>\n')


def main():
    try:
        import cairosvg
    except ImportError:
        cairosvg = None
        print("cairosvg not installed: writing SVGs only")

    for repo, (_, accent, draw) in REPOS.items():
        mark = draw()
        d = os.path.join(OUT, repo)
        os.makedirs(d, exist_ok=True)
        files = {
            "light": svg(mark, ADOBE, PINON, accent, edge=True, title=repo),
            "dark": svg(mark, PINON, CREAM, accent, title=repo),
            "ground": svg(mark, accent, ADOBE, ADOBE, title=repo),
        }
        for kind, text in files.items():
            with open(os.path.join(d, f"{repo}-{kind}.svg"), "w") as fh:
                fh.write(text)
        if cairosvg:
            ground = files["ground"].encode()
            for px in (16, 32, 180):
                cairosvg.svg2png(bytestring=ground, write_to=os.path.join(d, f"{repo}-{px}.png"),
                                 output_width=px, output_height=px)
            square = svg(mark, accent, ADOBE, ADOBE, rx=0).encode()
            cairosvg.svg2png(bytestring=square, write_to=os.path.join(d, f"{repo}-avatar-512.png"),
                             output_width=512, output_height=512)
        print(f"{repo}: done")


if __name__ == "__main__":
    main()
