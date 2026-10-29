# GitHub Workshops (built site)

Built static site for enterprise GitHub/Copilot workshops (Astro shell + Slidev decks), served from GitHub Pages at `/gh-workshops/`. This is a fork; every upstream commit is an automated `deploy: thomasiverson/ghcp-content@<sha>` from a private source repo, so there is no source code or build here.

## Rules

- Edits here are patches to build output. A future upstream deploy can overwrite them (including this file and `README.md`). Prefer adding new files (e.g. `<workshop>/cheat-sheets/*.md`) over editing generated ones, and tell the user when a change will be lost on the next upstream sync.
- Never delete `.nojekyll`: without it GitHub Pages hides `_astro/` and the whole site loses its CSS/JS.
- All internal URLs are absolute and start with `/gh-workshops/`. Keep that prefix in any link or asset path you add.
- `_astro/` is shared by every workshop page, and `*/slides/assets/` files are content-hashed bundles referenced by name from `slides/*/index.html`. Don't rename them; edit in place only when necessary and keep edits minimal.
- Generated HTML/JS is minified. Don't run formatters or prettifiers on it; make surgical string edits.

## Layout

- `index.html` — landing page listing all workshops.
- `<workshop>/index.html` — workshop overview; `workshop/`, `lab/`, `demo/`, `setup/` — single static HTML pages (Astro).
- `<workshop>/slides/<n>/index.html` — Slidev SPA shell, one per slide; real slide text and speaker notes live in `<workshop>/slides/assets/md-*.js` and `index-*.js`. Grep there to find or change slide content.
- `<workshop>/assets/`, `templates/` — downloadable files and docs for attendees.

## Commands

No build, lint or tests. To preview, serve the parent of a directory named `gh-workshops` (needed for the base path):

```bash
d=$(mktemp -d) && ln -s "$PWD" "$d/gh-workshops" && python3 -m http.server 8000 -d "$d"
```

Then open http://localhost:8000/gh-workshops/. Before calling a change done, load each edited page there and check the browser console for errors.
