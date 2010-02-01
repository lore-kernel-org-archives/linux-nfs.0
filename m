From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] NFS: Make close(2) asynchronous when closing NFS O_DIRECT
	files
Date: Mon, 01 Feb 2010 14:17:50 -0500
Message-ID: <20100201191749.20189.81922.stgit@localhost.localdomain>
References: <20100201191415.20189.39710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43823 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab0BATSz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:18:55 -0500
In-Reply-To: <20100201191415.20189.39710.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv2 and v3:

O_DIRECT writes are always synchronous, and aren't cached, so nothing
should be flushed when closing an NFS O_DIRECT file descriptor.  Thus
there are no write errors to report on close(2).

In addition, there's no cached data to verify on the next open(2),
so we don't need clean GETATTR results at close time to compare with.

Thus, there's no need for the nfs_revalidate_inode() call when closing
an NFS O_DIRECT file.  This reduces the number of synchronous
on-the-wire requests for a simple open-write-close of an NFS O_DIRECT
file by roughly 20%.

For NFSv4:

Call nfs4_do_close() with wait set to zero when closing an NFS
O_DIRECT file.  The CLOSE will go on the wire, but the application
won't wait for it to complete.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..873717f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -620,11 +620,6 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 	__put_nfs_open_context(ctx, 0);
 }
 
-static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
-{
-	__put_nfs_open_context(ctx, 1);
-}
-
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
@@ -671,7 +666,7 @@ static void nfs_file_clear_open_context(struct file *filp)
 		spin_lock(&inode->i_lock);
 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
 		spin_unlock(&inode->i_lock);
-		put_nfs_open_context_sync(ctx);
+		__put_nfs_open_context(ctx, filp->f_flags & O_DIRECT ? 0 : 1);
 	}
 }
 

