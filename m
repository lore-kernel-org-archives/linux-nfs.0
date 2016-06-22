Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33145 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcFVUsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 16:48:32 -0400
Received: by mail-io0-f194.google.com with SMTP id t74so8238710ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 13:48:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 12/13] NFS: Remove inode->i_dio_count from the NFS O_DIRECT code
Date: Wed, 22 Jun 2016 16:47:47 -0400
Message-Id: <1466628468-3958-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466628468-3958-11-git-send-email-trond.myklebust@primarydata.com>
References: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-2-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-3-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-4-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-5-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-6-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-7-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-8-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-9-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-10-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we can serialise O_DIRECT and write/truncate using the
inode->i_rwsem, we no longer need inode->i_dio_count.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 22 +++++++---------------
 fs/nfs/file.c   |  2 --
 fs/nfs/inode.c  |  1 -
 3 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d96a4b7aa5c0..742cc34c3456 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -372,15 +372,8 @@ out:
  * Synchronous I/O uses a stack-allocated iocb.  Thus we can't trust
  * the iocb is still valid here if this is a synchronous request.
  */
-static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
+static void nfs_direct_complete(struct nfs_direct_req *dreq)
 {
-	struct inode *inode = dreq->inode;
-
-	if (write)
-		nfs_zap_mapping(inode, inode->i_mapping);
-
-	inode_dio_end(inode);
-
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
@@ -431,7 +424,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	}
 out_put:
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	hdr->release(hdr);
 }
 
@@ -479,7 +472,6 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
-	inode_dio_begin(inode);
 
 	while (iov_iter_count(iter)) {
 		struct page **pagevec;
@@ -531,13 +523,12 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
-		inode_dio_end(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
 
 	if (put_dreq(dreq))
-		nfs_direct_complete(dreq, false);
+		nfs_direct_complete(dreq);
 	return 0;
 }
 
@@ -761,6 +752,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
 	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	struct inode *inode = dreq->inode;
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -772,7 +764,9 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			nfs_direct_complete(dreq, true);
+			nfs_zap_mapping(inode, inode->i_mapping);
+
+			nfs_direct_complete(dreq);
 	}
 }
 
@@ -894,7 +888,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
-	inode_dio_begin(inode);
 
 	NFS_I(inode)->write_io += iov_iter_count(iter);
 	while (iov_iter_count(iter)) {
@@ -955,7 +948,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
-		inode_dio_end(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index b5772e5a5961..8581e348c09b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -276,7 +276,6 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	trace_nfs_fsync_enter(inode);
 
-	inode_dio_wait(inode);
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
@@ -364,7 +363,6 @@ start:
 	/*
 	 * Wait for O_DIRECT to complete
 	 */
-	inode_dio_wait(mapping->host);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4e65a5a8a01b..9521fa6154c8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -141,7 +141,6 @@ void nfs_evict_inode(struct inode *inode)
 
 int nfs_sync_inode(struct inode *inode)
 {
-	inode_dio_wait(inode);
 	return nfs_wb_all(inode);
 }
 EXPORT_SYMBOL_GPL(nfs_sync_inode);
-- 
2.7.4

