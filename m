Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33166 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbcFUVf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 17:35:29 -0400
Received: by mail-io0-f195.google.com with SMTP id t74so3377359ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:35:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS O_DIRECT code
Date: Tue, 21 Jun 2016 17:34:52 -0400
Message-Id: <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we can serialise O_DIRECT and write/truncate using the
inode->i_rwsem, we no longer need inode->i_dio_count.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 12 +++---------
 fs/nfs/file.c   |  2 --
 fs/nfs/inode.c  |  1 -
 3 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 2333e9973802..92267316290a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -385,11 +385,6 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 		spin_unlock(&inode->i_lock);
 	}
 
-	if (write)
-		nfs_zap_mapping(inode, inode->i_mapping);
-
-	inode_dio_end(inode);
-
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
@@ -488,7 +483,6 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
-	inode_dio_begin(inode);
 
 	while (iov_iter_count(iter)) {
 		struct page **pagevec;
@@ -540,7 +534,6 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
-		inode_dio_end(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
@@ -770,6 +763,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
 	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	struct inode *inode = dreq->inode;
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -781,6 +775,8 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
+			nfs_zap_mapping(inode, inode->i_mapping);
+
 			nfs_direct_complete(dreq, true);
 	}
 }
@@ -903,7 +899,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
-	inode_dio_begin(inode);
 
 	NFS_I(inode)->write_io += iov_iter_count(iter);
 	while (iov_iter_count(iter)) {
@@ -964,7 +959,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
-		inode_dio_end(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index b1dd7f2c64f4..fb7a1b0b6a20 100644
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
index bd0390da3344..6bc65ffc3c6c 100644
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
2.5.5

