(setq cider-extensions-source-file-path (concat (file-name-directory load-file-name)
                                                "src/cider_extensions/core.clj"))

(defun cider-extensions-load-cider-extensions ()
  (interactive)
  (when (and (cider-connected-p)
             (file-exists-p cider-extensions-source-file-path))
    (message "loading cider-extensions")
    (cider-load-file cider-extensions-source-file-path)))

(add-hook 'cider-repl-mode-hook
          'cider-extensions-load-cider-extensions)

(defun cider-extensions-thread-first-completions ()
  "Offer completion for map keys at point based on CIDER runtime value."
  (interactive)
  (cider-interactive-eval (format "(cider-extensions.core/thread-first-completions (quote %s))"
                                  (cider-list-at-point))
                          (nrepl-make-response-handler (current-buffer)
                                                       (lambda (buffer value-string)
                                                         (message value-string)
                                                         (let ((value (read value-string)))
                                                           (if (listp value)
                                                               (with-current-buffer buffer
                                                                 (insert (first (helm :sources
                                                                                      (helm-build-sync-source "->"
                                                                                        :candidates value)
                                                                                      :buffer "*helm cider map keys*"))
                                                                         ;; (completing-read "" value)
                                                                         ))
                                                             (cider-emit-into-popup-buffer (cider-popup-buffer cider-result-buffer nil 'clojure-mode 'ancillary)
                                                                                           value)
                                                             ;; (message value)
                                                             )))
                                                       (lambda (_buffer _output))
                                                       (lambda (_buffer err)
                                                         (cider-emit-interactive-eval-err-output err))
                                                       '())
                          nil
                          (cider--nrepl-print-request-plist fill-column)))
