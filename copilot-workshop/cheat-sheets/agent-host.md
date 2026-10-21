# Copilot: Zero to Agents · 2-Hour Cheat Sheet (Agent Host)

> **Target:** VS Code chat → Session Target **Copilot** (runs in Agent Host) → modes **Interactive / Plan / Autopilot** · **Folder** isolation · **Manual** permissions
> **Repo:** `robpitcher/GitHubCopilot_Customized` (OctoCAT Supply) · **Format:** demo-first; audience try-its are optional, so keep moving
> Cut down from the full 4h45m Agent Host workshop guide. Everything below is in delivery order. Using the Local target instead? See `local.md`.

## Run of show

| ⏱ Clock | Block | Min | The one thing they must see |
|---|---|---|---|
| 0:00 | 1 · Welcome + app tour | 5 | The app runs; `.github/` is where customizations live |
| 0:05 | 2 · Interactive / Plan / Autopilot | 12 | Mode, model, and permissions are separate controls |
| 0:17 | 3 · Custom instructions | 15 | TAO: Copilot writes code for a framework it has never seen |
| 0:32 | 4 · Scoped instructions | 8 | Same question, better answer, thanks to `applyTo` |
| 0:40 | 5 · Agent skills | 15 | A skill loads by relevance, or on demand with `/name` |
| 0:55 | Break | 5 | (Optional: start the cloud agent now, see Break) |
| 1:00 | 6 · Custom agents | 12 | Tool list = what the agent is allowed to do |
| 1:12 | 7 · MCP: Playwright + GitHub | 15 | Copilot drives a real browser, then files an issue |
| 1:27 | 8 · Cloud agent + code review | 12 | Issue → PR → AI review |
| 1:39 | 9 · Wrap-up | 3 | The customization stack |
| 1:42 | Q&A / buffer | ~18 | |

**Running late? Cut in this order:** BDD scenarios (§7C) → MCP migration (§7A2) → prompt-file migration (§5E) → builder agent (§6A) → let Copilot do the TAO cleanup (use `git restore` instead, §3D) → creating the issue live (§7D; assign existing issue #12 in §8 instead).

## 0 · Prep (tonight, and 30 min before)

### Tonight

- [ ] Node.js 22+ installed
- [ ] Clone and install: `git clone https://github.com/robpitcher/GitHubCopilot_Customized.git` → `npm ci` (or `npm install`) → `npm run build`
- [ ] `npm run dev` → API on `http://localhost:3000` (Swagger at `/api-docs`), frontend on `http://localhost:5137` (Products page shows items)
- [ ] VS Code 1.140+, Copilot + Copilot Chat signed in. A new session shows **Copilot** in the Session Target, with **Interactive / Plan / Autopilot**, plus the Folder/worktree and permission controls
- [ ] Editor font size 16–18 for projection
- [ ] MCP: in a **Copilot** session, run **MCP: List Servers** and confirm `github` + `playwright` show up. Your repo only has `.vscode/mcp.json`, which VS Code forwards to Agent Host with limitations (see §7). Run one Playwright prompt and one GitHub prompt so the GitHub OAuth sign-in is already done
- [ ] Repo settings: Actions enabled, Copilot cloud agent enabled (branch protection on `main` is recommended)
- [ ] Create and commit `.github/agents/OctoCATEngineer.agent.md` (content in §6, under "Builder agent file"). The guide assumes it exists; your repo doesn't have it. Skip if you'll skip §6A
- [ ] Code-review backup: draft **PR #17** (shopping cart, opened by Copilot) exists. Mark it ready for review and request a Copilot review tonight, so a finished review is waiting if the live one is slow
- [ ] Rehearse each section once, then run **Reset** (end of this page)

### 30 minutes before

- [ ] `git status` is clean on `main`; `npm run dev` is running
- [ ] Browser tabs: repo, Issues, PR #17, `localhost:5137`, `localhost:3000/api-docs`, `github.com/copilot/agents`
- [ ] VS Code: close all editors, open a fresh session (Copilot · Folder · Interactive · Manual)

### Where your repo differs from the guide

| Guide assumes | Your repo | What to do |
|---|---|---|
| No `.github/skills/` folder | `frontend-design` skill already exists (from anthropics/skills) | Use it as the "real-world skill" example in §5A |
| `OctoCATEngineer.agent.md` exists | Not there | Create it tonight, or skip §6A |
| `ImplementationIdeas` is a search-only planner | Yours is the original write-capable version (`github/*`, `create_pull_request_with_copilot`) | Explain only; don't run it (§6C) |
| `.github/prompts/` gets migrated | 3 prompt files there; Agent Host **won't load them** | Mention it in §5; optional migration demo in §5E |
| Frontend `pages/` folder | Pages live in `frontend/src/components/entity/…` | Paths fixed in the files below |
| `api/src/middleware/auth.ts` | Doesn't exist | Context demo below uses `api/src/routes/product.ts` |
| Create a "test coverage" issue in §7 | Issue #12 already covers that | §7D creates the validation issue that §8 hands to the cloud agent |

## 1 · Welcome + app tour · 5 min · ⏱ 0:00

**Say**

- Goal: go from Copilot as autocomplete to Copilot that knows your team's rules: instructions, skills, agents, external tools, and cloud agents.
- Demo app: OctoCAT Supply. React 18 + Vite + Tailwind frontend, Express + TypeScript API with Swagger.
- Everything we build today is a plain file in `.github/`: reviewable, version-controlled, and portable across Copilot surfaces (VS Code, CLI, cloud agent).

**Do**

1. Show the repo in the browser. Open `api/ERD.png` (the data model).
2. In VS Code, expand `.github/`: prompts, agents, one skill, no instructions yet. "We'll build those."
3. Show the app at `localhost:5137` → Products, and the API docs at `localhost:3000/api-docs`.

**Ask the room:** Who has used Copilot Chat? What's your biggest frustration with it? (Common answer: "It doesn't know our internal stuff." That's §3.)

**The map** (show it now, come back to it in §9)

| Layer | File | When it loads |
|---|---|---|
| Custom instructions | `.github/copilot-instructions.md` | Every request |
| Scoped instructions | `.github/instructions/*.instructions.md` | When files matching `applyTo` are in play |
| Agent skills | `.github/skills/<name>/SKILL.md` | By relevance, or when you invoke `/name` |
| Custom agents | `.github/agents/*.agent.md` | When you pick it from the agents dropdown |
| MCP servers | `.mcp.json` (portable) | When Copilot needs one of the server's tools |

## 2 · Interactive / Plan / Autopilot · 12 min · ⏱ 0:05

**Say**

- **Agent Host** is a dedicated process that owns your sessions; the VS Code window just displays them. The **Copilot** target is the GitHub Copilot harness, the same runtime the Copilot CLI uses.
- Pick the **Session Target** before the first prompt. Model, mode, and permissions are separate controls: changing the model doesn't change the harness.
- Three modes. **Interactive** is for questions, coding, and steering. **Plan** researches and gives you a plan to review. **Autopilot** auto-approves tools and keeps going until it decides it's done, so use it only for trusted, bounded work.
- **Folder** isolation edits your checkout directly. **New worktree** works from committed state in a separate checkout and uses Allow all. A worktree isolates code, but it is not a security boundary.

| Need | Pick |
|---|---|
| "Understand, build, fix, iterate" | Copilot + Interactive, with a clear boundary in the prompt |
| "A plan I can review first" | Copilot + Plan (or `/plan`) |
| "Bounded work that can run unattended" | Copilot + Autopilot, only after you've reviewed the scope |

**Do**

**Set up:** New session → select the OctoCAT Supply folder → **Copilot** · **Folder** · **Interactive** · **Manual** permissions.

**A. Read-only question in Interactive.** Interactive can edit, so put the boundary in the prompt:

```prompt
Explain the API architecture and cite the route, model, and Swagger configuration files you used. Do not modify files or run commands.
```

✅ **Look for:** the **References** list, and no files changed.

**B. Plan.** Switch to **Plan**, or type:

```prompt
/plan Add input validation to the Product API POST endpoint. Preserve existing clients, identify decisions I need to make, and include verification steps. Do not implement yet.
```

✅ **Look for:** a plan you can review. Say that approving a plan does **not** approve the tool calls that come later. **Don't implement.**

**C. Autopilot (show, don't run).** Open the mode picker, point at Autopilot, explain that it skips approvals, then switch back to Interactive.

**D. Interactive does the work.**

```prompt
Open the Swagger documentation page for the API
```

✅ **Look for:** approval prompts on each tool call. "Manual permissions mean you approve every action." If the app isn't running, first send `Build and run the project`.

**E. Vague vs. verifiable (1 min).** A strong request states: **Outcome** · **Scope** · **Constraints** · **Evidence** · **Verification**. Attach `api/src/routes/product.ts` with **Add Context**, then:

```prompt
Explain the endpoints in this file and every model it uses. Cite the files and symbols you used, identify unhandled failure paths, and do not modify files or run commands.
```

> 💬 "The host owns the session, the harness runs the workflow, the model reasons, and permissions decide what happens without you. They're separate controls."

<details>
<summary>🛟 If it breaks</summary>

- **Copilot target or its modes are missing:** start a new session and pick Copilot *before* the first prompt. Update VS Code and the Copilot extensions. Availability also depends on org policy.
- **Agent starts a second dev server and hits a port conflict:** keep the server that's already running; check ports 3000 and 5137.
- **Need something only Local has:** Local (Ask / Agent / Plan) is still in the picker as a transitional fallback.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

```prompt
Identify the testing framework and current test files. Cite your evidence, do not modify files, and do not run commands.
```

Then run prompt B in Plan mode, and remind them not to implement it.

</details>

## 3 · Custom instructions · 15 min · ⏱ 0:17

**Say**

- `.github/copilot-instructions.md` (or `AGENTS.md`) is project guidance that Copilot adds to every request in this repo. It's reviewable, version-controlled context.
- **Good content:** coding standards, architecture patterns, internal frameworks, security rules, testing conventions. **Bad content:** whole API docs, tutorials, long prose. Keep it short, because it uses context on every request.
- Instructions guide behavior; they don't enforce anything. Enforcement still comes from tests, hooks, CI, and secret scanning.

**Do**

**A. Baseline.** New session → Copilot + **Interactive**. Ask this and remember the answer (you'll compare in §4):

```prompt
Explain how I should add a new API endpoint to this project. Cite evidence and do not modify files or run commands.
```

Note whether it mentions Swagger, the existing route pattern, or the entity model structure.

**B. Generate the instructions.** Command Palette → **Chat: Open Customizations** (or **Configure Chat** → **Overview**) → ask it to generate workspace instructions from the repository. Review the result: project name and stack, architecture (React + Express), build (`npm ci && npm run build`), tests (Vitest). Save it as `.github/copilot-instructions.md`.

> 💬 "Copilot just read the whole repo and wrote its own instruction manual. That file now goes along with every request."

**C. TAO: teach Copilot a framework it has never seen.** Open `docs/tao.md` for a moment: "a fictional internal observability framework that exists only in this workshop." Then add this to the end of `.github/copilot-instructions.md`:

```markdown file=.github/copilot-instructions.md (append)
## Observability Requirements
- Implement logging and monitoring using TAO (TypeScript API Observability)
- Reference: docs/tao.md
- Assume TAO is installed — never add the package
- Use @Measure, @Trace, and @Log decorators for all service methods
- Configure initTAO() in the application entry point
```

Stay in Copilot + **Interactive** (Manual permissions):

```prompt
Add observability to the Supplier route using our internal standards
```

✅ **Look for:** `import { Measure, Trace } from '@tao/core'` and `@Measure` / `@Trace` / `@Log` decorators, all taken from the local docs and instructions.

> 💬 "The repository supplied context for a framework that exists nowhere else. Imagine this for your company's internal libraries. It still needs review and a build, though: instructions steer the output, they don't guarantee it's correct."

Say that the code won't compile, on purpose: the TAO package doesn't exist. The failed build is the evidence that following instructions still needs validation.

**D. Clean up (required before §4).** Stay in Interactive:

```prompt
Revert the TAO observability changes you just made to the Supplier route, and remove the "Observability Requirements" section from .github/copilot-instructions.md. The TAO framework is fictional and the code won't compile.
```

✅ **Verify:** TAO imports and decorators are gone, the section is gone from the instructions file, and `npm run build` passes.

**Faster fallback:** run `git restore api/` and delete the Observability section by hand.

<details>
<summary>🛟 If it breaks</summary>

- **Can't find the generate option:** in Interactive, send:

```prompt
Analyze this repository and create a comprehensive copilot-instructions.md file that describes our tech stack, architecture, coding standards, and build process.
```

- **Instructions seem ignored:** the file must be exactly `.github/copilot-instructions.md`. Expand **References** to see whether it was used.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

Ask the baseline question, generate their own instructions through Chat: Open Customizations, then ask again.

</details>

## 4 · Scoped instructions · 8 min · ⏱ 0:32

**Say**

- Files in `.github/instructions/` named `*.instructions.md` carry an `applyTo` glob in their frontmatter. They only apply when you're working with matching files.
- `api/**` means: load these rules whenever a file under `api/` is in play. Different folders can have different rules.

**Do**

**A.** Create the API rules file:

```markdown file=.github/instructions/API.instructions.md
---
applyTo: "api/**"
---
# API Development Instructions

For REST APIs in this project:
- Use descriptive endpoint naming following REST conventions
- Add Swagger/OpenAPI docs for all API methods
- Implement proper error handling with appropriate HTTP status codes
- Follow the entity pattern established in existing routes
- Include input validation for all POST/PUT endpoints
```

**B.** Open `api/src/routes/product.ts`. New session → Copilot + **Interactive**:

```prompt
Explain how I should add a new API endpoint to this project. Cite the applicable instructions and existing route patterns. Do not modify files or run commands.
```

✅ **Look for (compare with §3A):** Swagger/OpenAPI docs, REST naming, HTTP status codes, POST/PUT validation, the entity pattern. Expand **References** and point at `API.instructions.md`.

> 💬 "Scoped instructions are like a per-folder `.editorconfig` for AI. They only kick in when you're working in matching files."

<details>
<summary>➕ Optional: a frontend rule file (if time)</summary>

```markdown file=.github/instructions/Frontend.instructions.md
---
applyTo: "frontend/**"
---
# Frontend Development Instructions

For React components in this project:
- Use functional components with TypeScript
- Use Tailwind CSS for all styling — no inline styles or CSS modules
- Follow the existing component structure in frontend/src/components/
- Use React hooks for state management
- All components should be exported as default exports
```

Open a file in `frontend/src/` and ask Copilot how to build a new component. Look for Tailwind and TypeScript guidance.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

Create `API.instructions.md`, open `product.ts`, and compare the answer with their baseline.

</details>

## 5 · Agent skills · 15 min · ⏱ 0:40

**Say**

- A skill is a folder containing `SKILL.md`, plus optional scripts or templates. Copilot sees each skill's name and `description` and may load the skill when your task matches. You can also invoke it yourself as `/skill-name`.
- **Instructions** are applicable standards. **Skills** are "when doing X, follow these steps." **Agents** (next section) are a role you pick.
- Skills are an open standard (VS Code, Copilot CLI, Copilot cloud agent, other agents). Project skills go in `.github/skills/`, personal ones in `~/.copilot/skills/`.
- **Prompt files** (`.github/prompts/*.prompt.md`) are deprecated in Agent Host and don't load there. Skills are the way forward (optional migration in E below).

| | Custom instructions | Agent skills |
|---|---|---|
| Location | `.github/copilot-instructions.md` | `.github/skills/*/SKILL.md` |
| When loaded | Included when applicable | By relevance, or by `/name` |
| Best for | Simple, universal rules | Detailed, specialized procedures |
| Can include | Markdown only | Markdown + scripts + resources |

**Do**

**A. A real one (1 min).** Open `.github/skills/frontend-design/SKILL.md`. It's already in your repo, from Anthropic's community skills. Point at the `description`: "This is the trigger."

**B. Create a skill.**

```bash
mkdir -p .github/skills/code-review-checklist
```

```markdown file=.github/skills/code-review-checklist/SKILL.md
---
name: code-review-checklist
description: Checklist for reviewing TypeScript and Express.js code.
  Use this when asked to review code, audit code quality, or check for
  security and performance issues.
---

When reviewing TypeScript or Express.js code, follow this checklist:

1. **Security**
   - Check for unsanitized user input in route handlers
   - Verify no hardcoded secrets, API keys, or credentials
   - Ensure proper authentication/authorization checks on protected routes
   - Look for SQL/NoSQL injection risks in database queries

2. **Input Validation**
   - Confirm all POST/PUT endpoints validate request body fields
   - Check for missing type guards on `req.params` and `req.query`
   - Verify appropriate HTTP status codes for validation failures (400, 422)

3. **Error Handling**
   - Ensure every route has try/catch with meaningful error responses
   - Check that errors are logged but sensitive details are not leaked to clients
   - Verify async errors are properly caught (no unhandled promise rejections)

4. **Performance**
   - Identify N+1 query patterns or unnecessary database calls
   - Check for missing pagination on list endpoints
   - Look for blocking synchronous operations in async handlers

5. **Maintainability**
   - Verify consistent naming conventions (camelCase for variables, PascalCase for types)
   - Check for DRY violations — duplicated logic that should be extracted
   - Ensure Swagger/OpenAPI annotations are present and accurate
```

Explain the two fields. `name` is lowercase with hyphens and matches the folder. `description` is the matching key, so say *when* to use the skill.

**C. Watch it load by relevance.** New session → Copilot + **Interactive**:

```prompt
Review the product route handler for security and performance issues
```

✅ **Look for:** **References** lists the skill, and the answer follows its sections (Security, Input Validation, Error Handling, Performance, Maintainability). If it didn't load, invoke it explicitly and compare:

```prompt
/code-review-checklist Review the product route handler for security and performance issues
```

Contrast with something unrelated:

```prompt
What entities does this API manage?
```

> 💬 "A good description makes automatic loading possible, not guaranteed. The slash command gives you a deterministic way to ask for the workflow."

**D. Who can trigger it.** Two optional frontmatter flags control that:

| Frontmatter | `/name` works | Copilot can load it by relevance | Use for |
|---|---|---|---|
| (neither set) | Yes | Yes | A general reusable skill |
| `user-invocable: false` | No | Yes | Background domain knowledge |
| `disable-model-invocation: true` | Yes | No | A deliberate workflow or approval checkpoint |

Where to find more: [github/awesome-copilot](https://github.com/github/awesome-copilot), [anthropics/skills](https://github.com/anthropics/skills), [skills.sh](https://skills.sh).

<details>
<summary>➕ E. Optional (3 min): migrate a prompt file to a skill</summary>

1. With the Copilot target selected, open `.github/prompts/Unit-Test-Coverage.prompt.md`. Point out the workflow, references, and success criteria worth keeping.
2. Command Palette → **Chat: Open Customizations** → **Overview** → **Migrate Prompt Files** → **Convert to Skills** → select `Unit-Test-Coverage.prompt.md` (keep the original).
3. Open `.github/skills/unit-test-coverage/SKILL.md`. Check that the folder matches `name`, the description says what and when, and the Local-only `mode` / `model` / `tools` lines are gone.
4. To keep it manual-only, add these to the frontmatter:

```yaml
user-invocable: true
disable-model-invocation: true
```

5. New session → `/unit-test-coverage` → check References. Stop before it generates a lot of tests.

> 💬 "Migration keeps the workflow, not every line of frontmatter. Modes, permissions, and tools belong to the harness and the agent."

</details>

<details>
<summary>🛟 If it breaks</summary>

- **Skill doesn't load:** check that the file is named exactly `SKILL.md` (case-sensitive), that the folder name matches `name`, and that your prompt uses words from the `description`. Fall back to `/code-review-checklist`.
- **Can't tell whether it loaded:** check References.

</details>

<details>
<summary>🧪 Audience try-it (optional): API route skill</summary>

```bash
mkdir -p .github/skills/api-route-creation
```

```markdown file=.github/skills/api-route-creation/SKILL.md
---
name: api-route-creation
description: Guide for creating new API routes in the Express.js backend.
  Use this when asked to add new endpoints, entities, or REST resources.
---

Follow this process when creating new API routes:

1. **Create the entity model** in `api/src/models/`
   - Follow the TypeScript interface pattern from existing models
   - Include all required and optional fields with proper types

2. **Create the route file** in `api/src/routes/`
   - Follow the pattern from `api/src/routes/product.ts`
   - Implement full CRUD: GET (list), GET (by ID), POST, PUT, DELETE
   - Add proper error handling with try/catch and appropriate HTTP status codes

3. **Register the route** in `api/src/index.ts`
   - Import the new route module
   - Add it to the Express app with the correct base path

4. **Add Swagger documentation**
   - Add JSDoc annotations with @swagger tags on each endpoint
   - Include request/response schemas, parameters, and example values

5. **Create tests** in `api/src/routes/<entity>.test.ts`
   - Follow the pattern from existing test files
   - Test all CRUD operations and error scenarios
   - Use vitest as the test framework
```

Then, in Copilot + Interactive:

```prompt
I need to add a new "Warehouse" entity and API endpoints for managing warehouses. Each warehouse has a name, address, city, state, zipCode, and capacity.
```

If References doesn't show the skill, stop and run:

```prompt
/api-route-creation Create a Warehouse entity with a name, address, city, state, zipCode, and capacity.
```

</details>

## Break · 5 min · ⏱ 0:55

**Optional, recommended:** start a cloud agent now so there's a finished PR to review in §8. In the browser, open **issue #12** ("Enhance test coverage in the API project") → **Assignees** → **Copilot**. It takes 5–30 minutes. This uses AI credits and Actions minutes.

## 6 · Custom agents · 12 min · ⏱ 1:00

**Say**

- `.github/agents/*.agent.md` (or `~/.copilot/agents/` for personal ones) defines a reusable role. With the Copilot target selected, agents appear in the Agent dropdown.
- Frontmatter: `description` (shown in the dropdown), `tools` (what it may use), `model` (optional).
- The tools list is the big lever: the same file format with different tools gives completely different behavior. Permissions and sandboxing still apply on top of it.
- Skill vs agent: a skill teaches a workflow. An agent is a role you choose, with its own tool limits.

**Do**

**A. The builder, OctoCATEngineer (optional, 3 min).** Open `.github/agents/OctoCATEngineer.agent.md` (created tonight). Point out the tools (search, edit, terminal, problems) and that there's no `model`, so it uses your selected Copilot model. Select it in the Agent dropdown:

```prompt
Add a GET /api/products/search endpoint that accepts a `name` query parameter and returns matching products. Follow the existing route pattern and include Swagger documentation and focused tests.
```

Show it reading `product.ts` for the pattern before it edits. Stop it after a minute if you need the time. **Reset:** `git restore api/`, then `git clean -n api/` to preview and `git clean -f api/` to remove new files.

**B. A read-only reviewer, CodeReviewer (6 min).** Create:

```markdown file=.github/agents/CodeReviewer.agent.md
---
tools: ['codebase', 'search', 'usages', 'problems']
description: Review code for security, performance, and best practices
---

You are an expert code reviewer specializing in TypeScript and React applications.

When reviewing code:

1. **Security**: Check for XSS, injection, insecure data handling
2. **Performance**: Identify N+1 queries, unnecessary re-renders, memory leaks
3. **Best Practices**: Verify error handling, input validation, type safety
4. **Maintainability**: Check naming, code organization, DRY violations

Always provide:
- Severity level (Critical / Warning / Suggestion)
- Specific file and line references
- Concrete fix recommendations with code examples

Be direct and opinionated. Don't say "consider" — say "change this to..."
```

It appears in the Agent dropdown right away. Point out: read-only tools (no `editFiles`, no `runCommands`), no hard-coded model, and a reviewer persona. Select **CodeReviewer**:

```prompt
Review the product route handler for security and performance issues
```

Follow-up:

```prompt
Now review the error handling across all API routes
```

✅ **Look for:** severity labels, file and line references, a "change this to…" tone, and no files edited.

> 💬 "Same file format, completely different behavior. The tool list controls what an agent can do."

This is the same prompt as §5. The skill gave Copilot a checklist; the agent gives it a persona and guardrails (it can't edit).

**C. The advanced pattern, ImplementationIdeas (3 min, explain only).** Open `.github/agents/ImplementationIdeas.agent.md`. Your repo has the original version:

- `github/*` and `playwright/*`: wildcards for every tool on those MCP servers (§7)
- `model: Claude Sonnet 4.5`: the agent picks its own model
- "call GitHub's `create_pull_request_with_copilot`": it starts cloud-agent work on its own (§8)

The Agent Host guide recommends a safer design: a **search-only planner** that researches options and writes a delegation brief, so a human starts the cloud work explicitly. Use that as the talking point: "Research and delegation should be separate approval steps."

⚠️ **Don't run it live.** As written, it starts one cloud-agent session per idea it comes up with, and each uses AI credits and Actions minutes.

<details>
<summary>🛟 If it breaks</summary>

- **Agent isn't in the dropdown:** confirm the Copilot target is selected, then Command Palette → **Reload Window**.
- **Tool IDs flagged as invalid:** delete those entries and re-add tools through **Configure Tools** / **Add Tools**, with the Copilot target selected so the IDs match this harness.
- **Easiest way to author agents:** Chat: Open Customizations with the Copilot target selected generates files with the right tool IDs.

</details>

<details>
<summary>📄 Builder agent file (create tonight, for §6A)</summary>

Frontend paths are corrected to match your repo.

```markdown file=.github/agents/OctoCATEngineer.agent.md
---
tools: ['search', 'editFiles', 'runCommands', 'problems']
description: Full-stack engineer for the OctoCAT Supply app
---

You are a senior full-stack TypeScript engineer working on the OctoCAT Supply application — a supply chain management web app with a React 18+ frontend (Vite, Tailwind CSS) and an Express.js API backend (TypeScript, OpenAPI/Swagger).

## Your Approach

- Read existing code patterns before making changes — follow the conventions already established in the project
- Use TypeScript with strict typing for all new code
- Follow REST conventions for API endpoints
- Add Swagger/OpenAPI documentation annotations for any new or modified API routes
- Use Tailwind CSS for all frontend styling — no inline styles or CSS modules
- Use functional React components with hooks

## Backend Conventions

- Entity models go in `api/src/models/`
- Route handlers go in `api/src/routes/`
- Follow the pattern established in `api/src/routes/product.ts` for new routes
- Register new routes in `api/src/index.ts`
- Use proper error handling with try/catch and appropriate HTTP status codes
- Include input validation for all POST/PUT endpoints

## Frontend Conventions

- Entity pages go in `frontend/src/components/entity/<entity>/`
- Reusable components go in `frontend/src/components/`
- Follow the component structure in `frontend/src/components/entity/product/Products.tsx`
- Use React Router for navigation
- Handle loading, error, and empty states in all data-fetching components

## Testing

- Use vitest as the test framework
- Follow patterns from existing test files
- Run tests after making changes to verify nothing is broken

## Workflow

1. Understand the task by reading relevant existing code
2. Plan the changes needed
3. Implement the changes across all affected files
4. Build and verify the changes compile successfully
5. Run tests if applicable
```

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

Create `CodeReviewer.agent.md`, select it, and run the review prompt above.

</details>

## 7 · MCP: Playwright + GitHub · 15 min · ⏱ 1:12

**Say**

- MCP (Model Context Protocol) plugs external tools into Copilot. The config is part of the repo, so the whole team gets it.
- For Agent Host, the portable places are **`.mcp.json`** (workspace) and `~/.copilot/mcp-config.json` (user). `.vscode/mcp.json` is a compatibility source: VS Code forwards eligible servers, but Agent Host doesn't read it directly.
- There are two kinds of server. **HTTP** servers are remote and sign in with OAuth (GitHub). **stdio** servers run as a local process (Playwright). A server starts the first time Copilot needs one of its tools.

| Location | Read by | Use it for |
|---|---|---|
| `.mcp.json` | Agent Host and compatible tools | Workspace config (preferred) |
| `~/.copilot/mcp-config.json` | Copilot harness + Copilot CLI | Your personal servers |
| `.vscode/mcp.json` | VS Code (forwards eligible servers) | Compatibility only |

**Do**

**A. Check the servers (1 min).** Command Palette → **MCP: List Servers** in a Copilot session. Both `github` and `playwright` should be listed (forwarded from `.vscode/mcp.json`). "Not started" is normal until the first use.

**Approvals:** keep **Manual** permissions and review each external action before approving it. Use **Chat: Manage Tool Approval** to see saved choices. Don't grant global "always allow" just for convenience.

<details>
<summary>➕ A2. Optional (2 min): migrate to the portable <code>.mcp.json</code></summary>

1. Command Palette → **Chat: Open Customizations** → **Overview** → **Migrate MCP Servers**.
2. Review the Migratable and Not migratable groups, then migrate to the workspace-root `.mcp.json`. Keep `.vscode/mcp.json` until you've verified the result.
3. Check that the file has a top-level `mcpServers` key and no secrets.
4. Rename `.vscode/mcp.json` to `.vscode/mcp.json.pre-agent-host`, start a new Copilot session, and run **MCP: List Servers**. Both servers should still be there, now loaded from `.mcp.json`.

If the migration flow isn't available, paste this:

```json file=.mcp.json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@0.0.83", "--isolated"]
    }
  }
}
```

</details>

**B. Playwright drives a browser (5 min).** Copilot + **Interactive** (Manual):

```prompt
Browse to http://localhost:5137 and navigate to the Products page. Describe what you see.
```

✅ **Look for:** a real browser window opens, and Copilot describes the product grid, images, prices, and Add to Cart buttons.

```prompt
Click on one of the products and check if the product details are displayed correctly
```

> 💬 "You just ran a functional test in plain English. No test scripts, no selectors, no framework setup."

**C. BDD scenarios (optional, 3 min).** New session (+):

```prompt
Run the following BDD test scenarios against http://localhost:5137 using Playwright:
1. Given I navigate to the Products page, Then I should see a list of products with names, images, and prices
2. When I click on a product, Then I should see the product details
3. When I click "Add to Cart" on a product, Then I should see a confirmation
Report pass/fail for each scenario.
```

Bonus: `Create a workspace skill from the BDD workflow we just verified.` turns the conversation into a reusable `/bdd-playwright-tests` skill.

**D. GitHub from chat (5 min).** Name the repo explicitly:

```prompt
In robpitcher/GitHubCopilot_Customized, check which issues are assigned to me. Do not write anything.
```

Then create the issue you'll hand to the cloud agent in §8:

```prompt
In robpitcher/GitHubCopilot_Customized, draft a GitHub Issue titled "Add input validation to the Product API POST endpoint". Description: The POST /api/products endpoint accepts any payload without validation. Add Zod schema validation for required fields (name, price, supplierId). Return 400 with validation errors for invalid payloads. Include unit tests for the validation. Assign it to me. Show me the repository, title, body, labels, and assignee, wait for my approval, then create exactly one issue and return its URL.
```

✅ **Look for:** Copilot shows the draft and waits; you approve; the issue appears on the Issues tab. **Write down the issue number.**

> 💬 "You just managed your GitHub project without leaving VS Code. Every write waited for your approval. Next, we hand this issue to an autonomous agent."

<details>
<summary>🛟 If it breaks</summary>

- **Servers missing in Agent Host:** forwarding from `.vscode/mcp.json` has limits. Use A2, or paste the `.mcp.json` above and start a new session.
- **Playwright fails:** the app must be reachable from where Playwright runs (local desktop is easiest). Check that it's on `:5137`. Fallback: screenshots, then move on to GitHub MCP.
- **GitHub auth error:** send another GitHub prompt to trigger the OAuth flow again. Fallback: create the issue in the browser.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

```prompt
Browse to http://localhost:5137 and describe what you see on the home page
```

```prompt
Navigate to the Products page and click on the first product. Describe the product details you see.
```

</details>

## 8 · Cloud agent + Copilot code review · 12 min · ⏱ 1:27

**Say**

- Cloud agents run on GitHub, not in your editor. They're asynchronous: assign the work and go do something else.
- The loop: **Issue → Copilot cloud agent** (branch, code, tests) **→ PR → Copilot code review + human review → merge.**
- It follows the repo's supported instructions and skills, but only what's pushed to GitHub. The files we made today exist only on this laptop unless we commit and push them.
- Per the guide: the cloud agent is generally available, and the "assign an issue to Copilot" flow is marked public preview in GitHub Docs.

**Do**

**A. Assign the issue (5 min).** In the browser, open the issue from §7D → **Assignees** → **Copilot**. Show the session starting in the agents panel or at `github.com/copilot/agents`. Explain the steps: it creates a branch, reads the code and the instructions/skills, implements the change, runs tests, and opens a PR. This takes 5–30 minutes. ⚠️ It uses AI credits and Actions minutes.

Remind them of §6C: "A custom agent can research and write the brief. A human approves, then the cloud agent implements."

> 💬 "You just delegated a coding task to an autonomous agent. It returns its work as a pull request for review."

**B. Copilot code review (7 min).** Open a PR: the cloud-agent PR if you started one at the break, otherwise **PR #17**. **Reviewers** → **Copilot**. Talk through the loop while you wait. Then show:

- Inline comments with suggested changes
- **Apply suggestion** creates a commit (only do this on a throwaway PR)
- Resolving or dismissing a comment
- Some file types are skipped (dependency manifests, logs, SVGs), so "reviewed" doesn't mean every changed file

> 💬 "Copilot catches pattern-based correctness, security, and maintainability issues. People still own intent, risk, and business behavior. The best setup is Copilot plus human review."

| | Copilot in Agent Host | Copilot cloud agent |
|---|---|---|
| Runs | Your machine, a connected host, or a Dev Container | GitHub's cloud, against the repo |
| Style | Interactive; you steer with modes and permissions | Async and autonomous |
| Output | File changes in your workspace | A pull request |
| Best for | Exploring and iterating | Well-defined tasks you can hand off |

**Ask the room:** What would you keep local, and what would you delegate? What guardrails would you require (branch protection, required human review)?

<details>
<summary>🛟 If it breaks</summary>

- **Cloud agent doesn't start:** check that Actions are enabled and Copilot cloud agent is enabled in repo settings; check plan and policy.
- **Review is slow:** show the review you requested on PR #17 last night.

</details>

## 9 · Wrap-up · 3 min · ⏱ 1:39

**Which tool for which job**

| If the thought is… | Use |
|---|---|
| "This is always true in our repo" | Custom instructions |
| "This is true for these folders" | Scoped instructions |
| "When doing X, follow these steps" | Agent skill (replaces prompt files) |
| "Act as this role, with only these tools" | Custom agent |
| "Copilot needs to reach an outside system" | MCP server (`.mcp.json`) |
| "Well-defined task; I don't need to watch" | Cloud agent + code review |

**Takeaways:** instructions capture tribal knowledge (TAO). Skills load by relevance or by `/name`. Agents are roles with guardrails. MCP extends Copilot's reach. Cloud agents close the loop from issue to PR to review. And the same `.github/` files follow you to the Copilot CLI and the cloud.

**Homework for attendees:** commit your `.github/` files. List 3–5 internal frameworks or patterns to turn into instructions. Turn existing prompt files into skills. Turn on Copilot code review.

**Likely questions**

- *What happened to prompt files?* They're deprecated in Agent Host. Use Chat: Open Customizations → Migrate Prompt Files → Convert to Skills.
- *Is Local going away?* The guide says it's scheduled for removal in a future VS Code release. Don't build new team workflows on it.
- *Do skills and instructions conflict?* Both can load at once. Instructions apply whenever they match; skills come in when relevant or when invoked.
- *Does the cloud agent respect branch protection?* Yes. It opens a PR, and your rules and reviews still apply.
- *Can we restrict MCP servers?* Org and enterprise Copilot policies control MCP access. Point them to the docs.

## Reset (after rehearsal, and after the session)

**GitHub:** close the issue you created in §7D, cancel any cloud-agent session that's still running, and close test PRs without merging:

```bash
gh issue close <ISSUE_NUMBER> --comment "Closing workshop demo artifact."
gh pr close <PR_NUMBER> --delete-branch
```

**Local:** stop `npm run dev` (Ctrl+C). If you did §7A2, restore the MCP file first:

```bash
mv .vscode/mcp.json.pre-agent-host .vscode/mcp.json
```

Then:

```bash
git status --short
git restore .
git clean -fd -n -- .github api .mcp.json
```

Read the dry-run list first, then remove only the workshop files:

```bash
git clean -f -- .github/copilot-instructions.md .github/agents/CodeReviewer.agent.md .mcp.json
git clean -fd -- .github/instructions .github/skills/code-review-checklist .github/skills/api-route-creation .github/skills/unit-test-coverage .github/skills/bdd-playwright-tests
```

Never run a plain `git clean -fd`. Keep `OctoCATEngineer.agent.md` if you committed it.

## Cut from this session (if someone asks)

| Topic | One-liner if asked |
|---|---|
| Inline completions + inline chat (`Cmd+I`) | Ghost text as you type; `Cmd+I` for a quick, focused edit in the current file |
| Claude / Codex targets, `CLAUDE.md`, `AGENTS.md` | Other harnesses in the same picker, each with its own config format |
| Copilot Memory | Personal preferences that Copilot recalls; never store secrets there |
| Folder vs. worktree, sandboxing in depth | Worktree = separate checkout (Allow all); sandboxing limits terminal commands only |
| GitHub Copilot CLI | The same Copilot runtime in your terminal; `/delegate` hands work to the cloud |

## Quick reference

| Type | Path | Loads |
|---|---|---|
| Project instructions | `.github/copilot-instructions.md` or `AGENTS.md` | When applicable |
| Scoped instructions | `.github/instructions/*.instructions.md` | When `applyTo` matches |
| Project skills | `.github/skills/<name>/SKILL.md` | By relevance or `/name` |
| Personal skills | `~/.copilot/skills/<name>/SKILL.md` | By relevance or `/name` |
| Custom agents | `.github/agents/*.agent.md` | When picked in the dropdown |
| MCP config | `.mcp.json` · `~/.copilot/mcp-config.json` | When a tool is needed |

**Shortcuts (Mac):** Command Palette `Cmd+Shift+P` · Inline chat `Cmd+I` · New session: the **+** in the Chat view · Mode picker: Interactive / Plan / Autopilot
