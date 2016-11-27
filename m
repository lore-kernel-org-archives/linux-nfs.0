Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:28986 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753222AbcK0G1s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:48 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 10/12] FFLS1: Simulate LAYOUTSTATS for 20 small file creations
Date: Sat, 26 Nov 2016 22:26:39 -0800
Message-ID: <1480228001-64821-11-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_flex.py | 84 +++++++++++++++++++++++++++++++++++++=
+++-
 1 file changed, 83 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex=
.py
index fdcfd32..6398592 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -3,11 +3,13 @@ from xdrdef.nfs4_type import *
 from xdrdef.nfs4_pack import *
 import nfs_ops
 op =3D nfs_ops.NFS4ops()
-from environment import check, fail, create_file, close_file
+from environment import check, fail, create_file, close_file, open_create_=
file_op
 from xdrdef.nfs4_pack import NFS4Packer as FlexPacker, \
 =09NFS4Unpacker as FlexUnpacker
 from nfs4lib import FancyNFS4Packer, get_nfstime
=20
+current_stateid =3D stateid4(1, '\0' * 12)
+
 def testStateid1(t, env):
     """Check for proper sequence handling in layout stateids.
=20
@@ -321,3 +323,83 @@ def testFlexLayoutTestAccess(t, env):
=20
     res =3D close_file(sess, fh, stateid=3Dopen_stateid)
     check(res)
+
+def testFlexLayoutStatsSmall(t, env):
+    """Open 20 "small" files and simulate LAYOUTSTATS for them
+    1) OPEN, LAYOUTGET
+    2) GETDEVINFO
+    3) LAYOUTRETURN, CLOSE
+
+    FLAGS: flex
+    CODE: FFLS1
+    """
+    lats =3D [93089, 107683, 112340, 113195, 130412, 138390, 140427, 15882=
4, 193078, 201879, 391634, 404757, 2201181, 2232614, 2280089, 2296343, 2341=
763, 2392984, 3064546, 3070314]
+    durs =3D [3387666, 3439506, 3737081, 4448315, 4380523, 4419273, 441974=
6, 5903420, 5932432, 5932938, 7573082, 11085497, 11125274, 11126513, 137203=
03, 15990926, 16020425, 16020948, 20181628, 20213871]
+
+    if len(lats) !=3D len(durs):
+        fail("Lats and durs not same")
+
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+
+    for i in range(len(lats)):
+        open_op =3D open_create_file_op(sess, env.testname(t) + str(i), op=
en_create=3DOPEN4_CREATE)
+        res =3D sess.compound( open_op +
+               [op.layoutget(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_RW,
+                            0, 0xffffffffffffffff, 4196, current_stateid, =
0xffff)])
+        check(res, NFS4_OK)
+        lo_stateid =3D res.resarray[-1].logr_stateid
+        fh =3D res.resarray[-2].object
+        open_stateid =3D res.resarray[-3].stateid
+
+        if lo_stateid.seqid !=3D 1:
+            fail("Expected stateid.seqid=3D=3D%i, got %i" % (1, lo_stateid=
.seqid))
+
+        layout =3D res.resarray[-1].logr_layout[-1]
+        p =3D FlexUnpacker(layout.loc_body)
+        opaque =3D p.unpack_ff_layout4()
+        p.done()
+
+        # Assume one mirror/storage device
+        ds =3D opaque.ffl_mirrors[-1].ffm_data_servers[-1]
+
+        stats_hint =3D opaque.ffl_stats_collect_hint
+
+        deviceid =3D ds.ffds_deviceid
+
+        ops =3D [op.putfh(fh),
+               op.getdeviceinfo(deviceid, LAYOUT4_FLEX_FILES, 0xffffffff, =
0)]
+        res =3D sess.compound(ops)
+        check(res)
+
+        gda =3D res.resarray[-1].gdir_device_addr
+
+        p =3D FlexUnpacker(gda.da_addr_body)
+        da =3D p.unpack_ff_device_addr4()
+        p.done()
+
+        rd_io =3D io_info4(0, 0)
+        wr_io =3D io_info4(1, 16384)
+
+        rd_lat =3D ff_io_latency4(0, 0, 0, 0, 0, nfstime4(0, 0), nfstime4(=
0, 0))
+        wr_lat =3D ff_io_latency4(1, 16384, 1, 16384, 0, nfstime4(0, lats[=
i]), nfstime4(0, lats[i]))
+
+        offset =3D 0
+        file_length =3D 16384
+
+        dur =3D durs[i]
+        fflu =3D ff_layoutupdate4(da.ffda_netaddrs[-1], ds.ffds_fh_vers[-1=
],
+                                rd_lat, wr_lat, nfstime4(0, dur), True)
+
+        ffio =3D ff_iostats4(offset, file_length, lo_stateid, rd_io, wr_io=
, deviceid, fflu)
+        fflr =3D ff_layoutreturn4([], [ffio])
+
+        p =3D FlexPacker()
+        p.pack_ff_layoutreturn4(fflr)
+
+        ops =3D [op.putfh(fh),
+               op.layoutreturn(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_AN=
Y,
+                               layoutreturn4(LAYOUTRETURN4_FILE,
+                                             layoutreturn_file4(0, 0xfffff=
fffffffffff, lo_stateid, p.get_buffer()))),
+               op.close(0, open_stateid)]
+        res =3D sess.compound(ops)
+        check(res)
--=20
2.3.6

