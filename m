From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/3] nfsd: track last inode only in use_wgather case
Date: Wed, 17 Jun 2009 12:59:29 -0400
Message-ID: <1245257971-22757-1-git-send-email-bfields@fieldses.org>
References: <20090617165442.GE21311@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Steve Dickson <steved@redhat.com>,
	Tom Talpey <tmtalpey@gmail.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60124 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbZFQQ7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 12:59:31 -0400
In-Reply-To: <20090617165442.GE21311@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Updating last_ino and last_dev probably isn't useful in the !use_wgather
case.

Also remove some pointless ifdef'd-out code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   25 ++++++++++---------------
 1 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f30cc4e..ebf56c6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1026,7 +1026,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (host_err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
 		kill_suid(dentry);
 
-	if (host_err >= 0 && stable) {
+	if (host_err >= 0 && stable && use_wgather) {
 		static ino_t	last_ino;
 		static dev_t	last_dev;
 
@@ -1042,21 +1042,16 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		 * nice and simple solution (IMHO), and it seems to
 		 * work:-)
 		 */
-		if (use_wgather) {
-			if (atomic_read(&inode->i_writecount) > 1
-			    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
-				dprintk("nfsd: write defer %d\n", task_pid_nr(current));
-				msleep(10);
-				dprintk("nfsd: write resume %d\n", task_pid_nr(current));
-			}
+		if (atomic_read(&inode->i_writecount) > 1
+		    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
+			dprintk("nfsd: write defer %d\n", task_pid_nr(current));
+			msleep(10);
+			dprintk("nfsd: write resume %d\n", task_pid_nr(current));
+		}
 
-			if (inode->i_state & I_DIRTY) {
-				dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-				host_err=nfsd_sync(file);
-			}
-#if 0
-			wake_up(&inode->i_wait);
-#endif
+		if (inode->i_state & I_DIRTY) {
+			dprintk("nfsd: write sync %d\n", task_pid_nr(current));
+			host_err=nfsd_sync(file);
 		}
 		last_ino = inode->i_ino;
 		last_dev = inode->i_sb->s_dev;
-- 
1.6.0.4

