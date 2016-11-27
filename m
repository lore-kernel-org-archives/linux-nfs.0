Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:42614 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753079AbcK0G1r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:47 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 08/12] Add a check to see if NFS4ERR_OLD_STATEID is issued on concurrent layoutgets
Date: Sat, 26 Nov 2016 22:26:37 -0800
Message-ID: <1480228001-64821-9-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_flex.py | 68 +++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 66 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex=
.py
index bb4405c..8ecb114 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -106,6 +106,70 @@ def testFlexLayoutReturnFile(t, env):
     res =3D close_file(sess, fh, stateid=3Dopen_stateid)
     check(res)
=20
+def testFlexLayoutOldSeqid(t, env):
+    """Check that we do not get NFS4ERR_OLD_STATEID if we send
+    two LAYOUTGETS in a row without bumping the seqid
+
+    FLAGS: flex
+    CODE: FFLOOS
+    """
+    seqid_next =3D 1
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+
+    # Get layout 1
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES,
+                        LAYOUTIOMODE4_RW,
+                        0, 0xffffffffffffffff, 8192, open_stateid, 0xffff)=
]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid =3D res.resarray[-1].logr_stateid
+
+    if lo_stateid.seqid !=3D seqid_next:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid.seqid))
+    seqid_next +=3D 1
+
+    # Get the first with the lo_stateid
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES,
+                        LAYOUTIOMODE4_RW,
+                        0, 0xffffffffffffffff, 8192, lo_stateid, 0xffff)]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid2 =3D res.resarray[-1].logr_stateid
+
+    if lo_stateid2.seqid !=3D seqid_next:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid2.seqid))
+    seqid_next +=3D 1
+
+    # Get the second with the original lo_stateid
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES,
+                        LAYOUTIOMODE4_RW,
+                        0, 0xffffffffffffffff, 8192, lo_stateid, 0xffff)]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid3 =3D res.resarray[-1].logr_stateid
+
+    if lo_stateid3.seqid !=3D seqid_next:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid3.seqid))
+    seqid_next +=3D 1
+
+    ops =3D [op.putfh(fh),
+           op.layoutreturn(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_ANY,
+                           layoutreturn4(LAYOUTRETURN4_FILE,
+                                         layoutreturn_file4(0, 0xfffffffff=
fffffff, lo_stateid, "")))]
+    res =3D sess.compound(ops)
+    check(res)
+    res =3D close_file(sess, fh, stateid=3Dopen_stateid)
+    check(res)
+
 def testFlexLayoutStress(t, env):
     """Alternate LAYOUTIOMODE4_RW/LAYOUTIOMODE4_READ layout segments in th=
e file
=20
@@ -117,7 +181,7 @@ def testFlexLayoutStress(t, env):
     # Create the file
     res =3D create_file(sess, env.testname(t))
     check(res)
-    # Get layout 1
+
     fh =3D res.resarray[-1].object
     open_stateid =3D res.resarray[-2].stateid
     lo_stateid =3D open_stateid
@@ -126,7 +190,7 @@ def testFlexLayoutStress(t, env):
         ops =3D [op.putfh(fh),
                op.layoutget(False, LAYOUT4_FLEX_FILES,
                             LAYOUTIOMODE4_READ if i%2  else LAYOUTIOMODE4_=
RW,
-                            i * 8192, 8192, 8192, lo_stateid, 0xffff)]
+                            0, 0xffffffffffffffff, 8192, lo_stateid, 0xfff=
f)]
         res =3D sess.compound(ops)
         check(res)
         lo_stateid =3D res.resarray[-1].logr_stateid
--=20
2.3.6

