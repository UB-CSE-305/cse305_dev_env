;; Load opam config file
(let ((opam-config-file (expand-file-name "opam-emacs.el" user-emacs-directory)))
  (when (file-exists-p opam-config-file)
    (load-file opam-config-file)))

;; Configure Flymake for verbose diagnostics
(use-package flymake
  :ensure t
  :pin gnu
  :config
  (setq flymake-diagnostic-format-alist
        '((t . (origin code message)))))

;; neocaml
;; https://github.com/bbatsov/neocaml
(use-package neocaml
  :ensure t)

;; Ocaml-eglot provides some ootb features
;; https://github.com/tarides/ocaml-eglot/blob/main/README.md
(use-package ocaml-eglot
  :ensure t
  :after neocaml
  :hook
  (neocaml-mode . ocaml-eglot-mode)
  (ocaml-eglot-mode . eglot-ensure)
  (ocaml-eglot-mode . (lambda () (add-hook #'before-save-hook #'eglot-format nil t)))
  :config
  (setq ocaml-eglot-syntax-checker 'flymake))

(use-package dune
  :ensure t)

(use-package opam-switch-mode
  :ensure t
  :hook
  (neocaml-base-mode . opam-switch-mode))
