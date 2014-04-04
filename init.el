;;; Commentary:
;; rejuvyesh's Emacs config

;;; Code:

(setq user-full-name "Jayesh Kumar Gupta"
      user-mail-address "mail@rejuvyesh.com")

;; site-lisp stores manually maintained packages
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/site-lisp/")
           (default-directory my-lisp-dir))
      (progn
        (setq load-path (cons my-lisp-dir load-path))
        (normal-top-level-add-subdirs-to-load-path))))
(setq load-path (cons (expand-file-name "~/.emacs.d") load-path))

;; package-repositories
(require 'package)
(add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; (unless (file-exists-p "~/.emacs.d/elpa/archives/melpa")
;; (package-refresh-contents))

;; ;; define custom lisp directory and load all subdirectories too
;; (let ((default-directory "~/.emacs.d/site-lisp/"))
;;       (normal-top-level-add-to-load-path '("."))
;;       (normal-top-level-add-subdirs-to-load-path))
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(require 'setup)
(setup-initialize)

;; safety first
(setq make-backup-files nil)
(defvar autosave-dir (expand-file-name "~/.emacs.d/cache/autosave-dir/"))
(setq auto-save-list-file-prefix "~/.emacs-saves/cache/auto-save-list/.saves-")
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
(setq confirm-kill-emacs 'y-or-n-p)

;; save location inside buffer
(setup "saveplace"
       (setq save-place-file "~/.emacs.d/cache/saveplace")
       (setq-default save-place t))

;; save minibuffer history
(savehist-mode 1)
(setq history-length         1500)
(setq search-ring-max        1000)
(setq regexp-search-ring-max 1000)
(setq savehist-file "~/.emacs.d/cache/history")
(setq savehist-additional-variables '(search-ring
                                      regexp-search-ring
                                      kill-ring
                                      compile-command))

; try to keep windows within a max margin
(setup "automargin"
       (setq automargin-target-width 120)
       (automargin-mode))

;; remove the toolbar which no-one uses :)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; optical stuff
;; (require 'heartbeat-cursor)
;; (blink-cursor-mode -1)
;; (heartbeat-cursor-mode)
(setq-default cursor-type 'box)
(setq inhibit-splash-screen t)

;; shows current selected region
(setq-default transient-mark-mode t)
(global-font-lock-mode t)
(setq jit-lock-stealth-time 5)
(setq frame-title-format "%b")
(set-fringe-mode '(1 . 10))

;; smart-mode
(setup "smart-mode-line"
       (setq sml/theme 'dark)
       (sml/setup))

;; scrolling
(setq scroll-preserve-screen-position t)
(setq mouse-wheel-progressive-speed nil)
(setq scroll-error-top-bottom t)
;; smooth scrolling with margin
(setup "smooth-scrolling"
       (setq smooth-scroll-margin 5)
       (setq scroll-margin 0)
       (setq scroll-conservatively 10000)
       ;; necessary or scrolling is really slow
       (setq-default bidi-display-reordering nil)
       (setq auto-window-vscroll nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove background color from terminal emacs,
;; so that it can remain transparent
;; http://stackoverflow.com/questions/19054228/emacs-disable-theme-background-color-in-terminal
(defun on-frame-open (frame)
  (if (not (display-graphic-p frame))
      (set-face-background 'default "unspecified-bg" frame)))
(on-frame-open (selected-frame))
(add-hook 'after-make-frame-functions 'on-frame-open)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theming
;; color

;; using modified molokai theme
(load-theme 'molokai t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; multiple cursors
(setup "multiple-cursors"
       (global-set-key (kbd "C-c d")         'mc/edit-lines)
       (global-set-key (kbd "<C-down>")      'mc/mark-next-like-this)
       (global-set-key (kbd "<C-up>")        'mc/mark-previous-like-this)
       (global-set-key (kbd "<M-C-down>")    'mc/skip-to-next-like-this)
       (global-set-key (kbd "<M-C-up>")      'mc/skip-to-previous-like-this)
       (global-set-key (kbd "C-c C-d")       'mc/mark-all-dwim)
       (global-set-key (kbd "C-c >")         'mc/mark-more-like-this-extended)
       (global-set-key (kbd "C-c <")         'mc/mark-more-like-this-extended)
       (global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click)
       (global-set-key (kbd "C-<down-mouse-1>") 'mc/add-cursor-on-click))
(setup-after "multiple-cursors-core"
             (define-key mc/keymap (kbd "<return>") nil)
             (define-key mc/keymap (kbd "C-j") 'multiple-cursors-mode))
(setup "phi-search"
       (global-set-key (kbd "C-c C-s") 'phi-search)
       (global-set-key (kbd "C-c C-r") 'phi-search-backward))
(setup-after "phi-search"
             (setup "phi-search-mc"
                    (define-key phi-search-default-map (kbd "<C-down>") 'phi-search-mc/mark-next)
                    (define-key phi-search-default-map (kbd "<C-up>")   'phi-search-mc/mark-previous)
                    (define-key phi-search-default-map (kbd "C-c C-k")  'phi-search-mc/mark-all)))

;; edit symbol in multiple places simultaneously
(setup-lazy '(iedit-mode) "iedit"
            (global-set-key (kbd "C-c ;") 'iedit-mode)
            (global-set-key (kbd "C-c C-;") 'iedit-mode-toggle-on-function))

;; undo tree
(global-undo-tree-mode)

;; undo highlighting
(setup "volatile-highlights"
       (volatile-highlights-mode t))

;; show #colors in matching color
(setup "rainbow-mode")

(ido-mode 1)
(setq ido-default-buffer-method 'selected-window)
(add-hook 'ido-make-file-list-hook 'ido-sort-mtime)
  (add-hook 'ido-make-dir-list-hook 'ido-sort-mtime)
  (require 'ido-ubiquitous)
  (setq ido-enable-flex-matching t) ; fuzzy matching
  (setq ido-everywhere t)
  (setq ido-use-virtual-buffers t)
  (setq ido-save-directory-list-file "~/.emacs.d/cache/ido.last")
  (setq ido-case-fold t) ; case insensitive
  (defun ido-sort-mtime ()
    (setq ido-temp-list
          (sort ido-temp-list
                (lambda (a b)
                  (let ((ta (nth 5 (file-attributes (concat ido-current-directory a))))
                        (tb (nth 5 (file-attributes (concat ido-current-directory b)))))
                    (if (= (nth 0 ta) (nth 0 tb))
                        (> (nth 1 ta) (nth 1 tb))
                      (> (nth 0 ta) (nth 0 tb)))))))
    (ido-to-end  ;; move . files to end (again)
     (delq nil (mapcar
                (lambda (x) (if (string-equal (substring x 0 1) ".") x))
                ido-temp-list))))

;; use y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)


(setq org-completion-use-ido t)

;; indentation
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(defun use-tabs () (setq indent-tabs-mode t))

;; automatically turn on indenting
(electric-indent-mode 1)
;; also when yanked
(defun yank-and-indent ()
  "Yank and then indent the newly formed region according to mode."
  (interactive)
  (yank)
  (call-interactively 'indent-region))
(global-set-key "\C-y" 'yank-and-indent)


;; Flycheck for code linting
(setup "flycheck"
       (add-hook 'after-init-hook #'global-flycheck-mode))
(setup-lazy '(flycheck-color-mode-line) "flycheck"
                              (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; load ESS for R
;; (setq load-path (cons "/usr/share/emacs/site-lisp/ess" load-path))
(require 'ess-site)
(setq inferior-julia-program-name "~/dev/julia/julia/usr/bin/julia-basic")
(add-to-list 'auto-mode-alist '("\\.jl$" . julia-mode))
;; auctex
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
(setq-default TeX-engine 'xetex)      ; use xelatex by default
(setq TeX-view-program-selection '((output-pdf "zathura")))
(require 'ac-math)
(add-to-list 'ac-modes 'latex-mode)   ; make auto-complete aware of `latex-mode`
(defun ac-latex-mode-setup ()         ; add ac-sources to default ac-sources
  (setq ac-sources
        (append '(ac-source-math-unicode ac-source-math-latex ac-source-latex-commands)
                ac-sources))
    )
;; align
(setup "align"
;; definitions for ruby code
;; fixes the most egregious mistake in detecting regions (hashes), but should be properly generalized at some point
       (setq align-region-separate "\\(^\\s-*[{}]?\\s-*$\\)\\|\\(=\\s-*[][{}()]\\s-*$\\)"))
(setup-expecting "align"
                 (setup-after "enh-ruby-mode"
                                  (defconst align-ruby-modes '(enh-ruby-mode)
                                    "align-perl-modes is a variable defined in `align.el'.")
                                  (defconst ruby-align-rules-list
                                    '((ruby-comma-delimiter
                                       (regexp . ",\\(\\s-*\\)[^/ \t\n]")
                                       (modes . '(enh-ruby-mode))
                                       (repeat . t))
                                      (ruby-string-after-func
                                       (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\)['\"]\\w+['\"]")
                                       (modes . '(enh-ruby-mode))
                                       (repeat . t))
                                      (ruby-symbol-after-func
                                       (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\):\\w+")
                                       (modes . '(enh-ruby-mode))))
                   "Alignment rules specific to the ruby mode.
See the variable `align-rules-list' for more details."))
                 (add-to-list 'align-perl-modes 'enh-ruby-mode)
                 (add-to-list 'align-dq-string-modes 'enh-ruby-mode)
                 (add-to-list 'align-sq-string-modes 'enh-ruby-mode)
                 (add-to-list 'align-open-comment-modes 'enh-ruby-mode)
                 (dolist (it ruby-align-rules-list)
                   (add-to-list 'align-rules-list it))
                 (setup-after "haskell-mode"
                 ;; haskell alignments
                                  (add-to-list 'align-rules-list
                                               '(haskell-types
                                                 (regexp . "\\(\\s-+\\)\\(::\\|∷\\)\\s-+")
                                                 (modes quote (haskell-mode literate-haskell-mode))))
                                  (add-to-list 'align-rules-list
                                               '(haskell-assignment
                                                 (regexp . "\\(\\s-+\\)=\\s-+")
                                                 (modes quote (haskell-mode literate-haskell-mode))))
                                  (add-to-list 'align-rules-list
                                               '(haskell-arrows
                                                 (regexp . "\\(\\s-+\\)\\(->\\|→\\)\\s-+")
                                                 (modes quote (haskell-mode literate-haskell-mode))))
                                  (add-to-list 'align-rules-list
                                               '(haskell-left-arrows
                                                 (regexp . "\\(\\s-+\\)\\(<-\\|←\\)\\s-+")
                                                 (modes quote (haskell-mode literate-haskell-mode)))))
                 ;; align current region
                 (global-set-key (kbd "C-c =") 'align-current)
                 ;; repeat regex (teh fuck ain't that the default?!)
                 (defun align-repeat (start end regexp)
                   "Repeat alignment with respect to the given regular expression."
                   (interactive "r\nsAlign regexp: ")
                   (align-regexp start end
                                 (concat "\\(\\s-*\\)" regexp) 1 1 t))
                 (global-set-key (kbd "C-c C-=") 'align-repeat))

;; python ;;
(elpy-enable)
(elpy-use-ipython)
(elpy-clean-modeline)

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
             (setup "yari"
                    (define-key enh-ruby-mode-map (kbd "C-c ?") 'yari)) ; ri documentation tool
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

;; expand-region
(setup-lazy '(er/expand-region er/contract-region) "expand-region"
            (global-set-key (kbd "<C-prior>") 'er/expand-region)
            (global-set-key (kbd "<C-next>") 'er/contract-region))

;; C coding style
(setq c-default-style "linux"
      c-basic-offset 4)
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
(add-hook 'auto-complete-mode-hook 'ac-common-setup)






;; snippets
(setup "yasnippet"
       (setq yas-snippet-dirs "~/.emacs.d/snippets")
;; (define-key yas-minor-mode-map [backtab] 'yas-next-field)
;; (define-key yas-minor-mode-map [(shift tab)] 'yas-next-field)
;; (define-key yas-minor-mode-map [(control tab)] 'yas-prev-field)
       (define-key yas-minor-mode-map (kbd "C-t") 'yas-next-field-or-maybe-expand)
       (define-key yas-minor-mode-map (kbd "M-t") 'yas-prev-field)
       (yas-global-mode 1))

;; auto-yasnippet
(setup-after "yasnippet"
             (setup "auto-yasnippet")
             (global-set-key (kbd "C-c ~") 'aya-create)
             (global-set-key (kbd "C-c C-~") 'aya-expand))

;; folding
(setup "hideshow")
(setup-lazy '(hs-minor-mode) "hideshowvis"
            (add-hook 'enh-ruby-hook   'hs-minor-mode))
(setup-lazy '(hs-minor-mode) "fold-dwim"
            (define-key global-map (kbd "C-c C-f") 'fold-dwim-toggle)
            (define-key global-map (kbd "C-c f")   'fold-dwim-hide-all)
            (define-key global-map (kbd "C-c F") 'fold-dwim-show-all))

;; fast navigation
(setup "imenu"
       ;; recentering
       (setq recenter-positions '(2 middle))
       (add-hook 'imenu-after-jump-hook 'recenter-top-bottom))
(setup "idomenu"
       (define-key global-map (kbd "C-c [") 'idomenu)
       (define-key global-map (kbd "C-c C-[") 'idomenu))
(setup "imenu-anywhere"
       (define-key global-map (kbd "C-c ]") 'imenu-anywhere)
       (define-key global-map (kbd "C-c C-]") 'imenu-anywhere))


;; text completion
(setup "smartparens-config"
       (smartparens-global-mode t)
       (show-smartparens-global-mode +1)
       (setq sp-highlight-pair-overlay nil)
       (show-smartparens-global-mode t)
       ;; markdown-mode
       (setup-expecting "markdown-mode" "org-mode"
                        (sp-with-modes '(markdown-mode)
                          (sp-local-pair "*" "*" :actions '(wrap autoskip))
                          (sp-local-tag "2" "**" "**")
                          (sp-local-tag "m" "$" "$") ; math
                          (sp-local-tag "<"  "<_>" "</_>" :transform 'sp-match-sgml-tags))
                        (sp-with-modes '(org-mode)
                          (sp-local-pair "$" "$" :actions '(wrap autoskip))
                          (sp-local-pair "$$" "$$" :actions '(wrap autoskip))))
       ;; html-mode
       (setup-expecting "html-mode" "sgml-mode"
                        (sp-with-modes '(html-mode sgml-mode)
                          (sp-local-pair "<" ">")))
       ;; sp keys
       (define-key sp-keymap (kbd "C-M-f") 'sp-forward-sexp)
       (define-key sp-keymap (kbd "C-M-b") 'sp-backward-sexp)
       (define-key sp-keymap (kbd "M-f") 'sp-forward-symbol)
       (define-key sp-keymap (kbd "M-b") 'sp-backward-symbol)
       (define-key sp-keymap (kbd "C-S-a") 'sp-beginning-of-sexp)
       (define-key sp-keymap (kbd "C-S-d") 'sp-end-of-sexp)
       (define-key sp-keymap (kbd "C-M-k") 'sp-kill-sexp)
       (define-key sp-keymap (kbd "C-M-w") 'sp-copy-sexp)
       (define-key sp-keymap (kbd "C-<left>") 'sp-add-to-next-sexp)
       (define-key sp-keymap (kbd "C-<right>") 'sp-add-to-previous-sexp)
       (define-key sp-keymap (kbd "M-<delete>") 'sp-unwrap-sexp)
       (define-key sp-keymap (kbd "M-<backspace>") 'sp-backward-unwrap-sexp))

;; auto correction
(setq abbrev-file-name
      "~/.emacs.d/abbrev_defs")
(setq save-abbrevs t)
(if (file-exists-p abbrev-file-name)
    (quietly-read-abbrev-file))
(setq default-abbrev-mode t)

;; auto completion
(setup "fuzzy")
(setup-after "fuzzy"
             (setup "auto-complete-config"
                    (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
                    (setq ac-auto-start 1)
                    (setq ac-use-menu-map t
                          ac-auto-show-menu t
                          ac-quick-help-delay 0.5
                          ac-use-fuzzy t
                          ac-ignore-case nil)
                    (setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
                    ;; extra modes auto-complete must support
                    (global-auto-complete-mode t)
                    (define-key ac-completing-map (kbd "RET") 'ac-complete)
                    (define-key ac-complete-mode-map "\M-n" 'ac-next)
                    (define-key ac-complete-mode-map "\M-p" 'ac-previous)
                    (dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
                                                        sass-mode yaml-mode haskell-mode 
                                                        html-mode nxml-mode sh-mode smarty-mode clojure-mode
                                                        lisp-mode textile-mode markdown-mode tuareg-mode
                                                        js2-mode css-mode less-css-mode matlab-mode enh-ruby-mode))
                      (add-to-list 'ac-modes mode))

                    (setq ac-comphist-file "~/.emacs.d/cache/ac-comphist.dat")
                    (setup-expecting "go-mode"
                                     (setup "go-autocomplete"))))


;; disabling Yasnippet completion
(setup-after "auto-complete" "yasnippet"
             (defun epy-snips-from-table (table)
               (with-no-warnings
                 (let ((hashtab (ac-yasnippet-table-hash table))
                       (parent (ac-yasnippet-table-parent table))
                       candidates)
                   (maphash (lambda (key value)
                              (push key candidates))
                            hashtab)
                   (identity candidates)
                   )))
             (defun epy-get-all-snips ()
               (let (candidates)
                 (maphash
                  (lambda (kk vv) (push (epy-snips-from-table vv) candidates)) yas--tables)
                 (apply 'append candidates))
               )
             (setq ac-ignores (concatenate 'list ac-ignores (epy-get-all-snips))))

;; recent files
(setup "recentf"
       (setq recentf-max-saved-items 1000)
       (setq recentf-save-file "~/.emacs.d/cache/recentf")
       (setq recentf-exclude (append recentf-exclude
                                     '("\.emacs\.d/cache"
                                       "\.emacs\.d/elpa")))
       (setq recentf-keep '(file-remote-p file-readable-p))
       (recentf-mode 1))

;; file completion

(setup-after "recentf"
             (defun recentf-ido-find-file ()
               "Find a recent file using Ido."
               (interactive)
               (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
                 (when file
                   (find-file file))))
             (global-set-key "\C-x\C-r" 'recentf-ido-find-file))

;; use regexp search and selected region (if any) by default
(defun region-as-string ()
  (buffer-substring (region-beginning)
                    (region-end)))

(defun isearch-forward-use-region ()
  (interactive)
  (when (region-active-p)
    (add-to-history 'regexp-search-ring (region-as-string))
    (deactivate-mark))
  (call-interactively 'isearch-forward-regexp))

(defun isearch-backward-use-region ()
  (interactive)
  (when (region-active-p)
    (add-to-history 'regexp-search-ring (region-as-string))
    (deactivate-mark))
  (call-interactively 'isearch-backward-regexp))

;; use regexp search by default
(global-set-key (kbd "C-s") 'isearch-forward-use-region)
(global-set-key (kbd "C-r") 'isearch-backward-use-region)
(global-set-key (kbd "C-S-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-S-r") 'isearch-backward-regexp)

;; make backspace sane
(define-key isearch-mode-map (kbd "<backspace>") 'isearch-del-char)

(define-key isearch-mode-map (kbd "C-c C-w") 'isearch-toggle-word)
(define-key isearch-mode-map (kbd "C-c C-r") 'isearch-toggle-regexp)
(define-key isearch-mode-map (kbd "C-c C-i") 'isearch-toggle-case-fold)
(define-key isearch-mode-map (kbd "C-c C-s") 'isearch-toggle-symbol)
(define-key isearch-mode-map (kbd "C-c C-SPC") 'isearch-toggle-lax-whitespace)
(define-key isearch-mode-map (kbd "C-c C-o") 'isearch-occur)

;; search wort at point, like vim
(defun isearch-word-at-point ()
  (interactive)
  (call-interactively 'isearch-forward-regexp))

(defun isearch-yank-word-hook ()
  (when (equal this-command 'isearch-word-at-point)
    (let ((string (concat "\\<"
                          (buffer-substring-no-properties
                           (progn (skip-syntax-backward "w_") (point))
                           (progn (skip-syntax-forward "w_") (point)))
                          "\\>")))
      (if (and isearch-case-fold-search
               (eq 'not-yanks search-upper-case))
          (setq string (downcase string)))
      (setq isearch-string string
            isearch-message
            (concat isearch-message
                    (mapconcat 'isearch-text-char-description
                               string ""))
            isearch-yank-flag t)
      (isearch-search-and-update))))

(add-hook 'isearch-mode-hook 'isearch-yank-word-hook)
(global-set-key (kbd "C-c *") 'isearch-word-at-point)


;; text stuff

(setup-expecting "org-mode"
                 (setq default-major-mode 'org-mode))
(prefer-coding-system 'utf-8)
(setq undo-limit 1000000)
(setq sentence-end-double-space nil)
(column-number-mode t)
(setq-default indicate-empty-lines t)

;; deltete selected
(delete-selection-mode t)

;; don't hard-wrap text, but use nice virtual wrapping
(setq-default fill-column 80)
(global-visual-line-mode 1)
(setup "adaptive-wrap"
       (setq visual-line-fringe-indicators '(nil right-curly-arrow)))

;; parentheses are connected and their content highlighted
(setq blink-matching-paren-distance nil)
(setq show-paren-style 'parenthesis)
(setq show-paren-delay 0)
(setup "highlight-parentheses"
       (defun turn-on-highlight-parentheses () (highlight-parentheses-mode 1))
       (add-hook 'emacs-lisp-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'lisp-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'java-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'python-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'c-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'haskell-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'enh-ruby-mode-hook 'turn-on-highlight-parentheses)
       (add-hook 'text-mode-hook 'turn-on-highlight-parentheses))

;; general key bindings
(global-set-key (kbd "C-c c")    'comment-region)
(global-set-key (kbd "C-c u")    'uncomment-region)
(global-set-key (kbd "C-c SPC")   'comment-dwim)
(global-set-key (kbd "C-c C-SPC") 'comment-dwim)
(global-set-key (kbd "C-c n")    'next-error)
(global-set-key (kbd "C-c p")    'previous-error)
(global-set-key (kbd "C-c i")    'indent-region)
(global-set-key (kbd "M-g")      'goto-line)
(global-set-key (kbd "C-S-M-x")   'eval-buffer)

(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "M-z") 'undo-tree-redo)

(global-set-key (kbd "C-f")   'forward-word)
(global-set-key (kbd "C-b")   'backward-word)
(global-set-key (kbd "M-f")   'forward-sentence)
(global-set-key (kbd "M-b")   'backward-sentence)
(global-set-key (kbd "<home>") 'beginning-of-buffer)
(global-set-key (kbd "<end>")  'end-of-buffer)

;; if no region is active, act on current line
(setup "whole-line-or-region"
       (setq whole-line-or-region-extensions-alist
             '((comment-dwim whole-line-or-region-comment-dwim-2 nil)
               (copy-region-as-kill whole-line-or-region-copy-region-as-kill nil)
               (kill-region whole-line-or-region-kill-region nil)
               (kill-ring-save whole-line-or-region-kill-ring-save nil)
               (yank whole-line-or-region-yank nil)
               ))
       (whole-line-or-region-mode 1))

;; tramp
(setup "tramp"
       (setq tramp-default-method "ssh")
       (setq tramp-persistency-file-name "~/.emacs.d/cache/tramp"))

;; reload file when it changed (and the buffer has no changes)
(global-auto-revert-mode 1)
;; also revert dired
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; move files to trash instead
(setq delete-by-moving-to-trash t)

; mark stuff like FIXME
(setup "fic-mode"
       (add-hook 'prog-mode-hook 'fic-mode)
       ;; misbehaving modes
       (add-hook 'enh-ruby-mode-hook 'fic-mode)
       (add-hook 'js2-mode-hook 'fic-mode))

;; csv
(setup "csv-mode"
       (add-to-list 'auto-mode-alist 'csv-mode "\\.[Cc][Ss][Vv]\\'")
       (setup "csv-nav-mode")
       (setq csv-separators '("," ";" "|" " ")))

;; markdown
;; (require 'markdown-mode)
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
       (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
       (defun no-electric-indent-yaml ()
         (electric-indent-mode -1)
         (define-key yaml-mode-map [(return)] 'newline-and-indent))
       (add-hook 'yaml-mode-hook 'no-electric-indent-yaml))

;; shell stuff
(setq sh-basic-offset tab-width)

;; json
(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))


(setup "matlab-load"
       (add-hook 'matlab-mode
                 (lambda ()
                   (auto-complete-mode 1)
                   ))
       (add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode)))

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

;; org-mode
(setq org-special-ctrl-a/e t)
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
(setq org-clock-persist-file "~/.emacs.d/cache/org-clock-save.el")
(org-clock-persistence-insinuate)
;; spoiler files
(defadvice org-todo-list (before org-todo-list-reload activate compile)
  "Scan for org files whenever todo list is loaded."
  ; 'find' is faster and has better control than lisp
  (setq org-agenda-files (mapcar 'abbreviate-file-name (split-string
    (shell-command-to-string "find ~/Documents/spoiler -type f -name \"*.org\" | sort")
    "\n"))))
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
;; keybindings
(define-key global-map "\C-ct" 'org-todo-list)
(org-defkey org-mode-map "\C-c\C-t" (lambda () (interactive) (org-todo "TODO")))
(org-defkey org-mode-map "\C-c\C-w" (lambda () (interactive) (org-todo "WAITING")))
(org-defkey org-mode-map "\C-c\C-d" (lambda () (interactive) (org-todo "DONE")))
;; shortcut for C-u C-c C-l
(defun org-insert-file-link () (interactive) (org-insert-link '(4)))
(org-defkey org-mode-map "\C-cf" 'org-insert-file-link)
(org-defkey org-mode-map "\C-cl" 'org-store-link)
;; go to last position before C-c C-o
(define-key global-map "\C-co" 'org-mark-ring-goto)
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

;; scratchpad buffers
(setup "scratch"
       ;; don't want to remember which key I used
       (global-set-key (kbd "C-c b") 'scratch)
       ;; don't start in lisp
       (setq initial-major-mode 'org-mode)
       (setq initial-scratch-message nil))

;; oh pretty!
(setup "pretty-lambdada"
       (global-pretty-lambda-mode))


;; normal bookmarks
(setq bookmark-default-file "~/.emacs.d/cache/bookmarks")

;; unset unwanted default keys
(loop for key in `(
                   (,(kbd "C-x C-z") suspend-frame)
                   (,(kbd "C-z") suspend-frame)
                   ([(insert)] overwrite-mode)
                   ([(insertchar)] overwrite-mode)
                   (,(kbd "C-]") abort-recursive-edit)
                   (,(kbd "C-@") set-mark-command)
                   (,(kbd "<C-down-mouse-1>") mouse-buffer-menu)
                   (,(kbd "<C-down-mouse-2>") facemenu-menu)
                   (,(kbd "<S-down-mouse-1>") mouse-appearance-menu)
                   (,(kbd "C-x C-t") transpose-lines)
                   (,(kbd "C-x C-q") read-only-mode)
                   (,(kbd "C-x C-o") delete-blank-lines)
                   (,(kbd "C-x C-n") set-goal-column)
                   (,(kbd "C-x TAB") indent-rigidly)
                   (,(kbd "C-x C-e") eval-last-sexp)
                   (,(kbd "C-x C-d") list-directory)
                   (,(kbd "C-x C-@") pop-global-mark)
                   (,(kbd "C-x SPC") gud-break)
                   (,(kbd "C-x #") server-edit)
                   (,(kbd "C-x $") set-selective-display)
                   (,(kbd "C-x '") expand-abbrev)
                   (,(kbd "C-x <") scroll-left)
                   (,(kbd "C-x =") what-cursor-position)
                   (,(kbd "C-x >") scroll-right)
                   (,(kbd "C-x [") backward-page)
                   (,(kbd "C-x ]") forward-page)
                   (,(kbd "C-x ^") enlarge-window)
                   (,(kbd "C-x `") next-error)
                   (,(kbd "C-x l") count-lines-page)
                   (,(kbd "C-x {") shrink-window-horizontally)
                   (,(kbd "C-x }") enlarge-window-horizontally)
                   (,(kbd "C-M-@") mark-sexp)
                   (,(kbd "C-M-d") down-list)
                   (,(kbd "C-M-l") reposition-window)
                   (,(kbd "C-M-n") forward-list)
                   (,(kbd "C-M-p") backward-list)
                   (,(kbd "C-M-t") transpose-sexps)
                   (,(kbd "C-M-u") backward-up-list)
                   (,(kbd "C-M-v") scroll-other-window)
                   (,(kbd "C-M-\\") indent-region)
                   (,(kbd "M-$") ispell-word)
                   (,(kbd "M-%") query-replace)
                   (,(kbd "M-'") abbrev-prefix-mark)
                   (,(kbd "M-(") insert-parentheses)
                   (,(kbd "M-)") move-past-close-and-reindent)
                   (,(kbd "M-*") pop-tag-mark)
                   (,(kbd "M-.") find-tag)
                   (,(kbd "M-,") tags-loop-continue)
                   (,(kbd "M-/") dabbrev-expand)
                   (,(kbd "M-=") count-words-region)
                   (,(kbd "M-@") mark-word)
                   (,(kbd "M-\\") delete-horizontal-space)
                   (,(kbd "M-`") tmm-menubar)
                   (,(kbd "M-a") backward-sentence)
                   (,(kbd "M-e") forward-sentence)
                   (,(kbd "M-m") back-to-indentation)
                   (,(kbd "M-o") facemenu-keymap)
                   (,(kbd "M-r") move-to-window-line-top-bottom)
                   (,(kbd "M-{") backward-paragraph)
                   (,(kbd "M-}") forward-paragraph)
                   (,(kbd "M-~") not-modified)
                   (,(kbd "C-M-S-v") scroll-other-window-down)
                   (,(kbd "C-M-%") query-replace-regexp)
                   (,(kbd "C-M-.") find-tag-regexp)
                   (,(kbd "C-M-/") dabbrev-completion)
                   )
      collect (if (eq (key-binding (first key)) (second key))
                  (global-unset-key (first key))))


;; semantic (code parser)
(require 'semantic)
(setq semanticdb-default-save-directory "~/.emacs.d/cache/semanticdb")
(semantic-mode 1)
(global-semantic-idle-summary-mode 1)
(global-semantic-idle-completions-mode 1)

;; ecb (code browser)
(require 'ecb-autoloads)
;; fix for emacs 24
(unless (boundp 'stack-trace-on-error)
  (defvar stack-trace-on-error nil))


;; keys
(global-set-key "\C-c\C-t" 'ecb-toggle-layout)
(global-set-key "\C-c;" 'ecb-minor-mode)


;; I never use set-fill-column and I hate hitting it by accident.
(global-set-key "\C-x\ f" 'find-file)

;;Make completion buffers in a shell disappear after 10 seconds.
;;<http://snarfed.org/space/why+I+don't+run+shells+inside+Emacs>
(add-hook 'completion-setup-hook
          (lambda () (run-at-time 10 nil
                                  (lambda () (delete-windows-on "*Completions*")))))

;; highlight current line
(defface hl-line '((t (:background "aquagreen")))
  "Face to use for `hl-line-face'." :group 'hl-line)
(setq hl-line-face 'hl-line)
(global-hl-line-mode t)


;; add current date
(defun insert-date (prefix)
  "Insert the current date. With prefix-argument, use ISO format. With
   two prefix arguments, write out the day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%d %B, %Y")
                 ((equal prefix '(4)) "%Y-%m-%d")
                 ((equal prefix '(16)) "%A, %d %B, %Y")))
        (system-time-locale "en_US"))
    (insert (format-time-string format))))

(global-set-key (kbd "C-c d") 'insert-date)

;; spell-checking
(autoload 'wcheck-mode "wcheck-mode"
  "Toggle wcheck-mode." t)
(setq ispell-really-hunspell t)
(setq wcheck-timer-idle .2)
(define-key global-map "\C-cs" 'wcheck-actions)
(setq-default
 wcheck-language "English"
 wcheck-language-data '(("English"
                         (program . "/usr/bin/enchant")
                         (args . ("-l" "-d" "en_US"))
                         (action-program . "/usr/bin/enchant")
                         (action-args "-a" "-d" "en_US")
                         (action-parser . enchant-suggestions-menu))
                        ))

 ;; add to dictionary functionality
 (defun enchant-suggestions-menu (marked-text)
   (cons (cons "[Add]" 'enchant-add-to-dictionary)
         (wcheck-parser-ispell-suggestions)))

 (defvar enchant-dictionaries-dir "~/.config/enchant")

 (defun enchant-add-to-dictionary (marked-text)
   (let* ((word (aref marked-text 0))
          (language (aref marked-text 4))
          (file (let ((code (nth 1 (member "-d" (wcheck-query-language-data
                                                 language 'action-args)))))
                  (when (stringp code)
                    (concat (file-name-as-directory enchant-dictionaries-dir)
                            code ".dic")))))

     (when (and file (file-writable-p file))
       (with-temp-buffer
         (insert word) (newline)
         (append-to-file (point-min) (point-max) file)
         (message "Added word \"%s\" to the %s dictionary"
                  word language)))))

 ;; enable spell-check in certain modes
 (defun turn-on-spell-check ()
   (wcheck-mode 1))
 (add-hook 'text-mode-hook 'turn-on-spell-check)
 (add-hook 'markdown-mode-hook 'turn-on-spell-check)
 (add-hook 'org-mode-hook 'turn-on-spell-check)

;; use automatic file headers
(load "~/.emacs.d/emacs-auto-insert.el")

;; mutt
;; mail support.
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)
(add-hook 'mail-mode-hook (lambda () (setq fill-column 72)))
;; Some saner clipboard
(setq x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

(winner-mode 1)

;; number windows, i.e. M-1 .. M-0 to jump to window
(require 'window-numbering)
(window-numbering-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checking out helm
(require 'helm-config)
(require 'helm-C-x-b)
(helm-mode t)
(global-set-key (kbd "M-t") 'helm-cmd-t)
(global-set-key [remap switch-to-buffer] 'helm-C-x-b)
(global-set-key (kbd "C-x c g") 'helm-do-grep)
(global-set-key (kbd "C-x c o") 'helm-occur)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(setq helm-ff-lynx-style-map nil
      helm-input-idle-delay 0.1
      helm-idle-delay 0.1
      )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; go to last change
;; http://www.emacswiki.org/emacs/GotoChg
(require 'goto-chg)
(global-set-key [f8] 'goto-last-change)

;; rainbow-delimiters.el
;; http://www.emacswiki.org/emacs/RainbowDelimiters
(require 'rainbow-delimiters)
(add-hook 'ess-mode-hook 'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode) ; for programming related modes

;; yascroll
(global-yascroll-bar-mode 1)

;; better search/replace
(require 'visual-regexp)
(require 'visual-regexp-steroids)
(global-set-key (kbd "C-c r") 'vr/query-replace)
(defun vr/query-replace-from-beginning ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (call-interactively 'vr/query-replace)))
(global-set-key (kbd "C-c R") 'vr/query-replace-from-beginning)

;; search info
(require 'anzu)
(global-anzu-mode t)

;; copy end of line, like C-k
(defun copy-line ()
  (interactive)
  (set 'this-command 'copy-to-kill)
  (save-excursion
    (set-mark (point))
    (if (= (point) (line-end-position))
        (forward-line)
      (goto-char (line-end-position)))
    (if (eq last-command 'copy-to-kill)
        (append-next-kill))
    (kill-ring-save (mark) (point))))
(global-set-key "\M-k" 'copy-line)

;; move to beginning of text on line
(defun smart-beginning-of-line ()
    "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line. If point was
already at that position, move point to beginning of line.

If visual-line-mode is on, then also jump to beginning of real line."
    (interactive) ; Use (interactive "^") in Emacs 23 to make shift-select work
    (let ((oldpos (point))
          (vispos (point)))

      (beginning-of-visual-line)
      (setq vispos (point))
      (beginning-of-line-text)

      (if (and (> vispos (point))
               (not (= oldpos vispos)))
          (goto-char vispos)
        (when (= oldpos (point))
          (beginning-of-line)))))
(global-set-key "\C-a" 'smart-beginning-of-line)

(defun smart-end-of-line ()
  "Move point to end of visual line or, if already there, to end of logical line."
  (interactive) ; Use (interactive "^") in Emacs 23 to make shift-select work
  (let ((oldpos (point)))

    (end-of-visual-line)
    (when (= oldpos (point))
      (end-of-line))))
(global-set-key "\C-e" 'smart-end-of-line)

;; move lines like in org-mode
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

;; fonts
(defvar small-font "Terminus 8")
(defvar normal-font "Consolas 10")
(defvar big-font "Ricty 14")
(defvar font-list (list
                   small-font
                   normal-font
                   big-font))
(defvar current-font normal-font)

(defun set-window-font ()
  (set-frame-font current-font))
(add-hook 'after-make-window-system-frame-hooks 'set-window-font)

;; shortcut for the fonts
(defun use-big-font ()
  "use big font"
  (interactive)
  (setq current-font big-font)
  (set-window-font))
(defun use-normal-font ()
  "use normal font"
  (interactive)
  (setq current-font normal-font)
  (set-window-font))
(defun use-small-font ()
  "use small font"
  (interactive)
  (setq current-font small-font)
  (set-window-font))
(global-set-key (kbd "C-c <f1>") 'use-small-font)
(global-set-key (kbd "C-c <f2>") 'use-normal-font)
(global-set-key (kbd "C-c <f3>") 'use-big-font)

;; More emacs rocks: Join current line with the next
(global-set-key (kbd "M-j")
                (lambda ()
                  (interactive)
                  (join-line -1)))

;; Find init file
(defun find-user-init-file ()
  "Edit the `user-init-file', in another window."
  (interactive)
  (find-file-other-window user-init-file))

(global-set-key (kbd "C-c I") 'find-user-init-file)

;; automatically create directories if necessary
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;; Guide Key
(require 'guide-key)
(setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-x v" "C-x 8" "C-x +" "C-x c"))
(guide-key-mode 1)
(setq guide-key/recursive-key-sequence-flag t)
(setq guide-key/popup-window-position 'bottom)

;; ace-jump (hint-style navigation)
(require 'ace-jump-mode)
(global-set-key (kbd "C-c j") 'ace-jump-mode)

;; expand-region
(require 'expand-region)
(global-set-key (kbd "<C-prior>") 'er/expand-region)
(global-set-key (kbd "<C-next>") 'er/contract-region)

;; Make shell more convenient, and suspend-frame less

(global-set-key (kbd "C-x M-z") 'suspend-frame)
;; make zsh aliases work
(setq shell-command-switch "-ic")

;; Webjump let's you quickly search google, wikipedia, emacs wiki
(global-set-key (kbd "C-x g") 'webjump)
(global-set-key (kbd "C-x M-g") 'browse-url-at-point)

;; M-n and M-p to move from current symbol
(smartscan-mode 1)

;; ag mode
(setq ag-highlight-search t)

;; enable some stuff
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; gist
;; (require 'cipher/aes)
;; (setq yagist-encrypt-risky-config t)

;; makefile has its issues
(add-hook 'makefile-mode-hook 'usetabs)

;; diminish
(require 'diminish)
(diminish 'highlight-parentheses-mode)
(diminish 'fic-mode)
(diminish 'auto-complete-mode "↝")
(diminish 'undo-tree-mode "↺")
(diminish 'visual-line-mode)
(diminish 'volatile-highlights-mode)
(diminish 'whole-line-or-region-mode)
(diminish 'yas-minor-mode)
(diminish 'smartparens-mode)
(diminish 'anzu-mode)
(diminish 'guide-key-mode)
(diminish 'hs-minor-mode)
