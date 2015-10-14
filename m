Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 04/10] NFS: Pass nfs_open_context instead of file to the lock procs
Date: Wed, 14 Oct 2015 14:23:31 -0400
Message-Id: <75f62db40948943b8d2d59dc975832f526af2bd6.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only use the file struct pointer to obtain the nfs_open_context (or the
inode for v2/v3), so just pass that instead.  This allows us to use the lock
procedure without a reference to a struct file which may not be available
while releasing locks after a file close.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c           |    9 ++++++---
 fs/nfs/nfs3proc.c       |    4 ++--
 fs/nfs/nfs4proc.c       |    4 +---
 fs/nfs/proc.c           |    4 ++--
 include/linux/nfs_xdr.h |    2 +-
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 57fefd2..319847c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -711,6 +711,7 @@ static int
 do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
+	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 	int status = 0;
 	unsigned int saved_type = fl->fl_type;
 
@@ -728,7 +729,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (is_local)
 		goto out_noconflict;
 
-	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+	status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
 out:
 	return status;
 out_noconflict:
@@ -756,6 +757,7 @@ static int
 do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
+	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 	struct nfs_lock_context *l_ctx;
 	int status;
 
@@ -782,7 +784,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * "-olocal_lock="
 	 */
 	if (!is_local)
-		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
 	else
 		status = do_vfs_lock(filp, fl);
 	return status;
@@ -797,6 +799,7 @@ static int
 do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
+	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 	int status;
 
 	/*
@@ -812,7 +815,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * "-olocal_lock="
 	 */
 	if (!is_local)
-		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
+		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
 	else
 		status = do_vfs_lock(filp, fl);
 	if (status < 0)
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cb28cce..a10e147 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -866,9 +866,9 @@ static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 }
 
 static int
-nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
+nfs3_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
 {
-	struct inode *inode = file_inode(filp);
+	struct inode *inode = d_inode(ctx->dentry);
 
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 28b771c..18a1ee7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6109,15 +6109,13 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 }
 
 static int
-nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
+nfs4_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *request)
 {
-	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
 	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
 	int status;
 
 	/* verify open state */
-	ctx = nfs_file_open_context(filp);
 	state = ctx->state;
 
 	if (IS_GETLK(cmd)) {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b417bbc..185deb9 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -634,9 +634,9 @@ nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
 }
 
 static int
-nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
+nfs_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
 {
-	struct inode *inode = file_inode(filp);
+	struct inode *inode = d_inode(ctx->dentry);
 
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52faf7e..627ddc4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1536,7 +1536,7 @@ struct nfs_rpc_ops {
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
-	int	(*lock)(struct file *, int, struct file_lock *);
+	int	(*lock)(struct nfs_open_context *, int, struct file_lock *);
 	int	(*lock_check_bounds)(const struct file_lock *);
 	void	(*clear_acl_cache)(struct inode *);
 	void	(*close_context)(struct nfs_open_context *ctx, int);
-- 
1.7.1

