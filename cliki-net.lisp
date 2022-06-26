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

.search
{ 
  float: right; 
  padding:  1em 0 0;
}
" stream))


(defmethod cliki-page-surround  ((cliki cliki-net) request function
				 &key title head)
  (let* ((stream (request-stream request))
	 (page (find-page cliki title))
         (home (cliki-url-root cliki)))
    (format stream
	    "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">~%")
    (labels ((ahref (l) (urlstring (merge-url home l)))) 
      (html-stream
       stream
       `(html
	 (head ((meta :charset "UTF-8"))
	       (title ,(format nil "CLiki : ~A" title))
	       ,@head
	       ((link :rel "alternate"
		      :type "application/rss+xml"
		      :title "Recent Changes"
		      :href ,(ahref  "recent-changes.rdf")))
	       ((link :rel "stylesheet" :href ,(ahref "admin/cliki.css"))))
	 (body
	  ((form  :action ,(ahref "admin/search"))
	   ((div :id "banner")
	    ((span :class "search")
	     ((input :name "words" :size "30"))
	     ((input :type "submit" :value "search")))
	    ((a :title "CLiki home page" :class "logo" :href ,(ahref nil))
	     "CL" ((span :class "sub") "iki"))
	    "the common lisp wiki"
	    (br)
	    ((div :id "navbar")
	     ((a :href ,(ahref (cliki-default-page-name cliki))) "Home")
	     ((a :href ,(ahref "Recent%20Changes")) "Recent Changes")
	     ((a :href ,(ahref "CLiki")) "About CLiki")
	     ((a :href ,(ahref "Text%20Formatting")) "Text Formatting")
	     ((a :onclick ,(format nil "if(name=window.prompt('New page name ([A-Za-z0-9 ])')) document.location='~a'+name ;return false;" (ahref "edit/" ))
		 :href "#" )
	      "Create New Page"))))
	  (h1 ,title)
	  ,function
	  ,@(if page
		  `(((div :id "footer")
		     ((a :href 
			 ,(if page (format nil "edit/~A?v=~A"
					   (urlstring-escape title)
					   (request-for-version page request))
			      (format nil "edit/~A"
				      (urlstring-escape title))))
		      "Edit page")
		     " | " 
		     ((a :href ,(format nil "~A?source"
					(urlstring-escape title)))
		      "View source")
		     " | Revisions: "
		     ,@(version-links cliki page request)))

		  '(((div :id "footer") (br))))
	  (p "CLiki pages can be edited by anyone at any time.  Imagine a fearsomely comprehensive disclaimer of liability.  Now fear, comprehensively")
	  ))))))

(defmethod check-page-save-allowed ((cliki cliki-net) page version user)
  (call-next-method) 
  (when (string-prefix-p "A N Other" user)
    (signal 'cliki-page-save-rejected "Anonymous posting is disabled.  Please provide a name (preferably your own")))




