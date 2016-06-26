Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32797 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbcFZA0l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 20:26:41 -0400
Received: by mail-it0-f65.google.com with SMTP id y93so6645786ita.0
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 17:26:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.2: Fix writeback races in nfs4_copy_file_range
Date: Sat, 25 Jun 2016 20:25:52 -0400
Message-Id: <1466900754-29584-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466900754-29584-2-git-send-email-trond.myklebust@primarydata.com>
References: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to ensure that any writes to the destination file are serialised
with the copy, meaning that the writeback has to occur under the inode lock.

Also relax the writeback requirement on the source, and rely on the
stateid checking to tell us if the source rebooted.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c |  9 +++++++++
 fs/nfs/nfs4file.c  | 14 +-------------
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 0f9f536e647b..778ad2778191 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -156,11 +156,20 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 	if (status)
 		return status;
 
+	status = filemap_write_and_wait_range(file_inode(src)->i_mapping,
+			pos_src, pos_src + (loff_t)count - 1);
+	if (status)
+		return status;
+
 	status = nfs4_set_rw_stateid(&args.dst_stateid, dst_lock->open_context,
 				     dst_lock, FMODE_WRITE);
 	if (status)
 		return status;
 
+	status = nfs_sync_inode(dst_inode);
+	if (status)
+		return status;
+
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args.seq_args, &res.seq_res, 0);
 	if (status == -ENOTSUPP)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 014b0e41ace5..7cdc0ab9e6f5 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,21 +133,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
-	struct inode *in_inode = file_inode(file_in);
-	struct inode *out_inode = file_inode(file_out);
-	int ret;
-
-	if (in_inode == out_inode)
+	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 
-	/* flush any pending writes */
-	ret = nfs_sync_inode(in_inode);
-	if (ret)
-		return ret;
-	ret = nfs_sync_inode(out_inode);
-	if (ret)
-		return ret;
-
 	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 }
 
-- 
2.7.4

