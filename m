Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34059 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbIAWLv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 18:11:51 -0400
Received: by padhy1 with SMTP id hy1so9030423pad.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 15:11:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFSv4.1/flexfiles: Mark layout for return if the mirrors are invalid
Date: Tue,  1 Sep 2015 15:11:46 -0700
Message-Id: <1441145506-2891-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441145506-2891-2-git-send-email-trond.myklebust@primarydata.com>
References: <1441145506-2891-1-git-send-email-trond.myklebust@primarydata.com>
 <1441145506-2891-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a read-write layout has an invalid mirror, then we should
mark it as invalid, and return it.
If a read-only layout has an invalid mirror, then mark it as invalid
and check if there is still at least one valid mirror before we return
it.

Note: Also fix incorrect use of pnfs_generic_mark_devid_invalid().
We really want nfs4_mark_deviceid_unavailable().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 45 ++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index b6c21e9fa002..e125e55de86d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -172,6 +172,32 @@ out_err:
 	return NULL;
 }
 
+static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
+		struct nfs4_deviceid_node *devid)
+{
+	nfs4_mark_deviceid_unavailable(devid);
+	if (!ff_layout_has_available_ds(lseg))
+		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
+				lseg);
+}
+
+static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
+		struct nfs4_ff_layout_mirror *mirror)
+{
+	if (mirror == NULL || mirror->mirror_ds == NULL) {
+		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
+					lseg);
+		return false;
+	}
+	if (mirror->mirror_ds->ds == NULL) {
+		struct nfs4_deviceid_node *devid;
+		devid = &mirror->mirror_ds->id_node;
+		ff_layout_mark_devid_invalid(lseg, devid);
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
-			nfs4_mark_deviceid_unavailable(devid);
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
-			nfs4_mark_deviceid_unavailable(devid);
-		}
 		goto out;
 	}
 
-- 
2.4.3

