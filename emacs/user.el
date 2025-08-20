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

;; Tuareg: an Emacs OCaml mode
;; https://github.com/ocaml/tuareg
(use-package tuareg
  :ensure t
  :mode (("\\.ocamlinit\\'" . tuareg-mode)))

;; Ocaml-eglot provides some ootb features
;; https://github.com/tarides/ocaml-eglot/blob/main/README.md
(use-package ocaml-eglot
  :ensure t
  :after tuareg
  :hook
  (tuareg-mode . ocaml-eglot)
  (ocaml-eglot . eglot-ensure)
  :config
  (setq ocaml-eglot-syntax-checker 'flymake))

;; Enable ocamlformat format-on-save
(add-hook 'tuareg-mode-hook (lambda ()
  (define-key tuareg-mode-map (kbd "C-M-<tab>") #'ocamlformat)
  (add-hook 'before-save-hook #'ocamlformat-before-save)))

(use-package dune
  :ensure t)

(use-package opam-switch-mode
  :ensure t
  :hook
  (tuareg-mode . opam-switch-mode))

(use-package ocp-indent
  :ensure t
  :config
  (add-hook 'ocaml-eglot-hook 'ocp-setup-indent))
