Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33930 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbbATApo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jan 2015 19:45:44 -0500
Received: by mail-pd0-f174.google.com with SMTP id ft15so10270898pdb.5
        for <linux-nfs@vger.kernel.org>; Mon, 19 Jan 2015 16:45:44 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v3] nfs: fix dio deadlock when O_DIRECT flag is flipped
Date: Tue, 20 Jan 2015 07:44:29 +0800
Message-Id: <1421711069-21378-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only support swap file calling nfs_direct_IO. However, application
might be able to get to nfs_direct_IO if it toggles O_DIRECT flag
during IO and it can deadlock because we grab inode->i_mutex in
nfs_file_direct_write(). So return 0 for such case. Then the generic
layer will fall back to buffer IO.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index fafeb07..1184118 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -253,6 +253,12 @@ static int nfs_direct_cmp_commit_data_verf(struct nfs_direct_req *dreq,
  */
 ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter, loff_t pos)
 {
+	struct inode *inode = iocb->ki_filp->f_mapping->host;
+
+	/* we only support swap file calling nfs_direct_IO */
+	if (!IS_SWAPFILE(inode))
+		return 0;
+
 #ifndef CONFIG_NFS_SWAP
 	dprintk("NFS: nfs_direct_IO (%pD) off/no(%Ld/%lu) EINVAL\n",
 			iocb->ki_filp, (long long) pos, iter->nr_segs);
-- 
1.9.1

