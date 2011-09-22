Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f42.google.com ([209.85.212.42]:46510 "EHLO
	mail-vw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab1IVMhn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 08:37:43 -0400
Received: by vwl1 with SMTP id 1so4529456vwl.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 05:37:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: when attempting to open a directory, fall back on normal lookup
Date: Thu, 22 Sep 2011 08:37:37 -0400
Message-Id: <1316695057-11610-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

commit d953126 changed how nfs_atomic_lookup handles an -EISDIR return
from an OPEN call. Prior to that patch, that caused the client to fall
back to doing a normal lookup. When that patch went in, the code began
returning that error to userspace. The d_revalidate codepath however
never had the corresponding change, so it was still possible to end up
with a NULL ctx->state pointer after that.

That patch caused a regression. When we attempt to open a directory that
does not have a cached dentry, that open now errors out with EISDIR. If
you attempt the same open with a cached dentry, it will succeed.

Fix this by reverting the change in nfs_atomic_lookup and allowing
attempts to open directories to fall back to a normal lookup. Also, have
the f_ops->open routine for NFS check to see if we're attempting to open
a regular file on NFSv4. If so, then something is very wrong since that
should have been handled by the lookup. Have it return an error
(ENOTDIR) to userspace in that case.

Cc: stable@kernel.org
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c   |    2 +-
 fs/nfs/inode.c |    8 ++++++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b238d95..ac28990 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1468,12 +1468,12 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 				res = NULL;
 				goto out;
 			/* This turned out not to be a regular file */
+			case -EISDIR:
 			case -ENOTDIR:
 				goto no_open;
 			case -ELOOP:
 				if (!(nd->intent.open.flags & O_NOFOLLOW))
 					goto no_open;
-			/* case -EISDIR: */
 			/* case -EINVAL: */
 			default:
 				res = ERR_CAST(inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..44948a6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -740,6 +740,14 @@ int nfs_open(struct inode *inode, struct file *filp)
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred;
 
+	/*
+	 * NFSv4 opens should be handled during the lookup. If we get to this
+	 * point on a NFSv4 open and this is a regular file, then something is
+	 * very wrong.
+	 */
+	if (S_ISREG(inode->i_mode) && NFS_PROTO(inode)->version == 4)
+		return -ENOTDIR;
+
 	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
-- 
1.7.6.2

