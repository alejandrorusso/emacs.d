;;; ob-shell.el --- org-babel functions for shell evaluation

;; Copyright (C) 2009-2014 Free Software Foundation, Inc.

;; Author: Eric Schulte
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating shell source code.

;;; Code:
(require 'ob)
(require 'shell)
(eval-when-compile (require 'cl))

(declare-function org-babel-comint-in-buffer "ob-comint" (buffer &rest body))
(declare-function org-babel-comint-wait-for-output "ob-comint" (buffer))
(declare-function org-babel-comint-buffer-livep "ob-comint" (buffer))
(declare-function org-babel-comint-with-output "ob-comint" (meta &rest body))
(declare-function orgtbl-to-generic "org-table" (table params))

(defvar org-babel-default-header-args:sh '())

(defcustom org-babel-sh-command shell-file-name
  "Command used to invoke a shell.
Set by default to the value of `shell-file-name'.  This will be
passed to `shell-command-on-region'"
  :group 'org-babel
  :type 'string)

(defcustom org-babel-sh-var-quote-fmt
  "$(cat <<'BABEL_TABLE'\n%s\nBABEL_TABLE\n)"
  "Format string used to escape variables when passed to shell scripts."
  :group 'org-babel
  :type 'string)

(defcustom org-babel-shell-names
  '("sh" "bash" "csh" "ash" "dash" "ksh" "mksh" "posh")
  "List of names of shell supported by babel shell code blocks."
  :group 'org-babel
  :type 'string
  :initialize
  (lambda (symbol value)
    (set-default symbol (second value))
    (mapc
     (lambda (name)
       (eval `(defun ,(intern (concat "org-babel-execute:" name)) (body params)
		,(format "Execute a block of %s commands with Babel." name)
		(let ((org-babel-sh-command ,name))
		  (org-babel-execute:shell body params)))))
     (second value))))

(defun org-babel-execute:shell (body params)
  "Execute a block of Shell commands with Babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((session (org-babel-sh-initiate-session
		   (cdr (assoc :session params))))
	 (stdin (let ((stdin (cdr (assoc :stdin params))))
                  (when stdin (org-babel-sh-var-to-string
                               (org-babel-ref-resolve stdin)))))
	 (cmdline (cdr (assoc :cmdline params)))
         (full-body (org-babel-expand-body:generic
		     body params (org-babel-variable-assignments:sh params))))
    (org-babel-reassemble-table
     (org-babel-sh-evaluate session full-body params stdin cmdline)
     (org-babel-pick-name
      (cdr (assoc :colname-names params)) (cdr (assoc :colnames params)))
     (org-babel-pick-name
      (cdr (assoc :rowname-names params)) (cdr (assoc :rownames params))))))

(defun org-babel-prep-session:sh (session params)
  "Prepare SESSION according to the header arguments specified in PARAMS."
  (let* ((session (org-babel-sh-initiate-session session))
	 (var-lines (org-babel-variable-assignments:sh params)))
    (org-babel-comint-in-buffer session
      (mapc (lambda (var)
              (insert var) (comint-send-input nil t)
              (org-babel-comint-wait-for-output session)) var-lines))
    session))

(defun org-babel-load-session:sh (session body params)
  "Load BODY into SESSION."
  (save-window-excursion
    (let ((buffer (org-babel-prep-session:sh session params)))
      (with-current-buffer buffer
        (goto-char (process-mark (get-buffer-process (current-buffer))))
        (insert (org-babel-chomp body)))
      buffer)))

;; helper functions
(defun org-babel-variable-assignments:sh-generic
    (varname values &optional sep hline)
  "Returns a list of statements declaring the values as a generic variable."
  (format "%s=%s" varname (org-babel-sh-var-to-sh values sep hline)))

(defun org-babel-variable-assignments:bash_array
    (varname values &optional sep hline)
  "Returns a list of statements declaring the values as a bash array."
  (format "unset %s\ndeclare -a %s=( \"%s\" )"
     varname varname
     (mapconcat 'identity
       (mapcar
         (lambda (value) (org-babel-sh-var-to-sh value sep hline))
         values)
       "\" \"")))

(defun org-babel-variable-assignments:bash_assoc
    (varname values &optional sep hline)
  "Returns a list of statements declaring the values as bash associative array."
  (format "unset %s\ndeclare -A %s\n%s"
    varname varname
    (mapconcat 'identity
      (mapcar
        (lambda (items)
          (format "%s[\"%s\"]=%s"
            varname
            (org-babel-sh-var-to-sh (car items) sep hline)
            (org-babel-sh-var-to-sh (cdr items) sep hline)))
        values)
      "\n")))

(defun org-babel-variable-assignments:bash (varname values &optional sep hline)
  "Represents the parameters as useful Bash shell variables."
  (if (listp values)
      (if (and (listp (car values)) (= 1 (length (car values))))
	  (org-babel-variable-assignments:bash_array varname values sep hline)
	(org-babel-variable-assignments:bash_assoc varname values sep hline))
    (org-babel-variable-assignments:sh-generic varname values sep hline)))

(defun org-babel-variable-assignments:sh (params)
  "Return list of shell statements assigning the block's variables."
  (let ((sep (cdr (assoc :separator params)))
	(hline (when (string= "yes" (cdr (assoc :hlines params)))
		 (or (cdr (assoc :hline-string params))
		     "hline"))))
    (mapcar
     (lambda (pair)
       (if (string= org-babel-sh-command "bash")
	   (org-babel-variable-assignments:bash
            (car pair) (cdr pair) sep hline)
         (org-babel-variable-assignments:sh-generic
	  (car pair) (cdr pair) sep hline)))
     (mapcar #'cdr (org-babel-get-header params :var)))))

(defun org-babel-sh-var-to-sh (var &optional sep hline)
  "Convert an elisp value to a shell variable.
Convert an elisp var into a string of shell commands specifying a
var of the same value."
  (format org-babel-sh-var-quote-fmt
	  (org-babel-sh-var-to-string var sep hline)))

(defun org-babel-sh-var-to-string (var &optional sep hline)
  "Convert an elisp value to a string."
  (let ((echo-var (lambda (v) (if (stringp v) v (format "%S" v)))))
    (cond
     ((and (listp var) (or (listp (car var)) (equal (car var) 'hline)))
      (orgtbl-to-generic var  (list :sep (or sep "\t") :fmt echo-var
				    :hline hline)))
     ((listp var)
      (mapconcat echo-var var "\n"))
     (t (funcall echo-var var)))))

(defun org-babel-sh-table-or-results (results)
  "Convert RESULTS to an appropriate elisp value.
If the results look like a table, then convert them into an
Emacs-lisp table, otherwise return the results as a string."
  (org-babel-script-escape results))

(defun org-babel-sh-initiate-session (&optional session params)
  "Initiate a session named SESSION according to PARAMS."
  (when (and session (not (string= session "none")))
    (save-window-excursion
      (or (org-babel-comint-buffer-livep session)
          (progn (shell session) (get-buffer (current-buffer)))))))

(defvar org-babel-sh-eoe-indicator "echo 'org_babel_sh_eoe'"
  "String to indicate that evaluation has completed.")
(defvar org-babel-sh-eoe-output "org_babel_sh_eoe"
  "String to indicate that evaluation has completed.")

(defun org-babel-sh-evaluate (session body &optional params stdin cmdline)
  "Pass BODY to the Shell process in BUFFER.
If RESULT-TYPE equals 'output then return a list of the outputs
of the statements in BODY, if RESULT-TYPE equals 'value then
return the value of the last statement in BODY."
  (let ((results
         (cond
          ((or stdin cmdline)	       ; external shell script w/STDIN
           (let ((script-file (org-babel-temp-file "sh-script-"))
                 (stdin-file (org-babel-temp-file "sh-stdin-"))
                 (shebang (cdr (assoc :shebang params)))
                 (padline (not (string= "no" (cdr (assoc :padline params))))))
             (with-temp-file script-file
               (when shebang (insert (concat shebang "\n")))
               (when padline (insert "\n"))
               (insert body))
             (set-file-modes script-file #o755)
             (with-temp-file stdin-file (insert (or stdin "")))
             (with-temp-buffer
               (call-process-shell-command
                (if shebang
                    script-file
                  (format "%s %s" org-babel-sh-command script-file))
                stdin-file
                (current-buffer) nil cmdline)
               (buffer-string))))
          (session                      ; session evaluation
           (mapconcat
            #'org-babel-sh-strip-weird-long-prompt
            (mapcar
             #'org-babel-trim
             (butlast
              (org-babel-comint-with-output
                  (session org-babel-sh-eoe-output t body)
                (mapc
                 (lambda (line)
                   (insert line)
                   (comint-send-input nil t)
                   (while (save-excursion
                            (goto-char comint-last-input-end)
                            (not (re-search-forward
                                  comint-prompt-regexp nil t)))
                     (accept-process-output
                      (get-buffer-process (current-buffer)))))
                 (append
                  (split-string (org-babel-trim body) "\n")
                  (list org-babel-sh-eoe-indicator))))
              2)) "\n"))
          ('otherwise                   ; external shell script
           (if (and (cdr (assoc :shebang params))
                    (> (length (cdr (assoc :shebang params))) 0))
               (let ((script-file (org-babel-temp-file "sh-script-"))
                     (shebang (cdr (assoc :shebang params)))
                     (padline (not (equal "no" (cdr (assoc :padline params))))))
                 (with-temp-file script-file
                   (when shebang (insert (concat shebang "\n")))
                   (when padline (insert "\n"))
                   (insert body))
                 (set-file-modes script-file #o755)
                 (org-babel-eval script-file ""))
             (org-babel-eval org-babel-sh-command (org-babel-trim body)))))))
    (when results
      (let ((result-params (cdr (assoc :result-params params))))
        (org-babel-result-cond result-params
          results
          (let ((tmp-file (org-babel-temp-file "sh-")))
            (with-temp-file tmp-file (insert results))
            (org-babel-import-elisp-from-file tmp-file)))))))

(defun org-babel-sh-strip-weird-long-prompt (string)
  "Remove prompt cruft from a string of shell output."
  (while (string-match "^% +[\r\n$]+ *" string)
    (setq string (substring string (match-end 0))))
  string)

(provide 'ob-shell)



;;; ob-shell.el ends here
