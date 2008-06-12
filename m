From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/15] NFS: Remove BKL from the sillydelete operations
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.63660.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbYFLTtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:24 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnNrn006179
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:23 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3317881..fd8e799 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -884,10 +884,8 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
 
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
-		lock_kernel();
 		drop_nlink(inode);
 		nfs_complete_unlink(dentry, inode);
-		unlock_kernel();
 	}
 	iput(inode);
 }
@@ -1434,9 +1432,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		spin_unlock(&dcache_lock);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
-		lock_kernel();
 		error = nfs_sillyrename(dir, dentry);
-		unlock_kernel();
 		return error;
 	}
 	if (!d_unhashed(dentry)) {
@@ -1617,9 +1613,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			goto out;
 
 		/* silly-rename the existing target ... */
-		lock_kernel();
 		err = nfs_sillyrename(new_dir, new_dentry);
-		unlock_kernel();
 		if (!err) {
 			new_dentry = rehash = dentry;
 			new_inode = NULL;

