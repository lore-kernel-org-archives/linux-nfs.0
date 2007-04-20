From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/5] NFS: clean up the unstable write code
Date: Fri, 20 Apr 2007 16:12:34 -0400
Message-ID: <20070420201234.7897.92105.stgit@heimdal.trondhjem.org>
References: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Florin Iucha <florin@iucha.net>,
	Adrian Bunk <bunk@stusta.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HezT7-0002nj-AP
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:34 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezT9-0006kW-Hh
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:35 -0700
In-Reply-To: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Get rid of the inlined #ifdefs.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c           |  117 ++++++++++++++++++++++++++++------------------
 include/linux/nfs_page.h |   30 ------------
 2 files changed, 71 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ad2e91b..3ed4feb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -460,6 +460,43 @@ nfs_mark_request_commit(struct nfs_page *req)
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
+
+static inline
+int nfs_write_need_commit(struct nfs_write_data *data)
+{
+	return data->verf.committed != NFS_FILE_SYNC;
+}
+
+static inline
+int nfs_reschedule_unstable_write(struct nfs_page *req)
+{
+	if (test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+		nfs_mark_request_commit(req);
+		return 1;
+	}
+	if (test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags)) {
+		nfs_redirty_request(req);
+		return 1;
+	}
+	return 0;
+}
+#else
+static inline void
+nfs_mark_request_commit(struct nfs_page *req)
+{
+}
+
+static inline
+int nfs_write_need_commit(struct nfs_write_data *data)
+{
+	return 0;
+}
+
+static inline
+int nfs_reschedule_unstable_write(struct nfs_page *req)
+{
+	return 0;
+}
 #endif
 
 /*
@@ -746,26 +783,12 @@ int nfs_updatepage(struct file *file, struct page *page,
 
 static void nfs_writepage_release(struct nfs_page *req)
 {
-	nfs_end_page_writeback(req->wb_page);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-	if (!PageError(req->wb_page)) {
-		if (NFS_NEED_RESCHED(req)) {
-			nfs_redirty_request(req);
-			goto out;
-		} else if (NFS_NEED_COMMIT(req)) {
-			nfs_mark_request_commit(req);
-			goto out;
-		}
-	}
-	nfs_inode_remove_request(req);
-
-out:
-	nfs_clear_commit(req);
-	nfs_clear_reschedule(req);
-#else
-	nfs_inode_remove_request(req);
-#endif
+	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req)) {
+		nfs_end_page_writeback(req->wb_page);
+		nfs_inode_remove_request(req);
+	} else
+		nfs_end_page_writeback(req->wb_page);
 	nfs_clear_page_writeback(req);
 }
 
@@ -1008,22 +1031,28 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 		nfs_set_pageerror(page);
 		req->wb_context->error = task->tk_status;
 		dprintk(", error = %d\n", task->tk_status);
-	} else {
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-		if (data->verf.committed < NFS_FILE_SYNC) {
-			if (!NFS_NEED_COMMIT(req)) {
-				nfs_defer_commit(req);
-				memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
-				dprintk(" defer commit\n");
-			} else if (memcmp(&req->wb_verf, &data->verf, sizeof(req->wb_verf))) {
-				nfs_defer_reschedule(req);
-				dprintk(" server reboot detected\n");
-			}
-		} else
-#endif
-			dprintk(" OK\n");
+		goto out;
 	}
 
+	if (nfs_write_need_commit(data)) {
+		spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+
+		spin_lock(req_lock);
+		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
+			/* Do nothing we need to resend the writes */
+		} else if (!test_and_set_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+			memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
+			dprintk(" defer commit\n");
+		} else if (memcmp(&req->wb_verf, &data->verf, sizeof(req->wb_verf))) {
+			set_bit(PG_NEED_RESCHED, &req->wb_flags);
+			clear_bit(PG_NEED_COMMIT, &req->wb_flags);
+			dprintk(" server reboot detected\n");
+		}
+		spin_unlock(req_lock);
+	} else
+		dprintk(" OK\n");
+
+out:
 	if (atomic_dec_and_test(&req->wb_complete))
 		nfs_writepage_release(req);
 }
@@ -1064,25 +1093,21 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 		if (task->tk_status < 0) {
 			nfs_set_pageerror(page);
 			req->wb_context->error = task->tk_status;
-			nfs_end_page_writeback(page);
-			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
-			goto next;
+			goto remove_request;
 		}
-		nfs_end_page_writeback(page);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-		if (data->args.stable != NFS_UNSTABLE || data->verf.committed == NFS_FILE_SYNC) {
-			nfs_inode_remove_request(req);
-			dprintk(" OK\n");
+		if (nfs_write_need_commit(data)) {
+			memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
+			nfs_mark_request_commit(req);
+			nfs_end_page_writeback(page);
+			dprintk(" marked for commit\n");
 			goto next;
 		}
-		memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
-		nfs_mark_request_commit(req);
-		dprintk(" marked for commit\n");
-#else
+		dprintk(" OK\n");
+remove_request:
+		nfs_end_page_writeback(page);
 		nfs_inode_remove_request(req);
-#endif
 	next:
 		nfs_clear_page_writeback(req);
 	}
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d111be6..16b0266 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -49,8 +49,6 @@ struct nfs_page {
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-#define NFS_NEED_COMMIT(req)	(test_bit(PG_NEED_COMMIT,&(req)->wb_flags))
-#define NFS_NEED_RESCHED(req)	(test_bit(PG_NEED_RESCHED,&(req)->wb_flags))
 
 extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
@@ -121,34 +119,6 @@ nfs_list_remove_request(struct nfs_page *req)
 	req->wb_list_head = NULL;
 }
 
-static inline int
-nfs_defer_commit(struct nfs_page *req)
-{
-	return !test_and_set_bit(PG_NEED_COMMIT, &req->wb_flags);
-}
-
-static inline void
-nfs_clear_commit(struct nfs_page *req)
-{
-	smp_mb__before_clear_bit();
-	clear_bit(PG_NEED_COMMIT, &req->wb_flags);
-	smp_mb__after_clear_bit();
-}
-
-static inline int
-nfs_defer_reschedule(struct nfs_page *req)
-{
-	return !test_and_set_bit(PG_NEED_RESCHED, &req->wb_flags);
-}
-
-static inline void
-nfs_clear_reschedule(struct nfs_page *req)
-{
-	smp_mb__before_clear_bit();
-	clear_bit(PG_NEED_RESCHED, &req->wb_flags);
-	smp_mb__after_clear_bit();
-}
-
 static inline struct nfs_page *
 nfs_list_entry(struct list_head *head)
 {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
