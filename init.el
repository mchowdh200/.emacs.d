
(setq load-prefer-newer 1)

;; change default garbage collection threshold to something higher
(setq gc-cons-threshold 20000000)

;; set high gc limit for minibuffer so doesn't slowdown on helm etc
(defun minibuffer-setup ()
  "Setup minibuffer."
  (setq gc-cons-threshold most-positive-fixnum))
(defun minibuffer-exit ()
  "Undo minibuffer setup."
  (setq gc-cons-threshold 20000000))

(add-hook 'minibuffer-setup-hook #'minibuffer-setup)
(add-hook 'minibuffer-exit-hook #'minibuffer-exit)

;; automatically garbage collect when switch away from emacs
(add-hook 'focus-out-hook 'garbage-collect)

;;(add-to-list 'load-path "~/.emacs.d/elpa")
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa"))
;; (add-to-list 'load-path 
;;              (expand-file-name "~/.emacs.d/elpa/ob-ipython/"))

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)


(when (memq window-system '(mac ns))
  ;; use terminal path in OSX GUI app
  ;; (exec-path-from-shell-initialize)
  (setq font-backend 'ns)
  )

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package exec-path-from-shell
  :ensure t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Themes/Highlighting

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;; when running emacs as a daemon, certain themes fail to load properly.
;; this code will check for this and load theme after a frame is created
(setq my-theme 'spacemacs-dark)

(defun load-my-theme (frame)
  (select-frame frame)
  (load-theme my-theme t))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'load-my-theme)
  (load-theme my-theme t))

;; highlight matching parens
(show-paren-mode 1)
(setq show-paren-delay 0)

;; highlight different levels of parens when in a programming mode
;;(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; puts the underline below the font bottomline instead of the baseline
;;(setq x-underline-at-descent-line t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Font Settings


(defun set-fonts (basic-font header-font base-size)
  ;; Basic font
  (setq default-frame-alist
        `((font . ,(concat basic-font "-" (number-to-string base-size)))))

  ;; Comment Header custom fonts
  (defface header-1-face
    `((t (:font ,(concat header-font "-" (number-to-string (fround (* base-size 1.75))))
                ;;:inherit default
                :weight bold
                :slant oblique
                :underline t)))
    "Header face level 1"
    :group 'custom-faces)

  (defface header-2-face
    `((t (:font ,(concat header-font "-" (number-to-string (fround (* base-size 1.3))))
                ;;:inherit default
                :weight bold
                :slant oblique)))
    "Header face level 2"
    :group 'custom-faces)

  ;; Change font of function declarations
  (set-face-attribute
   'font-lock-function-name-face (selected-frame)
   :font (concat header-font "-" (number-to-string (fround (* base-size 1.2))))
   :weight 'bold
   :slant 'oblique
   :underline nil)

  ;; Change font of type declarations
  (set-face-attribute
   'font-lock-type-face (selected-frame)
   :font (concat header-font "-" (number-to-string (fround (* base-size 1.4))))
   :weight 'bold
   :slant 'oblique
   :underline nil)

  ;; Change font of error warning
  (set-face-attribute
   'font-lock-warning-face (selected-frame)
   :weight 'bold
   :underline nil)

)

;; Apply font settings
(if (memq window-system '(mac ns))
  ;; for macs
  (set-fonts "Fira Code Retina"
             ;; "Helvetica Neue"
             "Fira Code Retina"
             14)
  ;; for linux
  (set-fonts "Fira Code Retina"
             "Fira Code Retina"
             13))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; UI settings
;; Default Frame width
(add-to-list 'default-frame-alist '(width . 90))

;; disable cursor blink
(blink-cursor-mode 0)

;; highlight current line
;; (global-hl-line-mode 1)

;; disable toolbar menubar and scrollbar
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; disable splash screen
(setq inhibit-splash-screen 1
      inhibit-startup-echo-area-message 1
      inhibit-startup-message 1)

;; just use y or n not yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; show column number in the modeline
(setq column-number-mode 1)

;; show function name in the modeline
;; (which-function-mode 1)
;; (setq which-function-unknown "∅")

;; (set-face-attribute 'which-func (selected-frame)
;;  :inherit font-lock-keyword-face)


;; Scrolling Settings
(use-package smooth-scrolling
  :ensure t
  :config (setq smooth-scroll-margin 5)
  :init (smooth-scrolling-mode 1))

(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

(setq mouse-wheel-scroll-amount '(2 ((shift) .2) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Tramp settings
(setq tramp-default-method "ssh")
(customize-set-variable 'tramp-syntax 'simplified)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File/buffer settings
;;;; TODO -- Organize this section better?

;; visualize the indentation level
(use-package indent-guide
  :ensure t
  :diminish indent-guide-mode
  :config
  (indent-guide-global-mode))

;; auto close brackets
(electric-pair-mode 1)

;; tabs insert spaces
(setq-default indent-tabs-mode nil)

;; default tab size
(setq-default tab-width 8)

;; default indentation level in cc mode
(add-hook 'c-mode-common-hook
          (lambda()
            (setq c-default-style "stroustrup" c-basic-offset 4)))

;; automatically refresh all buffers when files have changed on disk
(global-auto-revert-mode t)


;; hard line wrap at 80 chars
(set-fill-column 79)
(add-hook 'prog-mode-hook 'turn-on-auto-fill)
(add-hook 'prog-mode-hook (lambda () (set-fill-column 79)))

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook (lambda () (set-fill-column 79)))

;; dont soft wrap lines
(set-default 'truncate-lines t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Spaceline
;;;; The Spacemacs modeline
;; (use-package spaceline-config
;;   :ensure spaceline
;;   :config
;;   (spaceline-spacemacs-theme)
;;   (spaceline-toggle-hud-off)
;;   (setq spaceline-separator-dir-left '(right . right))
;;   (setq spaceline-separator-dir-right '(right . right))
;;   (setq ns-use-srgb-colorspace nil)
;;   (setq spaceline-highlight-face-func 'spaceline-highlight-face-modified)
;;   (add-hook 'emacs-startup-hook 'spaceline-compile)
;;   )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dashboard
;;;; Extraction of spacemacs' startup screen
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Helm
;;;; incremental completion and selection narrowing framework
(use-package helm
  :ensure t
  :diminish helm-mode
  :init
  (helm-mode 1)

  :config
  (setq helm-candidate-number-limit 100)

  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)


  (setq helm-M-x-fuzzy-match t)
  (setq helm-semantic-fuzzy-match t)
  (setq helm-imenu-fuzzy-match    t)

  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-z")  'helm-select-action)

  (helm-autoresize-mode 1))

(use-package helm-themes
  :ensure t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Projectile
(use-package projectile
  :ensure t
  :init (projectile-mode)
  :config (setq projectile-mode-line
                '(:eval (format " [%s]" (projectile-project-name)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Helm projectile
(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; keychord:
;;;; multi key mappings
(use-package key-chord
  :ensure t
  :config (key-chord-mode 1))


(use-package vterm
  :ensure t)

(use-package multi-vterm
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Multi Term
;; (use-package multi-term
;;   :ensure t
;;   :after evil
;;   :config
  
;;   ;; bring focus to terminal window after opening
;;   (setq multi-term-dedicated-select-after-open-p t)

;;   ;; Fix pasting into terminal
;;   (evil-define-key 'normal term-raw-map "p" 'term-paste)
;;   (evil-define-key 'insert term-raw-map (kbd "s-v") 'term-paste)

;;   ;; fix terminal tab completions
;;   (add-hook 'term-mode-hook (lambda()
;;                               (setq yas-dont-activate t)))
;;   (add-hook 'prog-mode-hook (lambda()
;;                               (setq yas-dont-activate nil))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; evil-mode settings
;;;; Vim like keybindings in emacs

(setq evil-search-module 'evil-search);; persistent search highlighting
(use-package evil
  :ensure t
  :after key-chord
  :config
  (evil-mode t)

  (global-undo-tree-mode)
  (evil-set-undo-system 'undo-tree)

  ;; remap the <space> key to :
  (define-key evil-normal-state-map (kbd "SPC") 'evil-ex)

  ;; remap the esc key to exit insert mode
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)

(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode)
  ;;(evil-leader/set-leader ",")
  (setq evil-leader/leader ",")

  ;; convenient map for M-x
  (evil-leader/set-key "m" 'helm-M-x)

  ;; move between windows in a frame
  (evil-leader/set-key
    "h" 'evil-window-left
    "j" 'evil-window-down
    "k" 'evil-window-up
    "l" 'evil-window-right)

  ;; toggle map for speedbar
  (evil-leader/set-key "y" 'sr-speedbar-toggle)

  ;; mapping for helm-find-files
  (evil-leader/set-key "f" 'helm-find-files)

  ;; toggle line numbers
  (evil-leader/set-key "n" 'display-line-numbers-mode)

  ;; open shell buffer
  (evil-leader/set-key "s" 'multi-vterm-dedicated-toggle)

  ;; highlight thing mode
  (evil-leader/set-key "t" 'highlight-thing-mode))

(use-package evil-commentary
  :ensure t
  :diminish evil-commentary-mode
  :config (evil-commentary-mode))


;; TODO Try to implement persistent evil-marks
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Custom Keywords
;;; prog-mode keywords
(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("\\<\\(TODO\\|DONE\\)" 1 font-lock-warning-face prepend
                )))))

;;; c-like language keywords
(add-hook 'c-mode-common-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^/// \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+/// \\(.*\\)" 1 'header-2-face prepend)
               ))))

;;; elisp keywords
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^;;; \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+;;; \\(.*\\)" 1 'header-2-face prepend)
               ("^;;;; \\(.*\\)" 1 'header-2-face prepend)
               ))))

;;; Haskell keywords
(add-hook 'haskell-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^--- \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+--- \\(.*\\)" 1 'header-2-face prepend)
               ("^---- \\(.*\\)" 1 'header-2-face prepend)
               ))))

;;; LaTeX keywords
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^%% \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+%% \\(.*\\)" 1 'header-2-face prepend)
               ("^%%% \\(.*\\)" 1 'header-2-face prepend)
               ))))

;;; MATLAB keywords
(add-hook 'matlab-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^%% \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+%% \\(.*\\)" 1 'header-2-face prepend)
               ("^%%% \\(.*\\)" 1 'header-2-face prepend)
               ("^\\s-+%%% \\(.*\\)" 1 'header-2-face prepend)
               ))))

;;; python keywords
(add-hook 'python-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^## \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+## \\(.*\\)" 1 'header-2-face prepend)
               ("^### \\(.*\\)" 1 'header-2-face prepend)
               ("^\\s-+### \\(.*\\)" 1 'header-2-face prepend)
               ;;("^class\\s-+\\(.*\\:\\)" 1 'header-2-face prepend)
               ))))

;;; shell keywords
(add-hook 'sh-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("^## \\(.*\\)" 1 'header-1-face prepend)
               ("^\\s-+## \\(.*\\)" 1 'header-2-face prepend)
               ("^### \\(.*\\)" 1 'header-2-face prepend)
               ("^\\s-+### \\(.*\\)" 1 'header-2-face prepend)
               ))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; flycheck Settings
;;(add-hook 'after-init-hook 'global-flycheck-mode)
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))

  ;; the default value was '(save idle-change new-line mode-enabled)
  ;; (setq flycheck-check-syntax-automatically '(save mode-enable))
  (setq flycheck-check-syntax-automatically '(mode-enabled save idle-change))
  (setq idle-update-delay 1)
  )

(add-hook 'c++-mode-hook
          (lambda () (setq flycheck-clang-language-standard "c++11")))
(add-hook 'c++-mode-hook
          (lambda() (setq flyckeck-clang-include-path
                          (list "/usr/local/Cellar/opencv3/3.1.0_1/include"))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Yasnippet
(use-package yasnippet
  :ensure t
  :diminish t
  :config
  (yas-global-mode 1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Company Mode

(use-package company
  :ensure t
  :config

  ;; enable company mode
  (add-hook 'after-init-hook 'global-company-mode)

  ;; documentation popups on idle
  (use-package company-quickhelp
    :ensure t
    :init
    (company-quickhelp-mode 1))

  ;;makes completion start automatically rather than waiting for 3 chars / 0.5sec
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 0))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Compile Settings
(global-set-key (kbd "<f5>") 'compile)
(add-hook 'compilation-mode-hook
          '(lambda ()
             (local-set-key (kbd "<f5>") 'kill-compilation)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; diminish
;;;; Suppress minor mode on the mode line
;; (require 'diminish)
(use-package diminish
  :config
  (diminish 'flycheck-mode)
  (diminish 'company-mode)
  (diminish 'auto-fill-function)
  (diminish 'auto-revert-mode)
  (diminish 'undo-tree-mode)
  (diminish 'highlight-thing-mode)
  (diminish 'yas-minor-mode)
  (diminish 'eldoc)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Python settings

(setq python-shell-interpreter "python3")

;; custom compile settings for python
(add-hook 'python-mode-hook
          (lambda ()
                   (set (make-local-variable 'compile-command)
                        (concat "python3 "
                                (file-relative-name buffer-file-name)))))
(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  :config
  (when (load "flycheck" t t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  )





(use-package conda
  :ensure t
  :config
  (setq conda-anaconda-home "~/anaconda3/")
  (conda-env-initialize-interactive-shells))

;; ipython notebooks
(use-package ein
  :ensure t)

;; sort python imports
(use-package py-isort
  :ensure t
  :diminish t)

;; snakemake syntax
(use-package snakemake-mode
  :ensure t)



;;; MATLAB settings
;; (load-library "matlab-load")
;; (use-package matlab
;;   :ensure t
;;   :config
;;   (setq matlab-shell-command-switches '("-nodesktop -nosplash"))

;;   (setq auto-mode-alist
;;         (cons '("\\.m$" . matlab-mode) auto-mode-alist))

;;   (add-hook 'matlab-mode-hook
;;             '(lambda ()
;;                (setq matlab-functions-have-end 1)))

;;   (add-hook 'matlab-mode-hook '(lambda ()
;;                                  (set-fill-column 79)))

;;   ;; (eval-after-load 'matlab
;;   ;;   '(define-key matlab-mode-map (kbd "<f5>") 'matlab-shell-save-and-go))
;;   (define-key matlab-mode-map (kbd "<f5>") 'matlab-shell-save-and-go)
;;   )




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LaTeX settings

;; Displays the pdf output of the .tex file in a neighboring split window
(use-package latex-preview-pane
  :ensure t
  :config
  (latex-preview-pane-enable))


(setq latex-run-command "pdflatex")

;; line wrap at 100 chars (did this separately for LaTeX because it seems
;; to redefine this upon entering LaTeX mode)
(add-hook 'LaTeX-mode-hook (lambda () (set-fill-column 100)))

;; autoclose math mode start and end chars
(add-hook 'plain-TeX-mode-hook
          (lambda()
            (set (make-variable-buffer-local 'TeX-electric-math) (cons "$" "$"))))
(add-hook 'LaTeX-mode-hook
          (lambda()
            (set (make-variable-buffer-local 'TeX-electric-math) (cons "$" "$"))))

;; check spelling for tex files
(dolist (hook '(LaTeX-mode-hook))
      (add-hook hook (lambda () (flyspell-mode 1))))

(setq TeX-parse-self t) ; Enable parse on load.
(setq TeX-auto-save t) ; Enable parse on save.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Org settings

;; Use the mouse for certain actions in org-mode
(use-package org-mouse)

;; startup without folds
(setq org-startup-folded nil)

(setq org-latex-listings t)
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-adapt-indentation t)
;; (setq org-odd-levels-only t)
(setq org-blank-before-new-entry t)
(setq org-image-actual-width nil)

;; use variable pitch fonts
;;(add-hook 'org-mode-hook (lambda () (variable-pitch-mode t)))

;; hide markup characters like *bold*, etc.
(setq org-hide-emphasis-markers t)

;; allow quotes in emphasis markup
(setcar (nthcdr 2 org-emphasis-regexp-components) " \t\r\n,\"")

;; allow for multiline emphasis markup
(setcar (nthcdr 4 org-emphasis-regexp-components) 100) 
(org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)

;; org-babel stuff
(setq org-confirm-babel-evaluate nil)
;; (setq org-src-fontify-natively t)
;; (setq org-src-tab-acts-natively t)
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)

;; org-babel ipython style code eval
(use-package ob-ipython
  :ensure t
  :config
  (setq ob-ipython-command "jupyter")
  (setq python-shell-unbuffered nil))


;; activate languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((ipython . t)
   ;; (matlab . t)
   ;; other languages..
   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Git settings
(use-package evil-magit
  :ensure t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Backup File Directory
(setq backup-by-copying t)
(setq delete-old-versions t)
(setq kept-old-versions 0)
(setq kept-new-versions 10)
(setq version-control t)
(let ((backup-dir (expand-file-name "backups" user-emacs-directory)))
  (setq backup-directory-alist (list (cons "." backup-dir))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auto-save Directory
(let ((auto-save-dir
       (file-name-as-directory
        (expand-file-name "autosave" user-emacs-directory))))
  (setq auto-save-list-file-prefix
        (expand-file-name ".saves-" auto-save-dir))
  (setq auto-save-file-name-transforms
        (list (list ".*" (replace-quote auto-save-dir) t))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Miscellaneous Settings
;; show the simplified dired view
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

;; suppress bell sound
(setq ring-bell-function 'ignore)

;; Make backups of files, even when they're in version control
;;(setq vc-make-backup-files t)

;; Don't save custom settings in init.el
(setq custom-file "~/.emacs.d/custom/custom-settings.el")
(load custom-file)

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:

(server-start)

(provide 'init)
;;; init.el ends here
