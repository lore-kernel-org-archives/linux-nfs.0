Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54436 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758244Ab1JFM3o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 08:29:44 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 5/5] SQUASHME pnfsd-exofs: Serve out a single group layout at a time
Date: Thu, 6 Oct 2011 14:29:35 +0200
Message-ID: <1317904175-17423-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8D9D56.6020803@panasas.com>
References: <4E8D9D56.6020803@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The number of devices in a system can get big real fast.
Just last week we tested with a x64 osd system. The layout
buffer sent from the pnfs client has space for about 21
components.

Serve out a single group segment at a time, and only send
a group-full of devices. Which is usually not bigger then 8
or 9.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/exofs/export.c |   32 +++++++++++++++++++++++++-------
 1 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index f85197e..815e807 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -94,6 +94,15 @@ void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
 	}
 }
 
+static void _align_io(struct ore_layout *layout, u64 *offset, u64 *length)
+{
+	u64 stripe_size = layout->group_width * layout->stripe_unit;
+	u64 group_size = stripe_size * layout->group_depth;
+
+	*offset = div64_u64(*offset, group_size) * group_size;
+	*length = group_size;
+}
+
 static enum nfsstat4 exofs_layout_get(
 	struct inode *inode,
 	struct exp_xdr_stream *xdr,
@@ -102,16 +111,24 @@ static enum nfsstat4 exofs_layout_get(
 {
 	struct exofs_i_info *oi = exofs_i(inode);
 	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
+	struct ore_striping_info si;
 	struct pnfs_osd_layout layout;
 	__be32 *start;
 	unsigned i;
 	bool in_recall;
 	enum nfsstat4 nfserr;
 
-	res->lg_seg.offset = 0;
-	res->lg_seg.length = NFS4_MAX_UINT64;
+	EXOFS_DBGMSG("(0x%lx) REQUESTED offset=0x%llx len=0x%llx iomod=0x%x\n",
+		     inode->i_ino, res->lg_seg.offset,
+		     res->lg_seg.length, res->lg_seg.iomode);
+
+	_align_io(&sbi->layout, &res->lg_seg.offset, &res->lg_seg.length);
 	res->lg_seg.iomode = IOMODE_RW;
-	res->lg_return_on_close = true; /* TODO: unused but will be soon */
+	res->lg_return_on_close = true;
+
+	EXOFS_DBGMSG("(0x%lx) RETURNED offset=0x%llx len=0x%llx iomod=0x%x\n",
+		     inode->i_ino, res->lg_seg.offset,
+		     res->lg_seg.length, res->lg_seg.iomode);
 
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
@@ -123,15 +140,16 @@ static enum nfsstat4 exofs_layout_get(
 	/* Fill in a pnfs_osd_layout struct */
 	ore_layout_2_pnfs_layout(&layout, &sbi->layout);
 
-	layout.olo_comps_index = 0;
-	layout.olo_num_comps = layout.olo_map.odm_num_comps;
+	ore_calc_stripe_info(&sbi->layout, res->lg_seg.offset, &si);
+	layout.olo_comps_index = si.dev;
+	layout.olo_num_comps = sbi->layout.group_width * sbi->layout.mirrors_p1;
 
 	nfserr = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
 	if (unlikely(nfserr))
 		goto out;
 
 	/* Encode layout components */
-	for (i = 0; i <  layout.olo_num_comps; i++) {
+	for (i = si.dev; i < si.dev + layout.olo_num_comps; i++) {
 		struct pnfs_osd_object_cred cred;
 		struct exofs_dev *ed = container_of(oi->oc.ods[i],
 							typeof(*ed), ored);
@@ -155,7 +173,7 @@ static enum nfsstat4 exofs_layout_get(
 		if (unlikely(nfserr)) {
 			EXOFS_DBGMSG("(0x%lx) nfserr=%u total=%u encoded=%u\n",
 				     inode->i_ino, nfserr, layout.olo_num_comps,
-				     i - 1);
+				     i - si.dev);
 			goto out;
 		}
 	}
-- 
1.7.2.3

