Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f48.google.com ([74.125.83.48]:61427 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUOyh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:37 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so2964403eei.35
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:36 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 4/9] SQUASHME: pnfsd: remove fs_layout_return sb parameter
Date: Mon, 21 Jan 2013 16:54:33 +0200
Message-Id: <1358780073-6026-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Boaz Harrosh <bharrosh@panasas.com>

Derive the superblock from the inode argument.
Let the caller provide the right inode, rather than NULL
for RETURN_{FSID,ALL}

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index c62af3d..b8d0db8 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -350,11 +350,12 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 	put_nfs4_file(fp);
 }
 
-void fs_layout_return(struct super_block *sb, struct inode *ino,
-		      struct nfsd4_pnfs_layoutreturn *lrp, int flags,
-		      void *recall_cookie)
+static void fs_layout_return(struct inode *ino,
+			     struct nfsd4_pnfs_layoutreturn *lrp,
+			     int flags, void *recall_cookie)
 {
 	int ret;
+	struct super_block *sb = ino->i_sb;
 
 	if (unlikely(!sb->s_pnfs_op->layout_return))
 		return;
@@ -362,9 +363,6 @@ void fs_layout_return(struct super_block *sb, struct inode *ino,
 	lrp->args.lr_flags = flags;
 	lrp->args.lr_cookie = recall_cookie;
 
-	if (!ino) /* FSID or ALL */
-		ino = sb->s_root->d_inode;
-
 	ret = sb->s_pnfs_op->layout_return(ino, &lrp->args);
 	dprintk("%s: inode %lu iomode=%d offset=0x%llx length=0x%llx "
 		"cookie = %p flags 0x%x status=%d\n",
@@ -1081,7 +1079,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	nfs4_unlock_state();
 
 	/* call exported filesystem layout_return (ignore return-code) */
-	fs_layout_return(sb, ino, lrp, 0, recall_cookie);
+	fs_layout_return(ino, lrp, 0, recall_cookie);
 
 out_no_fs_call:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
@@ -1201,9 +1199,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		inode = igrab(clr->clr_file->fi_inode);
 		if (WARN_ON(!inode))
 			return;
-	} else {
-		inode = NULL;
-	}
+	} else
+		inode = clr->clr_sb->s_root->d_inode;
 
 	dprintk("%s: clp %p fp %p: simulating layout_return\n", __func__,
 		clr->clr_client, clr->clr_file);
@@ -1219,8 +1216,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	recall_cookie = layoutrecall_done(clr);
 	spin_unlock(&layout_lock);
 
-	fs_layout_return(clr->clr_sb, inode, &lr, LR_FLAG_INTERN,
-			 recall_cookie);
+	fs_layout_return(inode, &lr, LR_FLAG_INTERN, recall_cookie);
 	iput(inode);
 }
 
@@ -1255,8 +1251,7 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 		empty = list_empty(&fp->fi_layouts);
 		found = true;
 		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
-		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
-				 LR_FLAG_INTERN,
+		fs_layout_return(fp->fi_inode, &lr, LR_FLAG_INTERN,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 	}
 	spin_unlock(&layout_lock);
@@ -1315,7 +1310,7 @@ void pnfs_expire_client(struct nfs4_client *clp)
 		dprintk("%s: inode %lu lp %p clp %p\n", __func__, inode->i_ino,
 			lp, clp);
 
-		fs_layout_return(inode->i_sb, inode, &lr, LR_FLAG_EXPIRE,
+		fs_layout_return(inode, &lr, LR_FLAG_EXPIRE,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 		iput(inode);
 	}
-- 
1.7.11.7

