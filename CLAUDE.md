# GitHub Workshops

Static site for enterprise GitHub/Copilot workshops (Astro shell + Slidev decks), served from GitHub Pages at `/gh-workshops/`. This is a fork. Upstream commits are automated `deploy: thomasiverson/ghcp-content@<sha>` builds from a private source repo, so existing workshops exist here only as build output. New workshops are authored here: source in `src/`, built output next to the existing ones.

## Rules

- Never delete `.nojekyll`: without it GitHub Pages hides `_astro/` and the whole site loses its CSS/JS.
- All internal URLs are absolute and start with `/gh-workshops/`. Keep that prefix in every link, asset path and Slidev `--base`.
- Don't edit existing workshops' generated files unless asked. `_astro/` is shared by every page, and `*/slides/assets/` are content-hashed bundles referenced by name; don't rename them, and never run formatters on minified output.
- Upstream deploys can overwrite anything here (including this file, `README.md` and the landing `index.html`). Warn the user when a change would be lost on the next upstream sync.
- A new workshop must match the existing ones: same folder layout, page shell, CSS and landing-page card. Copy structure from the closest existing workshop rather than inventing new markup or styles.
- Decks use `theme: ../../themes/github`. Its source in `src/themes/github/` was rebuilt from the compiled decks to match them exactly; read its `README.md` for the layouts, headmatter and `gh-*` classes before writing slides. Keep it matching the existing decks; don't restyle it.

## Layout

- `index.html`: landing page; one `workshop-card` per workshop, sorted by slug.
- `<slug>/index.html`: overview with `resource-card` links to `workshop`, `lab`, `slides/1`, and optionally `demo/`.
- `<slug>/{workshop,lab,demo}/index.html`: Markdown rendered into `<article class="markdown-body">` inside the shared Astro shell (header, `_astro/*.css`, `Base.astro…js`; lab pages also load `lab.astro…js`). Headings carry GitHub-style slug `id`s.
- `<slug>/slides/`: Slidev 52.12.0 build, `routerMode: history`, with `1..N/index.html`, `404.html`, `_redirects` and `assets/`. To read an existing deck's text and notes, grep `<slug>/slides/assets/md-*.js`.
- `src/workshops/<slug>/`: source for new workshops: `slides.md`, `workshop.md`, `lab.md`, optional `demo.md`. Keep the layout so it can move into ghcp-content unchanged (`../../themes/github` then resolves to `src/themes/github`).

## Commands

Preview: serve the parent of a directory named `gh-workshops`, then open http://localhost:8000/gh-workshops/:

```bash
d=$(mktemp -d) && ln -s "$PWD" "$d/gh-workshops" && python3 -m http.server 8000 -d "$d"
```

Slides: `src/build-slides.sh <slug>` builds `src/workshops/<slug>/slides.md` into `<slug>/slides/`. The first run installs the pinned Slidev CLI into the gitignored `.tools/`. A console error "Failed to patch FloatingVue" in built decks is a harmless upstream bug; ignore it.

Pages (planned, unverified): render each `.md` with a small script in `src/` that uses an existing generated page as the template, then record its command here. Don't add a `package.json` at the repo root.

Before calling work done, open the landing page, the overview, each page and the slide deck in the preview, click through the links, and check the browser console for errors.
