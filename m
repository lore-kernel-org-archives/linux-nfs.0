Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:60404 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbbGPQuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2015 12:50:19 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 7639E280A39
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2015 18:40:31 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 67C4113E9F
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2015 18:40:30 +0200 (MEST)
From: tigran.mkrtchyan@desy.de
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] pynfs: reduce code duplication
Date: Thu, 16 Jul 2015 18:40:28 +0200
Message-Id: <1437064828-15387-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

the test suite has two methods: check and checklist to
validate status codes of a compound operation. The both
methods are identical, except one of them accept a single
status code and other accepts a list.

Modify 'check' to accept a list as well to reduce code
duplication.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/environment.py        | 40 ++++++++++++------------------
 nfs4.1/server41tests/st_current_stateid.py |  6 ++---
 nfs4.1/server41tests/st_delegation.py      |  6 ++---
 nfs4.1/server41tests/st_destroy_session.py |  2 +-
 nfs4.1/server41tests/st_exchange_id.py     |  4 +--
 nfs4.1/server41tests/st_lookup.py          | 10 ++++----
 nfs4.1/server41tests/st_open.py            |  2 +-
 nfs4.1/server41tests/st_reboot.py          |  2 +-
 nfs4.1/server41tests/st_rename.py          | 14 +++++------
 nfs4.1/server41tests/st_verify.py          |  4 +--
 10 files changed, 41 insertions(+), 49 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 1d87dda..13473f7 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -162,7 +162,7 @@ class Environment(testmod.Environment):
         for comp in self.opts.home:
             path.append(comp)
             res = sess.compound(use_obj(path))
-            checklist(res, [NFS4_OK, NFS4ERR_NOENT],
+            check(res, [NFS4_OK, NFS4ERR_NOENT],
                       "LOOKUP /%s," % '/'.join(path))
             if res.status == NFS4ERR_NOENT:
                 res = create_obj(sess, path, NF4DIR)
@@ -170,7 +170,7 @@ class Environment(testmod.Environment):
         # ensure /tree exists and is empty
         tree = self.opts.path + ['tree']
         res = sess.compound(use_obj(tree))
-        checklist(res, [NFS4_OK, NFS4ERR_NOENT])
+        check(res, [NFS4_OK, NFS4ERR_NOENT])
         if res.status == NFS4ERR_NOENT:
             res = create_obj(sess, tree, NF4DIR)
             check(res, msg="Trying to create /%s," % '/'.join(tree))
@@ -262,36 +262,24 @@ def fail(msg):
     raise testmod.FailureException(msg)
 
 def check(res, stat=NFS4_OK, msg=None, warnlist=[]):
-    #if res.status == stat:
-    #    return
+
     if type(stat) is str:
         raise "You forgot to put 'msg=' in front of check's string arg"
-    log.debug("checking %r == %r" % (res, stat))
-    if res.status == stat:
+
+    statlist = stat
+    if type(statlist) == int:
+        statlist = [stat]
+
+    log.debug("checking %r == %r" % (res, statlist))
+    if res.status in statlist:
         if not (debug_fail and msg):
             return
-    desired = nfsstat4[stat]
-    received = nfsstat4[res.status]
-    if msg:
-        failedop_name = msg
-    elif res.resarray:
-        failedop_name = nfs_opnum4[res.resarray[-1].resop]
-    else:
-        failedop_name = 'Compound'
-    msg = "%s should return %s, instead got %s" % \
-          (failedop_name, desired, received)
-    if res.status in warnlist:
-        raise testmod.WarningException(msg)
-    else:
-        raise testmod.FailureException(msg)
 
-def checklist(res, statlist, msg=None):
-    if res.status in statlist:
-        return
     statnames = [nfsstat4[stat] for stat in statlist]
     desired = ' or '.join(statnames)
     if not desired:
         desired = 'one of <none>'
+
     received = nfsstat4[res.status]
     if msg:
         failedop_name = msg
@@ -301,7 +289,11 @@ def checklist(res, statlist, msg=None):
         failedop_name = 'Compound'
     msg = "%s should return %s, instead got %s" % \
           (failedop_name, desired, received)
-    raise testmod.FailureException(msg)
+    if res.status in warnlist:
+        raise testmod.WarningException(msg)
+    else:
+        raise testmod.FailureException(msg)
+
 
 def checkdict(expected, got, translate={}, failmsg=''):
     if failmsg: failmsg += ': '
diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index aa1f689..a0d6757 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -1,7 +1,7 @@
 from st_create_session import create_session
 from xdrdef.nfs4_const import *
 
-from environment import check, checklist, fail, create_file, open_file, close_file
+from environment import check, fail, create_file, open_file, close_file
 from environment import open_create_file_op, use_obj
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 from xdrdef.nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
@@ -99,7 +99,7 @@ def testOpenLookupClose(t, env):
     open_op = open_create_file_op(sess1, fname, open_create=OPEN4_CREATE)
     lookup_op = env.home + [op.lookup(fname)]
     res = sess1.compound(open_op + lookup_op + [op.close(0, current_stateid)])
-    checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
+    check(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
 
 def testCloseNoStateid(t, env):
     """test current state id processing by having CLOSE
@@ -116,7 +116,7 @@ def testCloseNoStateid(t, env):
     stateid = res.resarray[-2].stateid
 
     res = sess1.compound([op.putfh(fh), op.close(0, current_stateid)])
-    checklist(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
+    check(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
 
 def testOpenLayoutGet(t, env):
     """test current state id processing by having OPEN and LAYOUTGET
diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index ab01570..a506692 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -2,7 +2,7 @@ from st_create_session import create_session
 from st_open import open_claim4
 from xdrdef.nfs4_const import *
 
-from environment import check, checklist, fail, create_file, open_file, close_file
+from environment import check, fail, create_file, open_file, close_file
 from xdrdef.nfs4_type import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
@@ -59,7 +59,7 @@ def _testDeleg(t, env, openaccess, want, breakaccess, sec = None, sec2 = None):
     check(res)
     # Now get OPEN reply
     res = sess2.listen(slot)
-    checklist(res, [NFS4_OK, NFS4ERR_DELAY])
+    check(res, [NFS4_OK, NFS4ERR_DELAY])
     return recall
 
 def testReadDeleg(t, env):
@@ -181,7 +181,7 @@ def testDelegRevocation(t, env):
         res = sess2.compound(env.home + [open_op])
         if res.status == NFS4_OK:
             break;
-        checklist(res, [NFS4_OK, NFS4ERR_DELAY])
+        check(res, [NFS4_OK, NFS4ERR_DELAY])
 	# just to keep sess1 renewed.  This is a bit fragile, as we
         # depend on the above compound waiting no longer than the
         # server's lease period:
diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index d5bc9db..3c69983 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from xdrdef.nfs4_const import *
-from environment import check, checklist, fail, create_file, open_file
+from environment import check, fail, create_file, open_file
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 import nfs_ops
 op = nfs_ops.NFS4ops()
diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index 8867527..b0ab99c 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -2,7 +2,7 @@ from xdrdef.nfs4_const import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
 import time
-from environment import check, checklist, fail
+from environment import check, fail
 from xdrdef.nfs4_type import *
 from rpc import RPCAcceptError, GARBAGE_ARGS, RPCTimeout
 from nfs4lib import NFS4Error, hash_oids, encrypt_oids
@@ -394,7 +394,7 @@ def testUpdate100(t, env):
     res = _raw_exchange_id(env.c1, env.testname(t), verf=env.new_verifier(),
                            cred=env.cred2,
                            flags=EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)
-    checklist(res, [NFS4ERR_NOT_SAME, NFS4ERR_PERM])
+    check(res, [NFS4ERR_NOT_SAME, NFS4ERR_PERM])
     
 def testUpdate101(t, env):
     """
diff --git a/nfs4.1/server41tests/st_lookup.py b/nfs4.1/server41tests/st_lookup.py
index 63d1d5b..7ba6918 100644
--- a/nfs4.1/server41tests/st_lookup.py
+++ b/nfs4.1/server41tests/st_lookup.py
@@ -64,7 +64,7 @@ def testLongName(t, env):
 
 ##############################################################
 if 0:
-    from environment import check, checklist, get_invalid_utf8strings
+    from environment import check, get_invalid_utf8strings
 
     def testDir(t, env):
         """LOOKUP testtree dir
@@ -317,16 +317,16 @@ if 0:
         check(res)
         # Run tests
         res1 = c.compound(c.use_obj(dir + ['.']))
-        checklist(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+        check(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
                   "LOOKUP a nonexistant '.'")
         res2 = c.compound(c.use_obj(dir + ['..']))
-        checklist(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+        check(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
                   "LOOKUP a nonexistant '..'")
         res1 = c.compound(c.use_obj(dir + ['.', 'foo']))
-        checklist(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+        check(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
                   "LOOKUP a nonexistant '.'")
         res2 = c.compound(c.use_obj(dir + ['..', t.code]))
-        checklist(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+        check(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
                   "LOOKUP a nonexistant '..'")
 
     def testUnaccessibleDir(t, env):
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index ed4e4ee..24f051e 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,7 +1,7 @@
 from st_create_session import create_session
 from xdrdef.nfs4_const import *
 
-from environment import check, checklist, fail, create_file, open_file, close_file
+from environment import check, fail, create_file, open_file, close_file
 from environment import open_create_file_op
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 from xdrdef.nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index 144704d..b19c343 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -1,6 +1,6 @@
 from xdrdef.nfs4_const import *
 from xdrdef.nfs4_type import *
-from environment import check, checklist, fail, create_file, open_file, create_confirm
+from environment import check, fail, create_file, open_file, create_confirm
 import sys
 import os
 import nfs4lib
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index 3d49cce..f344733 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -1,5 +1,5 @@
 from xdrdef.nfs4_const import *
-from environment import check, checklist, fail, maketree, rename_obj, get_invalid_utf8strings, create_obj, create_confirm, link, use_obj, create_file
+from environment import check, fail, maketree, rename_obj, get_invalid_utf8strings, create_obj, create_confirm, link, use_obj, create_file
 import nfs_ops
 op = nfs_ops.NFS4ops()
 from xdrdef.nfs4_type import *
@@ -132,7 +132,7 @@ def testSfhLink(t, env):
     name = env.testname(t)
     sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.uselink + [name], env.c1.homedir + [name])
-    checklist(res, [NFS4ERR_SYMLINK, NFS4ERR_NOTDIR], "RENAME with non-dir <sfh>")
+    check(res, [NFS4ERR_SYMLINK, NFS4ERR_NOTDIR], "RENAME with non-dir <sfh>")
 
 def testSfhBlock(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -202,7 +202,7 @@ def testCfhLink(t, env):
     res = create_obj(sess, env.c1.homedir + [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.uselink + [name])
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
                                 "RENAME with non-dir <cfh>")
 
 def testCfhBlock(t, env):
@@ -390,7 +390,7 @@ def testDirToObj(t, env):
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['dir'], basedir + ['file'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies NOTDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
 
 def testDirToDir(t, env):
     """RENAME dir into existing, empty dir should retrun NFS4_OK
@@ -417,7 +417,7 @@ def testFileToDir(t, env):
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
 
 def testFileToFile(t, env):
     """RENAME file into existing file should return NFS4_OK
@@ -443,7 +443,7 @@ def testDirToFullDir(t, env):
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2', ['foo']]])
     res = rename_obj(sess, basedir + ['dir1'], basedir + ['dir2'])
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
 
 def testFileToFullDir(t, env):
     """RENAME file into existing, nonempty dir should fail
@@ -457,7 +457,7 @@ def testFileToFullDir(t, env):
     maketree(sess, [name, 'file', ['dir', ['foo']]])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
 
 
 def testSelfRenameDir(t, env):
diff --git a/nfs4.1/server41tests/st_verify.py b/nfs4.1/server41tests/st_verify.py
index ef98c8d..7fb8a47 100644
--- a/nfs4.1/server41tests/st_verify.py
+++ b/nfs4.1/server41tests/st_verify.py
@@ -1,7 +1,7 @@
 from xdrdef.nfs4_const import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
-from environment import check, checklist, get_invalid_clientid, makeStaleId, \
+from environment import check, get_invalid_clientid, makeStaleId, \
     do_getattrdict, use_obj
 
 def _try_mand(t, env, path):
@@ -47,7 +47,7 @@ def _try_unsupported(env, path):
         ops = baseops + [c.verify_op({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         if attr.writeonly:
-            checklist(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
+            check(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
                       "VERIFY with unsupported attr %s" % attr.name)
         else:
             check(res, NFS4ERR_ATTRNOTSUPP,
-- 
2.4.3

