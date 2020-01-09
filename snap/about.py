#!/bin/python

from snappy import ProductIO
import jpy

# JAVA VM size
Runtime = jpy.get_type('java.lang.Runtime')
heap_size = Runtime.getRuntime().maxMemory() / (1024*1024)
print('JVM size:',heap_size, "MB")

# ESA SNAP version
vc = jpy.get_type('org.esa.snap.core.util.VersionChecker')
version = vc.getInstance().getLocalVersion().toString()
print('SNAP VERSION:',version)
