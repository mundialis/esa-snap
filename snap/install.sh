#!/bin/sh

# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539778/Install+SNAP+on+the+command+line
# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# http://step.esa.int/main/download/snap-download/

SNAPVER=7
# avoid NullPointer crash during S-1 processing
java_max_mem=10G

# install module 'jpy' (A bi-directional Python-Java bridge)
git clone https://github.com/bcdev/jpy.git /src/snap/jpy
python3 -m ensurepip
pip3 install --upgrade pip wheel
(cd /src/snap/jpy && python3 setup.py build maven bdist_wheel)
# hack because ./snappy-conf will create this dir but also needs *.whl files...
mkdir -p /root/.snap/snap-python/snappy
cp /src/snap/jpy/dist/*.whl "/root/.snap/snap-python/snappy"

# install and update snap
wget -q -O /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh \
  "http://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_unix_${SNAPVER}_0.sh"

# hacks to make it run on alpine
sed -i 's+ bin/unpack200+ $JAVA_HOME/bin/unpack200+g' /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh
# more hacks to use system java and not oracle (included in installer).
# Oracle JAVA is not supported with alpine due to missing glibc.
sed -i 's+$INSTALL4J_JAVA_PREFIX "$app_java_home/bin/java"+$INSTALL4J_JAVA_PREFIX java+g' /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh
sed -i 's+-Dinstall4j.jvmDir="$app_java_home"+-Dinstall4j.jvmDir=$JAVA_HOME/jre+g' /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh
sed -i 's+-Djava.ext.dirs="$app_java_home/lib/ext:$app_java_home/jre/lib/ext"++g' /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh
sed -i 's+-classpath "$local_classpath"+-classpath "$local_classpath:$app_java_home/lib/ext:$app_java_home/jre/lib/ext"+g' /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh
sh /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh -q -varfile /src/snap/response.varfile

# one more hack to keep using system java
sed -i 's+jdkhome="./jre"+jdkhome="$JAVA_HOME"+g' /usr/local/snap/etc/snap.conf
/usr/local/snap/bin/snap --nosplash --nogui --modules --update-all
rm -rf /usr/local/snap/jre

# create snappy and python binding with snappy
/usr/local/snap/bin/snappy-conf /usr/bin/python3
(cd /root/.snap/snap-python/snappy && python3 setup.py install)

# increase the JAVA VM size to avoid NullPointer exception in Snappy during S-1 processing
(cd /root/.snap/snap-python/snappy && sed -i "s/^java_max_mem:.*/java_max_mem: $java_max_mem/" snappy.ini)

# test
/usr/bin/python3 -c 'from snappy import ProductIO'
if [ -f /src/snap/about.py ]
then
    /usr/bin/python3 /src/snap/about.py
    cp /src/snap/about.py /root/.snap/
fi


# cleanup installer
rm -f /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh

################################################################################
# keep for debugging
# export INSTALL4J_KEEP_TEMP=yes
