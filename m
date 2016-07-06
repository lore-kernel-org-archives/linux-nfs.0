Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34109 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932421AbcGFWbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:31:02 -0400
Received: by mail-it0-f67.google.com with SMTP id f6so891703ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:31:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 26/28] NFSv4.2: Fix writeback races in nfs4_copy_file_range
Date: Wed,  6 Jul 2016 18:30:03 -0400
Message-Id: <1467844205-76852-27-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-26-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-26-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to ensure that any writes to the destination file are serialised
with the copy, meaning that the writeback has to occur under the inode lock.

Also relax the writeback requirement on the source, and rely on the
stateid checking to tell us if the source rebooted. Add the helper
nfs_filemap_write_and_wait_range() to call pnfs_sync_inode() as
is appropriate for pNFS servers that may need a layoutcommit.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h  |  3 +++
 fs/nfs/nfs42proc.c |  9 +++++++++
 fs/nfs/nfs4file.c  | 14 +-------------
 fs/nfs/write.c     | 18 ++++++++++++++++++
 4 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 01dccf18da0a..3b01c9146e15 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -512,6 +512,9 @@ int nfs_key_timeout_notify(struct file *filp, struct inode *inode);
 bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
 void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio);
 
+int nfs_filemap_write_and_wait_range(struct address_space *mapping,
+		loff_t lstart, loff_t lend);
+
 #ifdef CONFIG_NFS_V4_1
 static inline
 void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 0f9f536e647b..b7d457cea03f 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -156,11 +156,20 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 	if (status)
 		return status;
 
+	status = nfs_filemap_write_and_wait_range(file_inode(src)->i_mapping,
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
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3087fb6f1983..538a473b324b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1913,6 +1913,24 @@ out_mark_dirty:
 EXPORT_SYMBOL_GPL(nfs_write_inode);
 
 /*
+ * Wrapper for filemap_write_and_wait_range()
+ *
+ * Needed for pNFS in order to ensure data becomes visible to the
+ * client.
+ */
+int nfs_filemap_write_and_wait_range(struct address_space *mapping,
+		loff_t lstart, loff_t lend)
+{
+	int ret;
+
+	ret = filemap_write_and_wait_range(mapping, lstart, lend);
+	if (ret == 0)
+		ret = pnfs_sync_inode(mapping->host, true);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nfs_filemap_write_and_wait_range);
+
+/*
  * flush the inode to disk.
  */
 int nfs_wb_all(struct inode *inode)
-- 
2.7.4

