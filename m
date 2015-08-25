Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34718 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbHYPfg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:36 -0400
Received: by pabzx8 with SMTP id zx8so36956829pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:36 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 09/11] nfs42: respect clone_blksize
Date: Tue, 25 Aug 2015 23:33:47 +0800
Message-Id: <1440516829-116041-10-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
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
 fs/nfs/nfs4file.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index c335cb0..ee8c014 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -174,12 +174,20 @@ nfs42_file_clone_range(struct file *src_file, struct file *dst_file,
 {
 	struct inode *dst_inode = file_inode(dst_file);
 	struct inode *src_inode = file_inode(src_file);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
+	unsigned int bs = server->clone_blksize;
 	int ret;
 
 	/* src and dst must be different files */
 	if (src_inode == dst_inode)
 		return -EINVAL;
 
+	/* check alignment w.r.t. clone_blksize */
+	if (bs)
+		if (!IS_ALIGNED(src_off, bs) || !IS_ALIGNED(dst_off, bs) ||
+		    (!IS_ALIGNED(count, bs) && i_size_read(src_inode) != (src_off + count)))
+			return -EINVAL;
+
 	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
 	if (dst_inode < src_inode) {
 		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
-- 
1.8.3.1

