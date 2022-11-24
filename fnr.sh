for f in $(find . -type f -print)
do
  if [[ "$f" == *".go" || "$f" == *".js" || "$f" == *".vue" ]]
  then
   echo $f
   sed -i "s/${1}/${2}/g"  "$f"
  fi
done
