(in-package :cliki)

(defparameter *html-entities*
  '((#\< . "lt")
    (#\> . "gt")
    (#\& . "amp")
    (#\" . "quot")))

(defun html-entity-char-p (char)
  (assoc char *html-entities* :test #'eql))

(defun html-entity-position (string &key (start 0))
  (position-if #'html-entity-char-p string :start start))

(defun html-entity-substitute (char)
  (cdr (assoc char *html-entities* :test #'eql)))

(defun html-escape (string)
  (html-escape-aux string 0 nil))

;; Don't cons up a whole new string if we end up not doing any
;; substitution.

(defun html-escape-aux (string start buffer)
  (let ((pos (html-entity-position string :start start)))
    (if (null pos)
	(if (null buffer)
	    string
	    (concatenate 'string
			 buffer
			 (subseq string start)))
	(html-escape-aux string
			 (+ pos 1)
			 (concatenate 'string
				      (or buffer "")
				      (subseq string start pos)
				      "&"
				      (html-entity-substitute (char string pos))
				      ";")))))


(defclass escape-html-stream (buffered-output-stream)
  ((output-stream :initarg :output-stream
		  :accessor escape-html-stream-output-stream)))

(defmethod buffered-output-stream-write-buffer ((stream escape-html-stream)
						&optional force-p)
  (let ((b (buffered-output-stream-buffer stream))
	(out (escape-html-stream-output-stream stream)))
    (if force-p
	;; Not sure of semantics of force-p.  Just transform the whole
	;; buffer and write it out?  May be more consy.
	(progn
	  (write-sequence (html-escape b) out)
	  (length b))
	(let ((pos (html-entity-position b)))
	  (if (null pos)
	      ;; No entities to substitute.
	      (length (write-sequence b out))
	      ;; Found one.
	      (let ((entity (html-entity-substitute (elt b pos))))
		(write-sequence b out :end pos)
		(write-char #\& out)
		(write-string entity out)
		(write-char #\; out)
		(+ pos 1)))))))
