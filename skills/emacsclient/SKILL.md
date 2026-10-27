---
name: emacsclient
description: 'Always use emacsclient instead of emacs. This applies to all Emacs operations: user requests, byte compilation, check-parens, running ERT tests, and any other elisp evaluation.'
tools: Bash
---

# Always use emacsclient

The user has an Emacs server running. **All** Emacs operations must go through `emacsclient`, never `emacs` or `emacs --batch`. This includes both user-requested actions and agent-initiated operations like byte compilation, syntax checking, or running tests.

## Examples

- Open a file: `emacsclient --no-wait "/path/to/file"`
- Evaluate elisp: `emacsclient --eval '(some-function)'`
- Open at a line: `emacsclient --no-wait +42 "/path/to/file"`
- Byte compile a file:
  ```sh
  emacsclient --eval '
  (byte-compile-file "/path/to/file.el")'
  ```
- Check parentheses:
  ```sh
  emacsclient --eval '
  (with-temp-buffer
    (insert-file-contents "/path/to/file.el")
    (check-parens))'
  ```
- Run ERT tests:
  ```sh
  emacsclient --eval '
  (progn
    (load "/path/to/test-file.el" nil t)
    (ert-run-tests-batch-and-exit "pattern"))'
  ```

## Output

- Each `--eval` flag evaluates exactly one form and prints that form's return
  value to stdout. Pass one `--eval` per form to evaluate multiple forms; extra
  forms trailing one string are ignored.
- Return values, don't `message`: `message` output goes to the user's
  `*Messages*` buffer, not back to the agent (only the returned value does).
- On error, `emacsclient` prints `*ERROR*: ...` and exits non-zero.

## Discovery

The user's running Emacs (loaded packages, bindings, state) is fair game to
introspect via `--eval` — probe it instead of asking:

- `(featurep 'magit)` — is a package loaded?
- `(documentation 'magit-status)` — a function's docstring.
- `(all-completions "magit-" obarray #'fboundp)` — enumerate bound functions.
- `(info "(elisp)Top")`, `apropos`, `describe-function` — manuals and search.

## Frames

- `--no-wait` reuses the user's existing frames. Never create frames
  (`-c`, `-t`) unless the user asks.

## Prompt blocking

`find-file` and other interactive operations can raise minibuffer prompts
(changed-on-disk, file locks, dangerous-local-variables, lsp's interactive
project import — use `agent-open-file' to suppress that one, see Library, ...).
While a prompt is up, the server stops servicing evals and `emacsclient`
appears to hang — a single unanswered prompt **wedges the whole Emacs session**
for the agent. The user must answer it before anything else proceeds.

- If an eval times out, ask the user whether Emacs is showing a prompt before
  diagnosing the server or retrying.
- A client-side timeout does not stop the server-side eval; after the user
  answers the prompt the eval may still complete. Check for its side effects
  server-side (e.g. overlays created, modes toggled) before re-running it,
  and say what you did if it was re-applied.

## Library

`agent-library.el` in this skill's directory is a growing shared library of
agent-side elisp (prompt-free opens, highlight-state verification, ...).
The user's init (`~/.emacs.d/emacs.el`) loads it, so its functions are always
available in the running server.

- When an eval pattern recurs, move it into the library with a docstring
  instead of inlining it again.
- This repo is the fork (`github.com/marcintustin/emacs-skills`, checked out
  at `~/dev/repos/emacs-skills`). Make changes here, commit, and push; then
  fast-forward the plugin cache copy from this fork. Never hand-edit the
  cache copy (its origin is upstream `xenodium/emacs-skills` and updates
  clobber local edits).
- Outside a session started by the user's init, load it with
  `(load "~/dev/repos/emacs-skills/skills/emacsclient/agent-library.el" nil t)`.

## Rules

- Always use `emacsclient`, never `emacs` or `emacs --batch`.
- Use `--no-wait` when opening files so the command returns immediately.
- Use `--eval` when evaluating elisp.
- Always format `--eval` elisp across multiple lines with proper indentation.
- Run `emacsclient` commands via the Bash tool.
- Return values instead of `message` when the agent needs to read output back.
- Introspect the running Emacs via `--eval` (see Discovery) instead of asking
  the user what is available.
- After a user answers an Emacs prompt that blocked an eval, verify the
  server-side state (the eval may have completed after the client gave up).
- Add reusable eval patterns to `agent-library.el` (see Library) instead of
  inlining them.
