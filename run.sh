awk '{ print $2 "=" $5 }' ergebnisse.txt | grep 'a.*' | head -1
awk '{ print $2 "=" $5 }' ergebnisse.txt | grep 'b.*' | head -1
awk '{ print $2 "=" $5 }' ergebnisse.txt | grep 'c.*' | head -1
awk '{ print $2 "=" $5 }' ergebnisse.txt | grep '.*' | head -1
