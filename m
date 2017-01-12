Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32875 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdALXCu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 18:02:50 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so3971084iom.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 15:02:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] NFSv4: update_changeattr should update the attribute timestamp
Date: Thu, 12 Jan 2017 18:02:40 -0500
Message-Id: <20170112230240.7730-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170112230240.7730-4-trond.myklebust@primarydata.com>
References: <20170112230240.7730-1-trond.myklebust@primarydata.com>
 <20170112230240.7730-2-trond.myklebust@primarydata.com>
 <20170112230240.7730-3-trond.myklebust@primarydata.com>
 <20170112230240.7730-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, the attribute cache remains marked as being expired.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a35204affa4..ecc151697fd4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1082,7 +1082,8 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
 }
 
-static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
+static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
+		unsigned long timestamp)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
 
@@ -1098,6 +1099,7 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 				NFS_INO_INVALID_ACL;
 	}
 	dir->i_version = cinfo->after;
+	nfsi->read_cache_jiffies = timestamp;
 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	nfs_fscache_invalidate(dir);
 	spin_unlock(&dir->i_lock);
@@ -2395,7 +2397,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 		else if (o_res->cinfo.before != o_res->cinfo.after)
 			data->file_created = 1;
 		if (data->file_created || dir->i_version != o_res->cinfo.after)
-			update_changeattr(dir, &o_res->cinfo);
+			update_changeattr(dir, &o_res->cinfo,
+					o_res->f_attr->time_start);
 	}
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
@@ -4073,11 +4076,12 @@ static int _nfs4_proc_remove(struct inode *dir, const struct qstr *name)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	unsigned long timestamp = jiffies;
 	int status;
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0)
-		update_changeattr(dir, &res.cinfo);
+		update_changeattr(dir, &res.cinfo, timestamp);
 	return status;
 }
 
@@ -4126,7 +4130,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 				    &data->timeout) == -EAGAIN)
 		return 0;
 	if (task->tk_status == 0)
-		update_changeattr(dir, &res->cinfo);
+		update_changeattr(dir, &res->cinfo, res->dir_attr->time_start);
 	return 1;
 }
 
@@ -4161,9 +4165,9 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		return 0;
 
 	if (task->tk_status == 0) {
-		update_changeattr(old_dir, &res->old_cinfo);
+		update_changeattr(old_dir, &res->old_cinfo, res->old_fattr->time_start);
 		if (new_dir != old_dir)
-			update_changeattr(new_dir, &res->new_cinfo);
+			update_changeattr(new_dir, &res->new_cinfo, res->new_fattr->time_start);
 	}
 	return 1;
 }
@@ -4201,7 +4205,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
-		update_changeattr(dir, &res.cinfo);
+		update_changeattr(dir, &res.cinfo, res.fattr->time_start);
 		status = nfs_post_op_update_inode(inode, res.fattr);
 		if (!status)
 			nfs_setsecurity(inode, res.fattr, res.label);
@@ -4276,7 +4280,8 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 	int status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &data->msg,
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
-		update_changeattr(dir, &data->res.dir_cinfo);
+		update_changeattr(dir, &data->res.dir_cinfo,
+				data->res.fattr->time_start);
 		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, data->res.label);
 	}
 	return status;
-- 
2.9.3

