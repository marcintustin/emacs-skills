---
name: monthly-impact-assessment
description: "Monthly personal impact assessment for Marcin Tustin: collect the preceding month's engineering evidence (git archaeology, GitLab MRs/releases, Datadog production telemetry) and update the impact journal plus resume master source. Use when the user asks for a monthly impact assessment, impact review, brag document update, or career evidence refresh."
tools: Bash, Read, Write, Edit, Glob, Grep
---

# Monthly impact assessment

Monthly evidence-collection procedure (git + GitLab + Datadog → evidence-tagged journal
entry → master-source refresh). Cadence: first week of the month, assessing the previous
calendar month.

> **Privacy boundary — read this first.** This skill is the *procedure only*. Every
> employer-internal specific — repo names, GitLab project IDs, Datadog service names,
> the query cookbook, customer names — lives in LOCAL-ONLY files under `~/dev/resume/`
> and must never be committed to this (public) repo:
> the Datadog cookbook at `~/dev/resume/impact/datadog-queries.md` and the collection
> script at `~/dev/resume/impact/collect-git.sh`. If a new artifact needs internal
> specifics, it goes under `~/dev/resume/`, not here.

## Fixed paths

| What | Where |
|---|---|
| Impact journal (append monthly entries) | `~/dev/resume/impact-journal.md` |
| Master source (resume feedstock; update metric bank + caveats) | `~/dev/resume/marcin-tustin-master-source.md` |
| Deep-evidence dossier (full ledgers; update rarely) | `~/dev/resume/marcin-tustin-career-evidence.md` |
| Raw git evidence per month | `~/dev/resume/impact/<YYYY-MM>-git.md` |
| Datadog query cookbook (service map, query set, pitfalls; LOCAL ONLY) | `~/dev/resume/impact/datadog-queries.md` |
| Git collection script (canonical repo list embedded; LOCAL ONLY) | `~/dev/resume/impact/collect-git.sh` |

## Procedure

1. **Window.** Previous calendar month (or since the last journal entry). Read the
   journal's latest entry for the comparison baseline; if none exists, treat the run
   as a bootstrap and say so.
2. **Git archaeology.** Run
   `bash ~/dev/resume/impact/collect-git.sh <YYYY-MM-01> <next-month-01> -o ~/dev/resume/impact/<YYYY-MM>-git.md`
   (add `--fetch` if remote refs should be included). It counts author commits/merges
   per repo and extracts MR titles from merge bodies. Read its output.
3. **GitLab.** Via the MCP gitlab tools on the tracked projects (IDs and watch-list
   live in the local cookbook, not here): `list_releases` for tags cut in-window;
   `list_merge_requests` (state=merged) to cross-check mainline state beyond your own
   merges. Note MRs still open (in-flight).
4. **Datadog.** Follow `~/dev/resume/impact/datadog-queries.md` exactly — service map,
   the monthly query set, and the syntax pitfalls. Compare every number against the
   prior journal entry and record direction + magnitude.
5. **Corroboration.** No Slack access: ask the user for their slackbot pass output or
   notable threads; mark those claims [S]. Anything only the user knows → [Needs input].
6. **Journal entry.** Write a new top entry in `~/dev/resume/impact-journal.md` using
   this skill's `templates/month-entry.md`: headline, shipped table (dates + MR refs),
   metrics delta table with arrows, achievements-with-receipts, cautions checklist, new
   caveats, open questions.
7. **Master source.** Update `marcin-tustin-master-source.md`: metric-bank numbers that
   materially moved, [Needs input] items now answered, and §11 cautions whose status
   changed. Do not rewrite history sections.
8. **Verify.** Every number in the entry must trace to the raw evidence files or a query
   output recorded this run. Re-read the entry against the cautions checklist before
   finishing. Open the journal and master source for the user via the emacsclient
   skill's `agent-open-file` (prompt-free), never bare find-file.

## Non-negotiable rules

- **Never fabricate or estimate a number.** If a query fails or a repo is stale, say
  so in the entry and mark the cell `[missing: reason]`.
- **Inherit the master source's §11 cautions verbatim** — status wording (beta vs GA),
  attribution limits (timing-correlated; joint work credited as built/founding-engineer,
  not sole author), title conventions, and mandatory sanitization of customer names,
  internal repo names, and ticket IDs for external use. The canonical caution list
  lives in the local master source; this file deliberately does not repeat its specifics.
- **Keep raw evidence local** in `~/dev/resume/impact/` — the journal cites, it does not hoard.
- **Nothing employer-internal enters this repo** (or any pushed repo). Procedure and
  shape only; specifics stay in the local files listed above.
- **Attribution:** production changes are "timing-correlated with my MRs" unless
  proven; state which numbers are MR-internal vs telemetry-verified.
- **Worktrees:** some repo directories are linked worktrees of a single project — the
  collection script's canonical list already accounts for this; adding sibling
  worktrees double-counts every commit.
- Monthly entries are append-mostly: correct a prior entry only by adding a dated
  correction note, never silently editing old numbers.
