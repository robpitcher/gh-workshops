# GitHub Workshops

Enterprise training materials — slide decks, hands-on labs, and demo scripts for teams adopting GitHub.

**View the site →** <https://robpitcher.github.io/gh-workshops/>

> This repository hosts the built static site. Source content is maintained in the [GH-Hack](https://github.com/thomasiverson/GH-Hack) private repo.

## Agent guidance

Repository instructions are maintained in [AGENTS.md](AGENTS.md).
[CLAUDE.md](CLAUDE.md) imports that file for Claude Code. GitHub Copilot discovers
the Slidev skill through `.github/skills/slidev/SKILL.md`, which points to the
shared guidance and references in `.claude/skills/slidev/`.

## GitHub Pages

This fork publishes the built static site from the root of the `robpitcher`
branch. In **Settings > Pages > Build and deployment**, use **Deploy from a
branch**, select **robpitcher**, and select **/ (root)**. This is a repository
setting, not a workflow file; changes must reach `robpitcher` to be published.
Keep `.nojekyll` and the `/gh-workshops/` URL prefix intact.

Syncing the fork updates only the default `gh-pages` branch, not `robpitcher`.
When merging `gh-pages` into `robpitcher` to pick up upstream workshops, upstream
deploy commits may conflict with fork-specific files such as these instructions,
skills, and this README; resolve in favor of the fork's versions.
