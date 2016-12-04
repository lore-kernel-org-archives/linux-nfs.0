Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33201 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcLDXKL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2016 18:10:11 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so19075282ioi.0
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2016 15:10:11 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix incorrect size revalidation when holding a delegation
Date: Sun,  4 Dec 2016 18:10:08 -0500
Message-Id: <20161204231008.31396-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should only care about checking the attributes if the page cache
is marked as dubious (using NFS_INO_REVAL_PAGECACHE) and the
NFS_INO_REVAL_FORCED flag is set.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 9ea85ae23c32..64c11f399b3d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -102,8 +102,11 @@ static int nfs_revalidate_file_size(struct inode *inode, struct file *filp)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
+	const unsigned long force_reval = NFS_INO_REVAL_PAGECACHE|NFS_INO_REVAL_FORCED;
+	unsigned long cache_validity = nfsi->cache_validity;
 
-	if (nfs_have_delegated_attributes(inode))
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) &&
+	    (cache_validity & force_reval) != force_reval)
 		goto out_noreval;
 
 	if (filp->f_flags & O_DIRECT)
-- 
2.9.3

