From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/15] NFS: Remove the BKL from the inode creation
	operations
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.57198.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbYFLTtW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:22 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnMmU006173
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:22 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_instantiate() does not require the BKL, neither do the attribute
updates or the RPC code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4ba889b..7e072ea 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1232,14 +1232,11 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 	if ((nd->flags & LOOKUP_CREATE) != 0)
 		open_flags = nd->intent.open.flags;
 
-	lock_kernel();
 	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, nd);
 	if (error != 0)
 		goto out_err;
-	unlock_kernel();
 	return 0;
 out_err:
-	unlock_kernel();
 	d_drop(dentry);
 	return error;
 }
@@ -1262,14 +1259,11 @@ nfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t rdev)
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	lock_kernel();
 	status = NFS_PROTO(dir)->mknod(dir, dentry, &attr, rdev);
 	if (status != 0)
 		goto out_err;
-	unlock_kernel();
 	return 0;
 out_err:
-	unlock_kernel();
 	d_drop(dentry);
 	return status;
 }
@@ -1288,15 +1282,12 @@ static int nfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	attr.ia_valid = ATTR_MODE;
 	attr.ia_mode = mode | S_IFDIR;
 
-	lock_kernel();
 	error = NFS_PROTO(dir)->mkdir(dir, dentry, &attr);
 	if (error != 0)
 		goto out_err;
-	unlock_kernel();
 	return 0;
 out_err:
 	d_drop(dentry);
-	unlock_kernel();
 	return error;
 }
 

