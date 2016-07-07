Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:58982 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbcGGFy7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 01:54:59 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH 1/2] nfs: Fix spurios EPERM when mkdir of existing dentry
Date: Thu,  7 Jul 2016 01:53:46 -0400
Message-Id: <1467870827-2959489-2-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
References: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's great when we can shave an extra RPC, but not at the expense
of correctness.
We should not return EPERM (from vfs_create/mknod/mkdir) if the
name already exists, even if we have no write access in parent.

Since the check in nfs_permission is clearly not enough to stave
off this, just throw in the extra READ access to actually
go through.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 fs/nfs/dir.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d8015a0..8c7835b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1383,8 +1383,10 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	/*
 	 * If we're doing an exclusive create, optimize away the lookup
 	 * but don't hash the dentry.
+	 * This optimization only works if we can write in the parent.
 	 */
-	if (nfs_is_exclusive_create(dir, flags))
+	if (nfs_is_exclusive_create(dir, flags) &&
+	    (inode_permission(dir, MAY_WRITE | MAY_READ | MAY_EXEC) == 0))
 		return NULL;
 
 	res = ERR_PTR(-ENOMEM);
-- 
2.7.4

