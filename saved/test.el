					; (require '~/grepping/pythonModule) does not work
					; import pythonModule by load; must be hard coded with absolute path
					;(expand-file-name "pythonModule.el")
					; use relative filename
(load (expand-file-name "pythonModule.el"))


					; createScratch to create results.txt
(createScratch "test.tex")
					; scanByLine uses ergebnisse.txt to comment variables in newerTest.tex
(scanByLine "test.tex")
+
; unnecessary tests
;(setq elementVar "a")
;(setq grepStart "awk \'\{ print $2 \"=\" $5 \}\' ergebnisse.txt | grep \'")
;(setq grepCommand (concat grepStart elementVar ".*\' | head -1"))
;(insert grepCommand)
;(shell-command grepCommand "values")
    ;(insert grepCommand)
