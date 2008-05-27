From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] NFS: Make nfs_open methods consistent
Date: Tue, 27 May 2008 16:29:22 -0400
Message-ID: <20080527202922.6651.18161.stgit@ellison.1015granger.net>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23020 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283AbYE0U36 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 16:29:58 -0400
In-Reply-To: <20080527202347.6651.54668.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Report the same debugging info and count function calls the
same for files and directories in nfs_opendir() and nfs_file_open().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c  |    8 ++++++--
 fs/nfs/file.c |    5 +++++
 2 files changed, 11 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 36e51f7..40b559a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -131,10 +131,14 @@ const struct inode_operations nfs4_dir_inode_operations = {
 static int
 nfs_opendir(struct inode *inode, struct file *filp)
 {
+	struct dentry *dentry = filp->f_path.dentry;
 	int res;
 
-	dfprintk(VFS, "NFS: opendir(%s/%ld)\n",
-			inode->i_sb->s_id, inode->i_ino);
+	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
+
+	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
 	lock_kernel();
 	/* Call generic open code in order to cache credentials */
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 06a1322..c3e7af0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -117,8 +117,13 @@ static int nfs_check_flags(int flags)
 static int
 nfs_file_open(struct inode *inode, struct file *filp)
 {
+	struct dentry *dentry = filp->f_path.dentry;
 	int res;
 
+	dfprintk(VFS, "NFS: open file(%s/%s)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
+
 	res = nfs_check_flags(filp->f_flags);
 	if (res)
 		return res;

