Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:39998 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbeFDWcB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:32:01 -0400
Received: by mail-it0-f68.google.com with SMTP id j186-v6so984130ita.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:32:01 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:59 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] NFS: Improve caching while holding a delegation
Date: Mon,  4 Jun 2018 18:31:27 -0400
Message-Id: <20180604223129.121477-9-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-8-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
 <20180604223129.121477-6-trond.myklebust@hammerspace.com>
 <20180604223129.121477-7-trond.myklebust@hammerspace.com>
 <20180604223129.121477-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure that the client completely ignores change attribute and size
changes on the server when it holds a delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f35c5eb09cc9..90d9fbfd82db 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1789,6 +1789,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	bool have_writers = nfs_file_has_buffered_writers(nfsi);
 	bool cache_revalidated = true;
 	bool attr_changed = false;
+	bool have_delegation;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
@@ -1823,6 +1824,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			!IS_AUTOMOUNT(inode))
 		server->fsid = fattr->fsid;
 
+	/* Save the delegation state before clearing cache_validity */
+	have_delegation = nfs_have_delegated_attributes(inode);
+
 	/*
 	 * Update the read time so we don't revalidate too often.
 	 */
@@ -1845,10 +1849,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/* More cache consistency checks */
 	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
 		if (!inode_eq_iversion_raw(inode, fattr->change_attr)) {
-			dprintk("NFS: change_attr change on server for file %s/%ld\n",
-					inode->i_sb->s_id, inode->i_ino);
 			/* Could it be a race with writeback? */
-			if (!have_writers) {
+			if (!(have_writers || have_delegation)) {
 				invalid |= NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL;
@@ -1859,6 +1861,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					| NFS_INO_INVALID_OTHER;
 				if (S_ISDIR(inode->i_mode))
 					nfs_force_lookup_revalidate(inode);
+				dprintk("NFS: change_attr change on server for file %s/%ld\n",
+						inode->i_sb->s_id,
+						inode->i_ino);
 			}
 			inode_set_iversion_raw(inode, fattr->change_attr);
 			attr_changed = true;
@@ -1893,7 +1898,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
 		new_isize = nfs_size_to_loff_t(fattr->size);
 		cur_isize = i_size_read(inode);
-		if (new_isize != cur_isize) {
+		if (new_isize != cur_isize && !have_delegation) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
 			if (!nfs_have_writebacks(inode) || new_isize > cur_isize) {
@@ -2022,9 +2027,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &= ~NFS_INO_INVALID_DATA;
-	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) ||
-			(save_cache_validity & NFS_INO_REVAL_FORCED))
-		nfs_set_cache_invalid(inode, invalid);
+	nfs_set_cache_invalid(inode, invalid);
 
 	return 0;
  out_err:
-- 
2.17.1

