Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35917 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbcFWUBb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 16:01:31 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so13091525ith.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2016 13:01:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 11/17] NFS Cleanup: move call to generic_write_checks() into fs/nfs/direct.c
Date: Thu, 23 Jun 2016 16:00:43 -0400
Message-Id: <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-2-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-3-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-4-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-5-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-6-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-7-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-8-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-9-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 12 ++++++++----
 fs/nfs/file.c   |  6 +-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 826d4dace0e5..0169eca8eb42 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -988,6 +988,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 {
 	ssize_t result = -EINVAL;
+	size_t count;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
@@ -998,8 +999,11 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	dfprintk(FILE, "NFS: direct write(%pD2, %zd@%Ld)\n",
 		file, iov_iter_count(iter), (long long) iocb->ki_pos);
 
-	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES,
-		      iov_iter_count(iter));
+	result = generic_write_checks(iocb, iter);
+	if (result <= 0)
+		return result;
+	count = result;
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	pos = iocb->ki_pos;
 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
@@ -1017,7 +1021,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 			goto out_unlock;
 	}
 
-	task_io_account_write(iov_iter_count(iter));
+	task_io_account_write(count);
 
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
@@ -1025,7 +1029,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 		goto out_unlock;
 
 	dreq->inode = inode;
-	dreq->bytes_left = dreq->max_count = iov_iter_count(iter);
+	dreq->bytes_left = dreq->max_count = count;
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index df4dd8e7e62e..c26847c84d00 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -629,12 +629,8 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result)
 		return result;
 
-	if (iocb->ki_flags & IOCB_DIRECT) {
-		result = generic_write_checks(iocb, from);
-		if (result <= 0)
-			return result;
+	if (iocb->ki_flags & IOCB_DIRECT)
 		return nfs_file_direct_write(iocb, from);
-	}
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
 		file, count, (long long) iocb->ki_pos);
-- 
2.7.4

