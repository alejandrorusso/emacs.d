;; major modes

;; load raw text in a basic mode (for performance reasons)
(add-to-list 'auto-mode-alist '("\\.log$" . fundamental-mode))

;; don't let them steal you keys
(defun unbreak-stupid-map (stupid-map)
  (define-key stupid-map (kbd "C-c") nil))

;; Flycheck for code linting
(setup "flycheck"
  (add-hook 'after-init-hook #'global-flycheck-mode))
(setup-lazy '(flycheck-color-mode-line) "flycheck"
  (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; C coding style
(setq c-default-style "linux"
      c-basic-offset tab-width)
(global-set-key (kbd "M-RET") 'c-indent-new-comment-line)

(setup-after "auto-complete-config"
  (add-hook 'c-mode-hook
            (lambda ()
              (add-to-list 'ac-sources 'ac-source-c-headers)
              (add-to-list 'ac-sources 'ac-source-c-header-symbols t)))
  (defun ac-cc-mode-setup ()
    (setq ac-clang-complete-executable "~/.emacs.d/el-get/emacs-clang-complete-async/clang-complete")
    (setq ac-sources '(ac-source-clang-async))
    (ac-clang-launch-completion-process)
    )
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup))

;; load ESS for R
;; (setq load-path (cons "/usr/share/emacs/site-lisp/ess" load-path))
(setup "ess-site"
  (setq inferior-julia-program-name "~/dev/julia/julia/usr/bin/julia-basic")
  (add-to-list 'auto-mode-alist '("\\.jl$" . julia-mode)))

;; auctex
(setup "auctex"
  (add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
  (setq-default TeX-engine 'xetex)      ; use xelatex by default
  (setq TeX-view-program-selection '((output-pdf "zathura")))
  (add-to-list 'ac-modes 'LaTeX-mode))   ; make auto-complete aware of `latex-mode`

(setup-lazy '(org-mode markdown-mode latex-mode) "ac-math"
  (defun ac-latex-mode-setup ()         ; add ac-sources to default ac-sources
    (setq ac-sources
          (append '(ac-source-math-unicode ac-source-math-latex ac-source-latex-commands)
                  ac-sources))
    ))

;; markdown
(setup "markdown-mode"
  (setq markdown-command "pandoc --smart -f markdown -t html")
  (add-to-list 'auto-mode-alist '("\\.pdc$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.mkd$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\bREADME$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.page$" . markdown-mode))
  ;; add pandoc hook
  (add-hook 'markdown-mode-hook 'turn-on-pandoc)
  (add-hook 'markdown-mode-hook
            (lambda()
              (add-to-list 'ac-sources 'ac-source-math-latex))))

;; yaml
(setup "yaml-mode"
  (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

;; org-mode
(setq load-path (cons "~/.emacs.d/site-lisp/org-mode/lisp" load-path))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; loaded so that we can diminish it later
(setup "org-indent"
  ;; proper indentation / folding
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-indent-indentation-per-level 2)
  (setq org-startup-folded 'content)
  (setq org-blank-before-new-entry '((heading . nil)
                                     (plain-list-item . auto))))
;; tag column
(setq org-tags-column -70)
;; dependencies
(setq org-enforce-todo-dependencies t)
;; make clock history persistent
(setq org-clock-persist 'history)

;; notes file
(setq org-default-notes-file "~/Documents/spoiler/notes.org")
(define-key global-map "\C-cC" 'org-capture)
(setq org-capture-templates
      '(("l" "Link" plain (file "~/Documents/spoiler/links.org")
         "- %?\n %x\n")
        ("n" "note" entry (file "~/Documents/spoiler/notes.org")
         "* %? %^g\n%U\n%a\n")
        ("q" "quote" entry (file "~/Documents/spoiler/quotes.org")
         "* %? \n%x\n%a\n")))
;; Todo states
(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "WAITING(w)" "DONE(d)")))
;; priorities
(setq org-default-priority 67) ;C
;; spoiler files
(defadvice org-todo-list (before org-todo-list-reload activate compile)
  "Scan for org files whenever todo list is loaded."
                                        ; 'find' is faster and has better control than lisp
  (setq org-agenda-files (mapcar 'abbreviate-file-name (split-string
                                                        (shell-command-to-string "find ~/Documents/spoiler -type f -name \"*.org\" | sort")
                                                        "\n"))))
;; code block
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (C          . t)
   (R          . t)
   (matlab     . t)
   (sh         . t)
   (ruby       . t)
   (python     . t)
   (haskell    . t)))
(add-to-list 'org-src-lang-modes '("c" . c))
(add-to-list 'org-src-lang-modes '("r" . ess-mode))
(add-to-list 'org-src-lang-modes '("h" . haskell))
(add-to-list 'org-src-lang-modes '("s" . sh))
(add-to-list 'org-src-lang-modes '("p" . python))
(add-to-list 'org-src-lang-modes '("ruby" . enh-ruby))
(setq org-src-fontify-natively t)
(setq org-confirm-babel-evaluate nil)

(org-defkey org-mode-map "\C-c\C-t" (lambda () (interactive) (org-todo "TODO")))
(org-defkey org-mode-map "\C-c\C-w" (lambda () (interactive) (org-todo "WAITING")))
(org-defkey org-mode-map "\C-c\C-d" (lambda () (interactive) (org-todo "DONE")))
;; shortcut for C-u C-c C-l
(defun org-insert-file-link () (interactive) (org-insert-link '(4)))
(org-defkey org-mode-map "\C-cl" 'org-store-link)

;; some templates
(setcdr (assoc "c" org-structure-template-alist)
        '("#+BEGIN_COMMENT\n?\n#+END_COMMENT"))
(add-to-list 'org-structure-template-alist
             '("r"
               "#+BEGIN_SRC ruby\n?\n#+END_SRC"
               "<src lang=\"ruby\">\n\n</src>"))
(add-hook 'org-mode-hook
          (lambda()
            (add-to-list 'ac-sources 'ac-source-math-unicode)
            (add-to-list 'ac-sources 'ac-source-math-latex)))

;; reload file when it changed (and the buffer has no changes)
(global-auto-revert-mode 1)
;; also revert dired
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; python 
(setup "elpy"
  (elpy-enable)
  (elpy-use-ipython)
  (elpy-clean-modeline))

;; haskell mode
(setup "haskell-mode")
(setup-after "haskell-mode"
  (setup "haskell-doc"
    (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode))
  (add-hook 'haskell-mode-hook (lambda () (ghc-init)))
  (setup "haskell-indentation"
    (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation))
  (setup "inf-haskell"
    (add-hook 'inferior-haskell-mode-hook 'turn-on-ghci-completion))
  (define-key haskell-mode-map (kbd "C-c ?") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-?") 'haskell-process-do-info))

;; ruby ;;
;; enhanced ruby mode
(setup "enh-ruby-mode"
  (setq enh-ruby-program "~/.rbenv/shims/ruby")
  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
  ;; replace normal ruby mode
  (defalias 'ruby-mode 'enh-ruby-mode)
  ;; better colors for warnings
  (defface erm-syn-warnline
    '((t (:underline "orange")))
    "Face used for marking warning lines."
    :group 'enh-ruby)
  (defface erm-syn-errline
    '((t (:underline "pink")))
    "Face used for marking error lines."
    :group 'enh-ruby)

  (define-key enh-ruby-mode-map (kbd "C-c C-n") 'enh-ruby-find-error)
  (define-key enh-ruby-mode-map (kbd "C-c C-p") 'enh-ruby-beginning-of-defun)
  ;; Rake files are Ruby, too
  (add-to-list 'auto-mode-alist '("\\.rake$" . enh-ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile$" . enh-ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile$" . enh-ruby-mode))
  (add-to-list 'auto-mode-alist '("Capfile$" . enh-ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.builder$" . enh-ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.gemspec$" . enh-ruby-mode)))
(setup-after "enh-ruby-mode"
  ;; misc stuff
  ;; ri documentation tool
  (setup "yari"
    (define-key enh-ruby-mode-map (kbd "C-c ?") 'yari)) 
  (setup "ruby-block" ; show what block an end belongs to
    (ruby-block-mode t)
    (setq ruby-block-highlight-toggle t)
    (setq ruby-indent-level tab-width)
    (setq enh-ruby-bounce-deep-indent t)
    (setq enh-ruby-deep-indent-paren nil))
  ;; erb
  (setup "rhtml-mode"
    (add-to-list 'auto-mode-alist '("\\.erb$" . rhtml-mode))))

;; Sometimes you have to
(setup "php-mode"
  (add-to-list 'auto-mode-alist '("\\.php$" . php-mode)))

;; javascript
(setup "js2-mode"
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))

;; lua
(setup "lua-mode"
  (setq lua-indent-level 2))

;; (s)css
(setq scss-compile-at-save nil)
(setq css-indent-level 2)

;; eldoc, ie function signatures in the minibuffer
(setup "eldoc"
  (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode))

;; go
(setup "go-mode"
  (add-to-list 'auto-mode-alist '("\\.go$" . go-mode))
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook #'gofmt-before-save)
  (define-key go-mode-map (kbd "M-t") 'godef-jump)
  (define-key go-mode-map (kbd "M-T") 'godef-jump-other-window)
  (setup "go-eldoc"
    (add-hook 'go-mode-hook 'go-eldoc-setup)))

;; crontab
(add-to-list 'auto-mode-alist '( "\\.?cron\\(tab\\)?\\'" . crontab-mode))

;; mark stuff like FIXME
(setup "fic-mode"
  (add-hook 'prog-mode-hook 'fic-mode)
  ;; misbehaving modes
  (add-hook 'enh-ruby-mode-hook 'fic-mode)
  (add-hook 'js2-mode-hook 'fic-mode))

;; csv
(setup "csv-mode"
  (add-to-list 'auto-mode-alist 'csv-mode "\\.[Cc][Ss][Vv]\\'")
  (setup "csv-nav")
  (setq csv-separators '("," ";" "|" " ")))

;; json
(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))

;; matlab
(setup "matlab-load"
  (add-hook 'matlab-mode
            (lambda ()
              (auto-complete-mode 1)
              ))
  (add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode)))

;; dired
(setup "dired"
  ;; move files between split panes
  (setq dired-dwim-target t))
(setup-after "dired" 
  (setup "wdired")
  (setup "dired-details")
  (setup "dired-details+")
  
  ;; reload dired after making changes
  (--each '(dired-do-rename
            dired-do-copy
            dired-create-directory
            wdired-abort-changes)
    (eval `(defadvice ,it (after revert-buffer activate)
             (revert-buffer))))
  (global-set-key (kbd "C-c C-j") 'dired-jump)
  (define-key dired-mode-map (kbd "C-c C-c") 'wdired-change-to-wdired-mode)
  (define-key dired-mode-map (kbd "<insert>") 'dired-mark)
  ;; C-a goes to filename
  (defun dired-back-to-start-of-files ()
    (interactive)
    (backward-char (- (current-column) 2)))
  (define-key dired-mode-map (kbd "C-a") 'dired-back-to-start-of-files)
  (define-key wdired-mode-map (kbd "C-a") 'dired-back-to-start-of-files)
  ;; M-up goes to first file
  (defun dired-back-to-top ()
    (interactive)
    (beginning-of-buffer)
    (dired-next-line 4))
  (define-key dired-mode-map (vector 'remap 'beginning-of-buffer) 'dired-back-to-top)
  (define-key wdired-mode-map (vector 'remap 'beginning-of-buffer) 'dired-back-to-top)
  (define-key dired-mode-map (vector 'remap 'smart-up) 'dired-back-to-top)
  ;; M-down goes to last file
  (defun dired-jump-to-bottom ()
    (interactive)
    (end-of-buffer)
    (dired-next-line -1))
  (define-key dired-mode-map (vector 'remap 'end-of-buffer) 'dired-jump-to-bottom)
  (define-key dired-mode-map (vector 'remap 'smart-down) 'dired-jump-to-bottom)
  (define-key wdired-mode-map (vector 'remap 'end-of-buffer) 'dired-jump-to-bottom))

;; mutt
;; mail support.
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)
(add-hook 'mail-mode-hook (lambda () (setq fill-column 72)))

;; shell stuff
(setq sh-basic-offset tab-width)

;; nix mode
(setup-lazy '(nix-node) "nix-node"
  (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
  (add-to-list 'auto-mode-alist '("\\.nix.in\\'" . nix-mode)))