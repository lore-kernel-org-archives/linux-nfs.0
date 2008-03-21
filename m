From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] NFS: Make nfs_open methods consistent
Date: Fri, 21 Mar 2008 19:02:24 -0400
Message-ID: <20080321230224.23627.85247.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:12484 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764947AbYCUXCk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 19:02:40 -0400
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
index 63f8f1c..2346e73 100644
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
index 7776a89..b50f86c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -113,8 +113,13 @@ static int nfs_check_flags(int flags)
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

