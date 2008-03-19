From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 2/2] nfs: don't ignore return value from nfs_pageio_add_request
Date: Wed, 19 Mar 2008 10:13:20 -0400
Message-ID: <1205936000-9336-2-git-send-email-iisaman@citi.umich.edu>
References: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:9158 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765409AbYCSUOw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:14:52 -0400
In-Reply-To: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
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
 fs/nfs/write.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3d7d963..77f8ac9 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -533,7 +533,10 @@ readpage_async_filler(void *data, struct page *page)
 
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
-	nfs_pageio_add_request(desc->pgio, new);
+	if (!nfs_pageio_add_request(desc->pgio, new)) {
+		error = desc->pagio->pg_error;
+		goto out_unlock;
+	}
 	return 0;
 out_error:
 	error = PTR_ERR(new);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 01bf68e..c8bb767 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -288,7 +288,10 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		BUG();
 	}
 	spin_unlock(&inode->i_lock);
-	nfs_pageio_add_request(pgio, req);
+	if (!nfs_pageio_add_request(pgio, req)) {
+		nfs_retry_request(req);
+		return pgio->pg_error;
+	}
 	return 0;
 }
 
-- 
1.5.3.3

