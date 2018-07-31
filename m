Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36809 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727999AbeGaTGI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 15:06:08 -0400
Received: by mail-it0-f65.google.com with SMTP id p81-v6so5468872itp.1
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 10:24:49 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFSv4: bump/drop the nlink count on the parent dir when we mkdir/rmdir
Date: Tue, 31 Jul 2018 13:24:24 -0400
Message-Id: <20180731172426.6491-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180731172426.6491-1-trond.myklebust@hammerspace.com>
References: <20180731172426.6491-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we always bump or drop the nlink count on the parent directory
when we do a mkdir or a rmdir(). This needs to be done by hand as we don't
have pre/post op attributes.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 50 +++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 42 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a8190ec31a2..0d56d3662005 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1071,12 +1071,26 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
 }
 
-static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
+static void
+nfs4_inc_nlink_locked(struct inode *inode)
+{
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_OTHER;
+	inc_nlink(inode);
+}
+
+static void
+nfs4_dec_nlink_locked(struct inode *inode)
+{
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_OTHER;
+	dec_nlink(inode);
+}
+
+static void
+update_changeattr_locked(struct inode *dir, struct nfs4_change_info *cinfo,
 		unsigned long timestamp)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
 
-	spin_lock(&dir->i_lock);
 	nfsi->cache_validity |= NFS_INO_INVALID_CTIME
 		| NFS_INO_INVALID_MTIME
 		| NFS_INO_INVALID_DATA;
@@ -1093,6 +1107,14 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
 	nfsi->read_cache_jiffies = timestamp;
 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	nfs_fscache_invalidate(dir);
+}
+
+static void
+update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
+		unsigned long timestamp)
+{
+	spin_lock(&dir->i_lock);
+	update_changeattr_locked(dir, cinfo, timestamp);
 	spin_unlock(&dir->i_lock);
 }
 
@@ -4237,7 +4259,8 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	return status;
 }
 
-static int _nfs4_proc_remove(struct inode *dir, const struct qstr *name)
+static int
+_nfs4_proc_remove(struct inode *dir, const struct qstr *name, u32 ftype)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs_removeargs args = {
@@ -4256,8 +4279,14 @@ static int _nfs4_proc_remove(struct inode *dir, const struct qstr *name)
 	int status;
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
-	if (status == 0)
-		update_changeattr(dir, &res.cinfo, timestamp);
+	if (status == 0) {
+		spin_lock(&dir->i_lock);
+		update_changeattr_locked(dir, &res.cinfo, timestamp);
+		/* Removing a directory decrements nlink in the parent */
+		if (ftype == NF4DIR && dir->i_nlink > 2)
+			nfs4_dec_nlink_locked(dir);
+		spin_unlock(&dir->i_lock);
+	}
 	return status;
 }
 
@@ -4274,7 +4303,7 @@ static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 			nfs4_inode_make_writeable(inode);
 	}
 	do {
-		err = _nfs4_proc_remove(dir, &dentry->d_name);
+		err = _nfs4_proc_remove(dir, &dentry->d_name, NF4REG);
 		trace_nfs4_remove(dir, &dentry->d_name, err);
 		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
@@ -4288,7 +4317,7 @@ static int nfs4_proc_rmdir(struct inode *dir, const struct qstr *name)
 	int err;
 
 	do {
-		err = _nfs4_proc_remove(dir, name);
+		err = _nfs4_proc_remove(dir, name, NF4DIR);
 		trace_nfs4_remove(dir, name, err);
 		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
@@ -4492,8 +4521,13 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 	int status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &data->msg,
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
-		update_changeattr(dir, &data->res.dir_cinfo,
+		spin_lock(&dir->i_lock);
+		update_changeattr_locked(dir, &data->res.dir_cinfo,
 				data->res.fattr->time_start);
+		/* Creating a directory bumps nlink in the parent */
+		if (data->arg.ftype == NF4DIR)
+			nfs4_inc_nlink_locked(dir);
+		spin_unlock(&dir->i_lock);
 		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, data->res.label);
 	}
 	return status;
-- 
2.17.1

