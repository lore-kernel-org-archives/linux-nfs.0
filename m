From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 31/37] NFS: Remove the redundant file_open entry from
	struct nfs_rpc_ops
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.93001.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbYFLTfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:35:14 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJZ9oG003500
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:35:09 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All instances are set to nfs_open(), so we should just remove the redundant
indirection. Ditto for the file_release op

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c           |    4 ++--
 fs/nfs/nfs3proc.c       |    2 --
 fs/nfs/nfs4proc.c       |    2 --
 fs/nfs/proc.c           |    2 --
 include/linux/nfs_xdr.h |    2 --
 5 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 78b26f8..509dcb5 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -129,7 +129,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 	lock_kernel();
-	res = NFS_PROTO(inode)->file_open(inode, filp);
+	res = nfs_open(inode, filp);
 	unlock_kernel();
 	return res;
 }
@@ -147,7 +147,7 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	if (filp->f_mode & FMODE_WRITE)
 		nfs_wb_all(dentry->d_inode);
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
-	return NFS_PROTO(inode)->file_release(inode, filp);
+	return nfs_release(inode, filp);
 }
 
 /**
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index b14b378..5c5fc8a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -803,8 +803,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
 	.commit_done	= nfs3_commit_done,
-	.file_open	= nfs_open,
-	.file_release	= nfs_release,
 	.lock		= nfs3_proc_lock,
 	.clear_acl_cache = nfs3_forget_cached_acls,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15084a0..75cdec4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3724,8 +3724,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
 	.commit_done	= nfs4_commit_done,
-	.file_open      = nfs_open,
-	.file_release   = nfs_release,
 	.lock		= nfs4_proc_lock,
 	.clear_acl_cache = nfs4_zap_acl_attr,
 };
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index c760558..4dbb84d 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -655,8 +655,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.write_setup	= nfs_proc_write_setup,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
-	.file_open	= nfs_open,
-	.file_release	= nfs_release,
 	.lock		= nfs_proc_lock,
 	.lock_check_bounds = nfs_lock_check_bounds,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8d780de..8c77c11 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -829,8 +829,6 @@ struct nfs_rpc_ops {
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_write_data *, struct rpc_message *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_write_data *);
-	int	(*file_open)   (struct inode *, struct file *);
-	int	(*file_release) (struct inode *, struct file *);
 	int	(*lock)(struct file *, int, struct file_lock *);
 	int	(*lock_check_bounds)(const struct file_lock *);
 	void	(*clear_acl_cache)(struct inode *);

