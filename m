From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 1/2] nfs: don't ignore return value from nfs_pageio_add_request
Date: Wed, 19 Mar 2008 17:36:23 -0400
Message-ID: <1205962584-11369-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:13890 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937815AbYCSVgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 17:36:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ignoring the return value from nfs_pageio_add_request can cause deadlocks.

In read path:
  call nfs_pageio_add_request from readpage_async_filler
  assume at this point that there are requests already in desc, that
    can't be merged with the current request.
  so nfs_pageio_doio is fired up to clear out desc.
  assume something goes wrong in setting up the io, so desc->pg_error is set.
  This causes nfs_pageio_add_request to return 0, *WITHOUT* adding the original
    request.
  BUT, since return code is ignored, readpage_async_filler assumes it has
    been added, and does nothing further, leaving page locked.
  do_generic_mapping_read will eventually call lock_page, resulting in deadlock

In write path:
  page is marked dirty by generic_perform_write
  nfs_writepages is called
  call nfs_pageio_add_request from nfs_page_async_flush
  assume at this point that there are requests already in desc, that
    can't be merged with the current request.
  so nfs_pageio_doio is fired up to clear out desc.
  assume something goes wrong in setting up the io, so desc->pg_error is set.
  This causes nfs_page_async_flush to return 0, *WITHOUT* adding the original
    request, yet marking the request as locked (PG_BUSY) and in writeback,
    clearing dirty marks.
  The next time a write is done to the page, deadlock will result as
    nfs_write_end calls nfs_update_request

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
---
 fs/nfs/read.c  |    5 ++++-
 fs/nfs/write.c |    8 +++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3d7d963..5a70be5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -533,7 +533,10 @@ readpage_async_filler(void *data, struct page *page)
 
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
-	nfs_pageio_add_request(desc->pgio, new);
+	if (!nfs_pageio_add_request(desc->pgio, new)) {
+		error = desc->pgio->pg_error;
+		goto out_unlock;
+	}
 	return 0;
 out_error:
 	error = PTR_ERR(new);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 80c61fd..db6c17b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -39,6 +39,7 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context*,
 					    unsigned int, unsigned int);
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
 				  struct inode *inode, int ioflags);
+static void nfs_redirty_request(struct nfs_page *req);
 static const struct rpc_call_ops nfs_write_partial_ops;
 static const struct rpc_call_ops nfs_write_full_ops;
 static const struct rpc_call_ops nfs_commit_ops;
@@ -288,7 +289,12 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		BUG();
 	}
 	spin_unlock(&inode->i_lock);
-	nfs_pageio_add_request(pgio, req);
+	if (!nfs_pageio_add_request(pgio, req)) {
+		nfs_redirty_request(req);
+		nfs_end_page_writeback(req->wb_page);
+		nfs_clear_page_tag_locked(req);
+		return pgio->pg_error;
+	}
 	return 0;
 }
 
-- 
1.5.3.3

