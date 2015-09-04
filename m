Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:34169 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932992AbbIDTYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 15:24:12 -0400
Received: by qgez77 with SMTP id z77so24132370qge.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 12:24:11 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Revert "NFS: Make close(2) asynchronous when closing NFS O_DIRECT files"
Date: Fri,  4 Sep 2015 15:24:07 -0400
Message-Id: <1441394647-16412-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
References: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit f895c53f8ace3c3e49ebf9def90e63fc6d46d2bf.

This commit causes a NFSv4 regression in that close()+unlink() can end
up failing. The reason is that we no longer have a guarantee that the
CLOSE has completed on the server, meaning that the subsequent call to
REMOVE may fail with NFS4ERR_FILE_OPEN if the server implements Windows
unlink() semantics.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ebaf991e4b02..54eb47799a41 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -852,6 +852,11 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 }
 EXPORT_SYMBOL_GPL(put_nfs_open_context);
 
+static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
+{
+	__put_nfs_open_context(ctx, 1);
+}
+
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
@@ -907,7 +912,7 @@ void nfs_file_clear_open_context(struct file *filp)
 		spin_lock(&inode->i_lock);
 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
 		spin_unlock(&inode->i_lock);
-		__put_nfs_open_context(ctx, filp->f_flags & O_DIRECT ? 0 : 1);
+		put_nfs_open_context_sync(ctx);
 	}
 }
 
-- 
2.4.3

