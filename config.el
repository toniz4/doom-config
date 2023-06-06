(setq user-full-name "Cássio Ribeiro Alves de Ávila"
      user-mail-address "cassioavila@protonmail.com")

;; (setq doom-font "Fantasque SansM Nerd Font:size=24")
(setq doom-font "GoMono Nerd Font Mono:pixelsize=20")

;; (remove-hook! 'after-setting-font-hook #'doom-init-all-the-icons-fonts-h)

;; (add-hook! 'after-setting-font-hook
;;   (defun doom-init-all-the-icons-fonts-h ()
;;     (when (fboundp 'set-fontset-font)
;;       (dolist (font (list doom-font
;;                           "Weather Icons"
;;                           "github-octicons"
;;                           "FontAwesome"
;;                           "all-the-icons"
;;                           "file-icons"
;;                           "Material Icons"))
;;         (set-fontset-font t 'unicode font nil 'append)))))

(setq tab-always-indent t)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")

(after! modus-themes
  (require-theme 'modus-themes)
  (setq modus-themes-org-blocks 'gray-background
        modus-themes-italic-constructs t
        ;; modus-themes-common-palette-overrides modus-themes-preset-overrides-intense
        ;; modus-themes-common-palette-overrides modus-themes-preset-overrides-intense
        )
  )

(load-theme 'modus-vivendi t)

(after! all-the-icons
  (setq all-the-icons-default-alltheicon-adjust 0
        all-the-icons-default-adjust 0
        all-the-icons-default-wicon-adjust 0
        all-the-icons-default-faicon-adjust 0
        all-the-icons-default-octicon-adjust 0
        all-the-icons-default-fileicon-adjust 0
        all-the-icons-default-material-adjust 0.05)
  (setq all-the-icons-scale-factor 0.75))

(after! hl-line
  (setq global-hl-line-modes nil))

(after! doom-modeline
  (setq doom-modeline-height 0))

(after! company
  (setq company-idle-delay 0.1)
  (setq company-selection-wrap-around t))

(after! lsp-mode
  ;; (defun fuck ()
  ;;   (message "%s" process-environment))
  ;; (add-hook! 'lsp-before-initialize-hook #'fuck)
  (setq lsp-dart-dap-flutter-hot-reload-on-save t))

;; (after! eglot
;;   (setq-default eglot-workspace-configuration
;;                 '(:pylsp (:plugins (:jedi_completion (:include_params t
;;                                                       :fuzzy t)
;;                                                      :pylint (:enabled :json-false)))
;;                   :dart_analysis_server (:closingLabels t))))

(after! dap-mode

  (dap-register-debug-template "Flutter :: Debug with custom env vars"
                               (list :type "flutter"
                                     :environment-variables '(("GRADLE_OPTS" . "-Dorg.gradle.project.android.aapt2FromMavenOverride=/nix/store/3svzmqsal084m2wffsj7drqk2kzi514c-android-sdk-env/share/android-sdk/build-tools/33.0.2/aapt2")))))

(after! dart-mode



  (defun flutter-hot-reload-if-running ()
    (when (flutter--running-p)
      (flutter-hot-reload)))

  (defun add-flutter-after-save-hook ()
    (add-hook! 'after-save-hook #'flutter-hot-reload-if-running))

  (defun set-flutter-sdk-dir ()
    (setq lsp-dart-flutter-sdk-dir (getenv "FLUTTER_SDK")))

  ;; (add-hook! 'dart-mode-hook #'set-flutter-sdk-dir #'add-flutter-after-save-hook)
  (add-hook! 'dart-mode-hook #'set-flutter-sdk-dir))

(after! cider
  (setq cider-clojure-cli-aliases ":dev")
  (remove-hook 'cider-mode-hook #'+clojure--cider-disable-completion))

(defun disable-lsp-completions ()
  (lsp-completion-mode -1)
  (setq-local lsp-completion-enable nil))

(after! '(clojure-mode clojurec-mode clojurescript-mode clojurex-mode)
  #'disable-lsp-completions)

(after! lsp-mode
  (set-popup-rule! " out\\*\\'" :side 'right)
  (add-hook! 'lsp-clojure-lsp-after-open-hook #'disable-lsp-completions))

(after! emms
  (setq emms-source-file-default-directory "/mnt/extern/music/")
  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async)
  (setq emms-browser-thumbnail-small-size 128)
  (setq emms-browser-thumbnail-medium-size 192)
  (setq emms-player-list '(emms-player-mpd))

  (defun my-emms-browser-format-line (bdata &optional target)
    "Return a propertized string to be inserted in the buffer."
    (unless target
      (setq target 'browser))
    (let* ((name (or (emms-browser-bdata-name bdata) "misc"))
           (level (emms-browser-bdata-level bdata))
           (type (emms-browser-bdata-type bdata))
           (indent (emms-browser-make-indent level))
           (track (emms-browser-bdata-first-track bdata))
           (path (concat emms-source-file-default-directory "/"
                         (emms-track-get track 'name)))
           (face (emms-browser-get-face bdata))
           (format (emms-browser-get-format bdata target))
           (props (list 'emms-browser-bdata bdata))
           (format-choices
            `(("i" . ,indent)
              ("n" . ,name)
              ("y" . ,(emms-track-get-year track))
              ("A" . ,(emms-track-get track 'info-album))
              ("a" . ,(emms-track-get track 'info-artist))
              ("C" . ,(emms-track-get track 'info-composer))
              ("p" . ,(emms-track-get track 'info-performer))
              ("t" . ,(emms-track-get track 'info-title))
              ("D" . ,(emms-browser-disc-number track))
              ("T" . ,(emms-browser-track-number track))
              ("d" . ,(emms-browser-track-duration track))))
           str)
      (when (equal type 'info-album)
        (setq format-choices (append format-choices
                                     `(("cS" . ,(emms-browser-get-cover-str path 'small))
                                       ("cM" . ,(emms-browser-get-cover-str path 'medium))
                                       ("cL" . ,(emms-browser-get-cover-str path 'large))))))

      (when (functionp format)
        (setq format (funcall format bdata format-choices)))

      (setq str
            (with-temp-buffer
              (insert format)
              (goto-char (point-min))
              (let ((start (point-min)))
                ;; jump over any image
                (when (re-search-forward "%c[SML]" nil t)
                  (setq start (point)))
                ;; jump over the indent
                (when (re-search-forward "%i" nil t)
                  (setq start (point)))
                (add-text-properties start (point-max)
                                     (list 'face face)))
              (buffer-string)))

      (setq str (emms-browser-format-spec str format-choices))

      ;; give tracks a 'boost' if they're not top-level
      ;; (covers take up an extra space)
      (when (and (eq type 'info-title)
                 (not (string= indent "")))
        (setq str (concat " " str)))

      ;; if we're in playlist mode, add a track
      (when (and (eq target 'playlist)
                 (eq type 'info-title))
        (setq props
              (append props `(emms-track ,track))))

      ;; add properties to the whole string
      (add-text-properties 0 (length str) props str)
      str))

  (advice-add 'emms-browser-format-line :override #'my-emms-browser-format-line))

(after! lispy
  (setq lispyville-key-theme
        '(slurp/barf-lispy operators c-w additional commentary)))

;; (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)

;; (after! electric
;;   (add-hook! 'prog-mode-hook
;;     (electric-pair-local-mode t)))

(after! smartparens
  (sp-local-pair 'dart-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
  (sp-local-pair 'dart-mode "(" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))

  (defun my-create-newline-and-enter-sexp (&rest _ignored)
    "Open a new brace or bracket expression, with relevant newlines and indent. "
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode)))

;; (after! tramp
;;   (connection-local-set-profile-variables
;;    'remote-without-auth-sources '((auth-sources . nil)))

;;   (connection-local-set-profiles
;;    '(:application tramp) 'remote-without-auth-sources))

(after! eldoc
  (setq eldoc-echo-area-use-multiline-p nil
        eldoc-echo-area-display-truncation-message nil))
