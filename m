Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33021 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbGMFvn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:51:43 -0400
Received: by padck2 with SMTP id ck2so36790298pad.0
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:51:43 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 7/7] nfs42: respect clone_blksize
Date: Mon, 13 Jul 2015 13:50:55 +0800
Message-Id: <1436766655-10696-8-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

draft-ietf-nfsv4-minorversion2-38.txt says:
   Both cl_src_offset and
   cl_dst_offset must be aligned to the clone block size Section 12.2.1.
   The number of bytes to be cloned must be a multiple of the clone
   block size, except in the case in which cl_src_offset plus the number
   of bytes to be cloned is equal to the source file size.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index dfa6620..e450a5f 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -173,8 +173,10 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 		  u64 src_off, u64 dst_off, u64 count)
 {
 	struct inode *dst_inode = file_inode(dst_file);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
 	struct fd src_file;
 	struct inode *src_inode;
+	unsigned int bs = server->clone_blksize;
 	int ret;
 
 	/* dst file must be opened for writing */
@@ -212,6 +214,15 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 	    src_inode->i_sb != dst_inode->i_sb)
 		goto out_fput;
 
+	/* check alignment w.r.t. clone_blksize */
+	ret = -EINVAL;
+	if (bs) {
+		if (!IS_ALIGNED(src_off, bs) || !IS_ALIGNED(dst_off, bs))
+			goto out_fput;
+		if (!IS_ALIGNED(count, bs) && i_size_read(src_inode) != (src_off + count))
+			goto out_fput;
+	}
+
 	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
 	if (dst_inode < src_inode) {
 		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
-- 
1.8.3.1

