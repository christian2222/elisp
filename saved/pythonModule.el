(provide 'pythonModule)

;; search text in strFile between (!) beginPattern and endPattern
(defun findPatternInFile (strFile beginPattern endPattern)




					; open the file
  (find-file strFile)
  (switch-to-buffer strFile)
					; got to the beginning of file
  (goto-char (point-min))
  
  (re-search-forward beginPattern (point-max) (message "oops"))
  (forward-line 1)
  (setq patternAnfang (point))
  (re-search-forward endPattern (point-max) (message "uups"))
  (forward-line -1)
					; got to end of line to also cover the last line
  (move-end-of-line nil)
  (setq patternEnde (point))
					; save selected text
  (setq searchedText  (buffer-substring-no-properties patternAnfang patternEnde))

					; close file
  (kill-buffer strFile)
					
					; return searchedText to define a variable by defvar
  (message searchedText)

  )



;; grep the grepBufferString-buffer to find variables surrounded by "\py{.}"
;; delete surrounding \{} from variables
;; then save the result to variables.py
(defun grepToVariablesPy(grepBufferString)
  					; grep \py{variable}s to new buffer "grep"
  (shell-command "grep -o '\\py{[^}]*}' toGrep.py" grepBufferString)
  (switch-to-buffer grepBufferString)
					; free variables from surrounding \py{}
  (goto-char (point-min))
  (replace-regexp "^py\{" "")
  (goto-char (point-min))
  (replace-regexp "}$" "")

					; save result to variables.py
  (write-file "variables.py")
  (kill-buffer "variables.py")
  )

;; create the final listing and save it to final.py
(defun createFinalPy(finalBufferString inputText)
  
  (generate-new-buffer finalBufferString)
  (switch-to-buffer finalBufferString)
  
  (insert "# *** python code ***\n")
  (insert inputText)
  (insert "\n")
  (insert "# *** variable listing ***\n")
					; save and close buffer
  (write-file "final.py")
  (kill-buffer "final.py")
					; use a sed command to wrap variables.py with surrounding python-code
					;note: not yet also implemented with replace-regexp
  (shell-command "sed 's/\\(.*\\)/print(\"Variable\\ \\1\\ is\\ :\\ \"\+\\ str(\\1))/g' variables.py >> final.py")  
  )


;; call python to evaluate the collected variables in final.py to results.txt
(defun createScratch (texFileString)


					; save current buffer
  (setq saveBuffer (current-buffer))
					; save current position
  (setq savePoint (point))

					;note: grepping a single \ makes problems
					; grep pythoncode
  (defvar pycodeText (findPatternInFile texFileString "begin{pycode}" "end{pycode}"))
					; grep latexcode
 (defvar latexcodeText (findPatternInFile texFileString "begin{document}" "end{document}"))



					; save the pythoncode in main.py
  (generate-new-buffer "pythonBuffer")
  (switch-to-buffer "pythonBuffer")
  (insert pycodeText)
  (write-file "main.py" nil)
  (kill-buffer "main.py")

					;save latex code for grepping
  (generate-new-buffer "grepVariables")
  (switch-to-buffer "grepVariables")
  (insert latexcodeText)
  (write-file "toGrep.py")
  
					; isolate the variables by calling grepToVariables
  (grepToVariablesPy "grep")

					; create final.py by calling createFinalPy
  (createFinalPy "final" pycodeText)


					; create new buffer results for results
  (generate-new-buffer "results")
  					; call python process on final.py and put the reult into the results buffer
  (call-process "python" nil "results" nil "final.py")
					; switch to buffer
  (switch-to-buffer "results")
					; save buffer to results.txt and close it
  (write-file "results.txt")
  (kill-buffer "results.txt")

  
					; back to the current buffer
  (switch-to-buffer saveBuffer)
					; return to saved posistion
  (goto-char savePoint)
  
  )

; scan a .tex-file by line and extend variable values in comments
(defun scanByLine(strFile)
					; delete newerTest.tex if it exists
  (if (file-exists-p "newerTest.tex") (delete-file "newerTest.tex"))
					; open file strFile
  (find-file strFile)
					; save whole file to variable whloeFile
  (goto-char (point-min))
  (setq startPoint (point))
					; (move-end-of-line nil)
  (goto-char (point-max))
  (setq endPoint (point))

  (setq wholeFile (buffer-substring-no-properties startPoint endPoint))
					; close buffer
  (kill-buffer strFile)
  ;(generate-new-buffer "tmp")
					; (elt (...) 2 ) gets the second item
					; create lineList
  (setq lineList (split-string wholeFile "\n"))
					; run operateOnLine on each elemenet of lineList and save to operatedList
  (setq operatedList (mapcar 'operateOnLine lineList))
  ; (insert operatedList)
					; return Stringrepresentation of operatedList which is the String-union of all list elements
  (message  "%s" operatedList)
  )

; operate on one -tex-file line
(defun operateOnLine(strLine)
					; generate second temporary buffer
  (generate-new-buffer "tmp2")
  (switch-to-buffer "tmp2")

					; insert line strLine and go back to the beginning
  (insert strLine)
  (goto-char (point-min))
  (setq startLine (point))
  					; re-search-forward regexp bound supressErrorWhenNotFound
					; returns true iff found, false == nil iff not found
  (if (re-search-forward "py{[^}]+}" nil "noError")
					; true part: re-search-forward found pattern
					; unite commands for trueth-case by progn
      (progn
					; extend comment ar end of line
       (move-end-of-line nil)
       (insert "% regexp found:")

					; choose the whole line
       (move-beginning-of-line nil)
       (setq startLine (point))
       (move-end-of-line nil)
       (setq endLine (point))
       
					; defvar was wrong! use setq instead
					; because defvar does not change a variable once it is initialized
       (setq preLine (buffer-substring-no-properties startLine endLine))
					; decode variables of current preLine and add theam at the end of the line
       (setq addAtEnd (decodeVariables preLine))
       (goto-char (point-min))
       (move-end-of-line nil)
       (insert addAtEnd)
       
       ; (move-end-of-line nil)
       ; (insert preLine)
      )
      ; else part: re-search-forward didn't find pattern
      (progn
       (move-end-of-line nil)
       ;(insert "% not found")
      )
  )
					; insert newline command at the end of line
  (move-end-of-line nil)
  (insert "\n")
					; choose whole line again, this time with the variables at the end of comment
  (goto-char (point-min))
  (setq startPoint (point))
  (goto-char (point-max))
  (setq endPoint (point))
  (setq completeLine (buffer-substring-no-properties startPoint endPoint))
					; append line to newerTest.tex
  (append-to-file startPoint endPoint "newerTest.tex")

  ; (setq newLine (buffer-substring-no-properties startPoint endPoint))
  
  
  ; (list-matching-lines "")
  ; (replace-regexp ""
  ; (if (not (equal "" strLine))
    ;    (message (concat strLine  "%% ***\n"))
     ;  (message "")
  ; 	       )

  ; )
					; kill current buffer
  (kill-buffer "tmp2")
					; return the completeLine as String
  (message "%s" completeLine)
  
  )

; find the variables in the strLine and calculate their values
(defun decodeVariables(strLine)

					; delete previous generated files if they exist
  (if (file-exists-p "decode.py") (delete-file "decode.py"))
  (if (file-exists-p "decodedVariables.py") (delete-file "decodedVariables.py"))
  (if (file-exists-p "values.py") (delete-file "values.py"))
  
					; save current line to decoder.py
  (generate-new-buffer "decoder")
  (switch-to-buffer "decoder")
  (insert strLine)
  (move-beginning-of-line nil)
  (write-file "decode.py")
  (kill-buffer "decode.py")

					; grepping py surroundings
  (shell-command "grep -o '\\py{[^}]*}' decode.py" "freeDecoder")
  (switch-to-buffer "freeDecoder")
  (goto-char (point-min))
  					; free variables from surrounding py{}
  (goto-char (point-min))
  (replace-regexp "^py\{" "")
  (goto-char (point-min))
  (replace-regexp "}$" "")
					; save result to decodedVariables.py
  (write-file "decodedVariables.py")

  
					; in each line of decodedVariables.py is a seperated variable
					; ~> load varList
  (goto-char (point-min))
  (setq varList (split-string (buffer-string) "\n"))

  (kill-buffer "decodedVariables.py")

					; generate values.py
  (generate-new-buffer "values")
  (switch-to-buffer "values")

					; for each construct over varList
  (while varList
    ; set element
    (setq elementVar (car varList))
					; awk ergebnisse.txt and grep then head afterwards
					; construct a complex commandline
    (setq grepStart "awk \'{ print $2 \"=\" $5 }\' ergebnisse.txt | grep \'")
    (setq grepCommand (concat grepStart elementVar ".*\' | head -1"))
    ;(insert grepCommand)
    ;(insert "\n")
					; run commandline and save result in tmpErg
    (setq tmpErg (shell-command-to-string grepCommand))
    (insert tmpErg)
    
    ; next element
    (setq varList (cdr varList))
    
  )
  
  ;(loop for (var) in varList
  ;	(setq grepStart "awk '{ print $2 \"=\" $5 } ergebnisse.txt ' | grep '")
  ;	(setq grepCommand (concat grepStart var ".*' | head -1"))
  ;	(shell-command grepCommand "values")	
  ; )
					; save buffer to values.py
  (write-file "values.py")
					; go back to start
  (goto-char (point-min))
					; values are isolated by lines
  (setq valueList (split-string (buffer-string) "\n"))
  ; (insert valueList)

					; create return variable
  (setq returnedString "")
  ; emulate for loop
  (while valueList
					; save value in elementVal
    (setq elementVal (car valueList))
					; update returnedString
    (setq returnedString (concat returnedString elementVal "\|"))
					; goto next element
    (setq valueList (cdr valueList))
  )
  ;(loop for (value) in valueList
  ;	(setq returnedString (concat returnedString value ";" ))
  ; )
  ; to comment out
  ; (goto-char (point-max))
  ; (insert returnedString)

					; save and close to values.py
  (write-file "values.py")
  (kill-buffer "values.py")

					; return returnedString
  (message returnedString)
  
  )


;(operateOnLine "hello \py{a}")

;(scanByLine "test.tex")
;(operateOnLine "test")


;          (if 3
 ;             (
;	       (print 'true)
;	       (print 'hello)
;	      )
 ;           'very-false)

;(setq liste '("car" "house" "mouse"))
 ;     (while liste
;	(setq element (car liste))
;	(insert element)
;	(setq liste (cdr liste))
;	)

; end of module
