From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 17/24] pnfs_submit: remove pnfs_update_layout_commit
Date: Tue,  8 Jun 2010 00:19:14 -0400
Message-ID: <1275970761-31806-18-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
 <1275970761-31806-15-git-send-email-iisaman@netapp.com>
 <1275970761-31806-16-git-send-email-iisaman@netapp.com>
 <1275970761-31806-17-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878Ab0FHETs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:48 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ8014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:36 -0700 (PDT)
In-Reply-To: <1275970761-31806-17-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This seems completely extraneous.  Also note this was being
called from within a spinlock.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c  |   39 ---------------------------------------
 fs/nfs/pnfs.h  |    1 -
 fs/nfs/write.c |    8 +-------
 3 files changed, 1 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 456b057..3d5c17b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1428,45 +1428,6 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pnfs_set_pg_test(inode, pgio);
 }
 
-/*
- * Get a layoutout for COMMIT
- */
-void
-pnfs_update_layout_commit(struct inode *inode,
-			struct list_head *head,
-			pgoff_t idx_start,
-			unsigned int npages)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct nfs_page *nfs_page = nfs_list_entry(head->next);
-	u64 count;
-	loff_t start;
-	int status;
-
-	dprintk("--> %s inode %p layout range: %Zd@%llu\n", __func__, inode,
-		(size_t)(npages * PAGE_CACHE_SIZE),
-		(u64)((u64)idx_start << PAGE_CACHE_SHIFT));
-
-	if (!pnfs_enabled_sb(nfss))
-		return;
-
-	/* COMMIT indicates the whole file with offset = count = 0
-	 * whereas layout segments indicate whole file with offset = 0,
-	 * count = NFS4_MAX_UINT64.
-	 */
-	count = (size_t)npages * PAGE_CACHE_SIZE;
-	start = (loff_t)idx_start <<  PAGE_CACHE_SHIFT;
-	if (start == 0 && count == 0)
-		count = NFS4_MAX_UINT64;
-
-	status = _pnfs_update_layout(inode, nfs_page->wb_context,
-				count,
-				start,
-				IOMODE_RW,
-				NULL);
-	dprintk("%s  virt update status %d\n", __func__, status);
-}
-
 static int
 pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e463c76..339485d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -58,7 +58,6 @@ enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
-void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e2fbddb..960006e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -538,14 +538,8 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, u
 	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
 	if (ret > 0)
 		nfsi->ncommit -= ret;
-	if (nfs_need_commit(NFS_I(inode))) {
+	if (nfs_need_commit(NFS_I(inode)))
 		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-#ifdef CONFIG_NFS_V4_1
-		/* FIXME: change pnfs_update_layout_commit to derive
-		   idx_start from head of list and pass ret rather than npages */
-		pnfs_update_layout_commit(inode, dst, idx_start, npages);
-#endif /* CONFIG_NFS_V4_1 */
-	}
 	return ret;
 }
 #else
-- 
1.6.6.1

