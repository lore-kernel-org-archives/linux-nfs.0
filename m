Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:22611 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752046AbcK0G1d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:33 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 05/12] Really, really close those open temp files to remove state on the server
Date: Sat, 26 Nov 2016 22:26:34 -0800
Message-ID: <1480228001-64821-6-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_current_stateid.py  | 24 ++++++++++++++++++++++++
 nfs4.1/server41tests/st_reclaim_complete.py |  4 ++++
 nfs4.1/server41tests/st_rename.py           |  4 ++++
 nfs4.1/server41tests/st_secinfo.py          | 20 ++++++++++++++++----
 nfs4.1/server41tests/st_sequence.py         |  8 ++++++++
 5 files changed, 56 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41te=
sts/st_current_stateid.py
index 01d78c0..792eee8 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -99,10 +99,23 @@ def testOpenLookupClose(t, env):
=20
     fname =3D env.testname(t)
     open_op =3D open_create_file_op(sess1, fname, open_create=3DOPEN4_CREA=
TE)
+
     lookup_op =3D env.home + [op.lookup(fname)]
     res =3D sess1.compound(open_op + lookup_op + [op.close(0, current_stat=
eid)])
     check(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
=20
+    # An unknown number of lookups will be present
+    for r in res.resarray:
+        if r.resop =3D=3D OP_OPEN:
+            stateid =3D r.stateid
+        elif r.resop =3D=3D OP_GETFH:
+            fh =3D r.object
+            break
+
+    # Test passed, now cleanup!
+    res =3D sess1.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
 def testCloseNoStateid(t, env):
     """test current state id processing by having CLOSE
        without operation which provides stateid
@@ -120,6 +133,10 @@ def testCloseNoStateid(t, env):
     res =3D sess1.compound([op.putfh(fh), op.close(0, current_stateid)])
     check(res, [NFS4ERR_STALE_STATEID, NFS4ERR_BAD_STATEID])
=20
+    # Test passed, now cleanup!
+    res =3D sess1.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
 def testOpenLayoutGet(t, env):
     """test current state id processing by having OPEN and LAYOUTGET
        in a single compound
@@ -170,6 +187,13 @@ def testOpenFreestateidClose(t, env):
     open_op =3D open_create_file_op(sess1, env.testname(t), open_create=3D=
OPEN4_CREATE)
     res =3D sess1.compound(open_op + [op.free_stateid(current_stateid), op=
.close(0, current_stateid)])
     check(res, NFS4ERR_LOCKS_HELD)
+    fh =3D res.resarray[-2].object
+    stateid =3D res.resarray[-3].stateid
+
+    # Test passed, now cleanup!
+    res =3D sess1.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
=20
 def testOpenSaveFHLookupRestoreFHClose(t, env):
     """test current state id processing by having OPEN, SAVEFH, LOOKUP, RE=
STOREFH and CLOSE
diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41t=
ests/st_reclaim_complete.py
index e945a9f..642ada2 100644
--- a/nfs4.1/server41tests/st_reclaim_complete.py
+++ b/nfs4.1/server41tests/st_reclaim_complete.py
@@ -47,6 +47,10 @@ def testReclaimAfterRECC(t, env):
=20
     check(res, NFS4ERR_NO_GRACE, warnlist =3D [NFS4ERR_EXIST | NFS4ERR_REC=
LAIM_BAD])
=20
+    # Cleanup
+    res =3D sess.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
 def testOpenBeforeRECC(t, env):
     """After a client establishes a new client ID, if non-reclaim
        locking operations are done before the RECLAIM_COMPLETE,
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_re=
name.py
index d87cca0..c7c2c20 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -496,6 +496,10 @@ def testSelfRenameFile(t, env):
         t.fail("RENAME of file %s into itself should do nothing, "
                "but cinfo was changed" % name)
=20
+    # Cleanup
+    res =3D sess.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
 def testLinkRename(t, env):
     """RENAME of file into its hard link should do nothing
=20
diff --git a/nfs4.1/server41tests/st_secinfo.py b/nfs4.1/server41tests/st_s=
ecinfo.py
index 234ec80..008dc1e 100644
--- a/nfs4.1/server41tests/st_secinfo.py
+++ b/nfs4.1/server41tests/st_secinfo.py
@@ -20,14 +20,20 @@ def testSupported(t, env):
     path =3D sess.c.homedir + [name]
     res =3D create_file(sess, owner, path, access=3DOPEN4_SHARE_ACCESS_WRI=
TE)
     check(res)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
=20
     # Get the filehandle of the tmpfile's parent dir
     res =3D sess.compound(use_obj(sess.c.homedir) + [op.getfh()])
     check(res)
-    fh =3D res.resarray[-1].object
+    fh_p =3D res.resarray[-1].object
=20
     # Just do a simple SECINFO
-    res =3D sess.compound([op.putfh(fh), op.secinfo(name)])
+    res =3D sess.compound([op.putfh(fh_p), op.secinfo(name)])
+    check(res)
+
+    # Cleanup
+    res =3D sess.compound([op.putfh(fh), op.close(0, stateid)])
     check(res)
=20
 def testSupported2(t, env):
@@ -45,12 +51,18 @@ def testSupported2(t, env):
     path =3D sess.c.homedir + [name]
     res =3D create_file(sess, owner, path, access=3DOPEN4_SHARE_ACCESS_WRI=
TE)
     check(res)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
=20
     # Get the filehandle of the tmpfile's parent dir
     res =3D sess.compound(use_obj(sess.c.homedir) + [op.getfh()])
     check(res)
-    fh =3D res.resarray[-1].object
+    fh_p =3D res.resarray[-1].object
=20
     # GETFH after do a SECINFO should get error NFS4ERR_NOFILEHANDLE
-    res =3D sess.compound([op.putfh(fh), op.secinfo(name), op.getfh()])
+    res =3D sess.compound([op.putfh(fh_p), op.secinfo(name), op.getfh()])
     check(res, NFS4ERR_NOFILEHANDLE)
+
+    # Cleanup
+    res =3D sess.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_=
sequence.py
index d12f355..d8d460c 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -129,6 +129,9 @@ def testReplayCache002(t, env):
     """
     sess1 =3D env.c1.new_client_session(env.testname(t))
     res =3D create_file(sess1, "%s_1" % env.testname(t))
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
+
     check(res)
     ops =3D env.home + [op.savefh(),\
           op.rename("%s_1" % env.testname(t), "%s_2" % env.testname(t))]
@@ -140,6 +143,11 @@ def testReplayCache002(t, env):
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
=20
+    # Cleanup
+    res =3D sess1.compound([op.putfh(fh), op.close(0, stateid)])
+    check(res)
+
+
 def testReplayCache003(t, env):
     """Send two unsuccessful idempotent compounds with same seqid
=20
--=20
2.3.6

