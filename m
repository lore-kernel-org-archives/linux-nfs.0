From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 1/2] nfs: nfs_redirty_request
Date: Wed, 19 Mar 2008 11:24:38 -0400
Message-ID: <1205940280-10479-2-git-send-email-iisaman@citi.umich.edu>
References: <1205940280-10479-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:14222 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625AbYCSUO5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:14:57 -0400
In-Reply-To: <1205940280-10479-1-git-send-email-iisaman@citi.umich.edu>
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
index 80c61fd..df85b7b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -407,7 +407,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 }
 
 static void
-nfs_redirty_request(struct nfs_page *req)
+nfs_mark_request_dirty(struct nfs_page *req)
 {
 	__set_page_dirty_nobuffers(req->wb_page);
 }
@@ -461,7 +461,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
 		return 1;
 	}
 	if (test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags)) {
-		nfs_redirty_request(req);
+		nfs_mark_request_dirty(req);
 		return 1;
 	}
 	return 0;
@@ -845,6 +845,17 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
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
@@ -900,8 +911,6 @@ out_bad:
 		nfs_writedata_release(data);
 	}
 	nfs_redirty_request(req);
-	nfs_end_page_writeback(req->wb_page);
-	nfs_clear_page_tag_locked(req);
 	return -ENOMEM;
 }
 
@@ -942,8 +951,6 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_redirty_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_clear_page_tag_locked(req);
 	}
 	return -ENOMEM;
 }
@@ -1291,7 +1298,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
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

