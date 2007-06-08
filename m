From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/5] locks: share more common lease code
Date: Fri,  8 Jun 2007 18:14:51 -0400
Message-ID: <42772.155282046$1181340914@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
 <11813408953536-git-send-email->
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408953536-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

Share more code between setlease (used by nfsd) and fcntl.

Also some minor cleanup.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c |   30 ++++++++++--------------------
 1 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 431a8b8..6ad3c7b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1346,6 +1346,14 @@ static int __setlease(struct file *filp, long arg, struct file_lock **flp)
 	struct inode *inode = dentry->d_inode;
 	int error, rdlease_count = 0, wrlease_count = 0;
 
+	if ((current->fsuid != inode->i_uid) && !capable(CAP_LEASE))
+		return -EACCES;
+	if (!S_ISREG(inode->i_mode))
+		return -EINVAL;
+	error = security_file_lock(filp, arg);
+	if (error)
+		return error;
+
 	time_out_leases(inode);
 
 	error = -EINVAL;
@@ -1431,18 +1439,8 @@ out:
 
 int setlease(struct file *filp, long arg, struct file_lock **lease)
 {
-	struct dentry *dentry = filp->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
 	int error;
 
-	if ((current->fsuid != inode->i_uid) && !capable(CAP_LEASE))
-		return -EACCES;
-	if (!S_ISREG(inode->i_mode))
-		return -EINVAL;
-	error = security_file_lock(filp, arg);
-	if (error)
-		return error;
-
 	lock_kernel();
 	error = __setlease(filp, arg, lease);
 	unlock_kernel();
@@ -1469,14 +1467,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 	struct inode *inode = dentry->d_inode;
 	int error;
 
-	if ((current->fsuid != inode->i_uid) && !capable(CAP_LEASE))
-		return -EACCES;
-	if (!S_ISREG(inode->i_mode))
-		return -EINVAL;
-	error = security_file_lock(filp, arg);
-	if (error)
-		return error;
-
 	locks_init_lock(&fl);
 	error = lease_init(filp, arg, &fl);
 	if (error)
@@ -1490,9 +1480,9 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 
 	error = fasync_helper(fd, filp, 1, &flp->fl_fasync);
 	if (error < 0) {
-		/* remove lease just inserted by __setlease */
+		/* remove lease just inserted by setlease */
 		flp->fl_type = F_UNLCK | F_INPROGRESS;
-		flp->fl_break_time = jiffies- 10;
+		flp->fl_break_time = jiffies - 10;
 		time_out_leases(inode);
 		goto out_unlock;
 	}
-- 
1.5.2

