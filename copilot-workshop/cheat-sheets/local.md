# Copilot: Zero to Agents · 2-Hour Cheat Sheet (Local)

> **Target:** VS Code chat → Session Target **Local** → roles **Ask / Agent / Plan**
> **Repo:** `robpitcher/GitHubCopilot_Customized` (OctoCAT Supply) · **Format:** demo-first; audience try-its are optional, so keep moving
> Cut down from the full 4h45m workshop guide. Everything below is in delivery order. Using the Copilot target instead? See `agent-host.md`.

## Run of show

| ⏱ Clock | Block | Min | The one thing they must see |
|---|---|---|---|
| 0:00 | 1 · Welcome + app tour | 5 | The app runs; `.github/` is where customizations live |
| 0:05 | 2 · Ask / Agent / Plan | 12 | Same repo, three roles, different behavior |
| 0:17 | 3 · Custom instructions | 15 | TAO: Copilot writes code for a framework it has never seen |
| 0:32 | 4 · Scoped instructions | 8 | Same question, better answer, thanks to `applyTo` |
| 0:40 | 5 · Agent skills | 15 | A skill loads on its own when the task matches |
| 0:55 | Break | 5 | (Optional: start the cloud agent now, see Break) |
| 1:00 | 6 · Custom agents | 12 | Tool list = what the agent is allowed to do |
| 1:12 | 7 · MCP: Playwright + GitHub | 15 | Copilot drives a real browser, then files an issue |
| 1:27 | 8 · Cloud agent + code review | 12 | Issue → PR → AI review |
| 1:39 | 9 · Wrap-up | 3 | The customization stack |
| 1:42 | Q&A / buffer | ~18 | |

**Running late? Cut in this order:** BDD scenarios (§7C) → builder agent (§6A) → let Copilot do the TAO cleanup (use `git restore` instead, §3D) → Plan role (§2) → creating the issue live (§7D; assign existing issue #12 in §8 instead).

## 0 · Prep (tonight, and 30 min before)

### Tonight

- [ ] Clone and install: `git clone https://github.com/robpitcher/GitHubCopilot_Customized.git` → `npm install` → `npm run build`
- [ ] `npm run dev` → API on `http://localhost:3000` (Swagger at `/api-docs`), frontend on `http://localhost:5137` (Products page shows items)
- [ ] VS Code 1.140+, Copilot + Copilot Chat signed in. New chat shows **Local** in the Session Target, with Ask / Agent / Plan in its role picker
- [ ] Editor font size 16–18 for projection
- [ ] MCP: `.vscode/mcp.json` has `github` + `playwright`; setting `chat.mcp.discovery.enabled` is on. Run one Playwright prompt and one GitHub prompt so the GitHub OAuth sign-in is already done
- [ ] Repo settings: Actions enabled, Copilot cloud agent enabled (branch protection on `main` is recommended)
- [ ] Create and commit `.github/agents/OctoCATEngineer.agent.md` (content in §6, under "Builder agent file"). The guide assumes it exists; your repo doesn't have it. Skip if you'll skip §6A
- [ ] Code-review backup: draft **PR #17** (shopping cart, opened by Copilot) exists. Mark it ready for review and request a Copilot review tonight, so a finished review is waiting if the live one is slow
- [ ] Rehearse each section once, then run **Reset** (end of this page)

### 30 minutes before

- [ ] `git status` is clean on `main`; `npm run dev` is running
- [ ] Browser tabs: repo, Issues, PR #17, `localhost:5137`, `localhost:3000/api-docs`
- [ ] VS Code: close all editors, open a fresh chat

### Where your repo differs from the guide

| Guide assumes | Your repo | What to do |
|---|---|---|
| No `.github/skills/` folder | `frontend-design` skill already exists (from anthropics/skills) | Use it as the "real-world skill" example in §5A |
| `OctoCATEngineer.agent.md` exists | Not there | Create it tonight, or skip §6A |
| Frontend lives in `src/` | Lives in `frontend/src/` | Use `frontend/**` in `applyTo` (already fixed below) |
| `api/middleware/auth.ts` | Doesn't exist | Context demos below use `api/src/routes/product.ts` |
| `model: Claude Sonnet 4` in agent files | May not be in your model picker | Change or delete the `model:` line |
| Create a "test coverage" issue in §7 | Issue #12 already covers that | §7D creates the validation issue that §8 hands to the cloud agent |

## 1 · Welcome + app tour · 5 min · ⏱ 0:00

**Say**

- Goal: go from Copilot as autocomplete to Copilot that knows your team's rules: instructions, skills, agents, external tools, and cloud agents.
- Demo app: OctoCAT Supply. React 18 + Vite + Tailwind frontend, Express + TypeScript API with Swagger.
- Everything we build today is a plain file in `.github/`: reviewable, version-controlled, shared through git.

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
| Agent skills | `.github/skills/<name>/SKILL.md` | When the task matches the skill's description |
| Custom agents | `.github/agents/*.agent.md` | When you pick it from the agents dropdown |
| MCP servers | `.vscode/mcp.json` | When Copilot needs one of the server's tools |

## 2 · Ask / Agent / Plan · 12 min · ⏱ 0:05

**Say**

- Start every new chat by picking the **Session Target** before the first prompt. Today that's **Local**, the built-in VS Code harness. "Local" doesn't mean the model runs on your machine.
- Local has three roles: **Ask** explains and doesn't edit. **Agent** edits files, runs commands, and iterates. **Plan** writes a plan for you to review before anything changes.
- The model picker is a separate control. Choosing a Claude model is not the same as choosing the Claude target.

| Need | Pick |
|---|---|
| "I need to understand something" | Local + Ask |
| "I need to build, fix, or test something" | Local + Agent |
| "I need to plan before changing code" | Local + Plan (or `/plan`) |

**Do**

**A. Ask.** New chat (+) → Target **Local** → role **Ask**:

```prompt
What testing framework does this project use and what's the current test coverage?
```

✅ **Look for:** Vitest, very little coverage (one test file, `branch.test.ts`), and no files changed.

**B. Plan.** Switch the role to **Plan** (or type `/plan`):

```prompt
How should I add comprehensive error handling to the API routes?
```

✅ **Look for:** a structured, step-by-step plan. **Don't approve the implementation.**

**C. Agent.** Switch the role to **Agent**:

```prompt
Open the Swagger documentation page for the API
```

✅ **Look for:** tool calls and approval prompts. "You stay in control of every action." If the app isn't running, first send `Build and run the project`.

**D. Give it context (30 sec).** Don't make Copilot guess which file you mean. Type `#` in chat to attach `#file`, `#selection`, or `#codebase`:

```prompt
Explain what #file:api/src/routes/product.ts does and list all the endpoints it defines
```

> 💬 "Ask to understand, Plan to think it through, Agent to do it. Pick the role before you type."

<details>
<summary>🛟 If it breaks</summary>

- **Ask / Agent / Plan missing:** start a new chat and select Local *before* the first prompt. Update VS Code and the Copilot extensions if it's still missing.
- **Target picker missing:** another target owns this session. Start a new chat and pick Local.
- **Agent starts a second dev server and hits a port conflict:** keep the server that's already running; check ports 3000 and 5137.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

Run prompts A, B, and C above in their own fork. Remind them not to approve the plan in B.

</details>

## 3 · Custom instructions · 15 min · ⏱ 0:17

**Say**

- `.github/copilot-instructions.md` is added to every Copilot request in this repo. It's always-on background context.
- **Good content:** coding standards, architecture patterns, internal frameworks, security rules, testing conventions. **Bad content:** whole API docs, tutorials, long prose. Keep it short, because it uses context on every request.
- Instructions guide behavior; they don't enforce anything. Enforcement still comes from tests, CI, and secret scanning.

**Do**

**A. Baseline.** New chat → Local + **Ask**. Ask this and remember the answer (you'll compare in §4):

```prompt
How should I add a new API endpoint to this project?
```

Note whether it mentions Swagger, the existing route pattern, or the entity model structure.

**B. Generate the instructions.** In the Chat view, click the gear icon ⚙️ → **Generate Agent Instructions**. Let it analyze the repo, then review the result: project name and stack, architecture (React + Express), build (`npm install && npm run build`), tests (Vitest). Save it as `.github/copilot-instructions.md`.

> 💬 "Copilot just read the whole repo and wrote its own instruction manual. That file now goes along with every request."

**C. TAO: teach Copilot a framework it has never seen.** Open `docs/tao.md` for a moment: "a fictional internal observability framework." Then add this to the end of `.github/copilot-instructions.md`:

```markdown file=.github/copilot-instructions.md (append)
## Observability Requirements
- Implement logging and monitoring using TAO (TypeScript API Observability)
- Reference: docs/tao.md
- Assume TAO is installed — never add the package
- Use @Measure, @Trace, and @Log decorators for all service methods
- Configure initTAO() in the application entry point
```

Switch to **Agent**:

```prompt
Add observability to the Supplier route using our internal standards
```

✅ **Look for:** `import { Measure, Trace } from '@tao/core'` and `@Measure` / `@Trace` / `@Log` decorators.

> 💬 "TAO doesn't exist anywhere on the internet; Copilot has never seen it. We described it in our instructions, so it generates code that uses it. Imagine this for your company's internal libraries."

Say that the code won't compile, on purpose: TAO is fictional. The point is that instructions override training data.

**D. Clean up (required before §4).** Stay in Agent:

```prompt
Revert the TAO observability changes you just made to the Supplier route, and remove the "Observability Requirements" section from .github/copilot-instructions.md. The TAO framework is fictional and the code won't compile.
```

✅ **Verify:** TAO imports and decorators are gone, the section is gone from the instructions file, and `npm run build` passes.

**Faster fallback:** run `git restore api/` and delete the Observability section by hand.

<details>
<summary>🛟 If it breaks</summary>

- **No "Generate Agent Instructions" in the gear menu:** try Command Palette → **Chat: Open Customizations**. Or, in Agent, send:

```prompt
Analyze this repository and create a comprehensive copilot-instructions.md file that describes our tech stack, architecture, coding standards, and build process.
```

- **Instructions seem ignored:** the file must be exactly `.github/copilot-instructions.md`. Expand **References** in the response to see whether it was used.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

Ask the baseline question in Ask, generate their own instructions with the gear icon, then ask the question again.

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

**B.** Open `api/src/routes/product.ts`. New chat → Local + **Ask** → ask the §3 baseline question again:

```prompt
How should I add a new API endpoint to this project?
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

- A skill is a folder containing `SKILL.md`, plus optional scripts or templates. Copilot reads each skill's `description` and loads the skill only when your task matches it.
- **Instructions** are always-true rules. **Skills** are "when doing X, follow these steps." **Agents** (next section) are a persona you pick.
- Skills are an open standard (VS Code, Copilot CLI, Copilot cloud agent, other agents). Project skills go in `.github/skills/`, personal ones in `~/.copilot/skills/`.

| | Custom instructions | Agent skills |
|---|---|---|
| Location | `.github/copilot-instructions.md` | `.github/skills/*/SKILL.md` |
| When loaded | Always, every request | Only when relevant to the task |
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

**C. Watch it load on its own.** New chat → Local + **Agent**:

```prompt
Review the product route handler for security and performance issues
```

✅ **Look for:** the answer follows the checklist sections (Security, Input Validation, Error Handling, Performance, Maintainability), and **References** lists `SKILL.md`.

Now the contrast. Ask something unrelated:

```prompt
What entities does this API manage?
```

✅ **Look for:** the skill is *not* loaded.

> 💬 "You didn't invoke the skill. Copilot matched your prompt to its description and loaded it. Instructions are always on; skills show up when they're relevant."

**D. Where to find more (30 sec):** [github/awesome-copilot](https://github.com/github/awesome-copilot), [anthropics/skills](https://github.com/anthropics/skills), [skills.sh](https://skills.sh).

<details>
<summary>🛟 If it breaks</summary>

- **Skill doesn't load:** check that the file is named exactly `SKILL.md` (case-sensitive), that the folder name matches `name`, and that your prompt uses words from the `description`.
- **Can't tell whether it loaded:** loading happens in the background, so check References. As a fallback, compare the answer to the same prompt asked before the skill existed.

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

Then, in Local + Agent:

```prompt
I need to add a new "Warehouse" entity and API endpoints for managing warehouses. Each warehouse has a name, address, city, state, zipCode, and capacity.
```

</details>

## Break · 5 min · ⏱ 0:55

**Optional, recommended:** start a cloud agent now so there's a finished PR to review in §8. In the browser, open **issue #12** ("Enhance test coverage in the API project") → **Assignees** → **Copilot**. It takes 5–30 minutes. This uses AI credits and Actions minutes.

## 6 · Custom agents · 12 min · ⏱ 1:00

**Say**

- `.github/agents/*.agent.md` defines a persona you pick from the agents dropdown. It stays active for the whole chat.
- Frontmatter: `description` (shown in the dropdown), `tools` (what it may use), `model` (optional).
- The tools list is the big lever: the same file format with different tools gives completely different behavior.
- Skill vs agent: a skill is a procedure Copilot loads when relevant. An agent is a role you choose, with its own tool limits.

**Do**

**A. The builder, OctoCATEngineer (optional, 3 min).** Open `.github/agents/OctoCATEngineer.agent.md` (created tonight). Point out the tools (read, edit, terminal) and that there's no `model`, so it uses your picker. Select it in the agents dropdown:

```prompt
Add a GET /api/products/search endpoint that accepts a "name" query parameter and returns matching products
```

Show it reading `product.ts` for the pattern before it edits. Stop it after a minute if you need the time. **Reset:** `git restore api/`, then `git clean -n api/` to preview and `git clean -f api/` to remove new files.

**B. A read-only reviewer, CodeReviewer (6 min).** Create:

```markdown file=.github/agents/CodeReviewer.agent.md
---
tools: ['codebase', 'search', 'usages', 'problems']
description: Review code for security, performance, and best practices
model: Claude Sonnet 4
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

It appears in the agents dropdown right away. Point out: read-only tools (no `editFiles`, no `runCommands`), its own model, and a reviewer persona. Select **CodeReviewer**:

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

**C. The advanced pattern, ImplementationIdeas (3 min, explain only).** Open `.github/agents/ImplementationIdeas.agent.md` and point out:

- `github/*` and `playwright/*`: wildcards for every tool on those MCP servers (§7)
- `model: Claude Sonnet 4.5`: the agent picks its own model
- "call GitHub's `create_pull_request_with_copilot`": it hands implementation to the cloud agent (§8). Agents calling agents.

⚠️ **Don't run it live** unless you mean to. It starts one cloud-agent session per idea it comes up with, and each uses AI credits and Actions minutes.

> 💬 "Simple builder → read-only reviewer → a strategist that delegates to the cloud."

<details>
<summary>🛟 If it breaks</summary>

- **Agent isn't in the dropdown:** Command Palette → **Reload Window**.
- **Tool IDs flagged as invalid:** delete those entries and re-add tools with the **Add Tools** / **Configure Tools** picker. IDs differ between versions (`codebase` vs `search/codebase`).
- **Model not found:** delete the `model:` line.

</details>

<details>
<summary>📄 Builder agent file (create tonight, for §6A)</summary>

Frontend paths are corrected to match your repo. If VS Code flags `azure-mcp/search` as unknown, delete it.

```markdown file=.github/agents/OctoCATEngineer.agent.md
---
tools: ['search/codebase', 'azure-mcp/search', 'edit/editFiles', 'execute/getTerminalOutput', 'execute/runInTerminal', 'read/terminalLastCommand', 'read/terminalSelection', 'read/problems']
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

- MCP (Model Context Protocol) plugs external tools into Copilot. The config is part of the repo (`.vscode/mcp.json`), so the whole team gets it.
- There are two kinds of server. **HTTP** servers are remote and sign in with OAuth (GitHub). **stdio** servers run as a local process (Playwright).
- A server starts the first time Copilot needs one of its tools, and you approve each tool call.

```json file=.vscode/mcp.json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**Do**

**A. Check the servers (1 min).** Open `.vscode/mcp.json`, then Command Palette → **MCP: List Servers**. "Not started" is normal until the first use.

**Approval tip:** the first tool call shows an **Allow ▾** button. Open the dropdown and choose **Allow Tools from Playwright Without Review in this Session**, and later the same for GitHub. That saves clicking Allow 20 times, and it resets when VS Code restarts.

**B. Playwright drives a browser (5 min).** Local + **Agent**:

```prompt
Browse to http://localhost:5137 and navigate to the Products page. Describe what you see.
```

✅ **Look for:** a real browser window opens, and Copilot describes the product grid, images, prices, and Add to Cart buttons.

```prompt
Click on one of the products and check if the product details are displayed correctly
```

> 💬 "You just ran a functional test in plain English. No test scripts, no selectors, no framework setup."

**C. BDD scenarios (optional, 3 min).** New chat (+):

```prompt
Run the following BDD test scenarios against http://localhost:5137 using Playwright:
1. Given I navigate to the Products page, Then I should see a list of products with names, images, and prices
2. When I click on a product, Then I should see the product details
3. When I click "Add to Cart" on a product, Then I should see a confirmation
Report pass/fail for each scenario.
```

**D. GitHub from chat (5 min).**

```prompt
Check which issues are assigned to me in this repo
```

Then create the issue you'll hand to the cloud agent in §8:

```prompt
Create a GitHub Issue titled "Add input validation to the Product API POST endpoint". Description: The POST /api/products endpoint accepts any payload without validation. Add Zod schema validation for required fields (name, price, supplierId). Return 400 with validation errors for invalid payloads. Include unit tests for the validation. Assign it to me.
```

✅ **Look for:** the issue on the repo's Issues tab in the browser, with a title, description, and assignee. **Write down the issue number.**

> 💬 "You just managed your GitHub project without leaving VS Code. Next, we hand this issue to an autonomous agent."

<details>
<summary>🛟 If it breaks</summary>

- **Server won't start:** check its status in **MCP: List Servers**. Confirm `chat.mcp.discovery.enabled` is on and Node.js is installed.
- **Playwright fails:** it must be local VS Code, not Codespaces. Check that the app is on `:5137`. Fallback: screenshots, then move on to GitHub MCP.
- **GitHub auth error:** send another GitHub prompt to trigger the OAuth flow again. Fallback: create the issue in the browser.

</details>

<details>
<summary>🧪 Audience try-it (optional)</summary>

```prompt
Browse to http://localhost:5137, go to Products, and verify that:
1. All products have images displayed
2. All products show a price
3. The "Add to Cart" button is visible on each product
Report any issues you find.
```

</details>

## 8 · Cloud agent + Copilot code review · 12 min · ⏱ 1:27

**Say**

- Cloud agents run on GitHub, not in your editor. They're asynchronous: assign the work and go do something else.
- The loop: **Issue → Copilot cloud agent** (branch, code, tests) **→ PR → Copilot code review + human review → merge.**
- It follows the repo's instructions and skills, but only what's pushed to GitHub. The files we made today exist only on this laptop unless we commit and push them.

**Do**

**A. Assign the issue (5 min).** In the browser, open the issue from §7D → **Assignees** → **Copilot**. Show the session starting (the agents panel, or a new `[WIP]` PR). Explain the steps: it creates a branch, reads the code and the instructions/skills, implements the change, runs tests, and opens a PR. This takes 5–30 minutes. ⚠️ It uses AI credits and Actions minutes.

Remind them of ImplementationIdeas from §6C: "IDE agents can hand work to this same cloud agent."

> 💬 "You just delegated a coding task to an autonomous agent, and it will follow your team's standards."

**B. Copilot code review (7 min).** Open a PR: the cloud-agent PR if you started one at the break, otherwise **PR #17**. **Reviewers** → **Copilot**. It takes 1–3 minutes, so talk through the loop while you wait. Then show:

- Inline comments with suggested changes
- **Apply suggestion** creates a commit (only do this on a throwaway PR)
- Resolving or dismissing a comment

> 💬 "Copilot catches pattern-based issues fast. It doesn't question business decisions; that's still your job. The best setup is Copilot plus human review."

| | VS Code Local session | Copilot cloud agent |
|---|---|---|
| Runs | In your editor | On GitHub |
| Style | Interactive; you steer | Async and autonomous |
| Output | File changes in your workspace | A pull request |
| Best for | Exploring and iterating | Well-defined tasks you can hand off |

**Ask the room:** What would you keep local, and what would you delegate? What guardrails would you require (branch protection, required human review)?

<details>
<summary>🛟 If it breaks</summary>

- **Cloud agent doesn't start:** check that Actions are enabled and Copilot cloud agent is enabled in repo settings.
- **Review is slow:** show the review you requested on PR #17 last night.

</details>

## 9 · Wrap-up · 3 min · ⏱ 1:39

**Which tool for which job**

| If the thought is… | Use |
|---|---|
| "This is always true in our repo" | Custom instructions |
| "This is true for these folders" | Scoped instructions |
| "When doing X, follow these steps" | Agent skill |
| "Act as this role, with only these tools" | Custom agent |
| "Copilot needs to reach an outside system" | MCP server |
| "Well-defined task; I don't need to watch" | Cloud agent + code review |

**Takeaways:** instructions capture tribal knowledge (TAO). Skills load themselves when relevant. Agents are personas with guardrails. MCP extends Copilot's reach. Cloud agents close the loop from issue to PR to review.

**Homework for attendees:** commit your `.github/` files. List 3–5 internal frameworks or patterns to turn into instructions. Build one skill for your team's most specialized workflow. Turn on Copilot code review.

**Likely questions**

- *Do skills and instructions conflict?* Both can load at once. Instructions are always included; skills come in when relevant.
- *Does the cloud agent respect branch protection?* Yes. It opens a PR, and your review rules still apply.
- *Do these files work outside VS Code?* The cloud agent reads the repo's instructions and skills; the Copilot CLI shares them too.
- *Can we restrict MCP servers?* Org and enterprise Copilot policies control MCP access. Point them to the docs.

## Reset (after rehearsal, and after the session)

**GitHub:** close the issue you created in §7D, cancel any cloud-agent session that's still running, and close test PRs without merging:

```bash
gh issue close <ISSUE_NUMBER> --comment "Closing workshop demo artifact."
gh pr close <PR_NUMBER> --delete-branch
```

**Local:** stop `npm run dev` (Ctrl+C), then:

```bash
git status --short
git restore .
git clean -fd -n -- .github api
```

Read the dry-run list first, then remove only the workshop files:

```bash
git clean -f -- .github/copilot-instructions.md .github/agents/CodeReviewer.agent.md
git clean -fd -- .github/instructions .github/skills/code-review-checklist .github/skills/api-route-creation
```

Never run a plain `git clean -fd`. Keep `OctoCATEngineer.agent.md` if you committed it.

## Cut from this session (if someone asks)

| Topic | One-liner if asked |
|---|---|
| Inline completions + inline chat (`Cmd+I`) | Ghost text as you type; `Cmd+I` for a quick, focused edit in the current file |
| Claude / Codex / Copilot targets, `CLAUDE.md` | Other harnesses in the same picker, each with its own config format |
| `@` participants and slash commands | `@workspace`, `@terminal`; `/explain`, `/fix`, `/tests` |
| Copilot Memory | Personal preferences that Copilot recalls; never store secrets there |
| Prompt files (`.github/prompts/*.prompt.md`) | Reusable task templates you run on demand (the repo has three) |
| GitHub Copilot CLI | The same agent in your terminal; `/delegate` hands work to the cloud |

## Quick reference

| Type | Path | Loads |
|---|---|---|
| Project instructions | `.github/copilot-instructions.md` | Always |
| Scoped instructions | `.github/instructions/*.instructions.md` | When `applyTo` matches |
| Project skills | `.github/skills/<name>/SKILL.md` | When relevant |
| Personal skills | `~/.copilot/skills/<name>/SKILL.md` | When relevant |
| Custom agents | `.github/agents/*.agent.md` | When picked in the dropdown |
| MCP config | `.vscode/mcp.json` | When a tool is needed |

**Shortcuts (Mac):** Command Palette `Cmd+Shift+P` · Inline chat `Cmd+I` · New chat: the **+** in the Chat view
