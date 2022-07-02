(in-package :cliki)

;;; once upon a time, cliki the engine was simply the code that runs
;;; cliki the web site.  These days there are multiple users of cliki
;;; the engine, and not all of them want our exact CSSified layout and
;;; crass donation solicitation.

(defclass cliki-net (cliki-instance) ())

(defmethod cliki-css-text ((cliki cliki-net) stream)
  (call-next-method)
  (write-sequence "
#banner a:hover.logo { text-decoration: none }
#banner a.logo { border-width: 0px }
" stream))


(defmethod cliki-page-surround  ((cliki cliki-net) request function
				 &key title head)
  (cliki-page-header cliki request title head)
  (prog1
      (funcall function (request-stream request))
    (cliki-page-footer cliki request title)))

(defmethod check-page-save-allowed ((cliki cliki-net) page version user)
  (call-next-method) 
  (when (string-prefix-p "A N Other" user)
    (signal 'cliki-page-save-rejected "Anonymous posting is disabled.  Please provide a name (preferably your own")))




