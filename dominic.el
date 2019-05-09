(defun pycode-send ()
					; save the current position to return to at the end of this function
  (setq savePoint (point))
					;(interactive)
					;(elpy-shell-get-or-create-process)
					; delete tmp.py
  (delete-file "tmp.py")
					; goto start of current buffer to search forward
  (goto-char (point(min))
					; search python code by regulat expressions, note the \\ for special chars
					; outcommented command: if we search backward
					; (re-search-backward "\\[begin\\ python\\]" (point-min) (message "oops"))
					; here we search forward; note the change to point-max
  (re-search-forward "\\[begin\\ python\\]" (point-max) (message "oops"))
  (forward-line 1)
  (setq myAnfang (point))
  (re-search-forward "\\[end\\ python\\]" (point-max) (message "uups"))
  (forward-line -1)
					; cuts whole line of, but cursor stands on position 1 in line above
					; move the cursor to the end of the line to get also the last line
  (move-end-of-line nil)
  (setq myEnde (point))
					;(python-shell-send-region Anfang Ende); send to file tmp.py
  (append-to-file  (buffer-substring-no-properties myAnfang myEnde) nil "tmp.py")
					;(python-shell-switch-to-shell)
					; call python process on tmp.py and put the reult into the *scratch* buffer
  (call-process "python" nil "*scratch*" nil "tmp.py")

 					; move to saved point
  (goto-char  savePoint)
  					; output the python-code for debugging
  (message savedText)
					;(message "Der Anfang ist: %s" myAnfang)

  )

; (buffer-substring-no-properties 1 10)

(pycode-send )
(replace-regexp )
[begin python]
# this is python
print "Hello Python!"
a = 8.7
b = a**2
complexVariable = a*b
# some text
[end python]

; (goto-char (point-max))
; (goto-char (point-min))


(defun grepPys ()
  (setq savePoint (point))
					; (call-process "./grepPy.sh" nil "*scratch*" nil "test.tex")
					; (shell-command "grepPy.sh test.tex" "*scratch*" nil)
  (call-process "./grepPy.sh" nil "*scratch*" nil)
  )

(shell-command "./grepPy.sh")
(inster-file-literally "./grepPy.sh")
(with-temp-file "test.txt"
  (insert "hello"))

(grepPys )
(generate-new-buffer "test")
					; (set-buffer "test") does not make it visible, but you can operate on it
(switch-to-buffer "test")
					; (display-buffer-in-side-window "test")









(defun makeSomeText()
					; generate a new buffer to use, named "test"
  (generate-new-buffer "test")
  
  					; save the current position to return to at the end of this function
  (setq savePoint (point))
					;(interactive)
					;(elpy-shell-get-or-create-process)

					; open the tex file
  (find-file "test.tex")
					; goto start of current bufferto search forward
  (goto-char (point-min))
					; search python code by regulat expressions, note the \\ for special chars
					; outcommented command: if we search backward
					; (re-search-backward "\\[begin\\ python\\]" (point-min) (message "oops"))
					; here we search forward; note the change to point-max
					; note: searching for a backslash makes problems
  (re-search-forward "begin{pycode}" (point-max) (message "oops"))
  (forward-line 1)
  (setq myAnfang (point))
  (re-search-forward "end{pycode}" (point-max) (message "uups"))
  (forward-line -1)
					; cuts whole line of, but cursor stands on position 1 in line above
					; move the cursor to the end of the line to get also the last line
  (move-end-of-line nil)
  (setq myEnde (point))
					;(python-shell-send-region Anfang Ende); send to file tmp.py

  (setq pythonText  (buffer-substring-no-properties myAnfang myEnde))
					; search for latex code
  (goto-char (point-min))
  (re-search-forward "begin{document}" (point-max) (message "oops"))
  (forward-line 1)
  (setq latexAnfang (point))
  (re-search-forward "end{document}" (point-max) (message "uups"))
  (forward-line -1)
  (move-end-of-line nil)
  (setq latexEnde (point))
  (setq latexText  (buffer-substring-no-properties latexAnfang latexEnde))

					; close the tex file
  (kill-buffer "test.tex")
  
  (switch-to-buffer "test")
  (insert "# *** python code ***\n")
  (insert pythonText)
  (insert "\n")
  (insert "# *** latex code ***\n")
  (insert latexText)
  (insert "\n")
  
  (goto-char (point-min))
					;  (search-forward "#" nil t)
					; (replace-match "# new String; ")
  ; (replace-regexp "#" "# other String:")
					; write to file; nll means dont ask for confirmation
  (write-file "buffer.py" nil)
  (kill-buffer "buffer.py")
  (generate-new-buffer "grep")
  (shell-command "grep -o '\\py{[^}]*}' buffer.py" "grep")
  (switch-to-buffer "grep")
  (goto-char (point-min))
  (replace-regexp "^py\{" "")
  (goto-char (point-min))
  (replace-regexp "}$" "")
  (goto-char (point-min))
  (replace-regexp "([a-zA-Z]*)" "print \1 \1")
  (write-file "variables.py" nil)
  (kill-buffer "variables.py")
					; (shell-command "sed 's/\\(.*\\)/\\1\\1/g' variables.py" "doubled.py") need double \\ for sed
  (generate-new-buffer "final")
  (switch-to-buffer"final")
  (insert pythonText)
  (insert "\n")
  (write-file "final.py")
  (kill-buffer "final.py")
  (shell-command "sed 's/\\(.*\\)/print(\"Variable\\ \\1\\ is\\ :\\ \"\+\\ str(\\1))/g' variables.py >> final.py")
  
  
					;(python-shell-switch-to-shell)
					; call python process on tmp.py and put the reult into the *scratch* buffer
					; (call-process "python" nil "*scratch*" nil "tmp.py")

					; back to the original buffer
  (switch-to-buffer "dominic.el")
  					; move to saved point
  (goto-char  savePoint)
  					; output the python-code for debugging
  (message pythonText)
					;(message "Der Anfang ist: %s" myAnfang)

  
					; (grep "\'e\' buffer.el")
					; (insert"Hello\n")
					; (insert "Bye\n")
  
  )

(makeSomeText )

(defun findPatternInFile (strFile beginPattern endPattern)
					; open th file
  (find-file strFile)
					; got to the beginning of file
  (goto-char (point-min))
  
  (re-search-forward beginPattern (point-max) (message "oops"))
  (forward-line 1)
  (setq patternAnfang (point))
  (re-search-forward endPattern (point-max) (message "uups"))
  (forward-line -1)
  (move-end-of-line nil)
  (setq patternEnde (point))
  (setq searchedText  (buffer-substring-no-properties patternAnfang patternEnde))

					; close file
  (kill-buffer strFile)
					; return searchedText to define a variable by defvar
  (message searchedText)

  )


; (defvar pycodeText (findPatternInFile "test.tex" "begin{pycode}" "end{pycode}"))
; (defvar latexcodeText (findPatternInFile "test.tex" "begin{document}" "end{document}"))
					; (insert latexcodeText)

(defun grepToVariablesPy(grepBufferString)
  					; grep \py{variable}s to new buffer "grep"
  (shell-command "grep -o '\\py{[^}]*}' toGrep.py" grepBufferString)
  (switch-to-buffer grepBufferString)
					; free variables from surrounding \py{}
  (goto-char (point-min))
  (replace-regexp "^py\{" "")
  (goto-char (point-min))
  (replace-regexp "}$" "")

  (write-file "variables.py")
  (kill-buffer "variables.py")
  )

(defun createFinalPy(finalBufferString inputText)
  (generate-new-buffer finalBufferString)
  (switch-to-buffer finalBufferString)
  (insert "# *** python code ***\n")
  (insert inputText)
  (insert "\n")
  (insert "# *** variable listing ***\n")
  (write-file "final.py")
  (kill-buffer "final.py")
  (shell-command "sed 's/\\(.*\\)/print(\"Variable\\ \\1\\ is\\ :\\ \"\+\\ str(\\1))/g' variables.py >> final.py")  
  )


(defun createScratch ()

					; save current position
  (setq savePoint (point))
  
  (defvar pycodeText (findPatternInFile "test.tex" "begin{pycode}" "end{pycode}"))
  (defvar latexcodeText (findPatternInFile "test.tex" "begin{document}" "end{document}"))

  (generate-new-buffer "pythonBuffer")
  (switch-to-buffer "pythonBuffer")
  (insert pycodeText)
  (write-file "main.py" nil)
  (kill-buffer "main.py")

  (generate-new-buffer "grepVariables")
  (switch-to-buffer "grepVariables")
  (insert latexcodeText)
  (write-file "toGrep.py")

  (grepToVariablesPy "grep")

  (createFinalPy "final" pycodeText)



  					; call python process on final.py and put the reult into the *scratch* buffer
  (call-process "python" nil "*scratch*" nil "final.py")

  
					; back to the current buffer
  (switch-to-buffer "dominic.el")
					; return to saved posistion
  (goto-char savePoint)
  
  )

(createScratch )









					; close the buffer (with asking for changes)
(kill-buffer "test")

(defun myFun ()
  (setq x "servus")
  (message "Hhuhu: %s" x)
  )


(defun myTest ()
  (message "Huhu World!")
  ;(+ 7 8)
  )

(myTest )
(find-file "test.tex")

(myFun )

(message "Hello")

(point)

(re-search-backward "\\[begin\\ python\\]" (point-min) (message "oops"))

(re-search-forward "\\[end\\ python\\]" (point-max) (message "uups"))

(message "This message appears in the echo area!")
(regexp-quote "\begin{pycode}")


[begin latex]
See $\py{a}$ for a new rault for $\py{b}$
\begin{eqnarray*
\int_x f(x) ds = \py{complexVariable} \cdot \py{a}
\end{eqnarray*
[end latex]
