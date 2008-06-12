From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/37] NFS: Make nfs_open methods consistent
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192200.24528.59630.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32435 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754230AbYFLTez (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:55 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: Report the same debugging info and count function calls the
same for files and directories in nfs_opendir() and nfs_file_open().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
index cef3636..202408d 100644
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

