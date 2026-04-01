"""Validate Kiln palette contrast ratios against WCAG AA standards."""

from __future__ import annotations

from kiln.generate import build_context, load_palette


def hex_to_rgb(hex_color: str) -> tuple[float, float, float]:
    hex_color = hex_color.lstrip("#")
    r = int(hex_color[0:2], 16) / 255
    g = int(hex_color[2:4], 16) / 255
    b = int(hex_color[4:6], 16) / 255
    return r, g, b


def relative_luminance(hex_color: str) -> float:
    r, g, b = hex_to_rgb(hex_color)
    components = []
    for c in (r, g, b):
        if c <= 0.03928:
            components.append(c / 12.92)
        else:
            components.append(((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * components[0] + 0.7152 * components[1] + 0.0722 * components[2]


def contrast_ratio(hex1: str, hex2: str) -> float:
    l1 = relative_luminance(hex1)
    l2 = relative_luminance(hex2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def validate_variant(variant_name: str) -> list[dict]:
    palette = load_palette()
    ctx = build_context(palette, variant_name)
    bg = ctx["colors"]["base"]["hex"]
    results = []

    # Check all accent colors against base background
    for name, color in ctx["accent_colors"].items():
        ratio = contrast_ratio(color["hex"], bg)
        results.append(
            {
                "pair": f"{name} on base",
                "fg": color["hex"],
                "bg": bg,
                "ratio": round(ratio, 2),
                "wcag_aa": ratio >= 4.5,
                "wcag_aaa": ratio >= 7.0,
            }
        )

    # Check text colors against base background
    for name, color in ctx["text_colors"].items():
        ratio = contrast_ratio(color["hex"], bg)
        results.append(
            {
                "pair": f"{name} on base",
                "fg": color["hex"],
                "bg": bg,
                "ratio": round(ratio, 2),
                "wcag_aa": ratio >= 4.5,
                "wcag_aaa": ratio >= 7.0,
            }
        )

    return results


def main():
    for variant in ("dark", "light"):
        print(f"\n{'=' * 60}")
        print(f"  {variant.upper()} VARIANT — WCAG Contrast Validation")
        print(f"{'=' * 60}")

        results = validate_variant(variant)
        failures = [r for r in results if not r["wcag_aa"]]

        for r in results:
            status = "✓ AA" if r["wcag_aa"] else "✗ FAIL"
            aaa = " (AAA)" if r["wcag_aaa"] else ""
            print(f"  {status}{aaa}  {r['ratio']:5.1f}:1  {r['pair']:<20s}  {r['fg']} on {r['bg']}")

        print(f"\n  Total: {len(results)} pairs checked")
        print(f"  Pass:  {len(results) - len(failures)}")
        print(f"  Fail:  {len(failures)}")

        if failures:
            print("\n  ⚠ FAILING PAIRS:")
            for r in failures:
                print(f"    {r['pair']}: {r['ratio']}:1 (need 4.5:1)")


if __name__ == "__main__":
    main()
