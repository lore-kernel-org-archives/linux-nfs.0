Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59242 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbaJMOIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2014 10:08:23 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4: open context can be NULL in nfs_put_open_context
Date: Mon, 13 Oct 2014 10:08:15 -0400
Message-ID: <1413209295-13509-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

If a pgio error is caught before the nfs_pgio_header args->context is set
with get_nfs_open_context, the context can be NULL.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 141c9f4..a2b148e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -798,6 +798,9 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	struct inode *inode = ctx->dentry->d_inode;
 	struct super_block *sb = ctx->dentry->d_sb;
 
+	if (ctx == NULL)
+		return;
+
 	if (!list_empty(&ctx->list)) {
 		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
 			return;
-- 
1.8.3.1

