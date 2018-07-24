Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388442AbeGXIjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:41 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 21/24] pynfs: python3 support plan: fix sort() fail and require python version
Date: Tue, 24 Jul 2018 15:33:39 +0800
Message-Id: <20180724073342.5738-21-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/testserver.py | 6 +++---
 nfs4.1/nfs4client.py | 2 +-
 nfs4.1/nfs4lib.py    | 2 +-
 nfs4.1/testclient.py | 6 +++---
 nfs4.1/testmod.py    | 5 ++++-
 nfs4.1/testserver.py | 6 +++---
 6 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index ebce58d..e4a6db7 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -1,7 +1,7 @@
 #!/usr/bin/env python
 # nfs4stest.py - nfsv4 server tester
 #
-# Requires python 2.5
+# Requires python 2.7
 # 
 # Written by Fred Isaman <iisaman@citi.umich.edu>
 # Copyright (C) 2004 University of Michigan, Center for 
@@ -26,8 +26,8 @@
 
 
 import sys
-if sys.hexversion < 0x02050000:
-    print("Requires python 2.5 or higher")
+if sys.hexversion < 0x02070000:
+    print("Requires python 2.7 or higher")
     sys.exit(1)
 import os
 # Allow to be run stright from package root
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index e8c649b..be6b234 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -645,7 +645,7 @@ C.compound([C.bind_conn_to_session_op('0000000000000001', False, 3, False, 73, d
 
 
 """ PROGRAM COVERAGE
-python2.5 ~/py_install/bin/coverage.py -x nfs4server.py
+python2.7 ~/py_install/bin/coverage.py -x nfs4server.py
 coverage.py -a -d cover nfs4server.py
 run test suite
 """
diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index d46706a..5fed3ba 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -28,7 +28,7 @@ state00 = xdrdef.nfs4_type.stateid4(0, "\0" * 12)
 state11 = xdrdef.nfs4_type.stateid4(0xffffffff, "\xff" * 12)
 state01 = xdrdef.nfs4_type.stateid4(1, "\0" * 12)
 
-import hashlib # Note this requires 2.5 or higher
+import hashlib # Note this requires 2.7 or higher
 
 op4 = nfs_ops.NFS4ops()
 
diff --git a/nfs4.1/testclient.py b/nfs4.1/testclient.py
index 5d21eaa..19bd148 100755
--- a/nfs4.1/testclient.py
+++ b/nfs4.1/testclient.py
@@ -1,7 +1,7 @@
 #!/usr/bin/env python
 # nfs4stest.py - nfsv4 server tester
 #
-# Requires python 2.5
+# Requires python 2.7
 # 
 # Written by Fred Isaman <iisaman@citi.umich.edu>
 # Copyright (C) 2004 University of Michigan, Center for 
@@ -23,8 +23,8 @@
 
 import use_local # HACK so don't have to rebuild constantly
 import sys
-if sys.hexversion < 0x02050000:
-    print("Requires python 2.5 or higher")
+if sys.hexversion < 0x02070000:
+    print("Requires python 2.7 or higher")
     sys.exit(1)
 import os
 
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 6f576e2..68f7a5f 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -1,6 +1,6 @@
 # testmod.py - run tests from a suite
 #
-# Requires python 2.5
+# Requires python 2.7
 # 
 # Written by Fred Isaman <iisaman@citi.umich.edu>
 # Copyright (C) 2004 University of Michigan, Center for 
@@ -157,6 +157,9 @@ class Test(object):
         else:
             return 1
 
+    def __lt__(self, other):
+        return self.__cmp__(other)
+
     def __str__(self):
         return "%-8s %s" % ( self.code, self.fullname)
 
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index 2becc13..249837e 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -1,7 +1,7 @@
 #!/usr/bin/env python
 # nfs4stest.py - nfsv4 server tester
 #
-# Requires python 2.5
+# Requires python 2.7
 # 
 # Written by Fred Isaman <iisaman@citi.umich.edu>
 # Copyright (C) 2004 University of Michigan, Center for 
@@ -27,8 +27,8 @@
 
 import use_local # HACK so don't have to rebuild constantly
 import sys
-if sys.hexversion < 0x02050000:
-    print("Requires python 2.5 or higher")
+if sys.hexversion < 0x02070000:
+    print("Requires python 2.7 or higher")
     sys.exit(1)
 import os
 
-- 
2.17.1

