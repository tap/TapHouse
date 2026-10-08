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

## Icons in the repos

Unlike the rest of `brand/`, a repo's own icons are distributed and guarded.
`scripts/sync.sh --icon <Library>` copies them, and the drift check compares
them byte for byte when the caller passes `icon: <Library>` (see the root
README). `<Library>` is the mark the repo uses: its own, or for a host package,
its library's. Which files a repo carries follows from its shape
(`scripts/icon-files.sh` is the rule, for both sides):

| Repo has | It carries | From |
|----------|------------|------|
| (every repo) | `.github/icon-light.svg`, `.github/icon-dark.svg` | `-light.svg`, `-dark.svg` |
| `book/book.toml` (an mdBook) | `book/theme/favicon.svg`, `book/theme/favicon.png` | `-ground.svg`, `-32.png` |
| `package-info.json.in` (a Max package) | `icon.png` | `-package.png` |

| Repo | `<Library>` |
|------|-------------|
| AmbiTap, AmbiTap-Max, AmbiTap-Pd | AmbiTap |
| MuTap, MuTap-Max | MuTap |
| TapTools, TapTools-Max | TapTools |
| SampleRateTap, OscTap, SoundFileTap, PythonTap | its own |

DspTap and AvasTap have no mark yet; RatioTap, folded into SampleRateTap's
`bridge`, gets none.

### README header

The README's title carries the mark, light or dark to follow the reader's
GitHub theme. Replace the `# Name` line with:

```html
# <picture><source media="(prefers-color-scheme: dark)" srcset=".github/icon-dark.svg"><img src=".github/icon-light.svg" width="40" height="40" alt="" align="top"></picture> Name
```

### Book favicon

mdBook takes `favicon.svg` and `favicon.png` from `book/theme/` in place of its
own, and still uses its defaults for every other theme file, so the two files
need no `book.toml` change. (Checked with mdBook v0.4.40, the version the books
pin: the built site differs from one without them in the two favicons only.)

### Package icons

A Max package shows the `icon.png` at its root. Each package ships its
library's ground icon there, rendered at 500×500 (the size of min's template
icon) with the tile's rounded corners:

| Package | Library | `icon.png` is |
|---------|---------|---------------|
| AmbiTap-Max | AmbiTap | `icons/AmbiTap/AmbiTap-package.png` |
| MuTap-Max | MuTap | `icons/MuTap/MuTap-package.png` |
| PythonTap | PythonTap | `icons/PythonTap/PythonTap-package.png` |
| TapTools-Max | TapTools | `icons/TapTools/TapTools-package.png` |

The map is `PACKAGES` in `make_icons.py`, which renders a package icon only for
the libraries in it. AmbiTap-Pd has none: Pd's package manager (deken) shows no
icon.

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
| `<Repo>-package.png` | Max package `icon.png`, 500×500, rounded (ground); only for libraries a package uses |

## Regenerating

The icons are drawn in code, so edit `make_icons.py` rather than the SVGs:

```sh
pip install -r brand/requirements.txt   # cairosvg, only needed for the PNGs
python3 brand/make_icons.py
```

The PNG bytes depend on the renderer: the committed ones come from cairosvg
2.9.1 (pinned in `requirements.txt`) over libcairo 1.18.0. Because repos'
icons are compared byte for byte, a re-render that changes the bytes of an
icon whose drawing did not change would send every repo back through
`sync.sh` for nothing; render with those versions, and check that `git status`
shows only the icons you meant to change.

Other than the files above, none of this is synced to consumer repos or
drift-checked; a repo that wants its icon copies the files it needs.
