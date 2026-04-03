"""Kiln theme generator — reads palette.yaml and renders Jinja2 templates."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
PALETTE_PATH = PROJECT_ROOT / "palette.yaml"
TEMPLATES_DIR = PROJECT_ROOT / "templates"
DIST_DIR = PROJECT_ROOT / "dist"

TARGETS = [
    "ghostty",
    "fish",
    "tide",
    "nvim",
    "tmux",
    "delta",
    "vscode",
    "obsidian",
    "web",
]


def load_palette(path: Path = PALETTE_PATH) -> dict:
    with open(path) as f:
        return yaml.safe_load(f)


def strip_hash(hex_color: str) -> str:
    return hex_color.lstrip("#")


def build_context(palette: dict, variant_name: str) -> dict:
    """Flatten palette YAML into a template-friendly context."""
    variant = palette["variants"][variant_name]
    ansi = palette["ansi_mapping"][variant_name]
    syntax = palette["syntax_mapping"]
    ui = palette["ui_mapping"]

    # Collect all colors into a flat dict: name -> {hex, hex_stripped, oklch, role}
    colors = {}
    for category in ("base", "text", "accents"):
        for name, data in variant[category].items():
            colors[name] = {
                "hex": data["hex"],
                "hex_stripped": strip_hash(data["hex"]),
                "oklch": data.get("oklch", {}),
                "role": data.get("role", ""),
                "category": category,
            }

    # Resolve ANSI mapping to actual hex values
    ansi_resolved = {}
    for ansi_name, color_ref in ansi.items():
        if color_ref in colors:
            ansi_resolved[ansi_name] = colors[color_ref]
        else:
            ansi_resolved[ansi_name] = {"hex": "#000000", "hex_stripped": "000000"}

    # Resolve syntax mapping
    syntax_resolved = {}
    for token, color_ref in syntax.items():
        if color_ref in colors:
            syntax_resolved[token] = colors[color_ref]

    # Resolve UI mapping
    ui_resolved = {}
    for role, color_ref in ui.items():
        if color_ref in colors:
            ui_resolved[role] = colors[color_ref]

    # Resolve heading mapping (per-variant with default fallback)
    heading_map = palette.get("heading_mapping", {})
    headings_raw = heading_map.get(variant_name, heading_map.get("default", {}))
    headings_resolved = {}
    for level, color_ref in headings_raw.items():
        if color_ref in colors:
            headings_resolved[level] = colors[color_ref]

    return {
        "theme_name": palette["name"],
        "version": palette["version"],
        "variant": variant_name,
        "display_name": variant["display_name"],
        "colors": colors,
        "ansi": ansi_resolved,
        "syntax": syntax_resolved,
        "ui": ui_resolved,
        "headings": headings_resolved,
        # Category-level access for iteration
        "base_colors": {k: v for k, v in colors.items() if v["category"] == "base"},
        "text_colors": {k: v for k, v in colors.items() if v["category"] == "text"},
        "accent_colors": {k: v for k, v in colors.items() if v["category"] == "accents"},
    }


def find_templates(target: str) -> list[Path]:
    """Find all .j2 templates for a target."""
    target_path = TEMPLATES_DIR / target
    if target_path.is_dir():
        return sorted(target_path.rglob("*.j2"))

    # Single file template
    candidates = list(TEMPLATES_DIR.glob(f"{target}*.j2"))
    return sorted(candidates)


def render_target(
    env: Environment, target: str, context: dict, dry_run: bool = False
) -> list[Path]:
    """Render all templates for a target, return list of output files."""
    templates = find_templates(target)
    if not templates:
        print(f"  [skip] No templates found for {target}", file=sys.stderr)
        return []

    variant = context["variant"]
    output_files = []

    for template_path in templates:
        rel_path = template_path.relative_to(TEMPLATES_DIR)
        template = env.get_template(str(rel_path))
        rendered = template.render(**context)

        # Determine output path: strip .j2, replace variant placeholder
        out_name = str(rel_path).removesuffix(".j2")
        out_dir = DIST_DIR / target / variant
        out_path = out_dir / Path(out_name).name

        if dry_run:
            print(f"  [dry-run] {out_path}")
        else:
            out_dir.mkdir(parents=True, exist_ok=True)
            out_path.write_text(rendered)
            print(f"  [wrote] {out_path}")

        output_files.append(out_path)

    return output_files


# Targets that combine both variants into a single output (e.g., Obsidian themes)
COMBINED_TARGETS = {"obsidian"}


DARK_VARIANTS = {"ember", "forge"}
LIGHT_VARIANTS = {"dawn", "glow"}

# Default dark/light pair for combined targets (e.g., Obsidian)
COMBINED_DARK = "ember"
COMBINED_LIGHT = "glow"


def render_combined_target(
    env: Environment, target: str, contexts: dict[str, dict], dry_run: bool = False
) -> list[Path]:
    """Render templates that need all variants in a single file."""
    templates = find_templates(target)
    if not templates:
        print(f"  [skip] No templates found for {target}", file=sys.stderr)
        return []

    # Build combined context: map the default dark/light pair into
    # "dark" and "light" keys so templates can use dark.*/light.* references.
    combined = {"version": contexts[next(iter(contexts))]["version"]}
    for variant_name, template_key in (
        (COMBINED_DARK, "dark"),
        (COMBINED_LIGHT, "light"),
    ):
        ctx = contexts[variant_name]
        variant_ctx = dict(ctx["colors"])
        variant_ctx["_headings"] = ctx.get("headings", {})
        combined[template_key] = variant_ctx

    output_files = []
    for template_path in templates:
        rel_path = template_path.relative_to(TEMPLATES_DIR)
        template = env.get_template(str(rel_path))
        rendered = template.render(**combined)

        out_name = str(rel_path).removesuffix(".j2")
        out_dir = DIST_DIR / target
        out_path = out_dir / Path(out_name).name

        if dry_run:
            print(f"  [dry-run] {out_path}")
        else:
            out_dir.mkdir(parents=True, exist_ok=True)
            out_path.write_text(rendered)
            print(f"  [wrote] {out_path}")

        output_files.append(out_path)

    return output_files


def generate(
    variants: list[str] | None = None,
    targets: list[str] | None = None,
    dry_run: bool = False,
) -> dict[str, list[Path]]:
    """Generate theme configs for specified variants and targets."""
    palette = load_palette()
    variants = variants or list(palette["variants"].keys())
    targets = targets or TARGETS

    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES_DIR)),
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["strip_hash"] = strip_hash

    all_outputs: dict[str, list[Path]] = {}

    # Handle combined targets (need all variants at once)
    combined_in_targets = [t for t in targets if t in COMBINED_TARGETS]
    per_variant_targets = [t for t in targets if t not in COMBINED_TARGETS]

    if combined_in_targets:
        contexts = {}
        for variant_name in palette["variants"]:
            contexts[variant_name] = build_context(palette, variant_name)

        print("\n=== Kiln (combined) ===")
        for target in combined_in_targets:
            outputs = render_combined_target(env, target, contexts, dry_run=dry_run)
            all_outputs[f"combined/{target}"] = outputs

    for variant_name in variants:
        if variant_name not in palette["variants"]:
            print(f"Unknown variant: {variant_name}", file=sys.stderr)
            continue

        context = build_context(palette, variant_name)
        print(f"\n=== {context['display_name']} ===")

        for target in per_variant_targets:
            outputs = render_target(env, target, context, dry_run=dry_run)
            key = f"{variant_name}/{target}"
            all_outputs[key] = outputs

    return all_outputs


def main():
    # Load palette early so we can use variant names in CLI choices
    palette = load_palette()
    variant_names = list(palette["variants"].keys())

    parser = argparse.ArgumentParser(description="Generate Kiln theme configs")
    parser.add_argument(
        "--variant",
        choices=variant_names + ["all"],
        default="all",
        help="Which variant to generate",
    )
    parser.add_argument(
        "--target",
        choices=TARGETS + ["all"],
        default="all",
        help="Which target app to generate for",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be generated without writing files",
    )
    args = parser.parse_args()

    variants = None if args.variant == "all" else [args.variant]
    targets = None if args.target == "all" else [args.target]

    generate(variants=variants, targets=targets, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
