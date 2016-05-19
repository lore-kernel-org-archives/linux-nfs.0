Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:34737 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041AbcESPaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2016 11:30:25 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 9133D280500
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:22 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 7749A13E82
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:22 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] reduce code duplication
Date: Thu, 19 May 2016 17:30:16 +0200
Message-Id: <1463671819-4933-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

this is a similar to 215116a change, which merges
checklist and check functions into a single one.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/servertests/environment.py         | 38 ++++++++++++-------------------
 nfs4.0/servertests/st_acl.py              |  2 +-
 nfs4.0/servertests/st_commit.py           |  6 ++---
 nfs4.0/servertests/st_compound.py         |  4 ++--
 nfs4.0/servertests/st_create.py           | 12 +++++-----
 nfs4.0/servertests/st_delegation.py       | 14 ++++++------
 nfs4.0/servertests/st_getattr.py          |  6 ++---
 nfs4.0/servertests/st_link.py             |  8 +++----
 nfs4.0/servertests/st_lock.py             | 18 +++++++--------
 nfs4.0/servertests/st_lockt.py            |  8 +++----
 nfs4.0/servertests/st_locku.py            | 12 +++++-----
 nfs4.0/servertests/st_lookup.py           | 14 ++++++------
 nfs4.0/servertests/st_lookupp.py          |  4 ++--
 nfs4.0/servertests/st_nverify.py          |  4 ++--
 nfs4.0/servertests/st_open.py             |  8 +++----
 nfs4.0/servertests/st_openconfirm.py      |  2 +-
 nfs4.0/servertests/st_read.py             |  6 ++---
 nfs4.0/servertests/st_readdir.py          |  8 +++----
 nfs4.0/servertests/st_reboot.py           | 10 ++++----
 nfs4.0/servertests/st_releaselockowner.py |  2 +-
 nfs4.0/servertests/st_remove.py           |  4 ++--
 nfs4.0/servertests/st_rename.py           | 14 ++++++------
 nfs4.0/servertests/st_replay.py           |  4 ++--
 nfs4.0/servertests/st_setattr.py          |  6 ++---
 nfs4.0/servertests/st_setclientid.py      |  4 ++--
 nfs4.0/servertests/st_verify.py           |  4 ++--
 nfs4.0/servertests/st_write.py            |  4 ++--
 27 files changed, 108 insertions(+), 118 deletions(-)

diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 9852178..6fe083a 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -155,7 +155,7 @@ class Environment(testmod.Environment):
         for comp in self.opts.path:
             path.append(comp)
             res = c.compound(c.use_obj(path))
-            checklist(res, [NFS4_OK, NFS4ERR_NOENT],
+            check(res, [NFS4_OK, NFS4ERR_NOENT],
                   "Could not LOOKUP /%s," % '/'.join(path))
             if res.status == NFS4ERR_NOENT:
                 res = c.create_obj(path)
@@ -163,7 +163,7 @@ class Environment(testmod.Environment):
         # remove /tree/*
         tree = self.opts.path[:-1] + ['tree']
         res = c.compound(c.use_obj(tree))
-        checklist(res, [NFS4_OK, NFS4ERR_NOENT])
+        check(res, [NFS4_OK, NFS4ERR_NOENT])
         if res.status == NFS4ERR_NOENT:
             res = c.create_obj(tree)
             check(res, msg="Trying to create /%s," % '/'.join(tree))
@@ -233,31 +233,18 @@ class Environment(testmod.Environment):
 debug_fail = False
 
 def check(res, stat=NFS4_OK, msg=None, warnlist=[]):
-    #if res.status == stat:
-    #    return
-    if res.status == stat:
-        if not (debug_fail and msg):
-            return
+
     if type(stat) is str:
         raise "You forgot to put 'msg=' in front of check's string arg"
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
+    statlist = stat
+    if type(statlist) == int:
+        statlist = [stat]
+
     if res.status in statlist:
-        return
+        if not (debug_fail and msg):
+            return
+
     statnames = [nfsstat4[stat] for stat in statlist]
     desired = ' or '.join(statnames)
     if not desired:
@@ -271,7 +258,10 @@ def checklist(res, statlist, msg=None):
         failedop_name = 'Compound'
     msg = "%s should return %s, instead got %s" % \
           (failedop_name, desired, received)
-    raise testmod.FailureException(msg)
+    if res.status in warnlist:
+        raise testmod.WarningException(msg)
+    else:
+        raise testmod.FailureException(msg)
 
 def checkdict(expected, got, translate={}, failmsg=''):
     if failmsg: failmsg += ': '
diff --git a/nfs4.0/servertests/st_acl.py b/nfs4.0/servertests/st_acl.py
index 653d996..097a4ec 100644
--- a/nfs4.0/servertests/st_acl.py
+++ b/nfs4.0/servertests/st_acl.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 from nfs4_type import nfsace4
 
 # assuming server will accept any small positive integer as an owner
diff --git a/nfs4.0/servertests/st_commit.py b/nfs4.0/servertests/st_commit.py
index 6b8ade7..bdeceae 100644
--- a/nfs4.0/servertests/st_commit.py
+++ b/nfs4.0/servertests/st_commit.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 
 _text = "Random data to write"
 
@@ -15,7 +15,7 @@ def _commit(t, c, offset=0, count=0, statlist=[NFS4_OK]):
     res = c.write_file(fh, _text, 0, stateid, how=UNSTABLE4)
     check(res, msg="WRITE with how=UNSTABLE4")
     res = c.commit_file(fh, offset, count)
-    checklist(res, statlist, msg="COMMIT with offset=%x, count=%x" % (offset, count))
+    check(res, statlist, msg="COMMIT with offset=%x, count=%x" % (offset, count))
 
 def testCommitOffset0(t, env):
     """COMMIT
@@ -80,7 +80,7 @@ def testLink(t, env):
     """
     c = env.c1
     res = c.commit_file(env.opts.uselink)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "COMMIT with non-file object")
+    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "COMMIT with non-file object")
 
 def testBlock(t, env):
     """COMMIT
diff --git a/nfs4.0/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
index d2af73b..17ae26d 100644
--- a/nfs4.0/servertests/st_compound.py
+++ b/nfs4.0/servertests/st_compound.py
@@ -1,7 +1,7 @@
 from nfs4_const import *
 from nfs4_type import nfs_argop4
 from nfs4_pack import NFS4Packer
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 from rpc import RPCError
 
 def testZeroOps(t, env):
@@ -100,7 +100,7 @@ def testLongCompound(t, env):
         while 1:
             count += step
             res = c.compound(baseops * count)
-            checklist(res, [NFS4_OK, NFS4ERR_RESOURCE],
+            check(res, [NFS4_OK, NFS4ERR_RESOURCE],
                       "COMPOUND with len=%i argarry" % (3*count))
             if res.status == NFS4ERR_RESOURCE:
                 return
diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
index 490c75b..149c8d7 100644
--- a/nfs4.0/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import createtype4, specdata4
-from environment import check, checklist
+from environment import check
 
 def getDefaultAttr(c):
     attr = {}
@@ -91,7 +91,7 @@ def testDirOffLink(t, env):
     """
     c = env.c1
     res = c.create_obj(env.opts.uselink + [t.code])
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK])
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK])
      
 def testDirOffBlock(t, env):
     """CREATE dir off a block device
@@ -172,7 +172,7 @@ def testZeroLengthForLNK(t, env):
     objtype = createtype4(NF4LNK, **{'linkdata':''})
     ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_NOENT], "CREATE with zero-length name for SYMLINK")
+    check(res, [NFS4ERR_INVAL, NFS4ERR_NOENT], "CREATE with zero-length name for SYMLINK")
 
 def testRegularFile(t, env):
     """CREATE should fail with NFS4ERR_BADTYPE for regular files
@@ -228,10 +228,10 @@ def testDots(t, env):
     """
     c = env.c1
     res = c.create_obj(c.homedir + ['.'])
-    checklist(res, [NFS4_OK, NFS4ERR_BADNAME],
+    check(res, [NFS4_OK, NFS4ERR_BADNAME],
                   "Trying to CREATE a dir named '.'")
     res2 = c.create_obj(c.homedir + ['..'])
-    checklist(res2, [NFS4_OK, NFS4ERR_BADNAME],
+    check(res2, [NFS4_OK, NFS4ERR_BADNAME],
                   "Trying to CREATE a dir named '..'")
     if res.status == NFS4_OK or res2.status == NFS4_OK:
         t.pass_warn("Allowed creation of dir named '.' or '..'")
@@ -258,7 +258,7 @@ def testSlash(t, env):
     res = c.create_obj(c.homedir + [t.code + '/foo'])
     if res.status == NFS4_OK:
         t.pass_warn("Allowed creation of dir named '%s/foo'" % t.code)
-    checklist(res, [NFS4ERR_BADNAME, NFS4ERR_BADCHAR],
+    check(res, [NFS4ERR_BADNAME, NFS4ERR_BADCHAR],
                   "Creation of dir named '%s/foo'" % t.code)
 
 def testLongName(t, env):
diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index eaff326..6994f91 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import nfs_client_id4, clientaddr4, cb_client4
-from environment import check, checklist
+from environment import check
 import os
 import threading
 import time
@@ -54,7 +54,7 @@ def _cause_recall(t, env):
                           deny=OPEN4_SHARE_DENY_NONE)
         _lock.release()
         if res.status == NFS4_OK: break
-        checklist(res, [NFS4_OK, NFS4ERR_DELAY], "Open which causes recall")
+        check(res, [NFS4_OK, NFS4ERR_DELAY], "Open which causes recall")
         env.sleep(sleeptime, 'Got NFS4ERR_DELAY on open')
     return c.confirm('newowner', res)
 
@@ -291,7 +291,7 @@ def testRenew(t, env, funct=None, response=NFS4_OK):
                               access=OPEN4_SHARE_ACCESS_WRITE)
             env.sleep(lease / 2, "Waiting to send RENEW")
             res = c.compound([c.renew_op(c.clientid)])
-            checklist(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN], "RENEW")
+            check(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN], "RENEW")
             if res.status != NFS4_OK:
                 noticed = True
                 break
@@ -362,7 +362,7 @@ def testDelegShare(t, env, funct=_recall, response=NFS4_OK):
                           access=OPEN4_SHARE_ACCESS_WRITE)
         _lock.release()
         if res.status in  [NFS4_OK, NFS4ERR_SHARE_DENIED]: break
-        checklist(res, [NFS4_OK, NFS4ERR_DELAY, NFS4ERR_SHARE_DENIED],
+        check(res, [NFS4_OK, NFS4ERR_DELAY, NFS4ERR_SHARE_DENIED],
                   "Open which causes recall")
         env.sleep(sleeptime, 'Got NFS4ERR_DELAY on open')
         sleeptime += 5
@@ -410,7 +410,7 @@ def testChangeDeleg(t, env, funct=_recall):
     confirm = res.resarray[0].switch.switch.setclientid_confirm
     confirmop = c.setclientid_confirm_op(c.clientid, confirm)
     res = c.compound([confirmop])
-    checklist(res, [NFS4_OK, NFS4ERR_RESOURCE])
+    check(res, [NFS4_OK, NFS4ERR_RESOURCE])
     if res.status == NFS4ERR_RESOURCE:
         # ibm workaround
         res = c.compound([confirmop])
@@ -522,7 +522,7 @@ def testClaimCur(t, env):
     res = c.open_file('newowner', c.homedir + [t.code],
                       access=OPEN4_SHARE_ACCESS_WRITE,
                       deny=OPEN4_SHARE_DENY_NONE)
-    checklist(res, [NFS4_OK, NFS4ERR_DELAY], "Open which causes recall")
+    check(res, [NFS4_OK, NFS4ERR_DELAY], "Open which causes recall")
     env.sleep(2, "Waiting for recall")
 
     # Now send some opens
@@ -541,7 +541,7 @@ def _retry_conflicting_op(env, c, op, opname):
         res = c.compound(op)
         _lock.release()
         if res.status == NFS4_OK: break
-        checklist(res, [NFS4_OK, NFS4ERR_DELAY],
+        check(res, [NFS4_OK, NFS4ERR_DELAY],
                             "%s which causes recall" % opname)
         env.sleep(1, 'Got NFS4ERR_DELAY on %s' % opname)
                             
diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index 6a4acdd..9dede73 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 from nfs4lib import get_attr_name
 
 def _try_mandatory(t, env, path):
@@ -481,7 +481,7 @@ def testFSLocations(t, env):
     ops = c.use_obj(env.opts.usefile)
     ops += [c.getattr([FATTR4_FS_LOCATIONS])]
     res = c.compound(ops)
-    checklist(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(fs_locations)")
+    check(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(fs_locations)")
     if res.status == NFS4ERR_ATTRNOTSUPP:
         t.fail_support("fs_locations not a supported attribute")
     # print res.resarray[-1].obj_attributes
@@ -512,7 +512,7 @@ def testOwnerName(t, env):
     ops = c.use_obj(env.opts.usefile)
     ops += [c.getattr([FATTR4_OWNER])]
     res = c.compound(ops)
-    checklist(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(owner)")
+    check(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(owner)")
     if res.status == NFS4ERR_ATTRNOTSUPP:
         t.fail_support("owner not a supported attribute")
     # print res.resarray[-1].obj_attributes
diff --git a/nfs4.0/servertests/st_link.py b/nfs4.0/servertests/st_link.py
index 633025b..d87b14d 100644
--- a/nfs4.0/servertests/st_link.py
+++ b/nfs4.0/servertests/st_link.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 
 def _basictest(t, c, path, error=NFS4_OK):
     """Link to path, and make sure FATTR4_NUMLINKS increases by one"""
@@ -143,7 +143,7 @@ def testCfhLink(t, env):
     CODE: LINK4a
     """
     res = env.c1.link(env.opts.usefile, env.opts.uselink + [t.code])
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
                 "LINK with <cfh> not a directory")
 
 def testCfhBlock(t, env):
@@ -238,10 +238,10 @@ def testDots(t, env):
     res = c.create_obj(dir)
     check(res)
     res1 = c.link(env.opts.usefile, dir + ['.'])
-    checklist(res1, [NFS4_OK, NFS4ERR_BADNAME],
+    check(res1, [NFS4_OK, NFS4ERR_BADNAME],
                   "Trying to make a hardlink named '.'")
     res2 = c.link(env.opts.usefile, dir + ['..'])
-    checklist(res2, [NFS4_OK, NFS4ERR_BADNAME],
+    check(res2, [NFS4_OK, NFS4ERR_BADNAME],
                   "Trying to make a hardlink named '..'")
     if res1.status == NFS4_OK or res2.status == NFS4_OK:
         t.pass_warn("Allowed creation of hardlink named '.' or '..'")
diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
index d54614d..5e5c69c 100644
--- a/nfs4.0/servertests/st_lock.py
+++ b/nfs4.0/servertests/st_lock.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import stateid4
-from environment import check, checklist, get_invalid_clientid, makeStaleId, makeBadIDganesha
+from environment import check, get_invalid_clientid, makeStaleId, makeBadIDganesha
 import time
 
 def testFile(t, env):
@@ -33,7 +33,7 @@ def testClose(t, env):
     res = c.lock_test(fh)
     check(res, NFS4ERR_DENIED, "Testing file %s is locked" % t.code)
     res = c.close_file(t.code, fh, stateid)
-    checklist(res, [NFS4_OK, NFS4ERR_LOCKS_HELD],
+    check(res, [NFS4_OK, NFS4ERR_LOCKS_HELD],
               "Trying to close locked file")
     if res.status == NFS4ERR_LOCKS_HELD:
         t.fail_support("Can not close locked files")
@@ -74,7 +74,7 @@ def test32bitRange(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     res = c.lock_file(t.code, fh, stateid, 0, 0xffffffffffff)
-    checklist(res, [NFS4_OK, NFS4ERR_BAD_RANGE], "LOCK range over 32 bits")
+    check(res, [NFS4_OK, NFS4ERR_BAD_RANGE], "LOCK range over 32 bits")
     if res.status == NFS4ERR_BAD_RANGE:
         t.fail_support("Server does not support 64 bit lock ranges")
 
@@ -91,7 +91,7 @@ def testOverlap(t, env):
     res1 = c.lock_file(t.code, fh, stateid, 25, 75)
     check(res1)
     res2 = c.relock_file(1, fh, res1.lockid, 50, 75)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "Overlapping locks")
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "Overlapping locks")
     if res2.status == NFS4ERR_LOCK_RANGE:
         t.fail_support("Server does not support lock consolidation")
     # Test the merged lock
@@ -116,7 +116,7 @@ def testDowngrade(t, env):
     check(res1)
     # Lock again with read lock
     res2 = c.relock_file(1, fh, res1.lockid, 25, 75, READ_LT)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_NOTSUPP], "Lock downgrade")
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_NOTSUPP], "Lock downgrade")
     if res2.status == NFS4ERR_LOCK_NOTSUPP:
         t.fail_support("Server does not support atomic lock downgrades")
     # Test the lock has changed
@@ -140,7 +140,7 @@ def testUpgrade(t, env):
     check(res1)
     # Lock again with write lock
     res2 = c.relock_file(1, fh, res1.lockid, 25, 75, WRITE_LT)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_NOTSUPP], "Lock upgrade")
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_NOTSUPP], "Lock upgrade")
     if res2.status == NFS4ERR_LOCK_NOTSUPP:
         t.fail_support("Server does not support atomic lock upgrades")
     # Test the lock has changed
@@ -161,7 +161,7 @@ def testMode(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, access=OPEN4_SHARE_ACCESS_READ)
     res = c.lock_file(t.code, fh, stateid)
-    checklist(res, [NFS4_OK, NFS4ERR_OPENMODE],
+    check(res, [NFS4_OK, NFS4ERR_OPENMODE],
               "Write-locking a read-mode file")
     if res.status == NFS4_OK:
         t.pass_warn("Allowed write-locking a read-mode file, "
@@ -409,7 +409,7 @@ def testTimedoutGrabLock(t, env):
     for i in range(3):
         env.sleep(sleeptime)
         res = c2.compound([c2.renew_op(c2.clientid)])
-        checklist(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN])
+        check(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN])
     # Client 2: Lock file, should work since Client 1's lock has expired
     res2 = c2.lock_file(t.code, fh2, stateid2, type=READ_LT)
     check(res2, msg="Locking file after another client's lock expires")
@@ -660,7 +660,7 @@ def testBlockTimeout(t, env):
     for i in range(3):
         env.sleep(sleeptime, "Waiting for queued blocking lock to timeout")
         res = c.compound([c.renew_op(c.clientid)])
-        checklist(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN])
+        check(res, [NFS4_OK, NFS4ERR_CB_PATH_DOWN])
     # Standard owner releases lock
     res1 = c.unlock_file(1, fh1, res1.lockid)
     check(res1)
diff --git a/nfs4.0/servertests/st_lockt.py b/nfs4.0/servertests/st_lockt.py
index 134f1fa..94b685b 100644
--- a/nfs4.0/servertests/st_lockt.py
+++ b/nfs4.0/servertests/st_lockt.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_clientid
+from environment import check, get_invalid_clientid
 
 def testUnlockedFile(t, env):
     """LOCKT on a regular unlocked file
@@ -48,7 +48,7 @@ def testLink(t, env):
     c = env.c1
     c.init_connection()
     res = c.lock_test(env.opts.uselink)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "LOCKT on non-file object")
+    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "LOCKT on non-file object")
    
 def testBlock(t, env):
     """LOCKT on non-file objects)
@@ -127,7 +127,7 @@ def test32bitRange(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     res = c.lock_test(fh, 0, 0xffffffffffff)
-    checklist(res, [NFS4_OK, NFS4ERR_BAD_RANGE], "LOCKT range over 32 bits")
+    check(res, [NFS4_OK, NFS4ERR_BAD_RANGE], "LOCKT range over 32 bits")
     if res.status == NFS4ERR_BAD_RANGE:
         t.fail_support("Server does not support 64 bit lock ranges")
               
@@ -147,7 +147,7 @@ def testOverlap(t, env):
     res = c.lock_test(fh, 100, 50, tester=lockowner)
     check(res, msg="LOCKT against own exactly matching lock")
     res = c.lock_test(fh, 75, 50, tester=lockowner)
-    checklist(res, [NFS4_OK, NFS4ERR_LOCK_RANGE],
+    check(res, [NFS4_OK, NFS4ERR_LOCK_RANGE],
               "LOCKT against own overlapping lock")
     if res.status == NFS4ERR_LOCK_RANGE:
         t.fail_support("Server does not support lock consolidation")
diff --git a/nfs4.0/servertests/st_locku.py b/nfs4.0/servertests/st_locku.py
index 06b342c..dc8acc8 100644
--- a/nfs4.0/servertests/st_locku.py
+++ b/nfs4.0/servertests/st_locku.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import stateid4
-from environment import check, checklist, makeStaleId
+from environment import check, makeStaleId
 
 def testFile(t, env):
     """LOCKU a regular file
@@ -34,7 +34,7 @@ def testUnlocked(t, env):
     res1 = c.lock_file(t.code, fh, stateid, 100, 100)
     check(res1, msg="Locking file %s" % t.code)
     res2 = c.unlock_file(1, fh, res1.lockid, 0, 50)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "LOCKU on an unlocked area")
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "LOCKU on an unlocked area")
     if res2.status == NFS4ERR_LOCK_RANGE:
         t.fail_support("LOCKU on an unlocked area should return OK")
 
@@ -51,7 +51,7 @@ def testSplit(t, env):
     res1 = c.lock_file(t.code, fh, stateid, 100, 100)
     check(res1, msg="Locking file %s" % t.code)
     res2 = c.unlock_file(1, fh, res1.lockid, 125, 50)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "LOCKU inside locked area")
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE], "LOCKU inside locked area")
     if res2.status == NFS4ERR_LOCK_RANGE:
         t.fail_support("LOCKU inside a locked area should return OK")
 
@@ -68,7 +68,7 @@ def testOverlap(t, env):
     res1 = c.lock_file(t.code, fh, stateid, 100, 100)
     check(res1, msg="Locking file %s" % t.code)
     res2 = c.unlock_file(1, fh, res1.lockid, 50, 100)
-    checklist(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE],
+    check(res2, [NFS4_OK, NFS4ERR_LOCK_RANGE],
               "LOCKU overlapping a locked area")
     if res2.status == NFS4ERR_LOCK_RANGE:
         t.fail("LOCKU overlapping a locked area should return OK, "
@@ -87,7 +87,7 @@ def test32bitRange(t, env):
     res1 = c.lock_file(t.code, fh, stateid)
     check(res1)
     res2 = c.unlock_file(1, fh, res1.lockid, 0, 0xffffffffffff)
-    checklist(res2, [NFS4_OK, NFS4ERR_BAD_RANGE, NFS4ERR_LOCK_RANGE],
+    check(res2, [NFS4_OK, NFS4ERR_BAD_RANGE, NFS4ERR_LOCK_RANGE],
               "LOCKU range over 32 bits")
     if res2.status == NFS4ERR_BAD_RANGE:
         t.fail("Allowed 64 bit LOCK range, but only 32 bit LOCKU range")
@@ -265,5 +265,5 @@ def testTimedoutUnlock(t, env):
     c2.init_connection()
     c2.open_confirm(t.code, access=OPEN4_SHARE_ACCESS_WRITE)
     res2 = c.unlock_file(1, fh, res1.lockid)
-    checklist(res2, [NFS4ERR_EXPIRED, NFS4_OK],
+    check(res2, [NFS4ERR_EXPIRED, NFS4_OK],
               "Try to unlock file after timed out")
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index 392be52..112ee51 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 import rpc
 
 def testDir(t, env):
@@ -218,7 +218,7 @@ def testNonAccessable(t, env):
     check(res)
     res = c.compound(c.use_obj(dir + ['foo']))
     if env.opts.uid == 0:
-	    checklist(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=000")
     else:
 	    check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=000")
 
@@ -254,16 +254,16 @@ def testDots(t, env):
     check(res)
     # Run tests
     res1 = c.compound(c.use_obj(dir + ['.']))
-    checklist(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+    check(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
               "LOOKUP a nonexistant '.'")
     res2 = c.compound(c.use_obj(dir + ['..']))
-    checklist(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+    check(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
               "LOOKUP a nonexistant '..'")
     res1 = c.compound(c.use_obj(dir + ['.', 'foo']))
-    checklist(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+    check(res1, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
               "LOOKUP a nonexistant '.'")
     res2 = c.compound(c.use_obj(dir + ['..', t.code]))
-    checklist(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
+    check(res2, [NFS4ERR_NOENT, NFS4ERR_BADNAME],
               "LOOKUP a nonexistant '..'")
 
 def testUnaccessibleDir(t, env):
@@ -281,7 +281,7 @@ def testUnaccessibleDir(t, env):
     check(res, msg="Setting mode=0 on directory %s" % t.code)
     res = c.compound(c.use_obj(path + ['hidden']))
     if env.opts.uid == 0:
-	    checklist(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=000")
     else:
 	    check(res, NFS4ERR_ACCESS, "LOOKUP off of dir with mode=000")
 
diff --git a/nfs4.0/servertests/st_lookupp.py b/nfs4.0/servertests/st_lookupp.py
index 6249700..4fa6e9b 100644
--- a/nfs4.0/servertests/st_lookupp.py
+++ b/nfs4.0/servertests/st_lookupp.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 
 def testDir(t, env):
     """LOOKUPP with directory (cfh)
@@ -54,7 +54,7 @@ def testLink(t, env):
     c = env.c1
     ops = c.use_obj(env.opts.uselink) + [c.lookupp_op()]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK],
                 "LOOKUPP with non-dir <cfh>")
     
 def testBlock(t, env):
diff --git a/nfs4.0/servertests/st_nverify.py b/nfs4.0/servertests/st_nverify.py
index 24e37e1..b0a8a4b 100644
--- a/nfs4.0/servertests/st_nverify.py
+++ b/nfs4.0/servertests/st_nverify.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_clientid, makeStaleId
+from environment import check, get_invalid_clientid, makeStaleId
 
 def _try_mand(env, path):
     c = env.c1
@@ -43,7 +43,7 @@ def _try_unsupported(env, path):
         ops = baseops + [c.nverify_op({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         if attr.writeonly:
-            checklist(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
+            check(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
                       "VERIFY with unsupported attr %s" % attr.name)
         else:
             check(res, NFS4ERR_ATTRNOTSUPP,
diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
index 1057d83..3637b41 100644
--- a/nfs4.0/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, checkdict, get_invalid_utf8strings
+from environment import check, checkdict, get_invalid_utf8strings
 from nfs4lib import get_bitnumattr_dict
 
 # Any test that uses create_confirm should depend on this test
@@ -79,7 +79,7 @@ def testCreatExclusiveFile(t, env):
     c.init_connection()
     # Create the file
     res = c.create_file(t.code, mode=EXCLUSIVE4, verifier='12345678', deny=OPEN4_SHARE_DENY_NONE)
-    checklist(res, [NFS4_OK, NFS4ERR_NOTSUPP],
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP],
               "Trying to do exclusive create of file %s" % t.code)
     if res.status == NFS4ERR_NOTSUPP:
         c.fail_support("Exclusive OPEN not supported")
@@ -310,7 +310,7 @@ def testClaimPrev(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     res = c.open_file(t.code, fh, claim_type=CLAIM_PREVIOUS, deleg_type=OPEN_DELEGATE_NONE)
-    checklist(res, [NFS4ERR_RECLAIM_BAD, NFS4ERR_NO_GRACE],
+    check(res, [NFS4ERR_RECLAIM_BAD, NFS4ERR_NO_GRACE],
             "Trying to OPEN with CLAIM_PREVIOUS")
 
 def testModeChange(t, env):
@@ -331,7 +331,7 @@ def testModeChange(t, env):
     res = c.open_file(t.code, access=OPEN4_SHARE_ACCESS_BOTH,
                       deny=OPEN4_SHARE_DENY_NONE)
     if env.opts.uid == 0:
-	    checklist(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=000" % t.code)
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=000" % t.code)
     else:
 	    check(res, NFS4ERR_ACCESS, "Opening file %s with mode=000" % t.code)
 
diff --git a/nfs4.0/servertests/st_openconfirm.py b/nfs4.0/servertests/st_openconfirm.py
index bd238dd..589454d 100644
--- a/nfs4.0/servertests/st_openconfirm.py
+++ b/nfs4.0/servertests/st_openconfirm.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import stateid4
-from environment import check, checklist, makeStaleId
+from environment import check, makeStaleId
 
 def _confirm(t, c, file, stateid):
     ops = c.use_obj(file)
diff --git a/nfs4.0/servertests/st_read.py b/nfs4.0/servertests/st_read.py
index 5a3932e..de13418 100644
--- a/nfs4.0/servertests/st_read.py
+++ b/nfs4.0/servertests/st_read.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, makeBadID, makeBadIDganesha, makeStaleId
+from environment import check, makeBadID, makeBadIDganesha, makeStaleId
 import rpc
 
 def _compare(t, res, expect, eof=True):
@@ -123,7 +123,7 @@ def testLink(t, env):
     """
     c = env.c1
     res = c.read_file(env.opts.uselink)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "Read of a non-file object")
+    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "Read of a non-file object")
 
 def testBlock(t, env):
     """READ with non-file objects
@@ -240,4 +240,4 @@ def testStolenStateid(t, env):
     c.security=rpc.SecAuthSys(0, "whatever", 3912, 2422, [])
     res = c.read_file(fh, stateid=stateid)
     c.security=security
-    checklist(res, [NFS4ERR_ACCESS, NFS4ERR_PERM], "READ with stolen stateid")
+    check(res, [NFS4ERR_ACCESS, NFS4ERR_PERM], "READ with stolen stateid")
diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index bf4add4..0a3b45a 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4lib import get_attr_name
-from environment import check, checklist
+from environment import check
 
 def _compare(t, entries, expect, attrlist=[]):
     names = [e.name for e in entries]
@@ -107,7 +107,7 @@ def testFhLink(t, env):
     ops = c.use_obj(env.opts.uselink)
     ops += [c.readdir()]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "READDIR with non-dir <cfh>")
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "READDIR with non-dir <cfh>")
 
 def testFhBlock(t, env):
     """READDIR with non-dir (cfh) should give NFS4ERR_NOTDIR
@@ -232,7 +232,7 @@ def testUnaccessibleDir(t, env):
     ops = c.use_obj(path) + [c.readdir()]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    checklist(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
     else:
 	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=000")
    
@@ -253,7 +253,7 @@ def testUnaccessibleDirAttrs(t, env):
           [c.readdir(attr_request=[FATTR4_RDATTR_ERROR, FATTR4_TYPE])]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    checklist(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
     else:
 	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=000")
    
diff --git a/nfs4.0/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
index ef91c07..02e458c 100644
--- a/nfs4.0/servertests/st_reboot.py
+++ b/nfs4.0/servertests/st_reboot.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 import os
 
 # NOTE - reboot tests are NOT part of the standard test suite
@@ -76,7 +76,7 @@ def testManyClaims(t, env):
             c.init_connection(badid)
             res = c.open_file(t.code, badfh, claim_type=CLAIM_PREVIOUS,
                               deleg_type=OPEN_DELEGATE_NONE)
-            checklist(res, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
+            check(res, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
                       "Reclaim with bad clientid %s" % badid)
     finally:
         env.sleep(sleeptime, "Waiting for grace period to end")
@@ -144,7 +144,7 @@ def testEdge1(t, env):
         c1.init_connection()
         res1 = c1.open_file(t.code, fh1, claim_type=CLAIM_PREVIOUS,
                             deleg_type=OPEN_DELEGATE_NONE)
-        checklist(res1, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
+        check(res1, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
               "Reclaim lock that has been interfered with")
     finally:
         env.sleep(sleeptime, "Waiting for grace period to end")
@@ -190,7 +190,7 @@ def testEdge2(t, env):
         c1.init_connection()
         res1 = c1.open_file(t.code, fh1, claim_type=CLAIM_PREVIOUS,
                             deleg_type=OPEN_DELEGATE_NONE)
-        checklist(res1, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
+        check(res1, [NFS4ERR_NO_GRACE, NFS4ERR_RECLAIM_BAD],
               "Reclaim lock that has been interfered with")
     finally:
         env.sleep(sleeptime, "Waiting for grace period to end")
@@ -222,7 +222,7 @@ def testRootSquash(t, env):
     c.init_connection()
     while 1:
         res = c.create_file(t.code, c.homedir + [t.code, 'file'])
-        checklist(res, [NFS4_OK, NFS4ERR_GRACE], "Creating file")
+        check(res, [NFS4_OK, NFS4ERR_GRACE], "Creating file")
         if res.status == NFS4ERR_GRACE:
             env.sleep(1, "Waiting for grace period to *just* finish")
         else:
diff --git a/nfs4.0/servertests/st_releaselockowner.py b/nfs4.0/servertests/st_releaselockowner.py
index 73b2b5a..a0b8949 100644
--- a/nfs4.0/servertests/st_releaselockowner.py
+++ b/nfs4.0/servertests/st_releaselockowner.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import lock_owner4
-from environment import check, checklist
+from environment import check
 
 def testFile(t, env):
     """RELEASE_LOCKOWNER - basic test
diff --git a/nfs4.0/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
index d475185..d1614a9 100644
--- a/nfs4.0/servertests/st_remove.py
+++ b/nfs4.0/servertests/st_remove.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 
 def testDir(t, env):
     """REMOVE on existing, removable object
@@ -121,7 +121,7 @@ def testCfhLink(t, env):
     c = env.c1
     ops = c.use_obj(env.opts.uselink) + [c.remove_op(t.code)]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "REMOVE with non-dir cfh")
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "REMOVE with non-dir cfh")
 
 def testCfhBlock(t, env):
     """REMOVE with non-dir (cfh) should give NFS4ERR_NOTDIR
diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
index 1e01d8e..0feba4b 100644
--- a/nfs4.0/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 
 def testValidDir(t, env):
     """RENAME : normal operation
@@ -130,7 +130,7 @@ def testSfhLink(t, env):
     """
     c = env.c1
     res = c.rename_obj(env.opts.uselink + [t.code], c.homedir + [t.code])
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "RENAME with non-dir <sfh>")
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "RENAME with non-dir <sfh>")
 
 def testSfhBlock(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -200,7 +200,7 @@ def testCfhLink(t, env):
     res = c.create_obj(t.code)
     check(res)
     res = c.rename_obj(c.homedir + [t.code], env.opts.uselink + [t.code])
-    checklist(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "RENAME with non-dir <cfh>")
+    check(res, [NFS4ERR_NOTDIR, NFS4ERR_SYMLINK], "RENAME with non-dir <cfh>")
 
 def testCfhBlock(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -386,7 +386,7 @@ def testDirToObj(t, env):
     c.maketree([t.code, ['dir'], 'file'])
     res = c.rename_obj(basedir + ['dir'], basedir + ['file'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies NOTDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
 
 def testDirToDir(t, env):
     """RENAME dir into existing, empty dir should retrun NFS4_OK
@@ -414,7 +414,7 @@ def testFileToDir(t, env):
     c.maketree([t.code, ['dir'], 'file'])
     res = c.rename_obj(basedir + ['file'], basedir + ['dir'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
 
 def testFileToFile(t, env):
     """RENAME file into existing file should return NFS4_OK
@@ -441,7 +441,7 @@ def testDirToFullDir(t, env):
     basedir = c.homedir + [t.code]
     c.maketree([t.code, ['dir1'], ['dir2', ['foo']]])
     res = c.rename_obj(basedir + ['dir1'], basedir + ['dir2'])
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
 
 def testFileToFullDir(t, env):
     """RENAME file into existing, nonempty dir should fail
@@ -456,7 +456,7 @@ def testFileToFullDir(t, env):
     c.maketree([t.code, 'file', ['dir', ['foo']]])
     res = c.rename_obj(basedir + ['file'], basedir + ['dir'])
     # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
-    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
+    check(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
 
 def testSelfRenameDir(t, env):
     """RENAME that does nothing
diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
index c126c06..7a63910 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -1,11 +1,11 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 from nfs4_type import *
 
 def _replay(env, c, ops, error=NFS4_OK):
     # Can send in an error list, but replays must return same error as orig
     if type(error) is list:
-        check_funct = checklist
+        check_funct = check
     else:
         check_funct = check
     res = c.compound(ops)
diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index b9cfd84..5e9c4e9 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_utf8strings
+from environment import check, get_invalid_utf8strings
 from nfs4lib import bitmap2list, dict2fattr
 from nfs4_type import nfstime4, settime4
 
@@ -39,7 +39,7 @@ def _try_readonly(t, env, path):
             check(res, NFS4ERR_INVAL,
                   "SETATTR the supported read-only attribute %s" % attr.name)
         else:
-            checklist(res, [NFS4ERR_INVAL, NFS4ERR_ATTRNOTSUPP],
+            check(res, [NFS4ERR_INVAL, NFS4ERR_ATTRNOTSUPP],
                   "SETATTR the unsupported read-only attribute %s" % attr.name)
 
 def _try_unsupported(t, env, path):
@@ -571,7 +571,7 @@ def testSizeLink(t, env):
     check(res)
     ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK],
+    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK],
             "SETATTR(FATTR4_SIZE) of a symlink")
     
 def testSizeBlock(t, env):
diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
index fbeab22..dbcb12e 100644
--- a/nfs4.0/servertests/st_setclientid.py
+++ b/nfs4.0/servertests/st_setclientid.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist
+from environment import check
 import os
 import struct, time
 
@@ -378,5 +378,5 @@ def testNoConfirm(t, env):
     ops = c.use_obj(c.homedir)
     ops += [c.open(t.code, t.code, OPEN4_CREATE)]
     res = c.compound(ops)
-    checklist(res, [NFS4ERR_STALE_CLIENTID, NFS4ERR_EXPIRED],
+    check(res, [NFS4ERR_STALE_CLIENTID, NFS4ERR_EXPIRED],
           "OPEN using clientid that was never confirmed")
diff --git a/nfs4.0/servertests/st_verify.py b/nfs4.0/servertests/st_verify.py
index 255b6a8..696575e 100644
--- a/nfs4.0/servertests/st_verify.py
+++ b/nfs4.0/servertests/st_verify.py
@@ -1,5 +1,5 @@
 from nfs4_const import *
-from environment import check, checklist, get_invalid_clientid, makeStaleId
+from environment import check, get_invalid_clientid, makeStaleId
 
 def _try_mand(env, path):
     c = env.c1
@@ -43,7 +43,7 @@ def _try_unsupported(env, path):
         ops = baseops + [c.verify_op({attr.bitnum: attr.sample})]
         res = c.compound(ops)
         if attr.writeonly:
-            checklist(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
+            check(res, [NFS4ERR_ATTRNOTSUPP, NFS4ERR_INVAL],
                       "VERIFY with unsupported attr %s" % attr.name)
         else:
             check(res, NFS4ERR_ATTRNOTSUPP,
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index c76cf94..f8efe33 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import *
-from environment import check, checklist, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
+from environment import check, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
 import struct
 
 _text = 'write data' # len=10
@@ -175,7 +175,7 @@ def testLink(t, env):
     res = c.create_obj(path, NF4LNK)
     check(res)
     res = c.write_file(path, _text)
-    checklist(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "WRITE to a symlink")
+    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK], "WRITE to a symlink")
 
 def testBlock(t, env):
     """WRITE to a non-file should return NFS4ERR_INVAL
-- 
2.5.5

