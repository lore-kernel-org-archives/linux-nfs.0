Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758360Ab2EIQvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 12:51:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] NFS: Prevent a deadlock in the new read and write code
Date: Wed,  9 May 2012 12:51:24 -0400
Message-Id: <1336582284-8558-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to avoid an ABBA lock ordering issue, the write code must
unlock and release the nfs_page _before_ it calls end_page_writeback.
Since the last release of the nfs_page will trigger a call to put
the open_context, we need to ensure that something else holds a
reference to the open context until we're done with the
end_page_writeback so that we don't end up calling iput while we're
still holding a PG_writeback lock.
We can fix this by changing nfs_writedata_release to put the open
context after we have processed all the page data.

The read code does not suffer from the same problem, since it doesn't
hold a lock on the nfs_page, so it just calls nfs_release_request after
unlocking the page itself. However, for symmetry reasons, we make the
same change to nfs_readdata_release.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/read.c  |    3 ++-
 fs/nfs/write.c |   13 ++++++++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index f23cf25..dec47e5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -87,8 +87,8 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	struct nfs_pgio_header *hdr = rdata->header;
 	struct nfs_read_header *read_header = container_of(hdr, struct nfs_read_header, header);
+	struct nfs_open_context *ctx = rdata->args.context;
 
-	put_nfs_open_context(rdata->args.context);
 	if (rdata->pages.pagevec != rdata->pages.page_array)
 		kfree(rdata->pages.pagevec);
 	if (rdata != &read_header->rpc_data)
@@ -97,6 +97,7 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 		rdata->header = NULL;
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
+	put_nfs_open_context(ctx);
 }
 
 static
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6f263da..69825f7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -119,8 +119,8 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 {
 	struct nfs_pgio_header *hdr = wdata->header;
 	struct nfs_write_header *write_header = container_of(hdr, struct nfs_write_header, header);
+	struct nfs_open_context *ctx = wdata->args.context;
 
-	put_nfs_open_context(wdata->args.context);
 	if (wdata->pages.pagevec != wdata->pages.page_array)
 		kfree(wdata->pages.pagevec);
 	if (wdata != &write_header->rpc_data)
@@ -129,6 +129,10 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 		wdata->header = NULL;
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
+	/* Note: put the open context after processing all the
+	 * page data in order to avoid a deadlock in nfs_write_completion.
+	 */
+	put_nfs_open_context(ctx);
 }
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
@@ -597,6 +601,13 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 
 #endif
 
+/*
+ * nfs_write_completion - process the results of the write RPC calls
+ *
+ * Note: this function assumes that the caller is holding a reference
+ * to the nfs_open_context in order to avoid a deadlock when calling
+ * nfs_end_page_writeback after nfs_unlock_request.
+ */
 static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_commit_info cinfo;
-- 
1.7.7.6

