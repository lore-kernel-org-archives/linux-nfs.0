From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 6/6] SQUASHME: pnfs-submit: pnfs_return_layout remove surrounding #ifdef CONFIG_NFS_V4_1
Date: Tue,  6 Jul 2010 17:08:53 +0300
Message-ID: <1278425333-22499-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28101 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752892Ab0GFOI4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:08:56 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define empty do nothing pnfs_return_layout(), pnfs_ld_layoutret_on_setattr() &
a new pnfs_layout_roc_iomode() in the !CONFIG_NFS_V4_1 case. Now they can be used
regardless.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/inode.c            |    3 +--
 fs/nfs/nfs4proc.c         |   15 ++-------------
 fs/nfs/nfs4state.c        |   17 ++++++++---------
 fs/nfs/pnfs.h             |   38 ++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4_pnfs.h |    8 --------
 5 files changed, 49 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 916d6d0..ee792ca 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1351,9 +1351,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_clear_inode(struct inode *inode)
 {
-#ifdef CONFIG_NFS_V4_1
 	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
-#endif /* CONFIG_NFS_V4_1 */
+
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
 	nfs_clear_inode(inode);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a80053..1f4fc77 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2333,18 +2333,6 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
-static void
-pnfs4_return_layout_on_setattr(struct inode *inode)
-{
-#ifdef CONFIG_NFS_V4_1
-	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	if (has_layout(nfsi) && pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
-		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 /* 
  * The file is not closed if it is opened due to the a request to change
  * the size of the file. The open call will not be needed once the
@@ -2371,7 +2359,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
-	pnfs4_return_layout_on_setattr(inode);
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
 
 	nfs_fattr_init(fattr);
 	
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bfe679b..8734688 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -594,19 +594,18 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else {
-#ifdef CONFIG_NFS_V4_1
-		struct nfs_inode *nfsi = NFS_I(state->inode);
-
-		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
-			struct nfs4_pnfs_layout_segment range;
+		u32 roc_iomode = pnfs_layout_roc_iomode(NFS_I(state->inode));
+		if (roc_iomode) {
+			struct nfs4_pnfs_layout_segment range = {
+				.iomode = roc_iomode,
+				.offset = 0,
+				.length = NFS4_MAX_UINT64,
+			};
 
-			range.iomode = nfsi->layout.roc_iomode;
-			range.offset = 0;
-			range.length = NFS4_MAX_UINT64;
 			pnfs_return_layout(state->inode, &range, NULL,
 					   RETURN_FILE, wait);
 		}
-#endif /* CONFIG_NFS_V4_1 */
+
 		nfs4_do_close(path, state, gfp_mask, wait);
 	}
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 55f3028..2b46e38 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -148,6 +148,23 @@ static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 	}
 }
 
+/* Should the pNFS client commit and return the layout upon a setattr
+ */
+static inline int
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	return NFS_SERVER(inode)->pnfs_curr_ld->ld_policy_ops->flags &
+		PNFS_LAYOUTRET_ON_SETATTR;
+}
+
+/* Should the pNFS client commit and return the layout on close
+ */
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
+{
+	return nfsi->layout.roc_iomode;
+}
+
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
@@ -294,6 +311,27 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	return 0;
 }
 
+static inline int
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	return false;
+}
+
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
+{
+	return 0;
+}
+
+static inline int pnfs_return_layout(struct inode *ino,
+				     struct nfs4_pnfs_layout_segment *lseg,
+				     const nfs4_stateid *stateid, /* optional */
+				     enum pnfs_layoutreturn_type type,
+				     bool wait)
+{
+	return 0;
+}
+
 static inline struct pnfs_layout_segment *
 nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
 {
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index f097e59..e9d822d 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -234,14 +234,6 @@ pnfs_ld_gather_across_stripes(struct pnfs_layoutdriver_type *ld)
 	return ld->ld_policy_ops->flags & PNFS_GATHER_ACROSS_STRIPES;
 }
 
-/* Should the pNFS client commit and return the layout upon a setattr
- */
-static inline int
-pnfs_ld_layoutret_on_setattr(struct pnfs_layoutdriver_type *ld)
-{
-	return ld->ld_policy_ops->flags & PNFS_LAYOUTRET_ON_SETATTR;
-}
-
 struct pnfs_device {
 	struct pnfs_deviceid dev_id;
 	unsigned int  layout_type;
-- 
1.6.6.1

