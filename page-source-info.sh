#!/bin/bash
#title      : Extract Information from webpage
#author     : Kashz
#version    : 0.1

# curls the URL > enum.html
# runs the check
# deletes enum.html

#example: ./page-source-info.sh 192.168.99.114/register

[ $# -eq 0 ] && {
  echo "Usage: $0 IP:PORT/PAGE"
  exit 1
}

if curl --fail -s $1 >enum.html; then

  echo "[+] href references:"
  cat enum.html | grep 'href' | tr -d ' '
  # cat enum.html | grep 'href' | tr -d ' ' | awk -F 'href=' '{print$2}' | awk -F '"' '{print$2}'

  echo
  echo "[+] src references:"
  cat enum.html | grep 'src' | tr -d ' '
  # cat enum.html | grep 'src' | tr -d ' ' | awk -F '"/' '{print$2}' | awk -F '"' '{printenum.html}'

  echo
  echo "[+] onclick references:"
  cat enum.html | grep 'onclick' | tr -d ' '

  echo
  echo "[+] path references:"
  cat enum.html | grep 'path' | tr -d ' '

  echo
  echo "[+] comments:"
  cat enum.html | grep '<!--' | tr -d ' '

  rm enum.html
else
  echo "[!!] Unable to curl URL"
  echo "[!!] Exiting"
fi
