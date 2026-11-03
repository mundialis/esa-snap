#!/bin/sh
# Build-time fixes for Alpine native-library compatibility and headless SNAPHU
# execution via GPT, including output handling for repeated runs.
set -eu

# Use Alpine's Fortran runtime with SNAP's bundled native libraries.
apk add --no-cache libgfortran
apk add --no-cache --virtual .native-fixes patchelf
workdir=$(mktemp -d)
cd "$workdir"

# Load jblas directly with system libgfortran, avoiding its bundled quadmath crash.
jar xf /usr/local/snap/microwavetbx/modules/ext/org.jlinda.jlinda-core/org-jblas/jblas.jar \
  lib/static/Linux/amd64/sse3/libjblas.so
cp lib/static/Linux/amd64/sse3/libjblas.so /usr/lib/libjblas.so
patchelf --add-needed libgcompat.so.0 /usr/lib/libjblas.so

# Patch the resource archive: SNAP would overwrite changes to extracted files.
jar xf /usr/local/snap/snap/modules/org-esa-snap-snap-netcdf.jar lib/amd64
for library in lib/amd64/*.so*; do
  patchelf --set-rpath '$ORIGIN' --add-needed libgcompat.so.0 "$library"
done
jar uf /usr/local/snap/snap/modules/org-esa-snap-snap-netcdf.jar lib/amd64

# The upstream adapter has empty/nested variables which prevent headless execution.
adapter=/root/.snap/auxdata/tool-adapters/Snaphu-unwrapping
sed -i '/^  <variables>/,/^  <\/variables>/c\
  <variables>\
    <variable><key>SNAPHU_HOME</key><value>/root</value><isShared>false</isShared></variable>\
    <variable><key>SNAPHU_TOOL_EXE</key><value>/usr/local</value><isShared>false</isShared></variable>\
    <variable><key>SNAPHU_EXE</key><value>snaphu</value><isShared>false</isShared></variable>\
    <variable><key>USERPROFILE</key><value>/root</value><isShared>false</isShared></variable>\
    <variable><key>HOME</key><value>/root</value><isShared>false</isShared></variable>\
    <variable><key>USER_HOME</key><value>/root</value><isShared>false</isShared></variable>\
  </variables>' "$adapter/META-INF/descriptor.xml"

# Expose the nested output folder as a GPT parameter and omit empty argv entries.
sed -i '/^  <\/parameters>/i\
    <parameter><name>outputFolder</name><dataType>java.io.File</dataType><description>SNAPHU output folder</description><notNull>true</notNull><notEmpty>true</notEmpty><parameterType>FolderParameter</parameterType></parameter>' \
  "$adapter/META-INF/descriptor.xml"
sed -i '/^[[:space:]]*$/d' "$adapter/Snaphu-unwrapping-template.vm"

# Preserve the new result during cleanup and allow repeated runs in the same folder.
sed -i 's|$targetFilePath.toFile().delete()|#if (!$fileName.startsWith("UnwPhase_") \|\| !$fileName.endsWith(".snaphu.img"))\n$targetFilePath.toFile().delete()\n#end|' \
  "$adapter/Snaphu-unwrapping-after.vm"
sed -i '/$copyMethod.invoke($NULL, $resultFilePath, $outputFile, $arrayObj)/i\
#set($deleteExistingOutput = $outputFile.toFile().delete())' \
  "$adapter/Snaphu-unwrapping-after.vm"

cd /
rm -rf "$workdir"
apk del .native-fixes
