Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35566 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933001AbbIDTYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 15:24:11 -0400
Received: by qgt47 with SMTP id 47so23979201qgt.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 12:24:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Optimise away the close-to-open getattr if there is no cached data
Date: Fri,  4 Sep 2015 15:24:06 -0400
Message-Id: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there is no cached data, then there is no need to track the file
change attribute on close.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 99a68bd9c178..ebaf991e4b02 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -766,6 +766,7 @@ EXPORT_SYMBOL_GPL(nfs_put_lock_context);
  */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 {
+	struct nfs_inode *nfsi;
 	struct inode *inode;
 	struct nfs_server *server;
 
@@ -774,7 +775,12 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 	if (!is_sync)
 		return;
 	inode = d_inode(ctx->dentry);
-	if (!list_empty(&NFS_I(inode)->open_files))
+	nfsi = NFS_I(inode);
+	if (inode->i_mapping->nrpages == 0)
+		return;
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+		return;
+	if (!list_empty(&nfsi->open_files))
 		return;
 	server = NFS_SERVER(inode);
 	if (server->flags & NFS_MOUNT_NOCTO)
-- 
2.4.3

