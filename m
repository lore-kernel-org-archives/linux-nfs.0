Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33397 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753070AbdEPNgg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 09:36:36 -0400
Received: by mail-io0-f193.google.com with SMTP id m4so14442586ioe.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 May 2017 06:36:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: Ensure we commit after writeback is complete
Date: Tue, 16 May 2017 09:36:27 -0400
Message-Id: <20170516133628.16525-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170516133628.16525-2-trond.myklebust@primarydata.com>
References: <20170516133628.16525-1-trond.myklebust@primarydata.com>
 <20170516133628.16525-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the page cache is being flushed, then we want to ensure that we
do start a commit once the pages are done being flushed.
If we just wait until all I/O is done to that file, we can end up
livelocking until the balance_dirty_pages() mechanism puts its
foot down and forces I/O to stop.
So instead we do more or less the same thing that O_DIRECT does,
and set up a counter to tell us when the flush is done,

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        |  3 +++
 fs/nfs/write.c           | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_page.h |  1 +
 include/linux/nfs_xdr.h  |  2 ++
 4 files changed, 63 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index de107d866297..83d2918f1b13 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -50,6 +50,7 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->cred = hdr->req->wb_context->cred;
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = mirror->pg_count;
+	hdr->io_completion = desc->pg_io_completion;
 	hdr->dreq = desc->pg_dreq;
 	hdr->release = release;
 	hdr->completion_ops = desc->pg_completion_ops;
@@ -709,6 +710,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
+	desc->pg_io_completion = NULL;
 	desc->pg_dreq = NULL;
 	desc->pg_bsize = bsize;
 
@@ -1231,6 +1233,7 @@ int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
 {
 	LIST_HEAD(failed);
 
+	desc->pg_io_completion = hdr->io_completion;
 	desc->pg_dreq = hdr->dreq;
 	while (!list_empty(&hdr->pages)) {
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index db7ba542559e..051197cb9195 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -40,6 +40,12 @@
 #define MIN_POOL_WRITE		(32)
 #define MIN_POOL_COMMIT		(4)
 
+struct nfs_io_completion {
+	void (*complete)(void *data);
+	void *data;
+	struct kref refcount;
+};
+
 /*
  * Local function declarations
  */
@@ -108,6 +114,39 @@ static void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 	mempool_free(hdr, nfs_wdata_mempool);
 }
 
+static struct nfs_io_completion *nfs_io_completion_alloc(gfp_t gfp_flags)
+{
+	return kmalloc(sizeof(struct nfs_io_completion), gfp_flags);
+}
+
+static void nfs_io_completion_init(struct nfs_io_completion *ioc,
+		void (*complete)(void *), void *data)
+{
+	ioc->complete = complete;
+	ioc->data = data;
+	kref_init(&ioc->refcount);
+}
+
+static void nfs_io_completion_release(struct kref *kref)
+{
+	struct nfs_io_completion *ioc = container_of(kref,
+			struct nfs_io_completion, refcount);
+	ioc->complete(ioc->data);
+	kfree(ioc);
+}
+
+static void nfs_io_completion_get(struct nfs_io_completion *ioc)
+{
+	if (ioc != NULL)
+		kref_get(&ioc->refcount);
+}
+
+static void nfs_io_completion_put(struct nfs_io_completion *ioc)
+{
+	if (ioc != NULL)
+		kref_put(&ioc->refcount, nfs_io_completion_release);
+}
+
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
 	ctx->error = error;
@@ -681,18 +720,29 @@ static int nfs_writepages_callback(struct page *page, struct writeback_control *
 	return ret;
 }
 
+static void nfs_io_completion_commit(void *inode)
+{
+	nfs_commit_inode(inode, 0);
+}
+
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
 	struct nfs_pageio_descriptor pgio;
+	struct nfs_io_completion *ioc = nfs_io_completion_alloc(GFP_NOFS);
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
+	if (ioc)
+		nfs_io_completion_init(ioc, nfs_io_completion_commit, inode);
+
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc), false,
 				&nfs_async_write_completion_ops);
+	pgio.pg_io_completion = ioc;
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
+	nfs_io_completion_put(ioc);
 
 	if (err < 0)
 		goto out_err;
@@ -940,6 +990,11 @@ int nfs_write_need_commit(struct nfs_pgio_header *hdr)
 	return hdr->verf.committed != NFS_FILE_SYNC;
 }
 
+static void nfs_async_write_init(struct nfs_pgio_header *hdr)
+{
+	nfs_io_completion_get(hdr->io_completion);
+}
+
 static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_commit_info cinfo;
@@ -973,6 +1028,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 		nfs_release_request(req);
 	}
 out:
+	nfs_io_completion_put(hdr->io_completion);
 	hdr->release(hdr);
 }
 
@@ -1378,6 +1434,7 @@ static void nfs_async_write_reschedule_io(struct nfs_pgio_header *hdr)
 }
 
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
+	.init_hdr = nfs_async_write_init,
 	.error_cleanup = nfs_async_write_error,
 	.completion = nfs_write_completion,
 	.reschedule_io = nfs_async_write_reschedule_io,
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 6138cf91346b..abbee2d15dce 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -93,6 +93,7 @@ struct nfs_pageio_descriptor {
 	const struct rpc_call_ops *pg_rpc_callops;
 	const struct nfs_pgio_completion_ops *pg_completion_ops;
 	struct pnfs_layout_segment *pg_lseg;
+	struct nfs_io_completion *pg_io_completion;
 	struct nfs_direct_req	*pg_dreq;
 	unsigned int		pg_bsize;	/* default bsize for mirrors */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ee998ed08cf6..ab6a8381459f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1422,6 +1422,7 @@ enum {
 	NFS_IOHDR_STAT,
 };
 
+struct nfs_io_completion;
 struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
@@ -1435,6 +1436,7 @@ struct nfs_pgio_header {
 	void (*release) (struct nfs_pgio_header *hdr);
 	const struct nfs_pgio_completion_ops *completion_ops;
 	const struct nfs_rw_ops	*rw_ops;
+	struct nfs_io_completion *io_completion;
 	struct nfs_direct_req	*dreq;
 	spinlock_t		lock;
 	/* fields protected by lock */
-- 
2.9.4

