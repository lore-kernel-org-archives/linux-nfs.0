Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35645 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbC3Jed (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 05:34:33 -0400
Received: by pddn5 with SMTP id n5so54184056pdd.2
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 02:34:33 -0700 (PDT)
Message-ID: <551918A4.7060109@gmail.com>
Date: Mon, 30 Mar 2015 17:34:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 2/3] 4.1 server tests: new helper new_pnfs_client_session
 for pnfs client
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/nfs4client.py                       |  9 +++++
 nfs4.1/server41tests/st_block.py           | 12 +++----
 nfs4.1/server41tests/st_current_stateid.py |  6 ++--
 nfs4.1/server41tests/st_debug.py           | 12 ++-----
 nfs4.1/server41tests/st_getdevicelist.py   | 54 +++++-------------------------
 5 files changed, 26 insertions(+), 67 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 9ffe310..62ccc3a 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -297,6 +297,15 @@ class NFS4Client(rpc.Client, rpc.Server):
         s.compound([op4.reclaim_complete(FALSE)])
         return s
 
+    def new_pnfs_client_session(self, name, flags=EXCHGID4_FLAG_USE_PNFS_MDS, sec=None):
+        # Make sure E_ID returns MDS capabilities
+        c = self.new_client(name, flags=flags)
+        if not c.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
+            fail("Server can not be used as pnfs metadata server")
+        s = c.create_session(sec=sec)
+        s.compound([op4.reclaim_complete(FALSE)])
+        return s
+
     def create_tag(self):
         current_stack = inspect.stack()
         stackid = 0
diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index a8c43dc..bf968f9 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -15,8 +15,7 @@ def testStateid1(t, env):
     FLAGS: block
     CODE: BLOCK1
     """
-    sess = env.c1.new_client_session(env.testname(t),
-                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -57,8 +56,7 @@ def testStateid2(t, env):
     FLAGS: block
     CODE: BLOCK2
     """
-    c1 = env.c1.new_client_session(env.testname(t),
-                                    flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -117,8 +115,7 @@ def testEmptyCommit(t, env):
     FLAGS: block
     CODE: BLOCK3
     """
-    c1 = env.c1.new_client_session(env.testname(t),
-                                    flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -179,8 +176,7 @@ def testSplitCommit(t, env):
     FLAGS: block
     CODE: BLOCK4
     """
-    sess = env.c1.new_client_session(env.testname(t),
-                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 98fc76f..aa1f689 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -125,8 +125,7 @@ def testOpenLayoutGet(t, env):
     FLAGS: currentstateid pnfs
     CODE: CSID7
     """
-    sess = env.c1.new_client_session(env.testname(t),
-                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
 
     open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
     res = sess.compound( open_op + 
@@ -142,8 +141,7 @@ def testOpenSetattr(t, env):
     CODE: CSID8
     """
     size = 8
-    sess = env.c1.new_client_session(env.testname(t),
-                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
 
     open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
     res = sess.compound( open_op +
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index efef6b5..233ca54 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -94,11 +94,7 @@ def testLayout(t, env):
     FLAGS: layout all
     CODE: LAYOUT1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
@@ -126,11 +122,7 @@ def testGetDevList(t, env):
     FLAGS: layout all
     CODE: LAYOUT2
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index 2765be8..b181020 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -14,11 +14,7 @@ def testGetDevList(t, env):
     FLAGS: pnfs
     CODE: GETDLIST1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server did not set EXCHGID4_FLAG_USE_PNFS_MDS")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
@@ -41,11 +37,7 @@ def testGetDevInfo(t, env):
     DEPEND: GETDLIST1
     CODE: GETDINFO1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server did not set EXCHGID4_FLAG_USE_PNFS_MDS")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
@@ -77,11 +69,7 @@ def testGetDevInfo(t, env):
 ##     FLAGS: pnfs
 ##     CODE: GETLAYOUT1
 ##     """
-##     # Make sure E_ID returns MDS capabilities
-##     c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-##     if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-##         fail("Server can not be used as pnfs metadata server")
-##     sess = c1.create_session()
+##     sess = env.c1.new_pnfs_client_session(env.testname(t))
 ##     # Test that fs handles block layouts
 ##     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
 ##     res = sess.compound(ops)
@@ -109,11 +97,7 @@ def testGetLayout(t, env):
     FLAGS: pnfs
     CODE: GETLAYOUT1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
@@ -150,11 +134,7 @@ def testEMCGetLayout(t, env):
     FLAGS: 
     CODE: GETLAYOUT100
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
@@ -192,11 +172,7 @@ def testLayoutReturnFile(t, env):
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -225,11 +201,7 @@ def testLayoutReturnFsid(t, env):
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET2
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     print sess.c.homedir
     # Create the file
     res = create_file(sess, env.testname(t))
@@ -257,11 +229,7 @@ def testLayoutReturnAll(t, env):
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET3
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     print sess.c.homedir
     # Create the file
     res = create_file(sess, env.testname(t))
@@ -287,11 +255,7 @@ def testLayoutCommit(t, env):
     FLAGS: pnfs
     CODE: LAYOUTCOMMIT1
     """
-    # Make sure E_ID returns MDS capabilities
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    if not c1.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-        fail("Server can not be used as pnfs metadata server")
-    sess = c1.create_session()
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
     # Test that fs handles block layouts
     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES |
                                                1<<FATTR4_LAYOUT_BLKSIZE)]
-- 
2.3.4

