From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/15] NFS: Remove BKL from NFS lookup code
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.44975.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62801 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbYFLTtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:25 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnN15006182
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:24 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All dentry-related operations are already BKL-safe, since they are
protected by the VFS locking. No extra locks should be needed in the NFS
code.

In the case of nfs_revalidate_inode(), we're only doing an attribute
update (protected by the inode->i_lock).
In the case of nfs_lookup(), we're instantiating a new dentry, so there
should be no contention possible until after we call d_materialise_unique.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cdcc0c3..c936102 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -777,7 +777,6 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	struct nfs_fattr fattr;
 
 	parent = dget_parent(dentry);
-	lock_kernel();
 	dir = parent->d_inode;
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode = dentry->d_inode;
@@ -815,7 +814,6 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
-	unlock_kernel();
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is valid\n",
 			__func__, dentry->d_parent->d_name.name,
@@ -834,7 +832,6 @@ out_zap_parent:
 		shrink_dcache_parent(dentry);
 	}
 	d_drop(dentry);
-	unlock_kernel();
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is invalid\n",
 			__func__, dentry->d_parent->d_name.name,
@@ -921,8 +918,6 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	res = ERR_PTR(-ENOMEM);
 	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
 
-	lock_kernel();
-
 	/*
 	 * If we're doing an exclusive create, optimize away the lookup
 	 * but don't hash the dentry.
@@ -930,7 +925,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	if (nfs_is_exclusive_create(dir, nd)) {
 		d_instantiate(dentry, NULL);
 		res = NULL;
-		goto out_unlock;
+		goto out;
 	}
 
 	parent = dentry->d_parent;
@@ -958,8 +953,6 @@ no_entry:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
-out_unlock:
-	unlock_kernel();
 out:
 	return res;
 }

