Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:44373 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755353AbdIGNaY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Sep 2017 09:30:24 -0400
From: <tarangg@amazon.com>
To: <trond.myklebust@primarydata.com>
CC: <jsstraus@amazon.com>, <linux-nfs@vger.kernel.org>,
        Tarang Gupta <tarangg@amazon.com>
Subject: [PATCH 1/1] NFS: Sync the correct byte range during synchronous writes
Date: Thu, 7 Sep 2017 09:29:23 -0400
Message-ID: <20170907132923.49969-1-tarangg@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 18290650b1c8 ("NFS: Move buffered I/O locking into
nfs_file_write()") nfs_file_write() has not flushed the correct byte
range during synchronous writes.  generic_write_sync() expects that
iocb->ki_pos points to the right edge of the range rather than the
left edge.

To replicate the problem, open a file with O_DSYNC, have the client
write at increasing offsets, and then print the successful offsets.
Block port 2049 partway through that sequence, and observe that the
client application indicates successful writes in advance of what the
server received.

Fixes: 18290650b1c8 ("NFS: Move buffered I/O locking into nfs_file_write()")
Signed-off-by: Jacob Strauss <jsstraus@amazon.com>
Signed-off-by: Tarang Gupta <tarangg@amazon.com>
Tested-by: Tarang Gupta <tarangg@amazon.com>
---
 fs/nfs/file.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..a85d1cf9b4a8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -631,11 +631,11 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result <= 0)
 		goto out;
 
-	result = generic_write_sync(iocb, result);
-	if (result < 0)
-		goto out;
 	written = result;
 	iocb->ki_pos += written;
+	result = generic_write_sync(iocb, written);
+	if (result < 0)
+		goto out;
 
 	/* Return error values */
 	if (nfs_need_check_write(file, inode)) {
-- 
2.11.0 (Apple Git-81)

