Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:51735 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751472AbeCTUnt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:49 -0400
Received: by mail-it0-f66.google.com with SMTP id j137-v6so4189269ita.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/8] NFS: Add a delegation return into nfs4_proc_unlink_setup()
Date: Tue, 20 Mar 2018 16:43:17 -0400
Message-Id: <20180320204320.93656-6-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-5-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
 <20180320204320.93656-4-trond.myklebust@primarydata.com>
 <20180320204320.93656-5-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that when we do finally delete the file, then we return the
delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3proc.c       | 2 +-
 fs/nfs/nfs4proc.c       | 9 ++++++---
 fs/nfs/proc.c           | 2 +-
 fs/nfs/unlink.c         | 2 +-
 include/linux/nfs_xdr.h | 2 +-
 5 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 08875dc17b52..ae03307bd8cd 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -411,7 +411,7 @@ nfs3_proc_remove(struct inode *dir, struct dentry *dentry)
 }
 
 static void
-nfs3_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
+nfs3_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7149028efc7..2953da680bc7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4231,17 +4231,20 @@ static int nfs4_proc_rmdir(struct inode *dir, const struct qstr *name)
 	return err;
 }
 
-static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
+static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
 {
-	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
+	struct inode *inode = d_inode(dentry);
 
-	res->server = server;
+	res->server = NFS_SB(dentry->d_sb);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 	nfs4_init_sequence(&args->seq_args, &res->seq_res, 1);
 
 	nfs_fattr_init(res->dir_attr);
+
+	if (inode)
+		nfs4_inode_return_delegation(inode);
 }
 
 static void nfs4_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 39dc9276b1f6..318b3f34a6d0 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -321,7 +321,7 @@ nfs_proc_remove(struct inode *dir, struct dentry *dentry)
 }
 
 static void
-nfs_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
+nfs_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
 {
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 44f101411422..bf54fc9ae135 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -105,7 +105,7 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(data->res.dir_attr);
 
-	NFS_PROTO(dir)->unlink_setup(&msg, dir);
+	NFS_PROTO(dir)->unlink_setup(&msg, data->dentry);
 
 	task_setup_data.rpc_client = NFS_CLIENT(dir);
 	task = rpc_run_task(&task_setup_data);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4b87e2d726b1..c4ba58b3c0f8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1591,7 +1591,7 @@ struct nfs_rpc_ops {
 	int	(*create)  (struct inode *, struct dentry *,
 			    struct iattr *, int);
 	int	(*remove)  (struct inode *, struct dentry *);
-	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
+	void	(*unlink_setup)  (struct rpc_message *, struct dentry *);
 	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	void	(*rename_setup)  (struct rpc_message *msg,
-- 
2.14.3

