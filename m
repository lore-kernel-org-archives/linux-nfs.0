Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38682 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932831AbdGKQoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 01/42] fs: Don't copy beyond the end of the file
Date: Tue, 11 Jul 2017 12:43:35 -0400
Message-ID: <20170711164416.1982-2-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
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
index 19d4d88..cc2618b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1584,6 +1584,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
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

