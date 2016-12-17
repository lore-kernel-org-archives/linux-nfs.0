Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34053 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755789AbcLQS1T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:19 -0500
Received: by mail-io0-f196.google.com with SMTP id y124so15270783iof.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:19 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] NFS: Don't revalidate the file on close if we hold a delegation
Date: Sat, 17 Dec 2016 13:27:06 -0500
Message-Id: <20161217182711.10643-5-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-4-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're holding a delegation, we can skip sending the close-to-open
GETATTR until we're returning that delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7de345fd8e1e..2fc237cd338e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -795,6 +795,8 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 	if (!is_sync)
 		return;
 	inode = d_inode(ctx->dentry);
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
+		return;
 	nfsi = NFS_I(inode);
 	if (inode->i_mapping->nrpages == 0)
 		return;
-- 
2.9.3

