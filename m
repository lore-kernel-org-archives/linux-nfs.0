Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19310 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932689AbbIDR36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:29:58 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 05/16] NFS add same file check and flush source and destination for COPY
Date: Fri, 4 Sep 2015 13:29:27 -0400
Message-ID: <1441387778-16465-6-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4file.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index cc3353a..7c6f651 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -136,6 +136,21 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, int flags)
 {
+	struct inode *in_inode = file_inode(file_in);
+	struct inode *out_inode = file_inode(file_out);
+	int ret;
+
+	if (in_inode == out_inode)
+		return -EINVAL;
+
+	/* flush any pending writes */
+	ret = nfs_sync_inode(in_inode);
+	if (ret)
+		return ret;
+	ret = nfs_sync_inode(out_inode);
+	if (ret)
+		return ret;
+
 	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 }
 
-- 
1.8.3.1

