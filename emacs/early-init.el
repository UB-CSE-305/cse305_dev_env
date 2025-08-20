;; early-init.el --- Initialization before system startup -*- lexical-binding: t -*-

;; Copyright 2022-2024 Ethan Blanton

;;                           *** NOTICE ***
;; =====================================================================
;; Normal Emacs configuration goes in init.el, you probably want to
;; edit that file instead of this one!
;; =====================================================================

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

;; You do not need to change or understand this file!

;;; Code:

;; Emacs Lisp is a garbage collected language.  This is great, but
;; Emacs initialization creates a large amount of garbage, and garbage
;; collection runs frequently during startup.  We can increase the
;; amount of memory allowed for allocation before the garbage
;; collector is invoked to speed up initialization.  We want to
;; restore it for normal operation, however.

(setq gc-cons-threshold (* 1024 1024 100))     ; 100 MB

(defun reduce-gc-cons-threshold-after-startup ()
  "Reduce the garbage collector allocation limit to a reasonable value.
The default value is 800 kB, which is very small now.  10 MB should be
a good compromise between performance and conservative memory use."
  (setq gc-cons-threshold (* 1024 1024 10)))  ; 10 MB

(add-hook 'emacs-startup-hook #'reduce-gc-cons-threshold-after-startup)

;; Emacs 28.1 introduced native code compilation of Emacs lisp, which
;; speeds up Emacs considerably for some operations.  However, the
;; native code compiler is picky (and therefore complains a lot) and
;; produces a bunch of temporary files that we don't necessarily need
;; or want cluttering up our Emacs config directory.

(when (featurep 'native-compile)
  ;; Quiet complaints from the JIT
  (setq native-comp-async-report-warnings-errors 'silent)

  ;; Move native compilation files to ~/.cache/emacs instead of ~/.emacs.d
  ;; Note that this probably only works on a Unix-like system
  (let ((cachedir (expand-file-name ".cache/emacs/eln-cache" (getenv "HOME"))))
    ;; Emacs 29 will have a safe way to do this.
    (if (fboundp 'startup-redirect-eln-cache)
	(startup-redirect-eln-cache cachedir)
      (setcar native-comp-eln-load-path cachedir))))

;;; early-init.el ends here
