From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 19/26] pnfs-submit: export some commit error handling for use by layout drivers
Date: Fri, 11 Jun 2010 03:31:46 -0400
Message-ID: <1276241513-17942-20-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
 <1276241513-17942-13-git-send-email-iisaman@netapp.com>
 <1276241513-17942-14-git-send-email-iisaman@netapp.com>
 <1276241513-17942-15-git-send-email-iisaman@netapp.com>
 <1276241513-17942-16-git-send-email-iisaman@netapp.com>
 <1276241513-17942-17-git-send-email-iisaman@netapp.com>
 <1276241513-17942-18-git-send-email-iisaman@netapp.com>
 <1276241513-17942-19-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757815Ab0FKHcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:32 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3uC024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:30 -0700 (PDT)
In-Reply-To: <1276241513-17942-19-git-send-email-iisaman@netapp.com>
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
index ac2608f..40abbd0 100644
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

