Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2EITSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:18:49 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/5] NFS: Prevent a deadlock in the new writeback code
Date: Wed,  9 May 2012 15:18:39 -0400
Message-Id: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have to unlock the nfs_page before we call nfs_end_page_writeback
to avoid races with functions that expect the page to be unlocked
when PG_locked and PG_writeback are not set.
The problem is that nfs_unlock_request also releases the nfs_page,
causing a deadlock if the release of the nfs_open_context
triggers an iput() while the PG_writeback flag is still set...

The solution is to separate the unlocking and release of the nfs_page,
so that we can do the former before nfs_end_page_writeback and the
latter after.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c        |   12 ++++++++++--
 fs/nfs/write.c           |    6 ++++--
 include/linux/nfs_page.h |    1 +
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 33a21ca..69146f3 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -128,10 +128,10 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 }
 
 /**
- * nfs_unlock_request - Unlock request and wake up sleepers.
+ * nfs_unlock_request_dont_release - Unlock request and wake up sleepers.
  * @req:
  */
-void nfs_unlock_request(struct nfs_page *req)
+void nfs_unlock_request_dont_release(struct nfs_page *req)
 {
 	if (!NFS_WBACK_BUSY(req)) {
 		printk(KERN_ERR "NFS: Invalid unlock attempted\n");
@@ -141,6 +141,14 @@ void nfs_unlock_request(struct nfs_page *req)
 	clear_bit(PG_BUSY, &req->wb_flags);
 	smp_mb__after_clear_bit();
 	wake_up_bit(&req->wb_flags, PG_BUSY);
+}
+
+/**
+ * nfs_unlock_request - Unlock request and release the nfs_page
+ */
+void nfs_unlock_request(struct nfs_page *req)
+{
+	nfs_unlock_request_dont_release(req);
 	nfs_release_request(req);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6f263da..fd36b31 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -628,8 +628,9 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 remove_req:
 		nfs_inode_remove_request(req);
 next:
-		nfs_unlock_request(req);
+		nfs_unlock_request_dont_release(req);
 		nfs_end_page_writeback(page);
+		nfs_release_request(req);
 	}
 out:
 	hdr->release(hdr);
@@ -1042,8 +1043,9 @@ static void nfs_redirty_request(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	nfs_mark_request_dirty(req);
-	nfs_unlock_request(req);
+	nfs_unlock_request_dont_release(req);
 	nfs_end_page_writeback(page);
+	nfs_release_request(req);
 }
 
 static void nfs_async_write_error(struct list_head *head)
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index f9ee9eb..ef75042 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -96,6 +96,7 @@ extern bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 				struct nfs_page *req);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
+extern void nfs_unlock_request_dont_release(struct nfs_page *req);
 
 /*
  * Lock the page of an asynchronous request without getting a new reference
-- 
1.7.7.6

