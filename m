From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] nfs: don't ignore return value from
	nfs_pageio_add_request
Date: Wed, 19 Mar 2008 17:39:11 -0400
Message-ID: <1205962751.18643.9.camel@heimdal.trondhjem.org>
References: <1205940280-10479-1-git-send-email-iisaman@citi.umich.edu>
	 <1205940280-10479-2-git-send-email-iisaman@citi.umich.edu>
	 <1205940280-10479-3-git-send-email-iisaman@citi.umich.edu>
	 <1205959447.14710.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58767 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932575AbYCSVjO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 17:39:14 -0400
In-Reply-To: <1205959447.14710.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-19 at 16:44 -0400, Trond Myklebust wrote:
> Please could you reverse the order of these two patches. I'd like to
> send this one in for 2.6.25, but I can't do that as long as it depends
> on the previous patch.

I ended up doing this myself, since I'd like to prepare this for merging
as soon as possible. Please could you ack the following updated patch.

Cheers
  Trond

---------------------------------
From: Fred Isaman <iisaman@citi.umich.edu>
Date: Wed, 19 Mar 2008 11:24:39 -0400
nfs: don't ignore return value from nfs_pageio_add_request

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/read.c  |    5 ++++-
 fs/nfs/write.c |    8 +++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index be9e827..ab2f7d2 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -531,7 +531,10 @@ readpage_async_filler(void *data, struct page *page)
 
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
index 3051302..7a2ba26 100644
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
@@ -279,7 +280,12 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		BUG();
 	}
 	spin_unlock(&inode->i_lock);
-	nfs_pageio_add_request(pgio, req);
+	if (!nfs_pageio_add_request(pgio, req)) {
+		nfs_redirty_request(req);
+		nfs_end_page_writeback(page);
+		nfs_clear_page_tag_locked(req);
+		return pgio->pg_error;
+	}
 	return 0;
 }
 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
