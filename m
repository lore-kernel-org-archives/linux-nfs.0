From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 16/24] NFS: Reduce stack footprint of nfs_proc_remove()
Date: Fri, 16 Apr 2010 16:31:14 -0400
Message-ID: <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932477Ab0DPUbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:33 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlB026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:32 -0700 (PDT)
In-Reply-To: <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c       |   13 +++++++++----
 fs/nfs/nfs3xdr.c        |    2 +-
 fs/nfs/nfs4proc.c       |   13 +++++++++----
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/unlink.c         |    4 +++-
 include/linux/nfs_xdr.h |    2 +-
 6 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 088dceb..80378d1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -406,12 +406,17 @@ nfs3_proc_remove(struct inode *dir, struct qstr *name)
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  remove %s\n", name->name);
-	nfs_fattr_init(&res.dir_attr);
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.dir_attr == NULL)
+		goto out;
+
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &res.dir_attr);
+	nfs_post_op_update_inode(dir, res.dir_attr);
+	nfs_free_fattr(res.dir_attr);
+out:
 	dprintk("NFS reply remove: %d\n", status);
 	return status;
 }
@@ -429,7 +434,7 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs3_async_handle_jukebox(task, dir))
 		return 0;
 	res = task->tk_msg.rpc_resp;
-	nfs_post_op_update_inode(dir, &res->dir_attr);
+	nfs_post_op_update_inode(dir, res->dir_attr);
 	return 1;
 }
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 56a86f6..75dcfc7 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -762,7 +762,7 @@ nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 static int
 nfs3_xdr_removeres(struct rpc_rqst *req, __be32 *p, struct nfs_removeres *res)
 {
-	return nfs3_xdr_wccstat(req, p, &res->dir_attr);
+	return nfs3_xdr_wccstat(req, p, res->dir_attr);
 }
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 345b6f9..f09a7b9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2599,14 +2599,19 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int status = -ENOMEM;
+
+	res.dir_attr = nfs_alloc_fattr();
+	if (res.dir_attr == NULL)
+		goto out;
 
-	nfs_fattr_init(&res.dir_attr);
 	status = nfs4_call_sync(server, &msg, &args, &res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, &res.dir_attr);
+		nfs_post_op_update_inode(dir, res.dir_attr);
 	}
+	nfs_free_fattr(res.dir_attr);
+out:
 	return status;
 }
 
@@ -2641,7 +2646,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
-	nfs_post_op_update_inode(dir, &res->dir_attr);
+	nfs_post_op_update_inode(dir, res->dir_attr);
 	return 1;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 38f3b58..8905806 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4815,7 +4815,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, &res->dir_attr, res->server,
+	decode_getfattr(&xdr, res->dir_attr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 6da3d3f..a2242af 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -23,6 +23,7 @@ struct nfs_unlinkdata {
 	struct nfs_removeres res;
 	struct inode *dir;
 	struct rpc_cred	*cred;
+	struct nfs_fattr dir_attr;
 };
 
 /**
@@ -169,7 +170,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 	}
 	nfs_sb_active(dir->i_sb);
 	data->args.fh = NFS_FH(dir);
-	nfs_fattr_init(&data->res.dir_attr);
+	nfs_fattr_init(data->res.dir_attr);
 
 	NFS_PROTO(dir)->unlink_setup(&msg, dir);
 
@@ -259,6 +260,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 		goto out_free;
 	}
 	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
+	data->res.dir_attr = &data->dir_attr;
 
 	status = -EBUSY;
 	spin_lock(&dentry->d_lock);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 89b2881..76e11c6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -386,8 +386,8 @@ struct nfs_removeargs {
 
 struct nfs_removeres {
 	const struct nfs_server *server;
+	struct nfs_fattr	*dir_attr;
 	struct nfs4_change_info	cinfo;
-	struct nfs_fattr	dir_attr;
 	struct nfs4_sequence_res 	seq_res;
 };
 
-- 
1.6.6.1

