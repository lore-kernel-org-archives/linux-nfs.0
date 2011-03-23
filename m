Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085Ab1CWMai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 08:30:38 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/11] NFSv4.1: pull error handling out of nfs_commit_list
Date: Wed, 23 Mar 2011 08:30:05 -0400
Message-Id: <1300883412-32296-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
References: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Create a separate support function for later use by data server
commit code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bf672fa..dbc8018 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1357,6 +1357,21 @@ static void nfs_init_commit(struct nfs_write_data *data,
 	nfs_fattr_init(&data->fattr);
 }
 
+static void nfs_retry_commit(struct list_head *page_list)
+{
+	struct nfs_page *req;
+
+	while (!list_empty(page_list)) {
+		req = nfs_list_entry(page_list->next);
+		nfs_list_remove_request(req);
+		nfs_mark_request_commit(req);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+			     BDI_RECLAIMABLE);
+		nfs_clear_page_tag_locked(req);
+	}
+}
+
 /*
  * Commit dirty pages
  */
@@ -1364,7 +1379,6 @@ static int
 nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	struct nfs_write_data	*data;
-	struct nfs_page         *req;
 
 	data = nfs_commitdata_alloc();
 
@@ -1375,15 +1389,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 	nfs_init_commit(data, head);
 	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
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
+	nfs_retry_commit(head);
 	nfs_commit_clear_lock(NFS_I(inode));
 	return -ENOMEM;
 }
-- 
1.7.2.1

