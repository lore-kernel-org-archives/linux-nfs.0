Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43244 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab1LGOKA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 09:10:00 -0500
Received: by eaak14 with SMTP id k14so501569eaa.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 06:09:59 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] SQUASHME: pnfsd-block: fix compile error when PNFSD_BLOCK in not enabled
Date: Wed,  7 Dec 2011 16:06:50 +0200
Message-Id: <1323266810-3167-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4EDF72B1.2060509@tonian.com>
References: <4EDF72B1.2060509@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reported-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/export.c      |    2 ++
 fs/nfsd/nfs4proc.c    |   10 ++++------
 fs/nfsd/nfsd4_block.h |   18 ++++++++++++++++--
 fs/nfsd/vfs.c         |    7 +++----
 4 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a38713e..730f395 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -381,6 +381,7 @@ static int pnfsd_check_export(struct inode *inode, int *flags)
 	return 0;
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 
+#if defined(CONFIG_PNFSD_BLOCK)
 	if (pnfs_block_enabled(inode, *flags)) {
 		if (!inode->i_sb->s_pnfs_op) {
 			dprintk("set pnfs block export structure\n");
@@ -392,6 +393,7 @@ static int pnfsd_check_export(struct inode *inode, int *flags)
 
 		return 0;
 	}
+#endif /* CONFIG_PNFSD_BLOCK */
 
 #endif /* CONFIG_PNFSD */
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7b5d897..aa79a45 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -904,12 +904,10 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 
 	nfsd4_get_verifier(cstate->current_fh.fh_dentry->d_inode->i_sb,
 			   &write->wr_verifier);
-	if (pnfs_block_enabled(cstate->current_fh.fh_dentry->d_inode, 0)) {
-		status = bl_layoutrecall(cstate->current_fh.fh_dentry->d_inode,
-			RETURN_FILE, write->wr_offset, write->wr_buflen, false);
-		if (status)
-			goto out_put;
-	}
+	status = bl_recall_layout(cstate->current_fh.fh_dentry->d_inode,
+		RETURN_FILE, write->wr_offset, write->wr_buflen, false);
+	if (status)
+		goto out_put;
 	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
 			     &cnt, &write->wr_how_written);
diff --git a/fs/nfsd/nfsd4_block.h b/fs/nfsd/nfsd4_block.h
index 9c2941f..38387de 100644
--- a/fs/nfsd/nfsd4_block.h
+++ b/fs/nfsd/nfsd4_block.h
@@ -77,7 +77,7 @@
 
 #ifdef CONFIG_PNFSD_BLOCK
 
-bool pnfs_block_enabled(struct inode *, int);
+bool pnfs_block_enabled(struct inode *, int ex_flags);
 void nfsd_bl_init(void);
 int bl_layout_type(struct super_block *sb);
 int bl_getdeviceiter(struct super_block *, u32 layout_type,
@@ -97,13 +97,27 @@ int bl_layoutreturn(struct inode *,
 int bl_init_proc(void);
 int bl_upcall(bl_comm_t *, bl_comm_msg_t *, bl_comm_res_t **);
 
+
+static inline int
+bl_recall_layout(struct inode *inode, int type, u64 offset, u64 len, bool with_nfs4_state_lock)
+{
+	if (pnfs_block_enabled(inode, 0))
+		return bl_layoutrecall(inode, type, offset, len, with_nfs4_state_lock);
+}
+
 extern bl_comm_t	*bl_comm_global;	// Ugly...
 
 #else
 
-static inline bool pnfs_block_enabled(struct inode *, int) { return false; }
+static inline bool pnfs_block_enabled(struct inode *i, int ex_flags) { return false; }
 static inline void nfsd_bl_init(void) {}
 
+static inline int bl_recall_layout(struct inode *inode, int type, u64 offset,
+				   u64 len, bool with_nfs4_state_lock)
+{
+	return 0;
+}
+
 #endif /* CONFIG_PNFSD_BLOCK */
 #endif /* __KERNEL__ */
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c4629fb..24091be 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -385,10 +385,9 @@ static int nfsd_break_lease(struct inode *inode)
 			if (is_inode_pnfsd_lexp(inode))
 				pnfsd_lexp_recall_layout(inode, with_nfs4_state_lock);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
-			if (pnfs_block_enabled(inode, 0))
-				err = bl_layoutrecall(inode, RETURN_FILE,
-					iap->ia_size, inode->i_size - iap->ia_size,
-					with_nfs4_state_lock);
+			err = bl_recall_layout(inode, RETURN_FILE, iap->ia_size,
+					       inode->i_size - iap->ia_size,
+					       with_nfs4_state_lock);
 		}
 
 		host_err = get_write_access(inode);
-- 
1.7.6

