# slidev-theme-github

The dark GitHub theme used by every deck on this site. The upstream source is private, so this copy was rebuilt from the compiled decks (Slidev 52.12.0). The 164 theme CSS rules match the original build exactly, and test slides render the same as the originals.

## Headmatter

```yaml
theme: ../../themes/github
title: "Workshop Title"
ghFooterTitle: "Short Workshop Name"   # footer text (see note below)
ghFooterLabel: ""                      # optional uppercase label after the title
mermaid:
  theme: dark
transition: slide-left
mdc: true
layout: cover
```

The header and footer are hidden on slide 1. The footer reads `ghFooterTitle` from each slide's own frontmatter, so content slides show "GitHub Workshop" unless they set it too. The original decks behave the same way.

## Layouts

| Layout | Use for | Content |
|---|---|---|
| `cover` | First slide | `# Title`, `## Subtitle`, `*tagline*`, `` `repo` `` |
| `default` | Content slides | Anything. Add `class: text-sm` or `text-xs` to fit dense slides. |
| `section` | Section dividers | `# Section name` only |
| `demo` | Live-demo cue | `# 🖥️ LIVE DEMO`, `### What`, short bullets, `*Then: …*` |
| `end` | Questions / thank you | `# Questions?`, optional `### …` and bullets |

Slidev's built-in layouts (`center`, `two-cols`, …) also work. Some upstream decks use them.

## Utility classes

Wrap the content in a `<div>`, with blank lines inside it so the Markdown still renders:

- **Boxes:** `gh-box`, `gh-box-accent` (blue), `gh-box-copilot` (purple), `gh-box-success`, `gh-box-attention`
- **Callouts:** `gh-callout` (💡 prefix), plus `gh-callout-blue`, `gh-callout-purple` or `gh-callout-green` for a coloured left border
- **Badges:** `<span class="gh-badge gh-badge-blue">` (also `green`, `purple`, `yellow`, `red`)
- **Stats:** `gh-stat` containing `gh-stat-value` and `gh-stat-label`
- **Two columns:** `gh-split`, a two-column grid of glass cards (one per direct child)

Colours are CSS variables in `styles/index.css` (`--gh-accent-fg`, `--gh-copilot`, `--gh-glass-bg`, …).
