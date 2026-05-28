;; -*- lexical-binding: t; -*-
(setq cider-extensions-source-file-path (concat (file-name-directory load-file-name)
                                                "src/cider_extensions/core.clj"))

(defun cider-extensions-load-cider-extensions ()
  (interactive)
  (when (and (cider-connected-p)
             (file-exists-p cider-extensions-source-file-path))
    (message "loading cider-extensions")
    (cider-load-file cider-extensions-source-file-path)))

(add-hook 'cider-connected-hook
          'cider-extensions-load-cider-extensions)

(defun cider-extensions-autocompletions ()
  "Offer autocompletions cursor using the context around the cursor and the program runtime state."
  (interactive)
  (let ((accumulated-value ""))
    (cider-interactive-eval (format "(cider-extensions.core/autocompletions (quote %s) (quote %s))"
                                    (cider-list-at-point)
                                    (ignore-errors (save-excursion
                                                     (up-list 2 t t)
                                                     (cider-sexp-at-point))))
                            (nrepl-make-response-handler (current-buffer)
                                                         ;; value handler: accumulate chunks
                                                         (lambda (buffer value-string)
                                                           (setq accumulated-value (concat accumulated-value value-string)))
                                                         (lambda (_buffer _output))
                                                         (lambda (_buffer err)
                                                           (cider-emit-interactive-eval-err-output err))
                                                         ;; done handler: process the complete accumulated value
                                                         (lambda (buffer)
                                                           (when (not (equal "nil" accumulated-value))
                                                             (let ((value (read accumulated-value)))
                                                               (if (listp value)
                                                                   (with-current-buffer buffer
                                                                     (insert (ivy-read "Choose: " value)))
                                                                 (cider-emit-into-popup-buffer (cider-popup-buffer cider-result-buffer nil 'clojure-mode 'ancillary)
                                                                                               value))))))
                            nil
                            (cider--nrepl-print-request-plist fill-column))))
