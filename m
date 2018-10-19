Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:36269 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726667AbeJSXgw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:36:52 -0400
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, fweimer@redhat.com, smfrench@gmail.com
Subject: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
Date: Fri, 19 Oct 2018 11:30:17 -0400
Message-Id: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 39b4a21..c60790f 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (unlikely(ret))
 		return ret;
 
+	if (pos_in >= i_size_read(inode_in))
+		return -EINVAL;
+
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND))
-- 
1.8.3.1
