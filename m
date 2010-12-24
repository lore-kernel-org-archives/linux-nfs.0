Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:22491 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab0LXWc3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Dec 2010 17:32:29 -0500
Date: Fri, 24 Dec 2010 23:22:37 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: Don't leak in nfs_proc_symlink()
Message-ID: <alpine.LNX.2.00.1012242318400.28973@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

In fs/nfs/proc.c::nfs_proc_symlink() we will leak memory if either 
nfs_alloc_fhandle() or nfs_alloc_fattr() returns NULL but the other one 
doesn't.
This patch ensures memory allocated by one when the other fails is always 
released (this is safe since nfs_free_fattr() and nfs_free_fhandle() both 
call kfree which deals gracefully with NULL pointers).


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 proc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 58e7f84..9e81d9b 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -458,7 +458,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	fattr = nfs_alloc_fattr();
 	status = -ENOMEM;
 	if (fh == NULL || fattr == NULL)
-		goto out;
+		goto out_free;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
@@ -471,6 +471,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	if (status == 0)
 		status = nfs_instantiate(dentry, fh, fattr);
 
+out_free:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
 out:



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

