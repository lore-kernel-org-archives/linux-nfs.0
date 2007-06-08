From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/5] nfs: disable leases over NFS
Date: Fri,  8 Jun 2007 18:14:55 -0400
Message-ID: <45540.106696035$1181340916@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
 <11813408953536-git-send-email->
 <11813408952518-git-send-email->
 <11813408951909-git-send-email->
 <11813408954053-git-send-email->
 <11813408951694-git-send-email->
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Peter Staubach <staubach@redhat.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408951694-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

As Peter Staubach says elsewhere
(http://marc.info/?l=linux-kernel&m=118113649526444&w=2):

> The problem is that some file system such as NFSv2 and NFSv3 do
> not have sufficient support to be able to support leases correctly.
> In particular for these two file systems, there is no over the wire
> protocol support.
>
> Currently, these two file systems fail the fcntl(F_SETLEASE) call
> accidentally, due to a reference counting difference.  These file
> systems should fail more consciously, with a proper error to
> indicate that the call is invalid for them.

Define an nfs setlease method that just returns -EINVAL.

If someone can demonstrate a real need, perhaps we could reenable
them in the presence of the "nolock" mount option.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: Peter Staubach <staubach@redhat.com>
---
 fs/nfs/file.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 9eb8eb4..467671b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -51,6 +51,7 @@ static int  nfs_fsync(struct file *, struct dentry *dentry, int datasync);
 static int nfs_check_flags(int flags);
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
+static int nfs_setlease(struct file *file, long arg, struct file_lock **fl);
 
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
@@ -67,6 +68,7 @@ const struct file_operations nfs_file_operations = {
 	.flock		= nfs_flock,
 	.sendfile	= nfs_file_sendfile,
 	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
 };
 
 const struct inode_operations nfs_file_inode_operations = {
@@ -555,3 +557,8 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 		return do_unlk(filp, cmd, fl);
 	return do_setlk(filp, cmd, fl);
 }
+
+static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
+{
+	return -EINVAL;
+}
-- 
1.5.2

