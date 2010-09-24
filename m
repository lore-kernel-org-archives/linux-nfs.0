Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771Ab0IXTOp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Sep 2010 15:14:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, pbunyan@redhat.com
Subject: [PATCH] NFS: initialize nfs_open_context.list member at allocation time
Date: Fri, 24 Sep 2010 15:14:43 -0400
Message-Id: <1285355683-7244-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

alloc_nfs_open_context creates a nfs_open_context struct, but doesn't
initialize the list_head embedded in it. In newer kernels, this is
harmless since the ctx is always put on a list soon after creation. In
an older RHEL4 kernel however, it's possible (though unlikely) for a ctx
to be passed to put_nfs_open_context without ever being put on a list,
which can cause an oops.

Since it's hard to predict how this code will change in the future,
let's go ahead and initialize the list.

Reported-by: Paul Bunyan <pbunyan@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d2d6c7..3185fc2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -638,6 +638,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct
 		ctx->dir_cookie = 0;
 		nfs_init_lock_context(&ctx->lock_context);
 		ctx->lock_context.open_context = ctx;
+		INIT_LIST_HEAD(&ctx->list);
 	}
 	return ctx;
 }
-- 
1.7.1

