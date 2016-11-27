Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:23273 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753079AbcK0G1p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:45 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 11/12] Factor out checking seqid for flex file layouts
Date: Sat, 26 Nov 2016 22:26:40 -0800
Message-ID: <1480228001-64821-12-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_flex.py | 48 +++++++++++++++++++------------------=
----
 1 file changed, 22 insertions(+), 26 deletions(-)

diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex=
.py
index 6398592..06dbba8 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -10,6 +10,10 @@ from nfs4lib import FancyNFS4Packer, get_nfstime
=20
 current_stateid =3D stateid4(1, '\0' * 12)
=20
+def check_seqid(stateid, seqid):
+    if stateid.seqid !=3D seqid:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid, stateid.se=
qid))
+
 def testStateid1(t, env):
     """Check for proper sequence handling in layout stateids.
=20
@@ -29,11 +33,12 @@ def testStateid1(t, env):
     res =3D sess.compound(ops)
     check(res)
     lo_stateid =3D res.resarray[-1].logr_stateid
-    if lo_stateid.seqid !=3D 1:
-        # From draft23 12.5.2 "The first successful LAYOUTGET processed by
-        # the server using a non-layout stateid as an argument MUST have t=
he
-        # "seqid" field of the layout stateid in the response set to one."
-        fail("Expected stateid.seqid=3D=3D1, got %i" % lo_stateid.seqid)
+
+    # From draft23 12.5.2 "The first successful LAYOUTGET processed by
+    # the server using a non-layout stateid as an argument MUST have the
+    # "seqid" field of the layout stateid in the response set to one."
+    check_seqid(lo_stateid, 1)
+
     for i in range(6):
         # Get subsequent layouts
         ops =3D [op.putfh(fh),
@@ -42,11 +47,10 @@ def testStateid1(t, env):
         res =3D sess.compound(ops)
         check(res)
         lo_stateid =3D res.resarray[-1].logr_stateid
-        if lo_stateid.seqid !=3D i + 2:
-            # From draft23 12.5.3 "After the layout stateid is established=
,
-            # the server increments by one the value of the "seqid" in eac=
h
-            # subsequent LAYOUTGET and LAYOUTRETURN response,
-            fail("Expected stateid.seqid=3D=3D%i, got %i" % (i+2, lo_state=
id.seqid))
+        # From draft23 12.5.3 "After the layout stateid is established,
+        # the server increments by one the value of the "seqid" in each
+        # subsequent LAYOUTGET and LAYOUTRETURN response,
+=09check_seqid(lo_stateid, i + 2)
     res =3D close_file(sess, fh, stateid=3Dopen_stateid)
     check(res)
=20
@@ -133,8 +137,7 @@ def testFlexLayoutOldSeqid(t, env):
     check(res)
     lo_stateid =3D res.resarray[-1].logr_stateid
=20
-    if lo_stateid.seqid !=3D seqid_next:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid.seqid))
+    check_seqid(lo_stateid, seqid_next)
     seqid_next +=3D 1
=20
     # Get the first with the lo_stateid
@@ -146,8 +149,7 @@ def testFlexLayoutOldSeqid(t, env):
     check(res)
     lo_stateid2 =3D res.resarray[-1].logr_stateid
=20
-    if lo_stateid2.seqid !=3D seqid_next:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid2.seqid))
+    check_seqid(lo_stateid2, seqid_next)
     seqid_next +=3D 1
=20
     # Get the second with the original lo_stateid
@@ -159,8 +161,7 @@ def testFlexLayoutOldSeqid(t, env):
     check(res)
     lo_stateid3 =3D res.resarray[-1].logr_stateid
=20
-    if lo_stateid3.seqid !=3D seqid_next:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, lo_st=
ateid3.seqid))
+    check_seqid(lo_stateid3, seqid_next)
     seqid_next +=3D 1
=20
     ops =3D [op.putfh(fh),
@@ -196,8 +197,7 @@ def testFlexLayoutStress(t, env):
         res =3D sess.compound(ops)
         check(res)
         lo_stateid =3D res.resarray[-1].logr_stateid
-        if lo_stateid.seqid !=3D seqid_next:
-            fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, l=
o_stateid.seqid))
+        check_seqid(lo_stateid, seqid_next)
         seqid_next +=3D 1
=20
     ops =3D [op.putfh(fh),
@@ -231,8 +231,7 @@ def testFlexGetDevInfo(t, env):
     res =3D sess.compound(ops)
     check(res)
     lo_stateid =3D res.resarray[-1].logr_stateid
-    if lo_stateid.seqid !=3D 1:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid.seq=
id))
+    check_seqid(lo_stateid, 1)
=20
     layout =3D res.resarray[-1].logr_layout[-1]
     p =3D FlexUnpacker(layout.loc_body)
@@ -280,8 +279,7 @@ def testFlexLayoutTestAccess(t, env):
     res =3D sess.compound(ops)
     check(res)
     lo_stateid =3D res.resarray[-1].logr_stateid
-    if lo_stateid.seqid !=3D 1:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid.seq=
id))
+    check_seqid(lo_stateid, 1)
=20
     layout =3D res.resarray[-1].logr_layout[-1]
     p =3D FlexUnpacker(layout.loc_body)
@@ -301,8 +299,7 @@ def testFlexLayoutTestAccess(t, env):
     res =3D sess.compound(ops)
     check(res)
     lo_stateid =3D res.resarray[-1].logr_stateid
-    if lo_stateid.seqid !=3D 2:
-        fail("Expected stateid.seqid=3D=3D%i, got %i" % (2, lo_stateid.seq=
id))
+    check_seqid(lo_stateid, 2)
=20
     layout =3D res.resarray[-1].logr_layout[-1]
     p =3D FlexUnpacker(layout.loc_body)
@@ -351,8 +348,7 @@ def testFlexLayoutStatsSmall(t, env):
         fh =3D res.resarray[-2].object
         open_stateid =3D res.resarray[-3].stateid
=20
-        if lo_stateid.seqid !=3D 1:
-            fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid=
.seqid))
+        check_seqid(lo_stateid, 1)
=20
         layout =3D res.resarray[-1].logr_layout[-1]
         p =3D FlexUnpacker(layout.loc_body)
--=20
2.3.6

