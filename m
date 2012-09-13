Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35886 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758517Ab2IMXdo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:33:44 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 01/10] Revert "pnfsd-exofs: Two clients must not write to the same RAID stripe"
Date: Fri, 14 Sep 2012 02:33:31 +0300
Message-ID: <1347579211-21444-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit c5c391c6f12e09a65e37ebe3e8c437d075d0befd.
---
 fs/exofs/export.c | 48 ++++++------------------------------------------
 1 file changed, 6 insertions(+), 42 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index bc69073..a53f575 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -29,9 +29,6 @@
 
 #include "linux/nfsd/pnfs_osd_xdr_srv.h"
 
-/* TODO: put in sysfs per sb */
-const static unsigned sb_shared_num_stripes = 8;
-
 static int exofs_layout_type(struct super_block *sb)
 {
 	return LAYOUT_OSD2_OBJECTS;
@@ -97,27 +94,14 @@ void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
 	}
 }
 
-static bool _align_io(struct ore_layout *layout, struct nfsd4_layout_seg *lseg,
-		      bool shared)
+static void _align_io(struct ore_layout *layout, u64 *offset, u64 *length)
 {
 	u64 stripe_size = (layout->group_width - layout->parity) *
 							layout->stripe_unit;
 	u64 group_size = stripe_size * layout->group_depth;
 
-	/* TODO: Don't ignore shared flag. Single writer can get a full group */
-	if (lseg->iomode != IOMODE_READ &&
-	    (layout->parity || (layout->mirrors_p1 > 1))) {
-		/* RAID writes */
-		lseg->offset = div64_u64(lseg->offset, stripe_size) *
-								stripe_size;
-		lseg->length = stripe_size * sb_shared_num_stripes;
-		return true;
-	} else {
-		/* reads or no data redundancy */
-		lseg->offset = div64_u64(lseg->offset, group_size) * group_size;
-		lseg->length = group_size;
-		return false;
-	}
+	*offset = div64_u64(*offset, group_size) * group_size;
+	*length = group_size;
 }
 
 static enum nfsstat4 exofs_layout_get(
@@ -132,41 +116,21 @@ static enum nfsstat4 exofs_layout_get(
 	struct pnfs_osd_layout layout;
 	__be32 *start;
 	unsigned i;
-	bool in_recall, need_recall;
+	bool in_recall;
 	enum nfsstat4 nfserr;
 
 	EXOFS_DBGMSG("(0x%lx) REQUESTED offset=0x%llx len=0x%llx iomod=0x%x\n",
 		     inode->i_ino, res->lg_seg.offset,
 		     res->lg_seg.length, res->lg_seg.iomode);
 
-	need_recall = _align_io(&sbi->layout, &res->lg_seg,
-				test_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags));
+	_align_io(&sbi->layout, &res->lg_seg.offset, &res->lg_seg.length);
+	res->lg_seg.iomode = IOMODE_RW;
 	res->lg_return_on_close = true;
 
 	EXOFS_DBGMSG("(0x%lx) RETURNED offset=0x%llx len=0x%llx iomod=0x%x\n",
 		     inode->i_ino, res->lg_seg.offset,
 		     res->lg_seg.length, res->lg_seg.iomode);
 
-	if (need_recall) {
-		int rc = cb_layout_recall(inode, IOMODE_RW, res->lg_seg.offset,
-				      res->lg_seg.length, (void *)0x17);
-		switch (rc) {
-		case 0:
-		case -EAGAIN:
-			EXOFS_DBGMSG("(0x%lx) @@@ Sharing of RAID5/1 stripe\n",
-				     inode->i_ino);
-			return NFS4ERR_RECALLCONFLICT;
-		default:
-			/* This is fine for now */
-			/* TODO: Fence object off */
-			EXOFS_DBGMSG("(0x%lx) !!!cb_layout_recall => %d\n",
-				     inode->i_ino, rc);
-			/*fallthrough*/
-		case -ENOENT:
-			break;
-		}
-	}
-
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
-- 
1.7.10.2.677.gb6bc67f

