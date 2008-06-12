From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/15] NFS: Remove the BKL from the rename, rmdir and
	unlink operations
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.72704.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbYFLTtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:24 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnNuc008569
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:23 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attribute updates are safe, and dentry operations are protected using VFS
level locks. Defer removing the BKL from sillyrename until a separate
patch.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c936102..3317881 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1297,14 +1297,12 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: rmdir(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
-	lock_kernel();
 	error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
 	/* Ensure the VFS deletes this inode */
 	if (error == 0 && dentry->d_inode != NULL)
 		clear_nlink(dentry->d_inode);
 	else if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
-	unlock_kernel();
 
 	return error;
 }
@@ -1429,7 +1427,6 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: unlink(%s/%ld, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name);
 
-	lock_kernel();
 	spin_lock(&dcache_lock);
 	spin_lock(&dentry->d_lock);
 	if (atomic_read(&dentry->d_count) > 1) {
@@ -1437,6 +1434,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		spin_unlock(&dcache_lock);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
+		lock_kernel();
 		error = nfs_sillyrename(dir, dentry);
 		unlock_kernel();
 		return error;
@@ -1452,7 +1450,6 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	} else if (need_rehash)
 		d_rehash(dentry);
-	unlock_kernel();
 	return error;
 }
 
@@ -1587,7 +1584,6 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	 * To prevent any new references to the target during the rename,
 	 * we unhash the dentry and free the inode in advance.
 	 */
-	lock_kernel();
 	if (!d_unhashed(new_dentry)) {
 		d_drop(new_dentry);
 		rehash = new_dentry;
@@ -1621,7 +1617,9 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			goto out;
 
 		/* silly-rename the existing target ... */
+		lock_kernel();
 		err = nfs_sillyrename(new_dir, new_dentry);
+		unlock_kernel();
 		if (!err) {
 			new_dentry = rehash = dentry;
 			new_inode = NULL;
@@ -1665,7 +1663,6 @@ out:
 	/* new dentry created? */
 	if (dentry)
 		dput(dentry);
-	unlock_kernel();
 	return error;
 }
 

