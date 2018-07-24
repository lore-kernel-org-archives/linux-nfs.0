Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388431AbeGXIje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:34 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 17/24] pynfs: python3 support plan: fix indent error on python3
Date: Tue, 24 Jul 2018 15:33:35 +0800
Message-Id: <20180724073342.5738-17-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/servertests/__init__.py             |  2 +-
 nfs4.0/servertests/st_getattr.py           | 12 +++++------
 nfs4.0/servertests/st_lookup.py            |  8 ++++----
 nfs4.0/servertests/st_open.py              |  4 ++--
 nfs4.0/servertests/st_opendowngrade.py     |  5 ++---
 nfs4.0/servertests/st_readdir.py           |  8 ++++----
 nfs4.0/servertests/st_write.py             |  4 ++--
 nfs4.1/server41tests/__init__.py           |  4 ++--
 nfs4.1/server41tests/environment.py        | 24 +++++++++++-----------
 nfs4.1/server41tests/st_current_stateid.py |  2 +-
 nfs4.1/server41tests/st_delegation.py      | 12 +++++------
 nfs4.1/server41tests/st_destroy_session.py |  2 +-
 nfs4.1/server41tests/st_flex.py            |  2 +-
 nfs4.1/testmod.py                          |  8 ++++----
 14 files changed, 48 insertions(+), 49 deletions(-)

diff --git a/nfs4.0/servertests/__init__.py b/nfs4.0/servertests/__init__.py
index 4b684cb..b5f4974 100644
--- a/nfs4.0/servertests/__init__.py
+++ b/nfs4.0/servertests/__init__.py
@@ -1,5 +1,5 @@
 __all__ = [ "st_access.py",
-	    "st_acl.py",
+            "st_acl.py",
             "st_close.py",
             "st_commit.py",
             "st_compound.py",
diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index 500542d..65a5701 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -525,18 +525,18 @@ def testOwnerName(t, env):
     def xxxtestMountedOnFileid(self):
         """GETATTR(FATTR4_MOUNTED_ON_FILEID)
 
-	This DOES NOT work on standard test tree.  It assumes that pseudofs
-	root / and pseudo fs node /unix exist, and that /unix is a mountpoint
-	of an exported file system. The fsid of "/" should differ from the
-	fsid of "/unix", and the mounted_on_fileid should != the filed with
-	both the Getattr of "/unix" and the Readdir of "/".
+        This DOES NOT work on standard test tree.  It assumes that pseudofs
+        root / and pseudo fs node /unix exist, and that /unix is a mountpoint
+        of an exported file system. The fsid of "/" should differ from the
+        fsid of "/unix", and the mounted_on_fileid should != the filed with
+        both the Getattr of "/unix" and the Readdir of "/".
         """
 
         request = [FATTR4_MOUNTED_ON_FILEID, FATTR4_FILEID, FATTR4_FSID]
         lookupops = [op.lookup("unix")]
         ops = [op.putrootfh()]
         ops.append(self.ncl.getattr(request))
-	ops += lookupops
+        ops += lookupops
         ops.append(self.ncl.getattr(request))
         res = self.ncl.do_ops(ops)
         self.assert_OK(res)
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index a57d4cb..eed7100 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -220,9 +220,9 @@ def testNonAccessable(t, env):
     check(res)
     res = c.compound(c.use_obj(dir + ['foo']))
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=0o000")
+        check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=0o000")
+        check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=0o000")
 
 def testInvalidUtf8(t, env):
     """LOOKUP with bad UTF-8 name strings should return NFS4ERR_INVAL
@@ -283,9 +283,9 @@ def testUnaccessibleDir(t, env):
     check(res, msg="Setting mode=0 on directory %s" % t.code)
     res = c.compound(c.use_obj(path + ['hidden']))
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=0o000")
+        check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "LOOKUP off of dir with mode=0o000")
+        check(res, NFS4ERR_ACCESS, "LOOKUP off of dir with mode=0o000")
 
 def testBadOpaque(t, env):
     """LOOKUP with a path component that has an incorrect array length
diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
index 12db5df..b4af81c 100644
--- a/nfs4.0/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -331,9 +331,9 @@ def testModeChange(t, env):
     res = c.open_file(t.code, access=OPEN4_SHARE_ACCESS_BOTH,
                       deny=OPEN4_SHARE_DENY_NONE)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=0o000" % t.code)
+        check(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=0o000" % t.code)
     else:
-	    check(res, NFS4ERR_ACCESS, "Opening file %s with mode=0o000" % t.code)
+        check(res, NFS4ERR_ACCESS, "Opening file %s with mode=0o000" % t.code)
 
 def testShareConflict1(t, env):
     """OPEN conflicting with previous share
diff --git a/nfs4.0/servertests/st_opendowngrade.py b/nfs4.0/servertests/st_opendowngrade.py
index 9cbf5cb..213b2dd 100644
--- a/nfs4.0/servertests/st_opendowngrade.py
+++ b/nfs4.0/servertests/st_opendowngrade.py
@@ -136,16 +136,15 @@ class open_sequence:
 						deny=OPEN4_SHARE_DENY_NONE,
 						mode=UNCHECKED4)
     def downgrade(self, access):
-	    res = self.client.downgrade_file(self.owner, self.fh, self.stateid,
+        res = self.client.downgrade_file(self.owner, self.fh, self.stateid,
 					access=access,
 					deny=OPEN4_SHARE_DENY_NONE)
-	    self.stateid = res.stateid
+        self.stateid = res.stateid
     def close(self):
         self.client.close_file(self.owner, self.fh, self.stateid)
     def lock(self, type):
         self.client.lock_file(self.owner, self.fh, self.stateid,
                     type=type)
-	
 
 def testOpenDowngradeSequence(t, env):
     """test complex upgrade/downgrade sequence
diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index fb484b6..798b2d0 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -232,9 +232,9 @@ def testUnaccessibleDir(t, env):
     ops = c.use_obj(path) + [c.readdir()]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
+        check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
+        check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
    
 def testUnaccessibleDirAttrs(t, env):
     """READDIR with (cfh) in unaccessible directory requesting attrs
@@ -253,9 +253,9 @@ def testUnaccessibleDirAttrs(t, env):
           [c.readdir(attr_request=[FATTR4_RDATTR_ERROR, FATTR4_TYPE])]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
+        check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
+        check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
    
 ###########################################
 
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index 4777e1b..5b48153 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -438,8 +438,8 @@ def testLargeReadWrite(t, env):
     check(res)
     data = res.resarray[-2].switch.switch.data
     if len(data) != len(writedata):
-	    t.fail("READ returned %d bytes, expected %d" %
-                                    (len(data), len(writedata)))
+        t.fail("READ returned %d bytes, expected %d" %
+                           (len(data), len(writedata)))
     if (data != '\0'*size):
         t.fail("READ returned unexpected data")
     res = c.read_file(fh, 0, size)
diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index a38c314..47bdd79 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -7,7 +7,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_secinfo_no_name.py",
            "st_secinfo.py",
            "st_sequence.py",
-	   "st_trunking.py",
+           "st_trunking.py",
            "st_open.py",
            "st_delegation.py",
            "st_verify.py",
@@ -22,6 +22,6 @@ __all__ = ["st_exchange_id.py", # draft 21
 ##           "st_debug.py",
 ##           "st_loop",
            "st_current_stateid.py",
-	   "st_sparse.py",
+           "st_sparse.py",
            "st_flex.py",
            ]
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 3020371..360089e 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -471,12 +471,12 @@ def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0o755}):
 def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                      access=OPEN4_SHARE_ACCESS_BOTH,
                      deny=OPEN4_SHARE_DENY_NONE,
-		     mode=GUARDED4, verifier=None,
-		     claim_type=CLAIM_NULL,
-		     want_deleg=False,
-		     deleg_type=None,
-		     open_create=OPEN4_NOCREATE,
-		     seqid=0, clientid=0):
+                     mode=GUARDED4, verifier=None,
+                     claim_type=CLAIM_NULL,
+                     want_deleg=False,
+                     deleg_type=None,
+                     open_create=OPEN4_NOCREATE,
+                     seqid=0, clientid=0):
     open_op = open_create_file_op(sess, owner, path, attrs, access, deny, mode,
                             verifier, claim_type, want_deleg, deleg_type,
                             open_create, seqid, clientid)
@@ -486,12 +486,12 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
 def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                      access=OPEN4_SHARE_ACCESS_BOTH,
                      deny=OPEN4_SHARE_DENY_NONE,
-		     mode=GUARDED4, verifier=None,
-		     claim_type=CLAIM_NULL,
-		     want_deleg=False,
-		     deleg_type=None,
-		     open_create=OPEN4_NOCREATE,
-		     seqid=0, clientid=0):
+                     mode=GUARDED4, verifier=None,
+                     claim_type=CLAIM_NULL,
+                     want_deleg=False,
+                     deleg_type=None,
+                     open_create=OPEN4_NOCREATE,
+                     seqid=0, clientid=0):
     # Set defaults
     if path is None:
         dir = sess.c.homedir
diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 792eee8..819dfb1 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -43,7 +43,7 @@ def testLockLockU(t, env):
     open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
     lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
     lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
-	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
+        op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
     res = sess1.compound([op.putfh(fh)] + lock_ops)
     check(res, NFS4_OK)
     res = close_file(sess1, fh, stateid=stateid)
diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index c5959f6..cbabb85 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -27,8 +27,8 @@ def __create_file_with_deleg(sess, name, access):
     return (fh, deleg)
 
 def _create_file_with_deleg(sess, name, access):
-	fh, deleg = __create_file_with_deleg(sess, name, access)
-	return fh
+    fh, deleg = __create_file_with_deleg(sess, name, access)
+    return fh
 
 def _testDeleg(t, env, openaccess, want, breakaccess, sec = None, sec2 = None):
     recall = threading.Event()
@@ -182,7 +182,7 @@ def testDelegRevocation(t, env):
         if res.status == NFS4_OK:
             break;
         check(res, [NFS4_OK, NFS4ERR_DELAY])
-	# just to keep sess1 renewed.  This is a bit fragile, as we
+        # just to keep sess1 renewed.  This is a bit fragile, as we
         # depend on the above compound waiting no longer than the
         # server's lease period:
         res = sess1.compound([])
@@ -196,7 +196,7 @@ def testDelegRevocation(t, env):
              " sucess of open conflicting with delegation")
     flags &= ~SEQ4_STATUS_RECALLABLE_STATE_REVOKED
     if flags:
-	print("WARNING: unexpected status flag(s) 0x%x set" % flags);
+        print("WARNING: unexpected status flag(s) 0x%x set" % flags);
     res = sess1.update_seq_state(res, slot)
     res = sess1.compound([op.test_stateid([delegstateid])])
     stateid_stat = res.resarray[0].tsr_status_codes[0]
@@ -210,7 +210,7 @@ def testDelegRevocation(t, env):
     res = sess1.c.compound([seq_op])
     flags = res.resarray[0].sr_status_flags
     if flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED:
-	fail("SEQ4_STATUS_RECALLABLE_STATE_REVOKED should be cleared after"
-	     " FREE_STATEID")
+        fail("SEQ4_STATUS_RECALLABLE_STATE_REVOKED should be cleared after"
+             " FREE_STATEID")
     if flags & ~SEQ4_STATUS_RECALLABLE_STATE_REVOKED:
         print("WARNING: unexpected status flag(s) 0x%x set" % flags)
diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index 466845d..c776617 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -97,7 +97,7 @@ def testDestroy3(t, env):
         recall.happened = True
         env.notify = recall.set # This is called after compound sent to queue
     def bad_post_hook(arg, env, res):
-	return None;
+        return None;
     def good_post_hook(arg, env, res):
         return res
     c = env.c1.new_client(env.testname(t))
diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex.py
index a14c926..35be489 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -50,7 +50,7 @@ def testStateid1(t, env):
         # From draft23 12.5.3 "After the layout stateid is established,
         # the server increments by one the value of the "seqid" in each
         # subsequent LAYOUTGET and LAYOUTRETURN response,
-	check_seqid(lo_stateid, i + 2)
+        check_seqid(lo_stateid, i + 2)
     res = close_file(sess, fh, stateid=open_stateid)
     check(res)
 
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 0cb76da..6f576e2 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -222,8 +222,8 @@ class Test(object):
             environment.startUp()
             self.runtest(self, environment)
             self.result = self._pass_result
-	    environment.clean_sessions()
-	    environment.clean_clients()
+            environment.clean_sessions()
+            environment.clean_clients()
         except KeyboardInterrupt:
             raise
         except TestException as e:
@@ -330,8 +330,8 @@ def _import_by_name(name):
 
 def parseversions(t):
     if len(t.vers_list) > 1:
-	    raise RuntimeError("Test %s has invalid version range %s"
-                               % (t.fullname, t.vers_list))
+        raise RuntimeError("Test %s has invalid version range %s"
+                           % (t.fullname, t.vers_list))
     if len(t.vers_list) == 0:
         return (0, sys.maxsize)
     limits = t.vers_list[0].split("-")
-- 
2.17.1

