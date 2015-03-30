Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33580 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbC3JeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 05:34:25 -0400
Received: by pdnc3 with SMTP id c3so170438900pdn.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 02:34:24 -0700 (PDT)
Message-ID: <55191898.8010803@gmail.com>
Date: Mon, 30 Mar 2015 17:34:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 1/3] 4.1 server tests: fix typos of FATTR4_FS_LAYOUT_TYPES
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit b01fb7d36d (nfs4.1 server: fix typos related to file layout)
have rename "FATTR4_FS_LAYOUT_TYPE" to "FATTR4_FS_LAYOUT_TYPES".

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/st_debug.py         | 12 +++++------
 nfs4.1/server41tests/st_getdevicelist.py | 36 ++++++++++++++++----------------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index 7294fe7..efef6b5 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -100,12 +100,12 @@ def testLayout(t, env):
         fail("Server can not be used as pnfs metadata server")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         fail("layout_type does not contain BLOCK")
     # Open the file
     owner = "owner for %s" % env.testname(t)
@@ -132,12 +132,12 @@ def testGetDevList(t, env):
         fail("Server can not be used as pnfs metadata server")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         fail("layout_type does not contain BLOCK")
     # Send GETDEVICELIST
     ops = use_obj(env.opts.path) + [op.getdevicelist(LAYOUT4_BLOCK_VOLUME, 0, 0, "")]
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index 55fc706..2765be8 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -20,12 +20,12 @@ def testGetDevList(t, env):
         fail("Server did not set EXCHGID4_FLAG_USE_PNFS_MDS")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    for lo_type in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    for lo_type in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         # Send GETDEVICELIST
         ops = use_obj(env.opts.path) + [op.getdevicelist(lo_type, 0xffffffff, 0, "")]
         res = sess.compound(ops)
@@ -47,12 +47,12 @@ def testGetDevInfo(t, env):
         fail("Server did not set EXCHGID4_FLAG_USE_PNFS_MDS")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    for lo_type in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    for lo_type in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         # Send GETDEVICELIST
         lo_type = LAYOUT4_BLOCK_VOLUME
         ops = use_obj(env.opts.path) + [op.getdevicelist(lo_type, 0xffffffff, 0, "")]
@@ -83,12 +83,12 @@ def testGetDevInfo(t, env):
 ##         fail("Server can not be used as pnfs metadata server")
 ##     sess = c1.create_session()
 ##     # Test that fs handles block layouts
-##     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+##     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
 ##     res = sess.compound(ops)
 ##     check(res)
-##     if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+##     if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
 ##         fail("fs_layout_type not available")
-##     if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+##     if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
 ##         fail("layout_type does not contain BLOCK")
 ##     # Open the file
 ##     owner = "owner for %s" % env.testname(t)
@@ -115,12 +115,12 @@ def testGetLayout(t, env):
         fail("Server can not be used as pnfs metadata server")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         fail("layout_type does not contain BLOCK")
     # Create the file
     res = create_file(sess, env.testname(t))
@@ -156,12 +156,12 @@ def testEMCGetLayout(t, env):
         fail("Server can not be used as pnfs metadata server")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE)]
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
     res = sess.compound(ops)
     check(res)
-    if FATTR4_FS_LAYOUT_TYPE not in res.resarray[-1].obj_attributes:
+    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
         fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPE]:
+    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
         fail("layout_type does not contain BLOCK")
     # Create the file
     file = ["server2fs1", "dump.eth"]
@@ -293,14 +293,14 @@ def testLayoutCommit(t, env):
         fail("Server can not be used as pnfs metadata server")
     sess = c1.create_session()
     # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPE |
+    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES |
                                                1<<FATTR4_LAYOUT_BLKSIZE)]
     res = sess.compound(ops)
     check(res)
     attrdict = res.resarray[-1].obj_attributes
-    if FATTR4_FS_LAYOUT_TYPE not in attrdict:
+    if FATTR4_FS_LAYOUT_TYPES not in attrdict:
         fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in attrdict[FATTR4_FS_LAYOUT_TYPE]:
+    if LAYOUT4_BLOCK_VOLUME not in attrdict[FATTR4_FS_LAYOUT_TYPES]:
         fail("layout_type does not contain BLOCK")
     blocksize = attrdict[FATTR4_LAYOUT_BLKSIZE]
     # Create the file
-- 
2.3.4

