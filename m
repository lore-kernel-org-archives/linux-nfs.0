Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:45876 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2AOTCo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:02:44 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id D7B961764
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:42 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8976313E86
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:40 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/5] client: move current stateid test into a dedicated module
Date: Sun, 15 Jan 2012 20:05:24 +0100
Message-Id: <1326654328-20557-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/__init__.py           |    1 +
 nfs4.1/server41tests/st_current_stateid.py |   86 ++++++++++++++++++++++++++++
 nfs4.1/server41tests/st_open.py            |   76 ------------------------
 3 files changed, 87 insertions(+), 76 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_current_stateid.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index eb92538..2bedb57 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -20,4 +20,5 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_block.py",
 ##           "st_debug.py",
 ##           "st_loop",
+           "st_current_stateid.py",
            ]
diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
new file mode 100644
index 0000000..1f24ec9
--- /dev/null
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -0,0 +1,86 @@
+from st_create_session import create_session
+from nfs4_const import *
+
+from environment import check, checklist, fail, create_file, open_file, close_file
+from environment import open_create_file_op
+from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
+from nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
+from nfs4_type import open_to_lock_owner4
+import nfs4_ops as op
+import threading
+
+
+current_stateid = stateid4(1, '\0' * 12)
+
+def testOpenAndClose(t, env):
+    """test current state id processing by having OPEN and CLOSE
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID1
+    """    
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.close(0, current_stateid)])
+    check(res, NFS4_OK)
+
+def testLockLockU(t, env):
+    """test current state id processing by having LOCK and LOCKU
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID2
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
+    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
+    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
+	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
+    res = sess1.compound([op.putfh(fh)] + lock_ops)
+    check(res, NFS4_OK)
+
+def testOpenWriteClose(t, env):
+    """test current state id processing by having OPEN, WRITE and CLOSE
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID3
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    data = "write test data"
+    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
+    res = sess1.compound(open_op + [op.write(current_stateid, 5, FILE_SYNC4, data),
+        op.close(0, current_stateid)])
+    check(res, NFS4_OK)
+
+def testLockWriteLocku(t, env):
+    """test current state id processing by having LOCK, WRITE and LOCKU
+       in a single compound
+
+    FLAGS: currentstateid all
+    CODE: CSID4
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    data = "write test data"
+    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
+    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
+    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
+        op.write(current_stateid, 5, FILE_SYNC4, data),
+        op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX),
+        op.close(0, stateid)]
+    res = sess1.compound([op.putfh(fh)] + lock_ops)
+    check(res, NFS4_OK)
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 1c51f71..895916a 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -240,79 +240,3 @@ def testOPENClaimFH(t, env):
     if res.resarray[-1].data != desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
 
-def testOpenAndClose(t, env):
-    """test current state id processing by having OPEN and CLOSE
-       in a single compound
-
-    FLAGS: currentstateid open all
-    CODE: OPEN31
-    """
-    current_stateid = stateid4(1, '\0' * 12)
-    sess1 = env.c1.new_client_session(env.testname(t))
-
-    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
-    res = sess1.compound(open_op + [op.close(0, current_stateid)])
-    check(res, NFS4_OK)
-
-def testLockLockU(t, env):
-    """test current state id processing by having LOCK and LOCKU
-       in a single compound
-
-    FLAGS: currentstateid open all
-    CODE: OPEN32
-    """
-    current_stateid = stateid4(1, '\0' * 12)
-    sess1 = env.c1.new_client_session(env.testname(t))
-
-    res = create_file(sess1, env.testname(t))
-    check(res)
-    fh = res.resarray[-1].object
-    stateid = res.resarray[-2].stateid
-
-    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
-    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
-    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
-	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
-    res = sess1.compound([op.putfh(fh)] + lock_ops)
-    check(res, NFS4_OK)
-
-def testOpenWriteClose(t, env):
-    """test current state id processing by having OPEN, WRITE and CLOSE
-       in a single compound
-
-    FLAGS: currentstateid open all
-    CODE: OPEN33
-    """
-    current_stateid = stateid4(1, '\0' * 12)
-    sess1 = env.c1.new_client_session(env.testname(t))
-
-    data = "write test data"
-    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
-    res = sess1.compound(open_op + [op.write(current_stateid, 5, FILE_SYNC4, data),
-        op.close(0, current_stateid)])
-    check(res, NFS4_OK)
-
-def testLockWriteLocku(t, env):
-    """test current state id processing by having LOCK, WRITE and LOCKU
-       in a single compound
-
-    FLAGS: currentstateid open all
-    CODE: OPEN34
-    """
-    current_stateid = stateid4(1, '\0' * 12)
-    sess1 = env.c1.new_client_session(env.testname(t))
-
-    res = create_file(sess1, env.testname(t))
-    check(res)
-    fh = res.resarray[-1].object
-    stateid = res.resarray[-2].stateid
-
-    data = "write test data"
-    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
-    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
-    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
-        op.write(current_stateid, 5, FILE_SYNC4, data),
-        op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX),
-        op.close(0, stateid)]
-    res = sess1.compound([op.putfh(fh)] + lock_ops)
-    check(res, NFS4_OK)
-- 
1.7.7.5

