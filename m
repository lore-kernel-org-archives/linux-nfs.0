From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/3] nfsd: Pull write-gathering code out of nfsd_vfs_write
Date: Wed, 17 Jun 2009 12:59:30 -0400
Message-ID: <1245257971-22757-2-git-send-email-bfields@fieldses.org>
References: <20090617165442.GE21311@fieldses.org>
 <1245257971-22757-1-git-send-email-bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Steve Dickson <steved@redhat.com>,
	Tom Talpey <tmtalpey@gmail.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60128 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbZFQQ7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 12:59:33 -0400
In-Reply-To: <1245257971-22757-1-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This is a relatively self-contained piece of code that handles a special
case--move it to its own function.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   69 ++++++++++++++++++++++++++++++++------------------------
 1 files changed, 39 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ebf56c6..6ad76a4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -963,6 +963,43 @@ static void kill_suid(struct dentry *dentry)
 	mutex_unlock(&dentry->d_inode->i_mutex);
 }
 
+/*
+ * Gathered writes: If another process is currently writing to the file,
+ * there's a high chance this is another nfsd (triggered by a bulk write
+ * from a client's biod). Rather than syncing the file with each write
+ * request, we sleep for 10 msec.
+ *
+ * I don't know if this roughly approximates C. Juszak's idea of
+ * gathered writes, but it's a nice and simple solution (IMHO), and it
+ * seems to work:-)
+ *
+ * Note: we do this only in the NFSv2 case, since v3 and higher have a
+ * better tool (separate unstable writes and commits) for solving this
+ * problem.
+ */
+static int wait_for_concurrent_writes(struct file *file)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	static ino_t last_ino;
+	static dev_t last_dev;
+	int err = 0;
+
+	if (atomic_read(&inode->i_writecount) > 1
+	    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
+		dprintk("nfsd: write defer %d\n", task_pid_nr(current));
+		msleep(10);
+		dprintk("nfsd: write resume %d\n", task_pid_nr(current));
+	}
+
+	if (inode->i_state & I_DIRTY) {
+		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
+		err = nfsd_sync(file);
+	}
+	last_ino = inode->i_ino;
+	last_dev = inode->i_sb->s_dev;
+	return err;
+}
+
 static __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
@@ -1026,36 +1063,8 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (host_err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
 		kill_suid(dentry);
 
-	if (host_err >= 0 && stable && use_wgather) {
-		static ino_t	last_ino;
-		static dev_t	last_dev;
-
-		/*
-		 * Gathered writes: If another process is currently
-		 * writing to the file, there's a high chance
-		 * this is another nfsd (triggered by a bulk write
-		 * from a client's biod). Rather than syncing the
-		 * file with each write request, we sleep for 10 msec.
-		 *
-		 * I don't know if this roughly approximates
-		 * C. Juszak's idea of gathered writes, but it's a
-		 * nice and simple solution (IMHO), and it seems to
-		 * work:-)
-		 */
-		if (atomic_read(&inode->i_writecount) > 1
-		    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
-			dprintk("nfsd: write defer %d\n", task_pid_nr(current));
-			msleep(10);
-			dprintk("nfsd: write resume %d\n", task_pid_nr(current));
-		}
-
-		if (inode->i_state & I_DIRTY) {
-			dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-			host_err=nfsd_sync(file);
-		}
-		last_ino = inode->i_ino;
-		last_dev = inode->i_sb->s_dev;
-	}
+	if (host_err >= 0 && stable && use_wgather)
+		host_err = wait_for_concurrent_writes(file);
 
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
 	if (host_err >= 0)
-- 
1.6.0.4

