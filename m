Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33137 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211AbbIAIRR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 04:17:17 -0400
Received: by paczk9 with SMTP id zk9so21005632pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 01:17:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/flexfiles: Mark layout for return if the mirrors are invalid
Date: Tue,  1 Sep 2015 01:17:14 -0700
Message-Id: <1441095434-11195-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a read-write layout has an invalid mirror, then we should
mark it as invalid, and return it.
If a read-only layout has an invalid mirror, then mark it as invalid
and check if there is still at least one valid mirror before we return
it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 45 ++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index b28fa4cbea52..1da9f0c4445d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -172,6 +172,32 @@ out_err:
 	return NULL;
 }
 
+static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
+		struct nfs4_deviceid_node *devid)
+{
+	pnfs_generic_mark_devid_invalid(devid);
+	if (lseg->pls_range.iomode != IOMODE_READ ||
+	    !ff_layout_has_available_ds(lseg))
+		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode, lseg);
+}
+
+static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
+		struct nfs4_ff_layout_mirror *mirror)
+{
+	if (mirror == NULL || mirror->mirror_ds == NULL ||
+	    mirror->mirror_ds->ds == NULL) {
+		if (mirror && mirror->mirror_ds) {
+			struct nfs4_deviceid_node *devid;
+			devid = &mirror->mirror_ds->id_node;
+			ff_layout_mark_devid_invalid(lseg, devid);
+		} else
+			pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
+					lseg);
+		return false;
+	}
+	return true;
+}
+
 static u64
 end_offset(u64 start, u64 len)
 {
@@ -336,16 +362,10 @@ nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 {
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
 	struct nfs_fh *fh = NULL;
-	struct nfs4_deviceid_node *devid;
 
-	if (mirror == NULL || mirror->mirror_ds == NULL ||
-	    mirror->mirror_ds->ds == NULL) {
-		printk(KERN_ERR "NFS: %s: No data server for mirror offset index %d\n",
+	if (!ff_layout_mirror_valid(lseg, mirror)) {
+		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
 			__func__, mirror_idx);
-		if (mirror && mirror->mirror_ds) {
-			devid = &mirror->mirror_ds->id_node;
-			pnfs_generic_mark_devid_invalid(devid);
-		}
 		goto out;
 	}
 
@@ -368,14 +388,9 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	unsigned int max_payload;
 	rpc_authflavor_t flavor;
 
-	if (mirror == NULL || mirror->mirror_ds == NULL ||
-	    mirror->mirror_ds->ds == NULL) {
-		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
+	if (!ff_layout_mirror_valid(lseg, mirror)) {
+		pr_err_ratelimited("NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
-		if (mirror && mirror->mirror_ds) {
-			devid = &mirror->mirror_ds->id_node;
-			pnfs_generic_mark_devid_invalid(devid);
-		}
 		goto out;
 	}
 
-- 
2.4.3

