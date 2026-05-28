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

(defvar-local cider-extensions--accumulated-value nil
  "Buffer-local variable to accumulate nREPL value response chunks.")

(defvar-local cider-extensions--callback nil
  "Buffer-local variable holding the callback for the current accumulating handler.")

(defun cider-extensions-accumulating-handler (buffer callback)
  "Return an nREPL response handler for BUFFER that accumulates value chunks.
When the response is done, calls CALLBACK with BUFFER and the complete
accumulated value string."
  (setq cider-extensions--accumulated-value "")
  (setq cider-extensions--callback callback)
  (nrepl-make-response-handler buffer
                               ;; value handler: accumulate chunks
                               (lambda (buffer value-string)
                                 (with-current-buffer buffer
                                   (setq cider-extensions--accumulated-value
                                         (concat cider-extensions--accumulated-value value-string))))
                               (lambda (_buffer _output))
                               (lambda (_buffer err)
                                 (cider-emit-interactive-eval-err-output err))
                               ;; done handler: call callback with the complete value
                               (lambda (buffer)
                                 (with-current-buffer buffer
                                   (funcall cider-extensions--callback buffer cider-extensions--accumulated-value)))))

(defun cider-extensions-cider-eval (expr callback)
  "Evaluate EXPR via nREPL and call CALLBACK with the result value string.
CALLBACK is called with two arguments: BUFFER and the complete accumulated
value string."
  (cider-interactive-eval expr
                          (cider-extensions-accumulating-handler (current-buffer)
                                                                 callback)
                          nil
                          (cider--nrepl-print-request-plist fill-column)))

(defun cider-extensions-autocompletions ()
  "Offer autocompletions cursor using the context around the cursor and the program runtime state."
  (interactive)
  (cider-extensions-cider-eval (format "(cider-extensions.core/autocompletions (quote %s) (quote %s))"
                                       (cider-list-at-point)
                                       (ignore-errors (save-excursion
                                                        (up-list 2 t t)
                                                        (cider-sexp-at-point))))
                               (lambda (buffer value-string)
                                 (when (not (equal "nil" value-string))
                                   (let ((value (read value-string)))
                                     (if (listp value)
                                         (with-current-buffer buffer
                                           (insert (ivy-read "Choose: " value)))
                                       (cider-emit-into-popup-buffer (cider-popup-buffer cider-result-buffer nil 'clojure-mode 'ancillary)
                                                                     value)))))))
