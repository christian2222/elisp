(defun testMe()
  (message "Ach was!")
  )

(defun callMe()
  ; don't use devar here!
  (setq icke (testMe))
  (insert icke)
  )
