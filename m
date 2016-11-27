Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:34717 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752650AbcK0G1k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:40 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 07/12] Simple tests of the flex file layout type
Date: Sat, 26 Nov 2016 22:26:36 -0800
Message-ID: <1480228001-64821-8-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/__init__.py |   1 +
 nfs4.1/server41tests/st_flex.py  | 144 +++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 145 insertions(+)
 create mode 100644 nfs4.1/server41tests/st_flex.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init=
__.py
index 8a423e1..a38c314 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -23,4 +23,5 @@ __all__ =3D ["st_exchange_id.py", # draft 21
 ##           "st_loop",
            "st_current_stateid.py",
 =09   "st_sparse.py",
+           "st_flex.py",
            ]
diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex=
.py
new file mode 100644
index 0000000..bb4405c
--- /dev/null
+++ b/nfs4.1/server41tests/st_flex.py
@@ -0,0 +1,144 @@
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
+from xdrdef.nfs4_pack import *
+import nfs_ops
+op =3D nfs_ops.NFS4ops()
+from environment import check, fail, create_file, close_file
+from xdrdef.nfs4_pack import NFS4Packer as FlexPacker, \
+=09NFS4Unpacker as FlexUnpacker
+from nfs4lib import FancyNFS4Packer, get_nfstime
+
+def testStateid1(t, env):
+    """Check for proper sequence handling in layout stateids.
+
+    FLAGS: flex
+    CODE: FFST1
+    """
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+    # Get layout 1
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_RW,
+                        0, 8192, 8192, open_stateid, 0xffff)]
+    res =3D sess.compound(ops)
+    check(res)
+    lo_stateid =3D res.resarray[-1].logr_stateid
+    if lo_stateid.seqid !=3D 1:
+        # From draft23 12.5.2 "The first successful LAYOUTGET processed by
+        # the server using a non-layout stateid as an argument MUST have t=
he
+        # "seqid" field of the layout stateid in the response set to one."
+        fail("Expected stateid.seqid=3D=3D1, got %i" % lo_stateid.seqid)
+    for i in range(6):
+        # Get subsequent layouts
+        ops =3D [op.putfh(fh),
+               op.layoutget(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_RW,
+                            (i+1)*8192, 8192, 8192, lo_stateid, 0xffff)]
+        res =3D sess.compound(ops)
+        check(res)
+        lo_stateid =3D res.resarray[-1].logr_stateid
+        if lo_stateid.seqid !=3D i + 2:
+            # From draft23 12.5.3 "After the layout stateid is established=
,
+            # the server increments by one the value of the "seqid" in eac=
h
+            # subsequent LAYOUTGET and LAYOUTRETURN response,
+            fail("Expected stateid.seqid=3D=3D%i, got %i" % (i+2, lo_state=
id.seqid))
+    res =3D close_file(sess, fh, stateid=3Dopen_stateid)
+    check(res)
+
+def testFlexGetLayout(t, env):
+    """Verify layout handling
+
+    FLAGS: flex
+    CODE: FFGLO1
+    """
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+    # Get layout
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_READ,
+                        0, 0xffffffffffffffff, 4196, open_stateid, 0xffff)=
]
+    res =3D sess.compound(ops)
+    check(res)
+    # Parse opaque
+    for layout in  res.resarray[-1].logr_layout:
+        if layout.loc_type =3D=3D LAYOUT4_FLEX_FILES:
+            p =3D FlexUnpacker(layout.loc_body)
+            opaque =3D p.unpack_ff_layout4()
+            p.done()
+    res =3D close_file(sess, fh, stateid=3Dopen_stateid)
+    check(res)
+
+def testFlexLayoutReturnFile(t, env):
+    """
+    Return a file's layout
+
+    FLAGS: flex
+    DEPEND: FFGLO1
+    CODE: FFLOR1
+    """
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+    # Get layout
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+    ops =3D [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_READ,
+                        0, 0xffffffffffffffff, 4196, open_stateid, 0xffff)=
]
+    res =3D sess.compound(ops)
+    check(res)
+    # Return layout
+    layout_stateid =3D res.resarray[-1].logr_stateid
+    ops =3D [op.putfh(fh),
+           op.layoutreturn(False, LAYOUT4_FLEX_FILES, LAYOUTIOMODE4_ANY,
+                           layoutreturn4(LAYOUTRETURN4_FILE,
+                                         layoutreturn_file4(0, 0xfffffffff=
fffffff, layout_stateid, "")))]
+    res =3D sess.compound(ops)
+    check(res)
+    res =3D close_file(sess, fh, stateid=3Dopen_stateid)
+    check(res)
+
+def testFlexLayoutStress(t, env):
+    """Alternate LAYOUTIOMODE4_RW/LAYOUTIOMODE4_READ layout segments in th=
e file
+
+    FLAGS: flex
+    CODE: FFLG2
+    """
+    seqid_next =3D 1
+    sess =3D env.c1.new_pnfs_client_session(env.testname(t))
+    # Create the file
+    res =3D create_file(sess, env.testname(t))
+    check(res)
+    # Get layout 1
+    fh =3D res.resarray[-1].object
+    open_stateid =3D res.resarray[-2].stateid
+    lo_stateid =3D open_stateid
+
+    for i in range(1000):
+        ops =3D [op.putfh(fh),
+               op.layoutget(False, LAYOUT4_FLEX_FILES,
+                            LAYOUTIOMODE4_READ if i%2  else LAYOUTIOMODE4_=
RW,
+                            i * 8192, 8192, 8192, lo_stateid, 0xffff)]
+        res =3D sess.compound(ops)
+        check(res)
+        lo_stateid =3D res.resarray[-1].logr_stateid
+        if lo_stateid.seqid !=3D seqid_next:
+            fail("Expected stateid.seqid=3D=3D%i, got %i" % (seqid_next, l=
o_stateid.seqid))
+        seqid_next +=3D 1
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
--=20
2.3.6

