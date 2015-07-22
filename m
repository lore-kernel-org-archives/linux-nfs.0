Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932746AbbGVIKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 04:10:47 -0400
From: "Jerome Marchand" <jmarchan@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
Date: Wed, 22 Jul 2015 10:10:43 +0200
Message-Id: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
{IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in
nfs_file_direct_write(). This code was introduced by commit a9ab5e840669
("nfs: page cache invalidation for dio").
This naive test patch avoid to take the mutex on a swapfile and makes
lockdep happy again. However I don't know much about NFS code and I
assume it's probably not the proper solution. Any thought?

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 fs/nfs/direct.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 38678d9..42324d4 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -974,7 +974,9 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	pos = iocb->ki_pos;
 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_CACHE_SHIFT;
 
-	mutex_lock(&inode->i_mutex);
+	/* Don't take the mutex while in reclaim_FS */
+	if (!IS_SWAPFILE(inode))
+		mutex_lock(&inode->i_mutex);
 
 	result = nfs_sync_mapping(mapping);
 	if (result)
@@ -1014,7 +1016,8 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 					      pos >> PAGE_CACHE_SHIFT, end);
 	}
 
-	mutex_unlock(&inode->i_mutex);
+	if (!IS_SWAPFILE(inode))
+		mutex_unlock(&inode->i_mutex);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -1035,7 +1038,8 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 out_release:
 	nfs_direct_req_release(dreq);
 out_unlock:
-	mutex_unlock(&inode->i_mutex);
+	if (!IS_SWAPFILE(inode))
+		mutex_unlock(&inode->i_mutex);
 	return result;
 }
 
-- 
1.9.3

