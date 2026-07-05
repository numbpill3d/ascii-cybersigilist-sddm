# ascii cybersigilist — SDDM theme

black screen. dark red text. the kind of login screen that looks like something you'd see on a terminal in a film where the protagonist is already too far gone to turn back.

![preview](terminal-red/preview.png)

## features

- braille-art logo in deep crimson (`#8B0000`), rendered on a font with real braille-block coverage so the dots sit on a clean grid (see [Troubleshooting](#troubleshooting) if you fork this and the art looks jittery)
- two single-character-wide scrolling columns on the screen edges — Russian and Japanese glyphs from loneliness poems, one descending left, one ascending right
- login box with monospace field labels, red-bordered focus states, `[ ENTER ]` button
- session picker popup with card layout — WAYLAND / X11 badges read from the actual SDDM session model roles, not name-sniffing. works with any installed session automatically (Sway, Plasma, Hyprland, i3, Openbox, GNOME, etc.)
- status bar: live clock, session switcher with `[W]`/`[X]` type pill, REBOOT and SHUTDOWN buttons
- Terminus font, hard corners, no rounding anywhere

## requirements

- Linux with SDDM 0.19+
- Qt 6 (`qt6-declarative` / `qt6-quickcontrols2` or your distro's equivalent — SDDM's Qt 6 greeter needs these to load QML themes)
- a monospace font with **braille block coverage** (U+2800–U+28FF). The theme requests `Adwaita Mono`, which ships with GNOME/Adwaita and covers it fully. If you don't have it, see [Troubleshooting](#troubleshooting) below before you install.
- root access (theme installs to `/usr/share/sddm/themes/`, config lives in `/etc/sddm.conf` or `/etc/sddm.conf.d/`)

## install

**1. Clone this repo:**

```bash
git clone https://github.com/numbpill3d/ascii-cybersigilist-sddm.git
cd ascii-cybersigilist-sddm
```

**2. Preview it before touching your system config.** SDDM greeters support a test-mode window that renders the real theme without logging you out or needing root:

```bash
sddm-greeter-qt6 --test-mode --theme ./terminal-red
```

(older SDDM builds may install this as `sddm-greeter` instead of `sddm-greeter-qt6` — check with `which sddm-greeter sddm-greeter-qt6`). If Wayland's QPA plugin gives you trouble, force X11/XWayland:

```bash
QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme ./terminal-red
```

Close the window (or `Ctrl+C` the process) once you've confirmed it looks right.

**3. Install system-wide:**

```bash
sudo cp -r terminal-red/ /usr/share/sddm/themes/
```

**4. Point SDDM at it.** Either edit `/etc/sddm.conf` directly, or (cleaner, survives package updates) drop a snippet in `/etc/sddm.conf.d/`:

```bash
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=terminal-red
EOF
```

**5. Restart SDDM** to see it on the real login screen:

```bash
sudo systemctl restart sddm
```

This will kill your current graphical session if you're running one — save your work first. If you'd rather not restart the display manager right away, the test-mode preview from step 2 is a faithful stand-in and is safe to run anytime, logged in or not.

## customizing

Everything lives in `terminal-red/Main.qml`, plain QtQuick — no build step.

- **Colors** — search for the hex literals (`#8B0000`, `#000000`, `#333333`, etc.) and swap them. There's no central palette variable; it's a flat file.
- **ASCII logo** — the `asciiLogo` `Text` element holds the braille-art string. Generate your own with any image→braille converter (`chafa --symbols=braille`, `img2txt -f utf8`, etc.) — just make sure every line comes out the same character length, or use `Text.AlignLeft` (not `AlignHCenter`) so ragged line lengths don't get individually re-centered and thrown out of column alignment.
- **Marquee poems** — the `leftMarqueeWrap.poem` / `rightMarqueeWrap.poem` properties are plain `\n`-joined strings, one glyph per line. Replace with whatever text you want scrolling.
- **Fonts** — `font.family: "Adwaita Mono"` on the ASCII logo is load-bearing (see below). Everything else uses `"Monospace"` (the system default alias) and is safe to change freely.

## troubleshooting

**The braille logo renders as scattered, unevenly-spaced dots instead of a clean picture.**

This happens when the font resolved for `font.family` doesn't actually contain glyphs for the braille block (U+2800–U+28FF). Most "generic monospace" fonts — including Noto Sans Mono, which is what `"Monospace"` resolves to on a lot of distros — have **zero** braille glyphs. When that happens, Qt silently falls back to a *different* font on a per-character basis for every dot in the logo, and that fallback font's glyph advance width almost never matches the primary font's monospace grid. The result is jitter that looks like an alignment bug but isn't — it's a font-substitution problem, and no amount of `Text.AlignLeft`/`AlignHCenter` fiddling fixes it.

Check whether your chosen font actually covers the block:

```bash
fc-match -f '%{file} : %{family}\n' "YourFontName:charset=2800"
```

If that resolves to a different family than the one you asked for, it doesn't have braille coverage and you'll get the jitter. Fonts confirmed to have full, consistent-width braille coverage:

- `Adwaita Mono` (what this theme ships with)
- `DejaVu Sans Mono`
- `Unifont`

**Session names/badges show blank or "undefined" in the picker.**

SDDM's `sessionModel` named roles (`model.name`, `model.wayland`) only resolve correctly inside a `Repeater` delegate's own context — reading them from outside (e.g. to build a lookup array) silently returns `undefined`. This theme works around it by either mirroring the values into a plain JS array from inside the delegate (`sessionDataStore` pattern) or reading them by numeric role index via `sessionModel.data(sessionModel.index(i, 0), roleId)`. If you're editing the session picker and see blanks, check which pattern the surrounding code uses and don't mix them.

**Theme doesn't show up at all / SDDM falls back to default.**

Check `journalctl -u sddm` for QML errors — a single syntax error in `Main.qml` will make SDDM silently discard the theme. Also confirm `Theme-Id` in `metadata.desktop` matches the directory name under `/usr/share/sddm/themes/` and the `Current=` value in your config exactly.

## uninstall

```bash
sudo rm -rf /usr/share/sddm/themes/terminal-red
sudo rm /etc/sddm.conf.d/theme.conf   # or edit /etc/sddm.conf back to your previous Current=
sudo systemctl restart sddm
```

## credits

original base theme by [Splicer Scorn](https://voidrane.nekoweb.org).
extended by deadgirl (numbpill3d) — marquee animations, session detection rewrite, status bar improvements, braille-font-fallback fix.

## license

CC-BY-SA 4.0
