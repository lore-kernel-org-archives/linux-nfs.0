Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:58255 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753222AbcK0G1q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:46 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 09/12] Check that the flex file access uid/gid are correct for the different iomodes
Date: Sat, 26 Nov 2016 22:26:38 -0800
Message-ID: <1480228001-64821-10-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_flex.py | 115 ++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 115 insertions(+)

diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex=
.py
index 8ecb114..fdcfd32 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -206,3 +206,118 @@ def testFlexLayoutStress(t, env):
     check(res)
     res =3D close_file(sess, fh, stateid=3Dopen_stateid)
     check(res)
+
+def testFlexGetDevInfo(t, env):
+    """Get the device info
+
+    FLAGS: flex
+    CODE: FFGDI1
+    """
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+    # Get layout 1
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+    lo_stateid =3D open_stateid
+
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES,
+                        LAYOUTIOMODE4_RW,
+                        0, 0xffffffffffffffff, 8192, lo_stateid, 0xffff)]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid =3D res.resarray[-1].logr_stateid
+    if lo_stateid.seqid !=3D 1:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid.seq=
id))
+
+    layout =3D res.resarray[-1].logr_layout[-1]
+    p =3D FlexUnpacker(layout.loc_body)
+    opaque =3D p.unpack_ff_layout4()
+    p.done()
+
+    # Assume one mirror/storage device
+    ds =3D opaque.ffl_mirrors[-1].ffm_data_servers[-1]
+
+    deviceid =3D ds.ffds_deviceid
+
+    ops =3D [op.putfh(fh),
+           op.getdeviceinfo(deviceid, LAYOUT4_FLEX_FILES, 0xffffffff, 0)]
+    res =3D sess.compound(ops)
+    check(res)
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
+def testFlexLayoutTestAccess(t, env):
+    """Get both a LAYOUTIOMODE4_RW and LAYOUTIOMODE4_READ segment
+    making sure that they have the same gid, but a different uid.
+
+    FLAGS: flex
+    CODE: FFLA1
+    """
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
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
+    if lo_stateid.seqid !=3D 1:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid.seq=
id))
+
+    layout =3D res.resarray[-1].logr_layout[-1]
+    p =3D FlexUnpacker(layout.loc_body)
+    opaque =3D p.unpack_ff_layout4()
+    p.done()
+
+    # Assume one mirror/storage device
+    ds =3D opaque.ffl_mirrors[-1].ffm_data_servers[-1]
+
+    uid_rw =3D ds.ffds_user
+    gid_rw =3D ds.ffds_group
+
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES,
+                        LAYOUTIOMODE4_READ,
+                        0, 0xffffffffffffffff, 8192, lo_stateid, 0xffff)]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid =3D res.resarray[-1].logr_stateid
+    if lo_stateid.seqid !=3D 2:
+        fail("Expected stateid.seqid=3D=3D%i, got %i" % (2, lo_stateid.seq=
id))
+
+    layout =3D res.resarray[-1].logr_layout[-1]
+    p =3D FlexUnpacker(layout.loc_body)
+    opaque =3D p.unpack_ff_layout4()
+    p.done()
+
+    # Assume one mirror/storage device
+    ds =3D opaque.ffl_mirrors[-1].ffm_data_servers[-1]
+
+    uid_rd =3D ds.ffds_user
+    gid_rd =3D ds.ffds_group
+
+    if uid_rw =3D=3D uid_rd:
+        fail("Expected uid_rd !=3D %i, got %i" % (uid_rd, uid_rw))
+
+    if gid_rw !=3D gid_rd:
+        fail("Expected gid_rd =3D=3D %i, got %i" % (gid_rd, gid_rw))
+
+    res =3D close_file(sess, fh, stateid=3Dopen_stateid)
+    check(res)
--=20
2.3.6

