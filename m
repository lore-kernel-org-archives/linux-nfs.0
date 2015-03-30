Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33551 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbC3Jen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 05:34:43 -0400
Received: by pacgg7 with SMTP id gg7so32839815pac.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 02:34:43 -0700 (PDT)
Message-ID: <551918AB.5030004@gmail.com>
Date: Mon, 30 Mar 2015 17:34:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 3/3] 4.1 server tests: new helper get_blocksize for pnfs client
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/environment.py      | 19 ++++++++++
 nfs4.1/server41tests/st_debug.py         | 11 ++----
 nfs4.1/server41tests/st_getdevicelist.py | 59 ++++++++------------------------
 3 files changed, 36 insertions(+), 53 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 7cc64b0..11c1b12 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -587,6 +587,25 @@ def create_close(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     close_file(sess, fh, stateid=stateid)
     return fh;
 
+def get_blocksize(sess, path, layout_type=LAYOUT4_BLOCK_VOLUME):
+    """ Test that fs handles layouts type, and get the blocksize
+
+    Returns the blocksize
+    """
+    if path is None:
+        fail("Needs path!!!")
+
+    ops = path + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES |
+                             1<<FATTR4_LAYOUT_BLKSIZE)]
+    res = sess.compound(ops)
+    check(res)
+    attrdict = res.resarray[-1].obj_attributes
+    if FATTR4_FS_LAYOUT_TYPES not in attrdict:
+        fail("fs_layout_type not available")
+    if LAYOUT4_BLOCK_VOLUME not in attrdict[FATTR4_FS_LAYOUT_TYPES]:
+        fail("layout_type does not contain BLOCK")
+    return attrdict[FATTR4_LAYOUT_BLKSIZE]
+
 def _getname(owner, path):
     if path is None:
         return owner
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index 233ca54..2b9890e 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -95,14 +95,7 @@ def testLayout(t, env):
     CODE: LAYOUT1
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
-    res = sess.compound(ops)
-    check(res)
-    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
-        fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
-        fail("layout_type does not contain BLOCK")
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Open the file
     owner = "owner for %s" % env.testname(t)
     # openres = open_file(sess, owner, env.opts.path + ["simple_extent"])
@@ -112,7 +105,7 @@ def testLayout(t, env):
     fh = openres.resarray[-1].object
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffff, 0, 0xffff)]
+                        0, 0xffffffff, 4*blocksize, 0xffff)]
     res = sess.compound(ops)
     check(res)
     
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index b181020..a556ce0 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -1,6 +1,6 @@
 from xdrdef.nfs4_const import *
 from xdrdef.nfs4_type import *
-from environment import check, fail, use_obj, open_file, create_file
+from environment import check, fail, use_obj, open_file, create_file, get_blocksize
 import nfs_ops
 op = nfs_ops.NFS4ops()
 from block import Packer as BlockPacker, Unpacker as BlockUnpacker, \
@@ -70,14 +70,7 @@ def testGetDevInfo(t, env):
 ##     CODE: GETLAYOUT1
 ##     """
 ##     sess = env.c1.new_pnfs_client_session(env.testname(t))
-##     # Test that fs handles block layouts
-##     ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
-##     res = sess.compound(ops)
-##     check(res)
-##     if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
-##         fail("fs_layout_type not available")
-##     if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
-##         fail("layout_type does not contain BLOCK")
+##     blocksize = get_blocksize(sess, use_obj(env.opts.path))
 ##     # Open the file
 ##     owner = "owner for %s" % env.testname(t)
 ##     # openres = open_file(sess, owner, env.opts.path + ["simple_extent"])
@@ -85,9 +78,10 @@ def testGetDevInfo(t, env):
 ##     check(openres)
 ##     # Get a layout
 ##     fh = openres.resarray[-1].object
+##     open_stateid = openres.resarray[-2].stateid
 ##     ops = [op.putfh(fh),
 ##            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-##                         0, 0xffffffff, 0, 0xffff)]
+##                         0, 0xffffffff, 4*blocksize, open_stateid, 0xffff)]
 ##     res = sess.compound(ops)
 ##     check(res)
     
@@ -98,14 +92,7 @@ def testGetLayout(t, env):
     CODE: GETLAYOUT1
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
-    res = sess.compound(ops)
-    check(res)
-    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
-        fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
-        fail("layout_type does not contain BLOCK")
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -114,7 +101,7 @@ def testGetLayout(t, env):
     open_stateid = res.resarray[-2].stateid
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffffffffffff, 0, open_stateid, 0xffff)]
+                        0, 0xffffffffffffffff, 4*blocksize, open_stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     # Parse opaque
@@ -135,14 +122,7 @@ def testEMCGetLayout(t, env):
     CODE: GETLAYOUT100
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES)]
-    res = sess.compound(ops)
-    check(res)
-    if FATTR4_FS_LAYOUT_TYPES not in res.resarray[-1].obj_attributes:
-        fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in res.resarray[-1].obj_attributes[FATTR4_FS_LAYOUT_TYPES]:
-        fail("layout_type does not contain BLOCK")
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     file = ["server2fs1", "dump.eth"]
     res = open_file(sess, env.testname(t), file)
@@ -153,7 +133,7 @@ def testEMCGetLayout(t, env):
     stateid.seqid = 0
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffffffffffff, 0, stateid, 0xffff)]
+                        0, 0xffffffffffffffff, 4*blocksize, stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     # Parse opaque
@@ -173,6 +153,7 @@ def testLayoutReturnFile(t, env):
     CODE: LAYOUTRET1
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -181,7 +162,7 @@ def testLayoutReturnFile(t, env):
     open_stateid = res.resarray[-2].stateid
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffffffffffff, 0, open_stateid, 0xffff)]
+                        0, 0xffffffffffffffff, 4*blocksize, open_stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     # Return layout
@@ -202,7 +183,7 @@ def testLayoutReturnFsid(t, env):
     CODE: LAYOUTRET2
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    print sess.c.homedir
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -211,7 +192,7 @@ def testLayoutReturnFsid(t, env):
     open_stateid = res.resarray[-2].stateid
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffffffffffff, 0, open_stateid, 0xffff)]
+                        0, 0xffffffffffffffff, 4*blocksize, open_stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     # Return layout
@@ -230,7 +211,7 @@ def testLayoutReturnAll(t, env):
     CODE: LAYOUTRET3
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    print sess.c.homedir
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -239,7 +220,7 @@ def testLayoutReturnAll(t, env):
     open_stateid = res.resarray[-2].stateid
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
-                        0, 0xffffffffffffffff, 0, open_stateid, 0xffff)]
+                        0, 0xffffffffffffffff, 4*blocksize, open_stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     # Return layout
@@ -256,17 +237,7 @@ def testLayoutCommit(t, env):
     CODE: LAYOUTCOMMIT1
     """
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    # Test that fs handles block layouts
-    ops = use_obj(env.opts.path) + [op.getattr(1<<FATTR4_FS_LAYOUT_TYPES |
-                                               1<<FATTR4_LAYOUT_BLKSIZE)]
-    res = sess.compound(ops)
-    check(res)
-    attrdict = res.resarray[-1].obj_attributes
-    if FATTR4_FS_LAYOUT_TYPES not in attrdict:
-        fail("fs_layout_type not available")
-    if LAYOUT4_BLOCK_VOLUME not in attrdict[FATTR4_FS_LAYOUT_TYPES]:
-        fail("layout_type does not contain BLOCK")
-    blocksize = attrdict[FATTR4_LAYOUT_BLKSIZE]
+    blocksize = get_blocksize(sess, use_obj(env.opts.path))
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
-- 
2.3.4

