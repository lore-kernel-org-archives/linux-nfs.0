Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35124 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933899AbbIDVBx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 17:01:53 -0400
Received: by qgt47 with SMTP id 47so25970446qgt.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 14:01:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFS: Optimise away the close-to-open getattr if there is no cached data
Date: Fri,  4 Sep 2015 17:01:49 -0400
Message-Id: <1441400510-19688-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there is no cached data, then there is no need to track the file
change attribute on close.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 99a68bd9c178..6307d8de103d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -761,11 +761,13 @@ EXPORT_SYMBOL_GPL(nfs_put_lock_context);
  * @ctx: pointer to context
  * @is_sync: is this a synchronous close
  *
- * always ensure that the attributes are up to date if we're mounted
- * with close-to-open semantics
+ * Ensure that the attributes are up to date if we're mounted
+ * with close-to-open semantics and we have cached data that will
+ * need to be revalidated on open.
  */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 {
+	struct nfs_inode *nfsi;
 	struct inode *inode;
 	struct nfs_server *server;
 
@@ -774,7 +776,12 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
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

