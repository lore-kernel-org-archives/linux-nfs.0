Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13487 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751957AbdI1R2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:22 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 01/12] fs: Don't copy beyond the end of the file
Date: Thu, 28 Sep 2017 13:28:08 -0400
Message-ID: <20170928172819.50703-2-kolga@netapp.com>
In-Reply-To: <20170928172819.50703-1-kolga@netapp.com>
References: <20170928172819.50703-1-kolga@netapp.com>
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
index a2b9a47..47aec8e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1563,6 +1563,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
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

