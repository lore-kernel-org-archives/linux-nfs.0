Received: from mailout1.samsung.com (mailout1.samsung.com [203.254.224.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B636D54707C
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 00:26:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.24
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791246395; cv=none; b=P6WEh3qJooimaUYXG7bWv5ttOPgPYIhkoZX7OKQ3eHeeU0EBg1lFXZn8GkXcggCsO+FWYkwFe4lS/tezDXYOvVPs03WphhhoWRh/Dvrxqg603YH0+U2XWNzon/wWFkSIj6Vrh4C4KeEKPEkTOFb4y5PFtSnLt85m0UOBoZ0Gfu4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791246395; c=relaxed/simple;
	bh=mJ7k63PC+cvN/zBKFFM8RV6+AOQ4LweXzP64o0lt5x8=;
	h=Mime-Version:Subject:From:To:CC:Message-ID:Date:Content-Type:
	 References; b=TVTS/RDgpMn4xaQGnyJWB88dVe5R3a7Oo5/Kdjpj0x4KS84QsKf/OEgl+1Ww4Pqg5GXejPVach35NTp/uUERsTMd0vIR4EzoevkoUf61+mE+fcInUGWYTBez9+7TVSLzN9cTHIdhHsHFadAROl6/5tlp/DfAcEOkGkux8IbSS8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=N8/YgPYv; arc=none smtp.client-ip=203.254.224.24
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="N8/YgPYv"
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20261006002623epoutp016a27d45e7520c2f55cc0fde850ef8b61~byRh2rAyO2253522535epoutp01D
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 00:26:23 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.samsung.com 20261006002623epoutp016a27d45e7520c2f55cc0fde850ef8b61~byRh2rAyO2253522535epoutp01D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1791246383;
	bh=NOnLE34qT3DV0pmdVnEpikaaCzPZ9pdjW6ih6oDVzwc=;
	h=Subject:Reply-To:From:To:CC:Date:References:From;
	b=N8/YgPYvH7or1SdT/13kTzsp4W7K+LJFvDqDX5CPxfpQG/RiA4ux0kspNdNDn+FB5
	 rSStlxCijP0xydFQss6z4SVLajqEke/+YOCemOWa2BxRnMTBNuotozHKgzZqT2rlKu
	 cnn9NFRkzg3fK9B58Qd46cyq0/Os7/cBKADVT+bg=
Received: from epsnrtp03.localdomain (unknown [182.195.42.155]) by
	epcas2p1.samsung.com (KnoxPortal) with ESMTPS id
	20261006002623epcas2p14f7c081252fa4e99504b6cba5760c20c~byRhQUfug0287502875epcas2p1C;
	Tue,  6 Oct 2026 00:26:23 +0000 (GMT)
Received: from epcas2p4.samsung.com (unknown [182.195.38.212]) by
	epsnrtp03.localdomain (Postfix) with ESMTP id 4hzH9p58cgz3hhT7; Tue,  6 Oct
	2026 00:26:22 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: [PATCH pynfs] Add a test for contiguous writable extents in a block
 layout
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: "calum.mackay@oracle.com" <calum.mackay@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"cel@kernel.org" <cel@kernel.org>, "jlayton@kernel.org"
	<jlayton@kernel.org>, "hch@lst.de" <hch@lst.de>, "dai.ngo@oracle.com"
	<dai.ngo@oracle.com>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261006002622epcms2p38e492aef17fdf79e48b05c9aada2918d@epcms2p3>
Date: Tue, 06 Oct 2026 09:26:22 +0900
X-CMS-MailID: 20261006002622epcms2p38e492aef17fdf79e48b05c9aada2918d
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261006002622epcms2p38e492aef17fdf79e48b05c9aada2918d
References: <CGME20261006002622epcms2p38e492aef17fdf79e48b05c9aada2918d@epcms2p3>

BLOCK5: a LAYOUTIOMODE4_RW LAYOUTGET over a hole between two allocated
blocks, where the server allocates the hole, gets extents that follow
three of the rules in RFC 5663 section 2.3.1: the extents are ordered by
offset, the writable extents (all but PNFS_BLOCK_READ_DATA) are
logically contiguous, and the first extent contains the requested offset
(so the extent list is not empty).  A server that maps each extent in
full can return the extent that the allocation merges with the ones
before it, overlapping them.

The test allocates three blocks of the layout block size
(FATTR4_LAYOUT_BLKSIZE) and deallocates the middle one, so that the
block the server allocates for the hole is likely to be that one and to
merge with both neighbours.  It warns if the layout does not cover the
three blocks or they are not contiguous on the volume, as then no merge
could be seen.  On Linux nfsd over XFS the freed block can be reused at
once on a sync export, where DEALLOCATE commits.  The minimum length is
one block, so that a server that returns one extent per LAYOUTGET does
not have to refuse the request.  Every layout in the reply is checked.
The test uses ALLOCATE and DEALLOCATE, so it needs NFSv4.2, and a server
without them does not support the test.

Linux nfsd over XFS fails BLOCK5 in five runs out of five on a test
kernel that maps with XFS_BMAPI_ENTIRE in xfs_fs_map_blocks() and does
not trim, which kernel commit 36ca6f11424a ("xfs: fix overlapping
extents returned for pNFS LAYOUTGET") stopped in 7.1.  nfsd-testing on
top of 7.3-rc4 passes it in five runs out of five, with and without
"xfs: map pNFS layouts to the end of the extent again".

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 nfs4.1/server41tests/st_block.py | 94 +++++++++++++++++++++++++++++++-
 1 file changed, 91 insertions(+), 3 deletions(-)

diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index 3cfc1c6..6c30585 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -2,10 +2,11 @@ from xdrdef.nfs4_const import *
 from xdrdef.nfs4_type import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
-from .environment import check, fail, create_file
+from .environment import check, fail, create_file, use_obj, \
+    get_blocksize
 from block import Packer as BlockPacker, Unpacker as BlockUnpacker, \
-    PNFS_BLOCK_READWRITE_DATA, pnfs_block_layoutupdate4, \
-    pnfs_block_extent4
+    PNFS_BLOCK_READWRITE_DATA, PNFS_BLOCK_READ_DATA, \
+    pnfs_block_layoutupdate4, pnfs_block_extent4
 from nfs4lib import FancyNFS4Packer, get_nfstime
 
 
@@ -215,3 +216,90 @@ def testSplitCommit(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
+
+def testRWExtentsContiguous(t, env):
+    """RW layout over a hole between allocated blocks has contiguous extents
+
+    The server allocates the hole for the layout.  Check three of the
+    rules in RFC 5663 section 2.3.1: the extents are ordered by offset,
+    the writable extents (all but PNFS_BLOCK_READ_DATA) are logically
+    contiguous, and the first extent contains the requested offset.  A
+    server that maps each extent in full can return the extent that the
+    allocation merges with the ones before it, overlapping them.  The
+    minimum length is one block, so that a server that returns one
+    extent per LAYOUTGET does not have to refuse the request.  Warn if
+    the layout does not cover the three blocks or they are not contiguous
+    on the volume, as then no merge could be seen.
+
+    FLAGS: block
+    CODE: BLOCK5
+    VERS: 2-
+    """
+    sess = env.c1.new_pnfs_client_session(env.testname(t))
+    bs = get_blocksize(sess, use_obj(env.opts.path))
+    res = create_file(sess, env.testname(t))
+    check(res)
+    fh = res.resarray[-1].object
+    open_stateid = res.resarray[-2].stateid
+    # Allocate three blocks, then deallocate the middle one: the block
+    # the server allocates for the hole is likely to be that one, and to
+    # merge with both neighbours.  (On Linux nfsd over XFS the freed block
+    # can be reused at once on a sync export, where DEALLOCATE commits.)
+    res = sess.compound([op.putfh(fh), op.allocate(open_stateid, 0, 3*bs)])
+    if res.status == NFS4ERR_NOTSUPP:
+        t.fail_support("ALLOCATE is not supported")
+    check(res)
+    res = sess.compound([op.putfh(fh), op.deallocate(open_stateid, bs, bs)])
+    if res.status == NFS4ERR_NOTSUPP:
+        t.fail_support("DEALLOCATE is not supported")
+    check(res)
+    ops = [op.putfh(fh),
+           op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
+                        0, 3*bs, bs, open_stateid, 0xffff)]
+    res = sess.compound(ops)
+    check(res)
+    found = False
+    blocks = {}
+    for layout in res.resarray[-1].logr_layout:
+        p = BlockUnpacker(layout.loc_body)
+        opaque = p.unpack_pnfs_block_layout4()
+        p.done()
+        ext = [(e.bex_file_offset, e.bex_length, e.bex_state)
+               for e in opaque.blo_extents]
+        print(layout.lo_offset, layout.lo_length, ext,
+              [e.bex_storage_offset for e in opaque.blo_extents])
+        if not ext:
+            fail("No extents in layout %d+%d" %
+                 (layout.lo_offset, layout.lo_length))
+        for a, b in zip(ext, ext[1:]):
+            if b[0] < a[0] or (b[0] == a[0] and
+                               a[2] != PNFS_BLOCK_READ_DATA and
+                               b[2] == PNFS_BLOCK_READ_DATA):
+                fail("Extents %s and %s are not in order" % (a, b))
+        writable = [e for e in ext if e[2] != PNFS_BLOCK_READ_DATA]
+        for a, b in zip(writable, writable[1:]):
+            if b[0] != a[0] + a[1]:
+                fail("Writable extents %s and %s are not logically "
+                     "contiguous" % (a, b))
+        if layout.lo_offset <= 0 < layout.lo_offset + layout.lo_length:
+            found = True
+            if not ext[0][0] <= 0 < ext[0][0] + ext[0][1]:
+                fail("First extent %s does not contain offset 0" %
+                     (ext[0],))
+        for e in opaque.blo_extents:
+            if e.bex_state == PNFS_BLOCK_READ_DATA:
+                continue
+            off = e.bex_file_offset
+            for i in range(3):
+                if off <= i*bs < off + e.bex_length:
+                    blocks[i] = (e.bex_vol_id,
+                                 e.bex_storage_offset + i*bs - off)
+    if not found:
+        fail("No layout contains offset 0")
+    if len(blocks) < 3:
+        t.pass_warn("The layout does not cover all three blocks, so a "
+                    "merge could not be seen")
+    if blocks[0][0] != blocks[1][0] or blocks[1][0] != blocks[2][0] or \
+       blocks[1][1] != blocks[0][1] + bs or blocks[2][1] != blocks[1][1] + bs:
+        t.pass_warn("The three blocks are not contiguous on the volume, "
+                    "so there were no extents to merge")
