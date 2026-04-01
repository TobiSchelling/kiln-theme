"""Tests for the Kiln generator."""

from kiln.generate import build_context, load_palette, strip_hash


def test_strip_hash():
    assert strip_hash("#E08A50") == "E08A50"
    assert strip_hash("E08A50") == "E08A50"


def test_load_palette():
    palette = load_palette()
    assert palette["name"] == "kiln"
    assert "dark" in palette["variants"]
    assert "light" in palette["variants"]


def test_build_context_dark():
    palette = load_palette()
    ctx = build_context(palette, "dark")
    assert ctx["variant"] == "dark"
    assert ctx["display_name"] == "Kiln Dark"
    assert "peach" in ctx["colors"]
    assert ctx["colors"]["peach"]["hex"] == "#E08A50"
    assert ctx["colors"]["peach"]["hex_stripped"] == "E08A50"
    assert ctx["colors"]["base"]["hex"] == "#1A1714"
    assert ctx["colors"]["text"]["hex"] == "#F8F4F0"


def test_build_context_light():
    palette = load_palette()
    ctx = build_context(palette, "light")
    assert ctx["variant"] == "light"
    assert ctx["colors"]["base"]["hex"] == "#EBE4D8"
    assert ctx["colors"]["text"]["hex"] == "#2A2318"


def test_ansi_mapping_resolved():
    palette = load_palette()
    ctx = build_context(palette, "dark")
    assert ctx["ansi"]["red"]["hex"] == "#E8665E"
    assert ctx["ansi"]["bright_yellow"]["hex"] == "#E08A50"  # peach


def test_all_27_colors_present():
    palette = load_palette()
    ctx = build_context(palette, "dark")
    assert len(ctx["base_colors"]) == 9
    assert len(ctx["text_colors"]) == 4
    assert len(ctx["accent_colors"]) == 14
    assert len(ctx["colors"]) == 27
