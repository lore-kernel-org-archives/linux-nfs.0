From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] locks: share more common lease code
Date: Fri, 1 Jun 2007 12:30:53 -0400
Message-ID: <20070601163053.GB10492@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org> <11806476252240-git-send-email-bfields@fieldses.org> <1180648297.7084.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1180648297.7084.7.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, May 31, 2007 at 05:51:37PM -0400, Trond Myklebust wrote:
> Why not move the security checks from setlease() into __setlease()? That
> way you can continue to avoid the calls to (re)take the BKL, which are
> redundant as far as fcntl_setlease() is concerned.

Sure.  Then setlease() just becomes a simple BKL-taking wrapper around
__setlease(); is that what you were thinking of?

--b.

>From 4ce02551ab16d2812299ac0ced43652f1af0deb1 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Thu, 31 May 2007 17:03:46 -0400
Subject: [PATCH] locks: share more common lease code

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
1.5.2.rc3

