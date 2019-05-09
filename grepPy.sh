echo "# *** code from latex file ***" > run.py
sed -n '/\\begin{pycode}/,/\\end{pycode}/{//b;p}' test.tex >> run.py
grep -o '\\py{[^}]*}' test.tex > variable.py
sed 's/\\py{//g; s/}//g' variable.py > isolationVariables.py
# grep -wo '[^\{}]*' variable.py > preIsolation.py
# grep '^[^py].*' preIsolation.py > isolationVariables.py
echo "# *** evaluating found variables ***" >> run.py
sed 's \(.*\) print(\"Variable\ \1\ is\ :\ \"\+\ str(\1)) ' isolationVariables.py >> run.py
python run.py  > ergebnisse
cat ergebnisse
