# Tap family icons

One mark per library, all drawn from the same motif: the **stem plot of a
filter tap**, a line ending in a dot. The shared structure is what makes the
icons read as one family. A single accent color, owned by one repo and used by
no other, is what tells them apart.

| Repo | Mark | Accent | Light | Dark | Ground |
|------|------|--------|:-----:|:----:|:------:|
| AmbiTap | Stem ring | Turquoise `#14786F` | <img src="icons/AmbiTap/AmbiTap-light.svg" width="48"> | <img src="icons/AmbiTap/AmbiTap-dark.svg" width="48"> | <img src="icons/AmbiTap/AmbiTap-ground.svg" width="48"> |
| SampleRateTap | Two clocks | Taos sky `#2C5F8A` | <img src="icons/SampleRateTap/SampleRateTap-light.svg" width="48"> | <img src="icons/SampleRateTap/SampleRateTap-dark.svg" width="48"> | <img src="icons/SampleRateTap/SampleRateTap-ground.svg" width="48"> |
| MuTap | μ with a tap | Chile `#A8331F` | <img src="icons/MuTap/MuTap-light.svg" width="48"> | <img src="icons/MuTap/MuTap-dark.svg" width="48"> | <img src="icons/MuTap/MuTap-ground.svg" width="48"> |
| SoundFileTap | Read head | Mesa dusk `#6E4566` | <img src="icons/SoundFileTap/SoundFileTap-light.svg" width="48"> | <img src="icons/SoundFileTap/SoundFileTap-dark.svg" width="48"> | <img src="icons/SoundFileTap/SoundFileTap-ground.svg" width="48"> |
| TapTools | t. | Terracotta `#B85A2E` | <img src="icons/TapTools/TapTools-light.svg" width="48"> | <img src="icons/TapTools/TapTools-dark.svg" width="48"> | <img src="icons/TapTools/TapTools-ground.svg" width="48"> |
| OscTap | Address `//` | Ochre `#A06A10` | <img src="icons/OscTap/OscTap-light.svg" width="48"> | <img src="icons/OscTap/OscTap-dark.svg" width="48"> | <img src="icons/OscTap/OscTap-ground.svg" width="48"> |
| PythonTap | Serpent | Juniper `#4F6B3E` | <img src="icons/PythonTap/PythonTap-light.svg" width="48"> | <img src="icons/PythonTap/PythonTap-dark.svg" width="48"> | <img src="icons/PythonTap/PythonTap-ground.svg" width="48"> |

Host packages (`AmbiTap-Max`, `AmbiTap-Pd`, `MuTap-Max`, `TapTools-Max`) use
their library's icon.

## Palette

A New Mexico palette: adobe and piñon for the shared neutrals, and one
landscape color per repo.

| Role | Name | Hex |
|------|------|-----|
| Light tile | Adobe | `#FBF6EE` |
| Ink, dark tile | Piñon | `#2B211C` |
| Ink on dark | Cream | `#F3E9DA` |
| Page ground | Adobe sand | `#EFE4D3` |
| Light-tile hairline | — | `#DCCDB6` |

The per-repo accents are in the table above. A new library gets a new accent;
an accent is never shared.

## Which version to use

- **Ground** (`-ground.svg`, PNGs): cream mark on a tile of the repo's color.
  Use it where the icon stands alone at small sizes: GitHub avatars and social
  previews, favicons, package and app icons.
- **Light / dark** (`-light.svg`, `-dark.svg`): the mark in piñon or cream,
  with only the tap in the repo's color. Use it where the icon sits on a page:
  README headers, docs, timothy.place.

The dark version's accent is weak against piñon for the darker accents (Taos
sky, mesa dusk, juniper), especially below 32 px. Prefer the ground version on
dark backgrounds at small sizes.

## Files

Each `icons/<Repo>/` holds:

| File | Use |
|------|-----|
| `<Repo>-light.svg`, `-dark.svg`, `-ground.svg` | Masters, 64×64 viewBox |
| `<Repo>-16.png`, `-32.png` | Favicons (ground) |
| `<Repo>-180.png` | Apple touch icon (ground) |
| `<Repo>-avatar-512.png` | Full-bleed square for GitHub; GitHub rounds it |

## Regenerating

The icons are drawn in code, so edit `make_icons.py` rather than the SVGs:

```sh
pip install cairosvg        # only needed for the PNGs
python3 brand/make_icons.py
```

None of this is synced to consumer repos or drift-checked; a repo that wants
its icon copies the files it needs.
