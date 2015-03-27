Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36433 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbbC0RG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:06:56 -0400
Received: by iedm5 with SMTP id m5so75556455ied.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:06:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs: Ensure that writes respect the O_SYNC flag when doing O_DIRECT
Date: Fri, 27 Mar 2015 13:06:53 -0400
Message-Id: <1427476013-14683-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the caller does not specify the O_SYNC flag, then it is legitimate
to return from O_DIRECT without doing a pNFS layoutcommit operation.
However if the file is opened O_DIRECT|O_SYNC then we'd better get it
right.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c   | 1 +
 fs/nfs/file.c     | 1 +
 fs/nfs/nfs4file.c | 1 +
 3 files changed, 3 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 51f617e45fd1..018a06a062bd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -1034,6 +1034,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 			if (i_size_read(inode) < iocb->ki_pos)
 				i_size_write(inode, iocb->ki_pos);
 			spin_unlock(&inode->i_lock);
+			generic_write_sync(file, pos, result);
 		}
 	}
 	nfs_direct_req_release(dreq);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6959cb76744b..28228f381266 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -281,6 +281,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	trace_nfs_fsync_enter(inode);
 
+	nfs_inode_dio_wait(inode);
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8da5409e6f1a..befe7a2c6284 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -104,6 +104,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	trace_nfs_fsync_enter(inode);
 
+	nfs_inode_dio_wait(inode);
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
-- 
2.1.0

