From: andros@netapp.com
Subject: [PATCH 2/2] SQUASHME pnfs-submit destroy all layouts upon lease expiration
Date: Wed, 21 Jul 2010 10:43:36 -0400
Message-ID: <1279723416-4467-2-git-send-email-andros@netapp.com>
References: <1279723416-4467-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60914 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758665Ab0GUOoO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 10:44:14 -0400
In-Reply-To: <1279723416-4467-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    1 +
 fs/nfs/pnfs.c      |   18 ++++++++++++++++++
 fs/nfs/pnfs.h      |    5 +++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2696909..18284bd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1471,6 +1471,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+			pnfs_destroy_all_layouts(clp);
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f255f5..a0415d5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -399,6 +399,24 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
 
+/*
+ * Called by the state manger to remove all layouts established under an
+ * expired lease.
+ */
+void
+pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+	struct pnfs_layout_type *lo;
+
+	while (!list_empty(&clp->cl_layouts)) {
+		lo = list_entry(clp->cl_layouts.next, struct pnfs_layout_type,
+				lo_layouts);
+		dprintk("%s freeing layout for inode %lu\n", __func__,
+			lo->lo_inode->i_ino);
+		pnfs_destroy_layout(NFS_I(lo->lo_inode));
+	}
+}
+
 static inline void
 init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1d16049..30c91d0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,6 +64,7 @@ void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segm
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
+void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout(struct inode *inode);
 void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
 
@@ -134,6 +135,10 @@ static inline void pnfs_update_layout(struct inode *ino,
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+}
+
 static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
-- 
1.6.6

