;;; ob-twoslash.el --- Org-babel functions for Twoslash  -*- lexical-binding: t; -*-

;; Author: violet
;; Keywords: literate programming, typescript, twoslash
;; Package-Requires: ((emacs "27.1") (org "9.0"))

;;; Commentary:

;; Org Babel backend for TypeScript Twoslash.  Executes code blocks
;; through the Twoslash engine via Docker and returns type information
;; and errors.

;;; Code:
(require 'ob)
(require 'ob-eval)

(add-to-list 'org-babel-tangle-lang-exts '("twoslash" . "ts"))

(defvar org-babel-default-header-args:twoslash '((:results . "output")))

(defvar ob-twoslash-docker-image "ob-twoslash"
  "Docker image name for the twoslash runner.")

(defun ob-twoslash--ensure-image ()
  "Ensure the Docker image exists, build if needed."
  (unless (= 0 (call-process "docker" nil nil nil
                              "image" "inspect" ob-twoslash-docker-image))
    (let ((pkg-dir (file-name-directory (or load-file-name buffer-file-name))))
      (message "ob-twoslash: building Docker image...")
      (let ((ret (call-process "docker" nil "*ob-twoslash-build*" nil
                               "build" "-t" ob-twoslash-docker-image pkg-dir)))
        (unless (= 0 ret)
          (error "ob-twoslash: docker build failed, see *ob-twoslash-build* buffer"))))))

(defun org-babel-execute:twoslash (body params)
  "Execute a Twoslash code block BODY with PARAMS."
  (ob-twoslash--ensure-image)
  (let ((tmp-file (org-babel-temp-file "twoslash-" ".ts")))
    (with-temp-file tmp-file
      (insert body))
    (org-babel-eval
     (format "docker run --rm -i %s < %s"
             (shell-quote-argument ob-twoslash-docker-image)
             (shell-quote-argument tmp-file))
     "")))

(defun org-babel-prep-session:twoslash (_session _params)
  "Twoslash does not support sessions."
  (error "Twoslash does not support sessions"))

(provide 'ob-twoslash)
;;; ob-twoslash.el ends here
