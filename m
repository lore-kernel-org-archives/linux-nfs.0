Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:37921 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbbASJPb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jan 2015 04:15:31 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so37694091pab.4
        for <linux-nfs@vger.kernel.org>; Mon, 19 Jan 2015 01:15:31 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2] nfs: fix dio deadlock when O_DIRECT flag is flipped
Date: Mon, 19 Jan 2015 17:15:11 +0800
Message-Id: <1421658911-18671-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running xfstest generic/036, we hit VM_BUG_ON() in nfs_direct_IO().
036 toggles O_DIRECT flag while IO is going on. We cannot simply remove
the VM_BUG_ON() there because we'll have a deadlock in the code path.
inode->i_mutex is taken when calling into ->direct_IO.
And nfs_file_direct_write() would grab inode->i_mutex again.

nfs_file_write() and generic_file_write_iter() checks for O_DIRECT twice,
and it creates a race window if user space is playing with O_DIRECT flag.
Fix it by calling generic_perform_write() instead, so that nfs_direct_IO()
is only invoked in swap on nfs case.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/file.c | 41 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 40 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2ab6f00..e98604a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -662,6 +662,45 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
+static ssize_t nfs_file_buffer_write(struct kiocb *iocb, struct iov_iter *from)
+{
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	ssize_t result = 0;
+	size_t count = iov_iter_count(from);
+	loff_t pos = iocb->ki_pos;
+	int ret;
+
+	mutex_lock(&inode->i_mutex);
+	/* We can write back this queue in page reclaim */
+	current->backing_dev_info = mapping->backing_dev_info;
+	ret = generic_write_checks(file, &pos, &count, 0);
+	if (ret)
+		goto out;
+
+	if (!count)
+		goto out;
+
+	iov_iter_truncate(from, count);
+	ret = file_remove_suid(file);
+	if (ret)
+		goto out;
+
+	ret = file_update_time(file);
+	if (ret)
+		goto out;
+
+	result = generic_perform_write(file, from, pos);
+	if (likely(result >= 0))
+		iocb->ki_pos = pos + result;
+
+out:
+	current->backing_dev_info = NULL;
+	mutex_unlock(&inode->i_mutex);
+	return result ? result : ret;
+}
+
 ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
@@ -697,7 +736,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (!count)
 		goto out;
 
-	result = generic_file_write_iter(iocb, from);
+	result = nfs_file_buffer_write(iocb, from);
 	if (result > 0)
 		written = result;
 
-- 
1.9.1

