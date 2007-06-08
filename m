From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/5] locks: provide a file lease method enabling cluster-coherent leases
Date: Fri,  8 Jun 2007 18:14:52 -0400
Message-ID: <14040.0549433709$1181340921@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
 <11813408953536-git-send-email->
 <11813408952518-git-send-email->
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408952518-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@fieldses.org>

Currently leases are only kept locally, so there's no way for a distributed
filesystem to enforce them against multiple clients.  We're particularly
interested in the case of nfsd exporting a cluster filesystem, in which
case nfsd needs cluster-coherent leases in order to implement delegations
correctly.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/locks.c         |    7 +++++--
 include/linux/fs.h |    1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 6ad3c7b..8fa4420 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1442,7 +1442,10 @@ int setlease(struct file *filp, long arg, struct file_lock **lease)
 	int error;
 
 	lock_kernel();
-	error = __setlease(filp, arg, lease);
+	if (filp->f_op && filp->f_op->setlease)
+		error = filp->f_op->setlease(filp, arg, lease);
+        else
+		error = __setlease(filp, arg, lease);
 	unlock_kernel();
 
 	return error;
@@ -1474,7 +1477,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 
 	lock_kernel();
 
-	error = __setlease(filp, arg, &flp);
+	error = setlease(filp, arg, &flp);
 	if (error || arg == F_UNLCK)
 		goto out_unlock;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b3ae77c..6b07c61 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1113,6 +1113,7 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
+	int (*setlease)(struct file *, long, struct file_lock **);
 };
 
 struct inode_operations {
-- 
1.5.2

