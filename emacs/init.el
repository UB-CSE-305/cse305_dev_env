;; init.el --- Emacs Configuration -*- lexical-binding: t -*-

;; Copyright 2022-2024 Ethan Blanton

;;; License:

;; This file is licensed under the following terms:

;; Permission to use, copy, modify, and/or distribute this software
;; for any purpose with or without fee is hereby granted.

;; The software is provided "as is" and the author disclaims all
;; warranties with regard to this software including all implied
;; warranties of merchantability and fitness. In no event shall the
;; author be liable for any special, direct, indirect, or
;; consequential damages or any damages whatsoever resulting from loss
;; of use, data or profits, whether in an action of contract,
;; negligence or other tortious action, arising out of or in
;; connection with the use or performance of this software.

;;; Commentary:

;; Provided by CSE 220 course staff at the University at Buffalo

;; This file contains a relatively minimal Emacs configuration that
;; provides most of the niceties of a modern editing environment such
;; as on-the-fly warnings and errors and code completion.  It is
;; usable as it is, but the power of Emacs is that you can easily
;; create your own custom configuration!

;; YOU MAY NOT WANT TO EDIT THIS FILE.  At the end, it will load the
;; file `user.el' in this directory.  Editing this file will make it
;; more difficult to integrate future changes from course staff.

;;; Code:

;;; Identify ourselves

;; This function serves only to show whether or not this config has
;; been loaded.  If it can be invoked with `M-x', then this
;; configuration is active.

(defun ub-cse-info ()
  "Print a message to the minibuffer."
  (interactive)
  (message "ub-cse config is loaded"))

;;; Old version compatibility

;; Some CSE machines have VERY old versions of Emacs.  This
;; configuration file attempts to deal with this in a way that is
;; minimally annoying, by simply not installing or activating features
;; that don't work on old versions of Emacs, and activating everything
;; on newer versions.

;;; Some package bug workarounds

;; The treemacs package (which creates a project-based list of files
;; and directories along the left side like many IDEs use) supports
;; SVG icons, but our build of Emacs may not.  Version 3.1 of treemacs
;; (and maybe others) doesn't handle this well.  Fortunately we can
;; fake it out.  This add-to-list basically says "I support SVG!", but
;; then later SVG loads will fail.  This might have other undesirable
;; side effects.
(when (and (boundp 'image-types)
           (not (memq 'svg image-types)))
  (add-to-list 'image-types 'svg))

;;; Set up package management

;; Not all Emacs packages are compatible with all Emacs versions; we
;; can control for this when installing packages, but, unfortunately,
;; once a package is installed, it will try to start on every version
;; of Emacs, regardless of whether it can be started or not.  We try
;; to mitigate this by creating a package directory per major Emacs
;; version.  If you install Emacs packages by hand and don't inform
;; your config (using package-install or use-package or similar), this
;; may cause weirdness on major version updates.
(setq package-user-dir
      (concat user-emacs-directory
	      "elpa-" (format "%d" emacs-major-version)))

;; Emacs contains a package manager that is accessed with
;; `list-packages'.  This configures a few extra repositories for that
;; package manager, sets up the package manager, and then uses it to
;; install a few packages that you probably want.

(require 'package)

(setq package-archives (append package-archives
                               '(("melpa-stable" . "https://stable.melpa.org/packages/")
				 ("melpa" . "https://melpa.org/packages/"))))

(package-initialize)

;; If we have never fetched the package index, do so now, so that the
;; default package set can be installed.
(unless package-archive-contents
  (package-refresh-contents))

;; Use `package-install' to install some packages that make the Emacs
;; experience more sophisticated.  Some of these require a newer
;; version of Emacs than is available on some CSE systems, so gate
;; them behind a check.

;; This doesn't normally have to be so complicated.

(dolist (pkg '(company eglot swiper vertico vertico-posframe treemacs
                       marginalia which-key))
  (condition-case ()
      (unless (package-installed-p pkg)
	(package-install pkg))
    (error nil)))

;;; Disable annoying stuff

;; By default, Emacs pops up a splash screen at startup, and we don't
;; need it.
(setq inhibit-startup-message t)

;; Emacs sometimes asks questions and expects and answer of "yes" or
;; "no", and sometimes asks a question and expects "y" or "n".
;; Setting this will cause it to use the short forms for almost
;; everything, which is both more consistent and less irritating.

;; The if is because old versions of Emacs don't have
;; `use-short-answers'.  For those, we change the function
;; `yes-or-no-p' to be `y-or-n-p' instead.  This is not ideal.
(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))

;; The toolbar is neither very useful nor very attractive, so disable
;; it.  You can re-enable it by changing this -1 to 1.  There are also
;; `menu-bar-mode' and `scroll-bar-mode', which disable menus and
;; scroll bars, respectively, but those may be valuable to new Emacs
;; users.
(tool-bar-mode -1)

;;; Enable desirable stuff

;; Enable more fonts and colors and decorations for code.
(setq font-lock-maximum-decoration t)

;; These two turn on line and column numbers in the mode line at the
;; bottom of the screen.
(line-number-mode 1)
(column-number-mode 1)

;; Show matching brackets and parentheses by highlighting both
;; elements of a pair when the cursor is adjacent.
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Insert brackets, parentheses, quotes, etc. in matching pairs, and
;; place the cursor between.
(electric-pair-mode 1)

;; When editing "program-like" files, display line numbers.  First we
;; create a function to turn on this feature, then we add it to the
;; hook called when prog-mode starts.  Most programming modes are
;; derived from prog-mode; `c-mode' certainly is.
(defun ub-cse-prog-mode ()
  (if (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode)
    (linum-mode 1)))

(add-hook 'prog-mode-hook #'ub-cse-prog-mode)

;; The following configurations often use `(when (require ...))'
;; forms.  This is because old versions of Emacs may not be able to
;; load these packages (see above).  With this form, the commands
;; inside are only invoked if the package can be successfully loaded.

;; Vertico provides candidates for completion for file names, buffers,
;; and other items in a vertical list, and the configured completion
;; styles allow for fuzzy matching.
(when (require 'vertico nil t)
 (setq completion-styles '(basic substring partial-completion flex)
       completion-ignore-case t
       read-file-name-completion-ignore-case t
       read-buffer-completion-ignore-case t)
 (vertico-mode 1))

;; Move many vertico completions to a box in the middle of the current
;; frame, instead of the minibuffer.
(when (require 'vertico-posframe nil t)
  ;; Provide a working vertico for terminal Emacs
  (setq vertico-posframe-fallback-mode #'vertico-buffer-mode)
  (vertico-posframe-mode 1))

;; The `gdb' debugger mode can provide much more information in its
;; default view, and `gdb-many-windows' enables this.  However, we
;; don't want to call it until gdb-mi is loaded, or we will get
;; errors.
;;
;; We can't use with-eval-after-load here because it isn't in the
;; Emacs on timberlake.
(eval-after-load "gdb-mi"
  (lambda ()
    (setq gdb-restore-window-configuration-after-quit t)
    (gdb-many-windows)))

;; COMPlete ANYthing provides completion for most things by pressing
;; TAB.  Enabling `global-company-mode' will turn this behavior on in
;; almost all buffers and modes.
(when (require 'company nil t)
  (global-company-mode))

;; Versions of clangd < 12 have a bug where they insert C++ headers
;; into C files: https://github.com/clangd/clangd/issues/780
;;
;; This function retrieves the version of the currently-available
;; clangd and returns it as a string.
(defun extract-clangd-version ()
  (with-temp-buffer
    (call-process "clangd" nil t nil "--version")
    (goto-char (point-min))
    (let* ((version-string (buffer-substring (point) (point-at-eol)))
	   (words (split-string version-string)))
      (cl-loop for subwords on words do
               (when (and (string= (car subwords) "version")
			  (string-match "^\\([0-9.]+\\).*$" (cadr subwords)))
		 (cl-return (match-string 1 (cadr subwords))))))))

;; Emacs polyGLOT uses the Microsoft Language Server Protocol to
;; provide a variety of features for code navigation, communication of
;; warnings and errors, code completion, etc. in any language with a
;; known language server.
(when (require 'eglot nil t)
  ;; Check the version of clangd and disable header insertion if it is
  ;; a buggy version that will insert C++ headers into C file.  Thanks
  ;; to Victoria for figuring this out.
  (when (version< (extract-clangd-version) "12")
    (add-to-list 'eglot-server-programs
		 '(c-mode . ("clangd" "--header-insertion=never"))))
  (add-hook 'c-mode-hook #'eglot-ensure))

;; Marginalia makes things like M-x and the describe- functions
;; provide much more context to their minibuffer completion.  In
;; conjunction with vertico, for example, `C-h v' and a few characters
;; of the variable you're looking for may tell you everything you need
;; to know, and you won't even have to select it.
(when (require 'marginalia nil t)
  (marginalia-mode))

;; Which-key provides preemptive assistance when the user presses the
;; beginning of a multi-key sequence and then pauses; for example, if
;; you press C-x but don't press the next key, which-key will pop up a
;; table of possible next keys with the commands to which they are
;; bound at the bottom of the screen.
(when (require 'which-key nil t)
  (which-key-mode))

;;; Default indentation style

;; This indentation style matches the style used by many UB courses,
;; including CSE 220.
(c-add-style "ub-cse"
	     '((c-basic-offset . 4)
	       (indent-tabs-mode . nil)
	       (c-hanging-braces-alist
		(defun-open        after)
		(defun-close       before)
		(defun-block-intro after)
		(class-open        after)
		(class-close       before)
		(inline-open       after)
		(inline-close      before)
		(block-open        after)
		(block-close       before)
		(substatement-open after)
		(extern-lang-open  after)
		(extern-lang-close before))
	       (c-offsets-alist
		(statement-block-intro . +)
		(label                 . 0)
		(case-label            . 0))))

;; This causes the ub-cse style to be used for any languages that
;; don't have a specifically-configured style; this will, by default,
;; include C, C++, Objective-C, etc.
(setcdr (assoc 'other c-default-style) "ub-cse")

;;; Load a reasonable theme

;; The default Emacs look is ugly.  Protesilaos Stavrou authored the
;; Modus themes, which are available in Emacs as of Emacs 28.1.  The
;; themes modus-operandi and modus-vivendi are light and dark
;; variants, respectively.

;; There are MANY themes for Emacs available in the package
;; repository.  You may find the `ef-themes' or `sublime-themes'
;; packages a good place to start to find a variety of usable themes.

;; Load modus if either our Emacs is new enough to include it, or the
;; package is installed.
(when (or (version<= "28" emacs-version) (require 'modus-themes nil t))
  (setq modus-themes-syntax '(alt-syntax green-strings)
        modus-themes-italic-constructs t
        modus-themes-mode-line '(accented)
        modus-themes-variable-pitch-ui nil)

  ;; Try changing 'modus-vivendi to 'modus-operandi for a light theme.
  (load-theme 'modus-vivendi))

;;; Key bindings

;; If pressing TAB to indent doesn't change anything, try completing.
(setq tab-always-indent 'complete)

;; Swiper is a more visual, but slower, search function than the
;; built-in isearch.  It will provide a list of matching lines in the
;; minibuffer.
(when (require 'swiper nil t)
  (global-set-key (kbd "C-s") #'swiper-isearch)
  (global-set-key (kbd "C-r") #'swiper-isearch-backward))

;; For modes that are strongly line-oriented and likely to have
;; repeating hits on the same line, swiper is more graceful than
;; swiper-isearch.  As an example, dired (the Emacs file management
;; mode).  Note that, as above, some CSE systems do not have
;; with-eval-after-load, so we use eval-after-load.  Postponing
;; evaluation prevents an error that dired-mode-map does not exist, if
;; dired has not yet been loaded.
(eval-after-load "dired.el"
  (lambda ()
    (define-key dired-mode-map (kbd "C-s") #'swiper)))

;; The Emacs default binding of C-z to `suspend-frame' is surprising,
;; particularly for users who expect C-z to be undo.  Provide a
;; replacement that suspends only at the terminal, and use that.

(defun cse-suspend-or-undo (&optional arg)
  "Suspend Emacs if the current frame is in a terminal, or undo."
  (interactive "*P")
  (if (eq (framep (selected-frame)) 't)
      (suspend-emacs)
    (undo arg)))

(global-set-key (kbd "C-z") #'cse-suspend-or-undo)

;; By default, Emacs doesn't provide much (really anything, in most
;; cases) in the way of a right-click menu.  In Emacs 28+,
;; `context-menu-mode' provides at least something.
(when (version<= "28" emacs-version)
  (context-menu-mode))

;;; Customizations

;; Emacs has a customization interface (available through the menus,
;; or via `customize') that allows various configuration options to be
;; changed and saved interactively.  By default it saves them to
;; init.el, which is not ideal.  We can, however, ask it to save them
;; to a different file.

;; Ask emacs not to litter this file with customizations
(setq custom-file (expand-file-name "emacs-custom.el" user-emacs-directory))
(load custom-file :noerror)

;;; Additional user configuration

;; If you would like to configure your Emacs without changing this
;; file (for example, so that you can easily restore it to its default
;; state), you can make your configuration changes by creating and
;; editing the file named `user.el'.

(let ((user-config-file (expand-file-name "user.el" user-emacs-directory)))
  (when (file-exists-p user-config-file)
    (load-file user-config-file)))

;;; init.el ends here
