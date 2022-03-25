function loadEnvFile() {
  echo "Loading .env file: $1"
  if [ -f $1 ]; then
    if [ "$2" == "debug" ]; then
      echo "--------------------"
    fi
    counter=0
    while read line || [ -n "$line" ]; do
      counter=$((counter+1))
      lineValue=$(echo $line | sed -E "s/\"|'|\`/ˈ/g" | xargs)
      lineValue=$(echo $lineValue | sed 's/#.*//g' | xargs)
      lineValueLengthString=${#lineValue}
      lineValueLength=$((lineValueLengthString + 0))

      if [ $lineValueLength -gt 0 ]; then
        if [ "$2" == "debug" ]; then
          echo -e "Read Line $counter:\t\t $lineValue"
        fi
        lineValueSubs=$(echo "$lineValue" | envsubst)
        if [ "$2" == "debug" ]; then
          echo -e "Substituted Values:\t $lineValueSubs"
        fi
        exportCommand="export $lineValueSubs"
        exportCommand=$(echo $exportCommand | sed -E 's/ˈ/\\"/g' | xargs)
        if [ "$2" == "debug" ]; then
          echo -e "Export Command:\t\t $exportCommand"
        fi
        eval $exportCommand
      else
        if [ "$2" == "debug" ]; then
          echo "Skipped empty line $counter."
        fi
      fi
      echo "--------------------"
    done <$1
    echo "$1 environment variables file imported."
  else
    echo "$1  environment variables file found."
  fi
}
