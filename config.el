(menu-bar-mode -1)
(tool-bar-mode -1)

(setq ring-bell-function 'ignore)

(defun color-buffer (proc &rest args)
  (interactive)
  (with-current-buffer (process-buffer proc)
    (read-only-mode -1)
    (ansi-color-apply-on-region (point-min) (point-max))
    (read-only-mode 1)))

(load-theme 'tango-dark t)

(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)

(set-face-attribute 'default nil
  :family "Iosevka Nerd Font"
  :width 'normal
  :weight 'normal)


(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)
(set-frame-parameter nil 'alpha-background '75)
(add-to-list 'default-frame-alist '(alpha-background . 75))


(use-package magit
  :config (advice-add 'magit-process-filter :after #'color-buffer))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-completion
  :if (display-graphic-p)
  :after all-the-icons
  :hook (marginalia-mode . all-the-icons-completion-mode))

(use-package vertico
  :config (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config (marginalia-mode))

(use-package ctrlf
  :config (ctrlf-mode +1))

(use-package helpful
  :config (global-set-key (kbd "C-h f") #'helpful-callable)
  :config (global-set-key (kbd "C-h v") #'helpful-variable)
  :config (global-set-key (kbd "C-h x") #'helpful-command))

(use-package which-key
  :config (which-key-mode))

(use-package eglot
  :config (add-to-list 'eglot-server-programs '(nix-mode . ("nil"))))

(use-package corfu
  :config (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-separator ?\s)
  (corfu-quit-no-match t))


(use-package flycheck
  :config (global-flycheck-mode)
  :custom
  (flycheck-pylintrc "~/mx/mixrank/etc/pylint/default.rc"))

(use-package nix-mode
  :hook (nix-mode . eglot-ensure))

(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(add-hook 'rust-ts-mode-hook #'eglot-ensure)
(add-hook 'python-ts-mode-hook #'eglot-ensure)
(add-hook 'python-ts-mode-hook #'flycheck-mode)


(use-package vterm
  :ensure t)

(use-package dashboard
  :ensure t
  :config (dashboard-setup-startup-hook)
  :custom
  (dashboard-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-startup-banner 3)
  (dashboard-set-footer nil)
  (dashboard-set-file-icons (display-graphic-p))
  (dashboard-set-heading-icons (display-graphic-p))
  (dashboard-agenda-time-string-format "%a %e de %b %t")
  (dashboard-items '((agenda . 10) (recents . 5) (bookmarks . 3)))
  (dashboard-agenda-prefix-format "%i %s")
  (dashboard-agenda-sort-strategy '(time-up)))

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package org
  :hook (org-mode . org-indent-mode)
  :config (define-key global-map "\C-ca" 'org-agenda)
  :config (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
  :custom
  (org-ellipsis " …")
  (org-hide-emphasis-markers t)
  (org-fontify-quote-and-verse-blocks t)
  (org-image-actual-width nil)
  (org-indirect-buffer-display 'other-window)
  (org-confirm-babel-evaluate nil)
  (org-edit-src-content-indentation 0)
  (org-agenda-files '("~/agenda.org"))
  (org-agenda-window-setup 'current-window)
  (org-agenda-restore-windows-after-quit t)
  (org-agenda-block-separator nil)
  (org-agenda-sticky t)
  (org-agenda-time-grid
      '((daily today require-timed)
        ()
        "......" "----------------"))
  :config
  (when (display-graphic-p)
      (setq org-agenda-category-icon-alist
       `(
	 ("Trabalho" ,(list (all-the-icons-material "work")) nil nil :ascent center)
	 ("Pessoal" ,(list (all-the-icons-material "account_box")) nil nil :ascent center)
	 ("Faculdade" ,(list (all-the-icons-material "school")) nil nil :ascent center)))))
