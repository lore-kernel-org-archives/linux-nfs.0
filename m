Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36026 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759090Ab2IMXfu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:35:50 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 04/10] SQUASHME: Remove unused lr_flags & co
Date: Fri, 14 Sep 2012 02:35:37 +0300
Message-ID: <1347579337-21548-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the member nfsd4_pnfs_layoutreturn::lr_flags was
only set and never used any where.

Perhaps the intention was to put it inside
nfsd4_pnfs_layoutreturn_arg, to be passed to the
s_pnfs_op->layout_return() operation, but it is
not so.

The following patches will change layoutreturn API
which will make these flags unnecessary, so just drop
them.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c | 16 ++++++----------
 fs/nfsd/xdr4.h      |  6 ------
 2 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index f0e193a..5228e3b 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -350,15 +350,13 @@ destroy_layout(struct nfs4_layout *lp)
 }
 
 void fs_layout_return(struct super_block *sb, struct inode *ino,
-		      struct nfsd4_pnfs_layoutreturn *lrp, int flags,
-		      void *recall_cookie)
+		      struct nfsd4_pnfs_layoutreturn *lrp, void *recall_cookie)
 {
 	int ret;
 
 	if (unlikely(!sb->s_pnfs_op->layout_return))
 		return;
 
-	lrp->lr_flags = flags;
 	lrp->args.lr_cookie = recall_cookie;
 
 	if (!ino) /* FSID or ALL */
@@ -366,10 +364,10 @@ void fs_layout_return(struct super_block *sb, struct inode *ino,
 
 	ret = sb->s_pnfs_op->layout_return(ino, &lrp->args);
 	dprintk("%s: inode %lu iomode=%d offset=0x%llx length=0x%llx "
-		"cookie = %p flags 0x%x status=%d\n",
+		"cookie=%p status=%d\n",
 		__func__, ino->i_ino, lrp->args.lr_seg.iomode,
 		lrp->args.lr_seg.offset, lrp->args.lr_seg.length,
-		recall_cookie, flags, ret);
+		recall_cookie, ret);
 }
 
 static u64
@@ -1077,7 +1075,7 @@ out:
 	nfs4_unlock_state();
 
 	/* call exported filesystem layout_return (ignore return-code) */
-	fs_layout_return(sb, ino, lrp, 0, recall_cookie);
+	fs_layout_return(sb, ino, lrp, recall_cookie);
 
 out_no_fs_call:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
@@ -1214,8 +1212,7 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
 	recall_cookie = layoutrecall_done(clr);
 	spin_unlock(&layout_lock);
 
-	fs_layout_return(clr->clr_sb, inode, &lr, LR_FLAG_INTERN,
-			 recall_cookie);
+	fs_layout_return(clr->clr_sb, inode, &lr, recall_cookie);
 	iput(inode);
 }
 
@@ -1250,7 +1247,6 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 		found = true;
 		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
 		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
-				 LR_FLAG_INTERN,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 	}
 	spin_unlock(&layout_lock);
@@ -1308,7 +1304,7 @@ void pnfs_expire_client(struct nfs4_client *clp)
 		dprintk("%s: inode %lu lp %p clp %p\n", __func__, inode->i_ino,
 			lp, clp);
 
-		fs_layout_return(inode->i_sb, inode, &lr, LR_FLAG_EXPIRE,
+		fs_layout_return(inode->i_sb, inode, &lr,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 		iput(inode);
 	}
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 9db2c0b..6350337 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -460,14 +460,8 @@ struct nfsd4_pnfs_layoutcommit {
 	struct nfsd4_pnfs_layoutcommit_res res;
 };
 
-enum layoutreturn_flags {
-	LR_FLAG_INTERN = 1 << 0,	/* internal return */
-	LR_FLAG_EXPIRE = 1 << 1,	/* return on client expiration */
-};
-
 struct nfsd4_pnfs_layoutreturn {
 	struct nfsd4_pnfs_layoutreturn_arg args;
-	u32			lr_flags;
 	stateid_t		lr_sid;		/* request/resopnse */
 	u32			lrs_present;	/* response */
 };
-- 
1.7.10.2.677.gb6bc67f

