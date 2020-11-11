# serialize ENV for cron-jobs
TMP_FILE=/tmp/cron_env
OUT_FILE=/cron_env
echo -n '' > "${OUT_FILE}"
env > "${TMP_FILE}"
while read -r line; do
  echo "${line}" | grep -q "^PWD="
  if [ $? = 0 ]; then
    continue
  fi
  if ! [[ ${line} =~ ^[a-zA-Z0-9_]+=.+$ ]]; then
    echo "$0: Messed up ENV: ${line}"
    continue
  fi
  echo "${line}" | grep -q "\s"
  if [ $? = 0 ]; then
    # double-quote blank separated values for $(export)
    # 1. awk: replace first(!) appearance of = with ="
    # 2. awk: replace end of line with double-quotes
    QUOTED=$(echo "${line}" | awk '{sub(/=/,"=\"");}1'| awk '{sub(/$/,"\"");}1')
    echo "export ${QUOTED}" >> "${OUT_FILE}"
  else
    echo "export ${line}" >> "${OUT_FILE}"
  fi
done <"${TMP_FILE}"
unlink "${TMP_FILE}"
# start crond in background
/usr/sbin/crond -b -S