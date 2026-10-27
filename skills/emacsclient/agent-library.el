;;; agent-library.el --- shared agent-side elisp for emacsclient-driven control -*- lexical-binding: t; -*-

;; Part of the emacs-skills fork (github.com/marcintustin/emacs-skills).
;; The user's init (~/.emacs.d/emacs.el) loads this file so these functions
;; are always available in the running Emacs server. Agents: when an eval
;; pattern recurs, move it here with a docstring instead of inlining it.

;; Declared in skills/highlight/agent-skill-highlight.el; declared here too
;; so references compile clean when that file has not been loaded.
(defvar agent-skill-highlight--overlays nil)
(defvar agent-skill-highlight-mode nil)

;;; lsp interactive project-import suppression

;; `lsp' on a file outside any lsp session folder calls
;; `lsp--find-root-interactively', which PROMPTS
;; ("FILE is not part of any project. ... Import project root ...") and
;; wedges the whole server until answered (see SKILL.md, Prompt blocking).
;; When suppressed, lsp logs "not in project or it is blocklisted" and
;; skips starting in the buffer, harmlessly.
(declare-function lsp--find-root-interactively "lsp-mode" (session))

(defvar agent--suppress-lsp-project-import nil
  "Skip lsp's interactive project import when non-nil.
The buffer-local value covers `lsp-deferred', whose idle timer runs
after `agent-open-file' returns; the dynamic binding covers lsp
started synchronously from mode hooks during the open.")

(put 'agent--suppress-lsp-project-import 'safe-local-variable 'booleanp)
(put 'agent--suppress-lsp-project-import 'permanent-local t)

(defun agent--lsp-no-project-import (orig &rest args)
  "Advice for `lsp--find-root-interactively': return nil under suppression."
  (if (bound-and-true-p agent--suppress-lsp-project-import)
      nil
    (apply orig args)))

(when (fboundp 'lsp--find-root-interactively)
  (advice-add 'lsp--find-root-interactively
              :around #'agent--lsp-no-project-import))

;;; Functions

(defun agent-open-file (file &optional line)
  "Open FILE in the user's session without raising prompts; return buffer name.
With LINE (1-indexed), move point to that line in the buffer.

Prompt suppression: file-local and directory-local variables are
disabled, stale unmodified buffers are reverted no-confirm (the usual
changed-on-disk prompt path), an existing *modified* buffer is
returned as-is (check `buffer-modified-p' first if that matters), and
lsp's interactive project-import prompt is skipped (see
`agent--suppress-lsp-project-import'); lsp simply does not start in
the buffer when it is outside any lsp session folder.

Call this before `agent-skill-highlight' (whose `find-file' would
otherwise prompt for non-project files)."
  (let ((enable-local-variables nil)
        (enable-local-eval nil)
        (enable-dir-local-variables nil)
        (agent--suppress-lsp-project-import t))
    (let ((oldbuf (get-file-buffer file)))
      (when (and (buffer-live-p oldbuf) (not (buffer-modified-p oldbuf)))
        (with-current-buffer oldbuf (revert-buffer t t))))
    (let ((buf (find-file-noselect file)))
      ;; Persist suppression past this dynamic let, for lsp-deferred's timer.
      (with-current-buffer buf
        (setq-local agent--suppress-lsp-project-import t))
      (with-current-buffer buf
        (when line
          (goto-char (point-min))
          (forward-line (1- line)))
        (display-buffer buf))
      (buffer-name buf))))

(defun agent-highlight-state (file)
  "Return (:buffer NAME :overlays N :mode BOOL) for FILE's agent-skill-highlight state.
:overlays is 0 when skills/highlight/agent-skill-highlight.el has not been
loaded (its variables are buffer-local and only it defines them)."
  (let ((buf (get-file-buffer file)))
    (if (buffer-live-p buf)
        (with-current-buffer buf
          (list :buffer (buffer-name buf)
                :overlays (if (boundp 'agent-skill-highlight--overlays)
                              (length agent-skill-highlight--overlays)
                            0)
                :mode (bound-and-true-p agent-skill-highlight-mode)))
      (list :buffer nil :overlays 0 :mode nil))))

(defun agent-clear-highlights (file)
  "Exit agent-skill-highlight-mode and remove its overlays in FILE's buffer.
No-op if the buffer or skills/highlight/agent-skill-highlight.el is missing."
  (let ((buf (get-file-buffer file)))
    (when (and (buffer-live-p buf) (fboundp 'agent-skill-highlight-mode))
      (with-current-buffer buf
        (when (bound-and-true-p agent-skill-highlight-mode)
          (agent-skill-highlight-mode -1))))))

(provide 'agent-library)
;;; agent-library.el ends here