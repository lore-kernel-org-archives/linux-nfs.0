Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33286 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbbGWStG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:49:06 -0400
Received: by obdeg2 with SMTP id eg2so1501976obd.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2015 11:49:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFS: Set NFS_INO_REVAL_PAGECACHE if the change attribute is uninitialised
Date: Thu, 23 Jul 2015 14:48:59 -0400
Message-Id: <1437677341-2943-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1437677341-2943-2-git-send-email-trond.myklebust@primarydata.com>
References: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can't allow caching of data until the change attribute has been
initialised correctly.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d654661defb3..426e4f8207ef 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -443,7 +443,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
-			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_PAGECACHE);
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			inode->i_size = nfs_size_to_loff_t(fattr->size);
 		else
-- 
2.4.3

