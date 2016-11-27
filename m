Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:58398 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751647AbcK0G1b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:31 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 03/12] Some more file closes to cleanup state on the server
Date: Sat, 26 Nov 2016 22:26:32 -0800
Message-ID: <1480228001-64821-4-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_current_stateid.py | 12 +++++++++++-
 nfs4.1/server41tests/st_debug.py           | 18 ++++++++++++++++--
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41te=
sts/st_current_stateid.py
index a0d6757..01d78c0 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -46,6 +46,8 @@ def testLockLockU(t, env):
 =09op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
     res =3D sess1.compound([op.putfh(fh)] + lock_ops)
     check(res, NFS4_OK)
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
=20
 def testOpenWriteClose(t, env):
     """test current state id processing by having OPEN, WRITE and CLOSE
@@ -132,6 +134,10 @@ def testOpenLayoutGet(t, env):
            [op.layoutget(False, LAYOUT4_NFSV4_1_FILES, LAYOUTIOMODE4_RW,
                         0, 8192, 8192, current_stateid, 0xffff)])
     check(res, NFS4_OK)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
+    res =3D close_file(sess, fh, stateid=3Dstateid)
+    check(res)
=20
 def testOpenSetattr(t, env):
     """test current state id processing by having OPEN and SETATTR
@@ -145,8 +151,12 @@ def testOpenSetattr(t, env):
=20
     open_op =3D open_create_file_op(sess, env.testname(t), open_create=3DO=
PEN4_CREATE)
     res =3D sess.compound( open_op +
-           [ op.setattr(current_stateid, {FATTR4_SIZE: size})])
+           [op.getfh(), op.setattr(current_stateid, {FATTR4_SIZE: size})])
     check(res, NFS4_OK)
+    fh =3D res.resarray[-3].object
+    stateid =3D res.resarray[-4].stateid
+    res =3D close_file(sess, fh, stateid=3Dstateid)
+    check(res)
=20
 def testOpenFreestateidClose(t, env):
     """test current state id processing by having OPEN, FREE_STATEID and C=
LOSE
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_deb=
ug.py
index 2b9890e..532ee7a 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from xdrdef.nfs4_const import *
-from environment import check, fail, create_file
+from environment import check, fail, create_file, close_file
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_clai=
m4
 import nfs_ops
 op =3D nfs_ops.NFS4ops()
@@ -19,6 +19,8 @@ def testSupported2(t, env):
                       access=3DOPEN4_SHARE_ACCESS_READ |
                       OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
     check(res) # STUB Should check delegation was granted
+    fh1 =3D res.resarray[-1].object
+    stateid1 =3D res.resarray[-2].stateid
     # c2 - OPEN - WRITE
     c2 =3D env.c1.new_client("%s_2" % env.testname(t))
     sess2 =3D c2.create_session()
@@ -31,6 +33,12 @@ def testSupported2(t, env):
     # STUB - since we are not handling callback, deleg_return never gets d=
one
     print res
     check(res)
+    fh2 =3D res.resarray[-1].object
+    stateid2 =3D res.resarray[-2].stateid
+    res =3D close_file(sess1, fh1, stateid=3Dstateid1)
+    check(res)
+    res =3D close_file(sess2, fh2, stateid=3Dstateid2)
+    check(res)
    =20
 def testReadWrite(t, env):
     """Do a simple READ and WRITE
@@ -58,7 +66,8 @@ def testReadWrite(t, env):
     res =3D sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
     print res
     check(res)
-
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
=20
 def testDeadlock(t, env):
     """Trigger deadlock bug
@@ -87,6 +96,8 @@ def testDeadlock(t, env):
         res =3D sess1.listen(xid)
         check(res)
         print res
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
=20
 def testLayout(t, env):
     """Verify layout handling
@@ -103,11 +114,14 @@ def testLayout(t, env):
     check(openres)
     # Get a layout
     fh =3D openres.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
     ops =3D [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_READ,
                         0, 0xffffffff, 4*blocksize, 0xffff)]
     res =3D sess.compound(ops)
     check(res)
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
    =20
 def testGetDevList(t, env):
     """Check devlist
--=20
2.3.6

