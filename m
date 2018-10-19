Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f195.google.com ([209.85.222.195]:41720 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727050AbeJSXgH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:36:07 -0400
Received: by mail-qk1-f195.google.com with SMTP id g13-v6so1623526qke.8
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:32 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
Date: Fri, 19 Oct 2018 11:29:22 -0400
Message-Id: <20181019152932.32462-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
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
