Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2EITSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:18:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 4/5] NFS: Clean up - Rename nfs_unlock_request and nfs_unlock_request_dont_release
Date: Wed,  9 May 2012 15:18:42 -0400
Message-Id: <1336591123-23400-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336591123-23400-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-2-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Function rename to ensure that the functionality of nfs_unlock_request()
mirrors that of nfs_lock_request(). Then let nfs_unlock_and_release_request()
do the work of what used to be called nfs_unlock_request()...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c          |   10 +++++-----
 fs/nfs/pagelist.c        |   11 ++++++-----
 fs/nfs/write.c           |   12 ++++++------
 include/linux/nfs_page.h |    2 +-
 4 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 465ea84..845e201 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -488,7 +488,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 
 	while (!list_empty(&failed)) {
 		nfs_release_request(req);
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 
 	if (put_dreq(dreq))
@@ -521,7 +521,7 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 			nfs_mark_request_commit(req, NULL, &cinfo);
 		} else
 			nfs_release_request(req);
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
@@ -662,7 +662,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			req->wb_offset = pos & ~PAGE_MASK;
 			if (!nfs_pageio_add_request(desc, req)) {
 				result = desc->pg_error;
-				nfs_unlock_request(req);
+				nfs_unlock_and_release_request(req);
 				nfs_release_request(req);
 				break;
 			}
@@ -739,7 +739,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		default:
 			nfs_release_request(req);
 		}
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 
 out_put:
@@ -756,7 +756,7 @@ static void nfs_write_sync_pgio_error(struct list_head *head)
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_release_request(req);
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 69146f3..aed913c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -128,10 +128,10 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 }
 
 /**
- * nfs_unlock_request_dont_release - Unlock request and wake up sleepers.
+ * nfs_unlock_request - Unlock request and wake up sleepers.
  * @req:
  */
-void nfs_unlock_request_dont_release(struct nfs_page *req)
+void nfs_unlock_request(struct nfs_page *req)
 {
 	if (!NFS_WBACK_BUSY(req)) {
 		printk(KERN_ERR "NFS: Invalid unlock attempted\n");
@@ -144,11 +144,12 @@ void nfs_unlock_request_dont_release(struct nfs_page *req)
 }
 
 /**
- * nfs_unlock_request - Unlock request and release the nfs_page
+ * nfs_unlock_and_release_request - Unlock request and release the nfs_page
+ * @req:
  */
-void nfs_unlock_request(struct nfs_page *req)
+void nfs_unlock_and_release_request(struct nfs_page *req)
 {
-	nfs_unlock_request_dont_release(req);
+	nfs_unlock_request(req);
 	nfs_release_request(req);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 553f7ef..8ffd7d5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -625,7 +625,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 remove_req:
 		nfs_inode_remove_request(req);
 next:
-		nfs_unlock_request_dont_release(req);
+		nfs_unlock_request(req);
 		nfs_end_page_writeback(req->wb_page);
 		nfs_release_request(req);
 	}
@@ -812,7 +812,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 	nfs_mark_request_dirty(req);
-	nfs_unlock_request(req);
+	nfs_unlock_and_release_request(req);
 	return 0;
 }
 
@@ -1039,7 +1039,7 @@ static int nfs_do_multiple_writes(struct list_head *head,
 static void nfs_redirty_request(struct nfs_page *req)
 {
 	nfs_mark_request_dirty(req);
-	nfs_unlock_request_dont_release(req);
+	nfs_unlock_request(req);
 	nfs_end_page_writeback(req->wb_page);
 	nfs_release_request(req);
 }
@@ -1477,7 +1477,7 @@ void nfs_retry_commit(struct list_head *page_list,
 			dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				     BDI_RECLAIMABLE);
 		}
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_retry_commit);
@@ -1555,7 +1555,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
 	next:
-		nfs_unlock_request(req);
+		nfs_unlock_and_release_request(req);
 	}
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
@@ -1726,7 +1726,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 			 * page as being dirty
 			 */
 			cancel_dirty_page(page, PAGE_CACHE_SIZE);
-			nfs_unlock_request(req);
+			nfs_unlock_and_release_request(req);
 			break;
 		}
 		ret = nfs_wait_on_request(req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 263f30a..88d166b 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -96,7 +96,7 @@ extern bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 				struct nfs_page *req);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
-extern void nfs_unlock_request_dont_release(struct nfs_page *req);
+extern	void nfs_unlock_and_release_request(struct nfs_page *req);
 
 /*
  * Lock the page of an asynchronous request
-- 
1.7.7.6

