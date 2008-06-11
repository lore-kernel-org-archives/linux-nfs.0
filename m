From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] NFS: Make nfs_open methods consistent
Date: Wed, 11 Jun 2008 17:55:42 -0400
Message-ID: <20080611215542.7068.83115.stgit@ellison.1015granger.net>
References: <20080611215018.7068.71737.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35305 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbYFKWCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 18:02:09 -0400
In-Reply-To: <20080611215018.7068.71737.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Report the same debugging info and count function calls the
same for files and directories in nfs_opendir() and nfs_file_open().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c  |    7 +++++--
 fs/nfs/file.c |    4 ++++
 2 files changed, 9 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9f31cc6..9a4fb51 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -133,8 +133,11 @@ nfs_opendir(struct inode *inode, struct file *filp)
 {
 	int res;
 
-	dfprintk(VFS, "NFS: opendir(%s/%ld)\n",
-			inode->i_sb->s_id, inode->i_ino);
+	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name);
+
+	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
 	lock_kernel();
 	/* Call generic open code in order to cache credentials */
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index bb09c48..ce18877 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -119,6 +119,10 @@ nfs_file_open(struct inode *inode, struct file *filp)
 {
 	int res;
 
+	dfprintk(VFS, "NFS: open file(%s/%s)\n",
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name);
+
 	res = nfs_check_flags(filp->f_flags);
 	if (res)
 		return res;

