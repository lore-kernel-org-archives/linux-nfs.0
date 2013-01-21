Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f169.google.com ([209.85.215.169]:46567 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab3AUOyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:49 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so2565283eaa.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:48 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 6/9] pnfsd: LR_FLAG_CL_EMPTY layout return flag
Date: Mon, 21 Jan 2013 16:54:45 +0200
Message-Id: <1358780085-6112-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 17 +++++++++++++----
 include/linux/nfsd/nfsd4_pnfs.h |  1 +
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d48abba..2d4f23d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1064,6 +1064,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	u64 ex_fsid = current_fh->fh_export->ex_fsid;
 	void *recall_cookie = NULL;
 	LIST_HEAD(lo_destroy_list);
+	int lr_flags = 0;
 
 	dprintk("NFSD: %s\n", __func__);
 
@@ -1098,9 +1099,12 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		layouts_found = pnfs_return_file_layouts(clp, fp, lrp, ls,
 							 &lo_destroy_list);
 		put_layout_state(ls);
+		if (!lrp->lrs_present)
+			lr_flags |= LR_FLAG_CL_EMPTY;
 	} else {
 		layouts_found = pnfs_return_client_layouts(clp, lrp, ex_fsid,
 							   &lo_destroy_list);
+		lr_flags |= LR_FLAG_CL_EMPTY;
 	}
 
 	dprintk("pNFS %s: clp %p fp %p layout_type 0x%x iomode %d "
@@ -1136,7 +1140,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	nfs4_unlock_state();
 
 	pnfsd_return_lo_list(&lo_destroy_list, ino ? ino : sb->s_root->d_inode,
-			     lrp, 0, recall_cookie);
+			     lrp, lr_flags, recall_cookie);
 
 out_no_fs_call:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
@@ -1252,24 +1256,29 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	struct inode *inode;
 	void *recall_cookie;
 	LIST_HEAD(lo_destroy_list);
+	int lr_flags = LR_FLAG_INTERN;
 
 	dprintk("%s: clp %p fp %p: simulating layout_return\n", __func__,
 		clr->clr_client, clr->clr_file);
 
-	if (clr->cb.cbl_recall_type == RETURN_FILE)
+	if (clr->cb.cbl_recall_type == RETURN_FILE) {
 		pnfs_return_file_layouts(clr->clr_client, clr->clr_file, &lr,
 					 NULL, &lo_destroy_list);
-	else
+		if (!lr.lrs_present)
+			lr_flags |= LR_FLAG_CL_EMPTY;
+	} else {
 		pnfs_return_client_layouts(clr->clr_client, &lr,
 					   clr->cb.cbl_fsid.major,
 					   &lo_destroy_list);
+		lr_flags |= LR_FLAG_CL_EMPTY;
+	}
 
 	spin_lock(&layout_lock);
 	recall_cookie = layoutrecall_done(clr);
 	spin_unlock(&layout_lock);
 
 	inode = clr->clr_file->fi_inode ?: clr->clr_sb->s_root->d_inode;
-	pnfsd_return_lo_list(&lo_destroy_list, inode, &lr, LR_FLAG_INTERN,
+	pnfsd_return_lo_list(&lo_destroy_list, inode, &lr, lr_flags,
 			     recall_cookie);
 }
 
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index ec77175..bfea9a6 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -113,6 +113,7 @@ struct nfsd4_pnfs_layoutcommit_res {
 enum layoutreturn_flags {
 	LR_FLAG_INTERN = 1 << 0,	/* internal return */
 	LR_FLAG_EXPIRE = 1 << 1,	/* return on client expiration */
+	LR_FLAG_CL_EMPTY = 1 << 2,	/* No more layout for returning client */
 };
 
 struct nfsd4_pnfs_layoutreturn_arg {
-- 
1.7.11.7

