Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38798 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdHCNpr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:47 -0400
Received: by mail-io0-f195.google.com with SMTP id o9so1296583iod.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/28] NFS: Teach nfs_try_to_update_request() to deal with request page_groups
Date: Thu,  3 Aug 2017 09:45:05 -0400
Message-Id: <20170803134523.4922-11-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-10-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the code, and avoid some flushes to disk.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 60 ++++++++++++++++++++--------------------------------------
 1 file changed, 20 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ee981353d4aa..0b4d1ef168e0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1107,39 +1107,19 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 
 	end = offset + bytes;
 
-	for (;;) {
-		if (!(PagePrivate(page) || PageSwapCache(page)))
-			return NULL;
-		spin_lock(&inode->i_lock);
-		req = nfs_page_find_head_request_locked(NFS_I(inode), page);
-		if (req == NULL)
-			goto out_unlock;
-
-		/* should be handled by nfs_flush_incompatible */
-		WARN_ON_ONCE(req->wb_head != req);
-		WARN_ON_ONCE(req->wb_this_page != req);
-
-		rqend = req->wb_offset + req->wb_bytes;
-		/*
-		 * Tell the caller to flush out the request if
-		 * the offsets are non-contiguous.
-		 * Note: nfs_flush_incompatible() will already
-		 * have flushed out requests having wrong owners.
-		 */
-		if (offset > rqend
-		    || end < req->wb_offset)
-			goto out_flushme;
-
-		if (nfs_lock_request(req))
-			break;
+	req = nfs_lock_and_join_requests(page);
+	if (IS_ERR_OR_NULL(req))
+		return req;
 
-		/* The request is locked, so wait and then retry */
-		spin_unlock(&inode->i_lock);
-		error = nfs_wait_on_request(req);
-		nfs_release_request(req);
-		if (error != 0)
-			goto out_err;
-	}
+	rqend = req->wb_offset + req->wb_bytes;
+	/*
+	 * Tell the caller to flush out the request if
+	 * the offsets are non-contiguous.
+	 * Note: nfs_flush_incompatible() will already
+	 * have flushed out requests having wrong owners.
+	 */
+	if (offset > rqend || end < req->wb_offset)
+		goto out_flushme;
 
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
@@ -1150,17 +1130,17 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		req->wb_bytes = end - req->wb_offset;
 	else
 		req->wb_bytes = rqend - req->wb_offset;
-out_unlock:
-	if (req)
-		nfs_clear_request_commit(req);
-	spin_unlock(&inode->i_lock);
 	return req;
 out_flushme:
-	spin_unlock(&inode->i_lock);
-	nfs_release_request(req);
+	/*
+	 * Note: we mark the request dirty here because
+	 * nfs_lock_and_join_requests() cannot preserve
+	 * commit flags, so we have to replay the write.
+	 */
+	nfs_mark_request_dirty(req);
+	nfs_unlock_and_release_request(req);
 	error = nfs_wb_page(inode, page);
-out_err:
-	return ERR_PTR(error);
+	return (error < 0) ? ERR_PTR(error) : NULL;
 }
 
 /*
-- 
2.13.3

