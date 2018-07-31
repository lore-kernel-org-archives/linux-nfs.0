Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39833 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732372AbeGaVgb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 17:36:31 -0400
Received: by mail-io0-f194.google.com with SMTP id o22-v6so14087298ioh.6
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 12:54:37 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/3] NFSv4: Detect nlink changes on cross-directory renames too
Date: Tue, 31 Jul 2018 15:54:11 -0400
Message-Id: <20180731195412.10912-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180731195412.10912-2-trond.myklebust@hammerspace.com>
References: <20180731195412.10912-1-trond.myklebust@hammerspace.com>
 <20180731195412.10912-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the object being renamed from one directory to another is also
a directory, then 'nlink' will change for both directories.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1a8423ff7606..2f07a31e2fb6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1087,13 +1087,14 @@ nfs4_dec_nlink_locked(struct inode *inode)
 
 static void
 update_changeattr_locked(struct inode *dir, struct nfs4_change_info *cinfo,
-		unsigned long timestamp)
+		unsigned long timestamp, unsigned long cache_validity)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
 
 	nfsi->cache_validity |= NFS_INO_INVALID_CTIME
 		| NFS_INO_INVALID_MTIME
-		| NFS_INO_INVALID_DATA;
+		| NFS_INO_INVALID_DATA
+		| cache_validity;
 	if (cinfo->atomic && cinfo->before == inode_peek_iversion_raw(dir)) {
 		nfsi->cache_validity &= ~NFS_INO_REVAL_PAGECACHE;
 		nfsi->attrtimeo_timestamp = jiffies;
@@ -1111,10 +1112,10 @@ update_changeattr_locked(struct inode *dir, struct nfs4_change_info *cinfo,
 
 static void
 update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
-		unsigned long timestamp)
+		unsigned long timestamp, unsigned long cache_validity)
 {
 	spin_lock(&dir->i_lock);
-	update_changeattr_locked(dir, cinfo, timestamp);
+	update_changeattr_locked(dir, cinfo, timestamp, cache_validity);
 	spin_unlock(&dir->i_lock);
 }
 
@@ -2503,7 +2504,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data,
 		if (data->file_created ||
 		    inode_peek_iversion_raw(dir) != o_res->cinfo.after)
 			update_changeattr(dir, &o_res->cinfo,
-					o_res->f_attr->time_start);
+					o_res->f_attr->time_start, 0);
 	}
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
@@ -4281,7 +4282,7 @@ _nfs4_proc_remove(struct inode *dir, const struct qstr *name, u32 ftype)
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0) {
 		spin_lock(&dir->i_lock);
-		update_changeattr_locked(dir, &res.cinfo, timestamp);
+		update_changeattr_locked(dir, &res.cinfo, timestamp, 0);
 		/* Removing a directory decrements nlink in the parent */
 		if (ftype == NF4DIR && dir->i_nlink > 2)
 			nfs4_dec_nlink_locked(dir);
@@ -4361,7 +4362,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 				    &data->timeout) == -EAGAIN)
 		return 0;
 	if (task->tk_status == 0)
-		update_changeattr(dir, &res->cinfo, res->dir_attr->time_start);
+		update_changeattr(dir, &res->cinfo,
+				res->dir_attr->time_start, 0);
 	return 1;
 }
 
@@ -4403,9 +4405,18 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		return 0;
 
 	if (task->tk_status == 0) {
-		update_changeattr(old_dir, &res->old_cinfo, res->old_fattr->time_start);
-		if (new_dir != old_dir)
-			update_changeattr(new_dir, &res->new_cinfo, res->new_fattr->time_start);
+		if (new_dir != old_dir) {
+			/* Note: If we moved a directory, nlink will change */
+			update_changeattr(old_dir, &res->old_cinfo,
+					res->old_fattr->time_start,
+					NFS_INO_INVALID_OTHER);
+			update_changeattr(new_dir, &res->new_cinfo,
+					res->new_fattr->time_start,
+					NFS_INO_INVALID_OTHER);
+		} else
+			update_changeattr(old_dir, &res->old_cinfo,
+					res->old_fattr->time_start,
+					0);
 	}
 	return 1;
 }
@@ -4446,7 +4457,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
-		update_changeattr(dir, &res.cinfo, res.fattr->time_start);
+		update_changeattr(dir, &res.cinfo, res.fattr->time_start, 0);
 		status = nfs_post_op_update_inode(inode, res.fattr);
 		if (!status)
 			nfs_setsecurity(inode, res.fattr, res.label);
@@ -4523,7 +4534,7 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 	if (status == 0) {
 		spin_lock(&dir->i_lock);
 		update_changeattr_locked(dir, &data->res.dir_cinfo,
-				data->res.fattr->time_start);
+				data->res.fattr->time_start, 0);
 		/* Creating a directory bumps nlink in the parent */
 		if (data->arg.ftype == NF4DIR)
 			nfs4_inc_nlink_locked(dir);
-- 
2.17.1

