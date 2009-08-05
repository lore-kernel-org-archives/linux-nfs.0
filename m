From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ->migratepage aops for nfs missing
Date: Tue, 04 Aug 2009 20:02:47 -0400
Message-ID: <1249430567.12510.3.camel@heimdal.trondhjem.org>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org>
	 <20090804202648.GA12484@basil.fritz.box>  <25558.1249423367@redhat.com>
	 <1249423594.12510.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: David Howells <dhowells@redhat.com>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40178 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933812AbZHEACx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 20:02:53 -0400
In-Reply-To: <1249423594.12510.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-04 at 18:06 -0400, Trond Myklebust wrote:
> On Tue, 2009-08-04 at 23:02 +0100, David Howells wrote:
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > The only thing I'm not 100% sure about is fscache, but I think the
> > > correct thing is just to call nfs_fscache_release_page(). David?
> > 
> > Yes, probably.  Note that that will only release the page unconditionally if
> > gfp includes __GFP_WAIT.
> 
> Right, but I believe that migratepage does allow you to sleep, so that
> shouldn't be a problem.
> 
> Cheers
>   Trond
Something like this ought to do it then...

Cheers
  Trond
-----------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Add a ->migratepage() aop for NFS

Make NFS a bit more NUMA-friendly...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c     |    1 +
 fs/nfs/internal.h |    6 +++
 fs/nfs/write.c    |   92 ++++++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 77 insertions(+), 22 deletions(-)


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
index 0a0a2ff..6abf248 100644
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
@@ -1582,6 +1594,42 @@ int nfs_wb_page(struct inode *inode, struct page* page)
 	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
 }
 
+#ifdef CONFIG_MIGRATION
+int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
+		struct page *page)
+{
+	struct inode *inode = page->mapping->host;
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


