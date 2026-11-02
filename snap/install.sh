#!/bin/sh
set -eu

# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539778/Install+SNAP+on+the+command+line
# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# http://step.esa.int/main/download/snap-download/

SNAPVER=14
# avoid NullPointer crash during S-1 processing
java_max_mem=10G

# install and update snap
wget -q -O /src/snap/esa-snap_all_linux-${SNAPVER}.0.0.sh \
  "https://download.esa.int/step/snap/${SNAPVER}.0/installers/esa-snap_all_linux-${SNAPVER}.0.0.sh"

export INSTALL4J_JAVA_HOME="$JAVA_HOME"

# use the Alpine system JVM for the installer
sh /src/snap/esa-snap_all_linux-${SNAPVER}.0.0.sh -q -varfile /src/snap/response.varfile

# one more hack to keep using system java
sed -i 's+jdkhome="./jre"+jdkhome="$JAVA_HOME"+g' /usr/local/snap/etc/snap.conf
# freezing, when no updates available. Now there are updates, so reactivating.
/usr/local/snap/bin/snap --nosplash --nogui --modules --update-all
rm -rf /usr/local/snap/jre

# cleanup installer
rm -f /src/snap/esa-snap_all_linux-${SNAPVER}.0.0.sh

# Build SNAPHU against Alpine's musl libc.
SNAPHUVER=2.0.7
wget -q -O /tmp/snaphu.tar.gz \
  "https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/snaphu-v${SNAPHUVER}.tar.gz"
echo "c03ac126f9a964321bb5d6fb5b4004728368da268d7cb8407bb295a8abe5b262  /tmp/snaphu.tar.gz" | sha256sum -c -
tar -xzf /tmp/snaphu.tar.gz -C /tmp
# SNAPHU 2.0.7 predates GCC 15's default C23 function declarations.
make -C "/tmp/snaphu-v${SNAPHUVER}/src" CC=gcc CFLAGS="-O3 -Wall -std=gnu17"
cp "/tmp/snaphu-v${SNAPHUVER}/bin/snaphu" /usr/local/bin/snaphu

# Install the official SNAP tool adapter and initialise its user configuration.
/usr/local/snap/bin/snap --nosplash --nogui --modules --install \
  org.esa.snap.core.gpf.operators.tooladapter.snaphu.unwrapping
/usr/local/snap/bin/gpt -h

# Use the compiled binary; no interactive bundle download is needed.
adapter_found=false
for descriptor in /root/.snap/auxdata/tool-adapters/*/META-INF/descriptor.xml; do
  [ -f "$descriptor" ] || continue
  if grep -q '<alias>Snaphu-unwrapping</alias>' "$descriptor"; then
    sed -i 's|<mainToolFileLocation>.*</mainToolFileLocation>|<mainToolFileLocation>/usr/local/bin/snaphu</mainToolFileLocation>|' "$descriptor"
    sed -i '/<linuxBundle>/,/<\/linuxBundle>/s|<bundleType>ZIP</bundleType>|<bundleType>NONE</bundleType>|' "$descriptor"
    adapter_found=true
  fi
done
[ "$adapter_found" = true ]
