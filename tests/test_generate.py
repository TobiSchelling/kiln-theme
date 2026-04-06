"""Tests for the Kiln generator."""

from kiln.generate import build_context, load_palette, strip_hash


def test_strip_hash():
    assert strip_hash("#E08A50") == "E08A50"
    assert strip_hash("E08A50") == "E08A50"


def test_load_palette():
    palette = load_palette()
    assert palette["name"] == "kiln"
    assert "ember" in palette["variants"]
    assert "glow" in palette["variants"]


def test_build_context_ember():
    palette = load_palette()
    ctx = build_context(palette, "ember")
    assert ctx["variant"] == "ember"
    assert ctx["display_name"] == "Kiln Ember"
    assert "peach" in ctx["colors"]
    assert ctx["colors"]["peach"]["hex"] == "#D3721E"
    assert ctx["colors"]["peach"]["hex_stripped"] == "D3721E"
    assert ctx["colors"]["base"]["hex"] == "#0B0501"
    assert ctx["colors"]["text"]["hex"] == "#FBF4ED"


def test_build_context_glow():
    palette = load_palette()
    ctx = build_context(palette, "glow")
    assert ctx["variant"] == "glow"
    assert ctx["colors"]["base"]["hex"] == "#FFFCF5"
    assert ctx["colors"]["text"]["hex"] == "#171008"


def test_ansi_mapping_resolved():
    palette = load_palette()
    ctx = build_context(palette, "ember")
    assert ctx["ansi"]["red"]["hex"] == "#E45D58"
    assert ctx["ansi"]["bright_yellow"]["hex"] == "#D3721E"  # peach


def test_all_27_colors_present():
    palette = load_palette()
    ctx = build_context(palette, "ember")
    assert len(ctx["base_colors"]) == 9
    assert len(ctx["text_colors"]) == 4
    assert len(ctx["accent_colors"]) == 14
    assert len(ctx["colors"]) == 27
