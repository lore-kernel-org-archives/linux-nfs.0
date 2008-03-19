From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 2/2] nfs: nfs_redirty_request
Date: Wed, 19 Mar 2008 17:36:24 -0400
Message-ID: <1205962584-11369-2-git-send-email-iisaman@citi.umich.edu>
References: <1205962584-11369-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:6023 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937816AbYCSVgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 17:36:25 -0400
In-Reply-To: <1205962584-11369-1-git-send-email-iisaman@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred <iisaman@citi.umich.edu>

Both flush functions have the same error handling routine.  Pull
it out as a function.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
---
 fs/nfs/write.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index db6c17b..33bb9d4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -413,7 +413,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 }
 
 static void
-nfs_redirty_request(struct nfs_page *req)
+nfs_mark_request_dirty(struct nfs_page *req)
 {
 	__set_page_dirty_nobuffers(req->wb_page);
 }
@@ -467,7 +467,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
 		return 1;
 	}
 	if (test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags)) {
-		nfs_redirty_request(req);
+		nfs_mark_request_dirty(req);
 		return 1;
 	}
 	return 0;
@@ -851,6 +851,17 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		rpc_put_task(task);
 }
 
+/* If a nfs_flush_* function fails, it should remove reqs from @head and
+ * call this on each, which will prepare them to be retried on next
+ * writeback using standard nfs.
+ */
+static void nfs_redirty_request(struct nfs_page *req)
+{
+	nfs_mark_request_dirty(req);
+	nfs_end_page_writeback(req->wb_page);
+	nfs_clear_page_tag_locked(req);
+}
+
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
@@ -906,8 +917,6 @@ out_bad:
 		nfs_writedata_release(data);
 	}
 	nfs_redirty_request(req);
-	nfs_end_page_writeback(req->wb_page);
-	nfs_clear_page_tag_locked(req);
 	return -ENOMEM;
 }
 
@@ -948,8 +957,6 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_redirty_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_clear_page_tag_locked(req);
 	}
 	return -ENOMEM;
 }
@@ -1297,7 +1304,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		}
 		/* We have a mismatch. Write the page again */
 		dprintk(" mismatch\n");
-		nfs_redirty_request(req);
+		nfs_mark_request_dirty(req);
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
-- 
1.5.3.3

