Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59039 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755574Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] Share showresults.py between 4.0 and 4.1
Date: Thu, 28 Jul 2011 16:03:01 -0400
Message-Id: <1311883384-20260-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Code for showresults.py is identical between 4.0 and 4.1.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.0/showresults.py |   74 -------------------------------------------------
 nfs4.1/showresults.py |   74 -------------------------------------------------
 showresults.py        |   74 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 148 deletions(-)
 delete mode 100755 nfs4.0/showresults.py
 delete mode 100755 nfs4.1/showresults.py
 create mode 100755 showresults.py

diff --git a/nfs4.0/showresults.py b/nfs4.0/showresults.py
deleted file mode 100755
index 4b69b0e..0000000
--- a/nfs4.0/showresults.py
+++ /dev/null
@@ -1,74 +0,0 @@
-#!/usr/bin/env python
-# showresults.py - redisplay results from nfsv4 server tester output file
-#
-# Requires python 2.3
-# 
-# Written by Fred Isaman <iisaman@citi.umich.edu>
-# Copyright (C) 2004 University of Michigan, Center for 
-#                    Information Technology Integration
-#
-
-
-# Allow to be run stright from package root
-if  __name__ == "__main__":
-    import os.path
-    import sys
-    if os.path.isfile(os.path.join(sys.path[0], 'lib', 'testmod.py')):
-        sys.path.insert(1, os.path.join(sys.path[0], 'lib'))
-
-#import cPickle as pickle
-import pickle
-import testmod
-from optparse import OptionParser
-
-class MyUnpickler(pickle.Unpickler):
-    class Unknown(object):
-        def __init__(self, name):
-            self.name = name
-    
-    def find_class(self, module, name):
-        # Handle function renames gracefully
-        __import__(module)
-        mod = sys.modules[module]
-        try:
-            klass = getattr(mod, name)
-            return klass
-        except:
-            return self.Unknown(name)
-
-def show(filename, opt):
-    fd = file(filename, 'r')
-    p = MyUnpickler(fd)
-    tests = p.load()
-    testmod.printresults(tests, opt)
-
-def scan_options(p):
-    """Parse command line options"""
-    p.add_option("--showpass", action="store_true", default=True,
-                 help="Show passed tests [default]")
-    p.add_option("--hidepass", action="store_false", dest="showpass",
-                 help="Hide passed tests")
-    p.add_option("--showomit", action="store_true", default=False,
-                 help="Show omitted tests")
-    p.add_option("--hideomit", action="store_false", dest="showomit",
-                 help="Hide omitted tests [default]")
-    p.add_option("--showwarn", action="store_true", default=True,
-                 help="Show tests that gave warnings [default]")
-    p.add_option("--hidewarn", action="store_false", dest="showwarn",
-                 help="Hide tests that gave warnings")
-    p.add_option("--showfail", action="store_true", default=True,
-                 help="Show failed tests [default]")
-    p.add_option("--hidefail", action="store_false", dest="showfail",
-                 help="Hide failed tests")
-    return p.parse_args()
-
-def main():
-    p = OptionParser("%prog [options] filename")
-    opt, args = scan_options(p)
-    if not args:
-        p.error("Need a filename")
-    for a in args:
-        show(a, opt)
-
-if __name__ == "__main__":
-    main()
diff --git a/nfs4.1/showresults.py b/nfs4.1/showresults.py
deleted file mode 100755
index 4b69b0e..0000000
--- a/nfs4.1/showresults.py
+++ /dev/null
@@ -1,74 +0,0 @@
-#!/usr/bin/env python
-# showresults.py - redisplay results from nfsv4 server tester output file
-#
-# Requires python 2.3
-# 
-# Written by Fred Isaman <iisaman@citi.umich.edu>
-# Copyright (C) 2004 University of Michigan, Center for 
-#                    Information Technology Integration
-#
-
-
-# Allow to be run stright from package root
-if  __name__ == "__main__":
-    import os.path
-    import sys
-    if os.path.isfile(os.path.join(sys.path[0], 'lib', 'testmod.py')):
-        sys.path.insert(1, os.path.join(sys.path[0], 'lib'))
-
-#import cPickle as pickle
-import pickle
-import testmod
-from optparse import OptionParser
-
-class MyUnpickler(pickle.Unpickler):
-    class Unknown(object):
-        def __init__(self, name):
-            self.name = name
-    
-    def find_class(self, module, name):
-        # Handle function renames gracefully
-        __import__(module)
-        mod = sys.modules[module]
-        try:
-            klass = getattr(mod, name)
-            return klass
-        except:
-            return self.Unknown(name)
-
-def show(filename, opt):
-    fd = file(filename, 'r')
-    p = MyUnpickler(fd)
-    tests = p.load()
-    testmod.printresults(tests, opt)
-
-def scan_options(p):
-    """Parse command line options"""
-    p.add_option("--showpass", action="store_true", default=True,
-                 help="Show passed tests [default]")
-    p.add_option("--hidepass", action="store_false", dest="showpass",
-                 help="Hide passed tests")
-    p.add_option("--showomit", action="store_true", default=False,
-                 help="Show omitted tests")
-    p.add_option("--hideomit", action="store_false", dest="showomit",
-                 help="Hide omitted tests [default]")
-    p.add_option("--showwarn", action="store_true", default=True,
-                 help="Show tests that gave warnings [default]")
-    p.add_option("--hidewarn", action="store_false", dest="showwarn",
-                 help="Hide tests that gave warnings")
-    p.add_option("--showfail", action="store_true", default=True,
-                 help="Show failed tests [default]")
-    p.add_option("--hidefail", action="store_false", dest="showfail",
-                 help="Hide failed tests")
-    return p.parse_args()
-
-def main():
-    p = OptionParser("%prog [options] filename")
-    opt, args = scan_options(p)
-    if not args:
-        p.error("Need a filename")
-    for a in args:
-        show(a, opt)
-
-if __name__ == "__main__":
-    main()
diff --git a/showresults.py b/showresults.py
new file mode 100755
index 0000000..b843a5f
--- /dev/null
+++ b/showresults.py
@@ -0,0 +1,74 @@
+#!/usr/bin/env python
+# showresults.py - redisplay results from nfsv4 server tester output file
+#
+# Requires python 2.3
+# 
+# Written by Fred Isaman <iisaman@citi.umich.edu>
+# Copyright (C) 2004 University of Michigan, Center for 
+#                    Information Technology Integration
+#
+
+
+# Allow to be run stright from package root
+if  __name__ == "__main__":
+    import os.path
+    import sys
+    if os.path.isfile(os.path.join(sys.path[0], 'nfs4.1', 'testmod.py')):
+        sys.path.insert(1, os.path.join(sys.path[0], 'nfs4.1'))
+
+#import cPickle as pickle
+import pickle
+import testmod
+from optparse import OptionParser
+
+class MyUnpickler(pickle.Unpickler):
+    class Unknown(object):
+        def __init__(self, name):
+            self.name = name
+    
+    def find_class(self, module, name):
+        # Handle function renames gracefully
+        __import__(module)
+        mod = sys.modules[module]
+        try:
+            klass = getattr(mod, name)
+            return klass
+        except:
+            return self.Unknown(name)
+
+def show(filename, opt):
+    fd = file(filename, 'r')
+    p = MyUnpickler(fd)
+    tests = p.load()
+    testmod.printresults(tests, opt)
+
+def scan_options(p):
+    """Parse command line options"""
+    p.add_option("--showpass", action="store_true", default=True,
+                 help="Show passed tests [default]")
+    p.add_option("--hidepass", action="store_false", dest="showpass",
+                 help="Hide passed tests")
+    p.add_option("--showomit", action="store_true", default=False,
+                 help="Show omitted tests")
+    p.add_option("--hideomit", action="store_false", dest="showomit",
+                 help="Hide omitted tests [default]")
+    p.add_option("--showwarn", action="store_true", default=True,
+                 help="Show tests that gave warnings [default]")
+    p.add_option("--hidewarn", action="store_false", dest="showwarn",
+                 help="Hide tests that gave warnings")
+    p.add_option("--showfail", action="store_true", default=True,
+                 help="Show failed tests [default]")
+    p.add_option("--hidefail", action="store_false", dest="showfail",
+                 help="Hide failed tests")
+    return p.parse_args()
+
+def main():
+    p = OptionParser("%prog [options] filename")
+    opt, args = scan_options(p)
+    if not args:
+        p.error("Need a filename")
+    for a in args:
+        show(a, opt)
+
+if __name__ == "__main__":
+    main()
-- 
1.7.4.1

