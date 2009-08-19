From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/32] NFS: Add a ->migratepage() aop for NFS
Date: Wed, 19 Aug 2009 19:38:49 -0400
Message-ID: <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116AbZHSXk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:58 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNehc1001920
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:44 -0700 (PDT)
In-Reply-To: <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make NFS a bit more friendly to NUMA and memory hot removal...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c     |    1 +
 fs/nfs/internal.h |    6 +++
 fs/nfs/write.c    |   91 ++++++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 76 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0506232..dfc8967 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -479,6 +479,7 @@ const struct address_space_operations nfs_file_aops = {
 	.invalidatepage = nfs_invalidate_page,
 	.releasepage = nfs_release_page,
 	.direct_IO = nfs_direct_IO,
+	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 };
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7dd90a6..e2ccb4a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -248,6 +248,12 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+#ifdef CONFIG_MIGRATION
+extern int nfs_migrate_page(struct address_space *,
+		struct page *, struct page *);
+#else
+#define nfs_migrate_page NULL
+#endif
 
 /* nfs4proc.c */
 extern int _nfs4_call_sync(struct nfs_server *server,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0a0a2ff..6240e64 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -13,6 +13,7 @@
 #include <linux/file.h>
 #include <linux/writeback.h>
 #include <linux/swap.h>
+#include <linux/migrate.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -26,6 +27,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "nfs4_fs.h"
+#include "fscache.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -220,24 +222,17 @@ static void nfs_end_page_writeback(struct page *page)
 		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
 }
 
-/*
- * Find an associated nfs write request, and prepare to flush it out
- * May return an error if the user signalled nfs_wait_on_request().
- */
-static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page)
+static struct nfs_page *nfs_find_and_lock_request(struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct nfs_page *req;
 	int ret;
 
 	spin_lock(&inode->i_lock);
-	for(;;) {
+	for (;;) {
 		req = nfs_page_find_request_locked(page);
-		if (req == NULL) {
-			spin_unlock(&inode->i_lock);
-			return 0;
-		}
+		if (req == NULL)
+			break;
 		if (nfs_set_page_tag_locked(req))
 			break;
 		/* Note: If we hold the page lock, as is the case in nfs_writepage,
@@ -249,23 +244,40 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		ret = nfs_wait_on_request(req);
 		nfs_release_request(req);
 		if (ret != 0)
-			return ret;
+			return ERR_PTR(ret);
 		spin_lock(&inode->i_lock);
 	}
-	if (test_bit(PG_CLEAN, &req->wb_flags)) {
-		spin_unlock(&inode->i_lock);
-		BUG();
-	}
-	if (nfs_set_page_writeback(page) != 0) {
-		spin_unlock(&inode->i_lock);
-		BUG();
-	}
 	spin_unlock(&inode->i_lock);
+	return req;
+}
+
+/*
+ * Find an associated nfs write request, and prepare to flush it out
+ * May return an error if the user signalled nfs_wait_on_request().
+ */
+static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
+				struct page *page)
+{
+	struct nfs_page *req;
+	int ret = 0;
+
+	req = nfs_find_and_lock_request(page);
+	if (!req)
+		goto out;
+	ret = PTR_ERR(req);
+	if (IS_ERR(req))
+		goto out;
+
+	ret = nfs_set_page_writeback(page);
+	BUG_ON(ret != 0);
+	BUG_ON(test_bit(PG_CLEAN, &req->wb_flags));
+
 	if (!nfs_pageio_add_request(pgio, req)) {
 		nfs_redirty_request(req);
-		return pgio->pg_error;
+		ret = pgio->pg_error;
 	}
-	return 0;
+out:
+	return ret;
 }
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
@@ -1582,6 +1594,41 @@ int nfs_wb_page(struct inode *inode, struct page* page)
 	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
 }
 
+#ifdef CONFIG_MIGRATION
+int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
+		struct page *page)
+{
+	struct nfs_page *req;
+	int ret;
+
+	if (PageFsCache(page))
+		nfs_fscache_release_page(page, GFP_KERNEL);
+
+	req = nfs_find_and_lock_request(page);
+	ret = PTR_ERR(req);
+	if (IS_ERR(req))
+		goto out;
+
+	ret = migrate_page(mapping, newpage, page);
+	if (!req)
+		goto out;
+	if (ret)
+		goto out_unlock;
+	page_cache_get(newpage);
+	req->wb_page = newpage;
+	SetPagePrivate(newpage);
+	set_page_private(newpage, page_private(page));
+	ClearPagePrivate(page);
+	set_page_private(page, 0);
+	page_cache_release(page);
+out_unlock:
+	nfs_clear_page_tag_locked(req);
+	nfs_release_request(req);
+out:
+	return ret;
+}
+#endif
+
 int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
-- 
1.6.0.4
