From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/15] NFS: Remove attribute update related BKL references
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.67821.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbYFLTtW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:22 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnLJ1008546
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:21 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    4 ----
 fs/nfs/super.c |    4 ----
 2 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3adabd1..df23f98 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -370,7 +370,6 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	if ((attr->ia_valid & ~ATTR_FILE) == 0)
 		return 0;
 
-	lock_kernel();
 	/* Write all dirty data */
 	if (S_ISREG(inode->i_mode)) {
 		filemap_write_and_wait(inode->i_mapping);
@@ -384,7 +383,6 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
 	if (error == 0)
 		nfs_refresh_inode(inode, &fattr);
-	unlock_kernel();
 	return error;
 }
 
@@ -700,7 +698,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	lock_kernel();
 	if (is_bad_inode(inode))
  		goto out_nowait;
 	if (NFS_STALE(inode))
@@ -749,7 +746,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	nfs_wake_up_inode(inode);
 
  out_nowait:
-	unlock_kernel();
 	return status;
 }
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 226ae6a..39c028e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -371,8 +371,6 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	};
 	int error;
 
-	lock_kernel();
-
 	error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
 	if (error < 0)
 		goto out_err;
@@ -404,12 +402,10 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 
 	buf->f_namelen = server->namelen;
 
-	unlock_kernel();
 	return 0;
 
  out_err:
 	dprintk("%s: statfs error = %d\n", __func__, -error);
-	unlock_kernel();
 	return error;
 }
 

