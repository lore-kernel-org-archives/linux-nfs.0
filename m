From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 1/2] nfs: nfs_retry_request
Date: Wed, 19 Mar 2008 10:13:19 -0400
Message-ID: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:38088 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756299AbYCSUOy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:14:54 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred <iisaman@citi.umich.edu>

Both flush functions have the same error handling routine.  Pull
it out as a function.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
---
 fs/nfs/write.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 80c61fd..01bf68e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -845,6 +845,17 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		rpc_put_task(task);
 }
 
+/* If a nfs_flush_* function fails, it should remove reqs from @head and
+ * call this on each, which will prepare them to be retried on next
+ * writeback using standard nfs.
+ */
+static void nfs_retry_request(struct nfs_page *req)
+{
+	nfs_redirty_request(req);
+	nfs_end_page_writeback(req->wb_page);
+	nfs_clear_page_tag_locked(req);
+}
+
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
@@ -899,9 +910,7 @@ out_bad:
 		list_del(&data->pages);
 		nfs_writedata_release(data);
 	}
-	nfs_redirty_request(req);
-	nfs_end_page_writeback(req->wb_page);
-	nfs_clear_page_tag_locked(req);
+	nfs_retry_request(req);
 	return -ENOMEM;
 }
 
@@ -941,9 +950,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_redirty_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_clear_page_tag_locked(req);
+		nfs_retry_request(req);
 	}
 	return -ENOMEM;
 }
-- 
1.5.3.3

