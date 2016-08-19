Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12561 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754350AbcHSRZo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:44 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [PATCH Version-2 01/12] fs: Don't copy beyond the end of the file
Date: Fri, 19 Aug 2016 13:25:01 -0400
Message-ID: <1471627512-4102-2-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 66215a7..1cbab4e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1497,6 +1497,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
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

