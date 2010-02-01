From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: Proper accounting for NFS VFS calls
Date: Mon, 01 Feb 2010 14:17:14 -0500
Message-ID: <20100201191714.20189.24779.stgit@localhost.localdomain>
References: <20100201191415.20189.39710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35646 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580Ab0BATRt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:17:49 -0500
In-Reply-To: <20100201191415.20189.39710.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nit: The VFSOPEN and VFSFLUSH counters are function call counters.
Count every call to these routines.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..f028e7d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -123,11 +123,11 @@ nfs_file_open(struct inode *inode, struct file *filp)
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name);
 
+	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 	res = nfs_check_flags(filp->f_flags);
 	if (res)
 		return res;
 
-	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 	res = nfs_open(inode, filp);
 	return res;
 }
@@ -237,9 +237,9 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 
+	nfs_inc_stats(inode, NFSIOS_VFSFLUSH);
 	if ((file->f_mode & FMODE_WRITE) == 0)
 		return 0;
-	nfs_inc_stats(inode, NFSIOS_VFSFLUSH);
 
 	/* Flush writes to the server and return any errors */
 	return nfs_do_fsync(ctx, inode);

