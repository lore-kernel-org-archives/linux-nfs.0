From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 19/24] pnfs: export some commit error handling for use by layout drivers
Date: Tue,  8 Jun 2010 00:19:16 -0400
Message-ID: <1275970761-31806-20-git-send-email-iisaman@netapp.com>
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
 <1275970761-31806-18-git-send-email-iisaman@netapp.com>
 <1275970761-31806-19-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961Ab0FHETt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:49 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQA014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:38 -0700 (PDT)
In-Reply-To: <1275970761-31806-19-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There exists code to deal with a memory error during commit before the
RPC has been sent.  Separate this out and export it for later use by the
filelayout driver.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/internal.h |    1 +
 fs/nfs/write.c    |   29 ++++++++++++++++++-----------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 517aa0b..b754446 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -288,6 +288,7 @@ extern int pnfs_initiate_commit(struct nfs_write_data *data,
 			       const struct rpc_call_ops *call_ops,
 			       int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+extern void nfs_mark_list_commit(struct list_head *head);
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
 		struct page *, struct page *);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 960006e..811c776 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1377,6 +1377,23 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 				    how);
 }
 
+/* Handle memory error during commit */
+void nfs_mark_list_commit(struct list_head *head)
+{
+	struct nfs_page         *req;
+
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_mark_request_commit(req);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
+		nfs_clear_page_tag_locked(req);
+	}
+}
+EXPORT_SYMBOL(nfs_mark_list_commit);
+
 /*
  * Commit dirty pages
  */
@@ -1384,25 +1401,15 @@ static int
 nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	struct nfs_write_data	*data;
-	struct nfs_page         *req;
 
 	data = nfs_commitdata_alloc();
-
 	if (!data)
 		goto out_bad;
 
 	/* Set up the argument struct */
 	return nfs_commit_rpcsetup(head, data, how);
  out_bad:
-	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_mark_request_commit(req);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
-		nfs_clear_page_tag_locked(req);
-	}
+	nfs_mark_list_commit(head);
 	nfs_commit_clear_lock(NFS_I(inode));
 	return -ENOMEM;
 }
-- 
1.6.6.1

