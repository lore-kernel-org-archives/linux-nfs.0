Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38968 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932459AbeE3WwV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 18:52:21 -0400
Received: by mail-it0-f66.google.com with SMTP id c3-v6so25668960itj.4
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 15:52:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id b75-v6sm21753530ioa.50.2018.05.30.15.52.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 15:52:20 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4: Fix sillyrename to return the delegation when appropriate
Date: Wed, 30 May 2018 18:51:58 -0400
Message-Id: <20180530225158.8659-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we pass down the inode of the file being deleted so
that we can return any delegation being held.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3proc.c       |  4 +++-
 fs/nfs/nfs4proc.c       |  5 +++--
 fs/nfs/proc.c           |  4 +++-
 fs/nfs/unlink.c         | 10 +++++-----
 include/linux/nfs_xdr.h |  2 +-
 5 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 6ed6a4195906..5645ef4c5259 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -414,7 +414,9 @@ nfs3_proc_remove(struct inode *dir, struct dentry *dentry)
 }
 
 static void
-nfs3_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
+nfs3_proc_unlink_setup(struct rpc_message *msg,
+		struct dentry *dentry,
+		struct inode *inode)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 844eafbf1564..d21c5e4220a0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4260,11 +4260,12 @@ static int nfs4_proc_rmdir(struct inode *dir, const struct qstr *name)
 	return err;
 }
 
-static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
+static void nfs4_proc_unlink_setup(struct rpc_message *msg,
+		struct dentry *dentry,
+		struct inode *inode)
 {
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
-	struct inode *inode = d_inode(dentry);
 
 	res->server = NFS_SB(dentry->d_sb);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 80c350b6232a..763f77e7f1f1 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -321,7 +321,9 @@ nfs_proc_remove(struct inode *dir, struct dentry *dentry)
 }
 
 static void
-nfs_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentry)
+nfs_proc_unlink_setup(struct rpc_message *msg,
+		struct dentry *dentry,
+		struct inode *inode)
 {
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index bf54fc9ae135..6a73b8c808ea 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -85,7 +85,7 @@ static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_call_prepare = nfs_unlink_prepare,
 };
 
-static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
+static void nfs_do_call_unlink(struct inode *inode, struct nfs_unlinkdata *data)
 {
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
@@ -105,7 +105,7 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(data->res.dir_attr);
 
-	NFS_PROTO(dir)->unlink_setup(&msg, data->dentry);
+	NFS_PROTO(dir)->unlink_setup(&msg, data->dentry, inode);
 
 	task_setup_data.rpc_client = NFS_CLIENT(dir);
 	task = rpc_run_task(&task_setup_data);
@@ -113,7 +113,7 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
 		rpc_put_task_async(task);
 }
 
-static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
+static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nfs_unlinkdata *data)
 {
 	struct inode *dir = d_inode(dentry->d_parent);
 	struct dentry *alias;
@@ -153,7 +153,7 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 		return ret;
 	}
 	data->dentry = alias;
-	nfs_do_call_unlink(data);
+	nfs_do_call_unlink(inode, data);
 	return 1;
 }
 
@@ -231,7 +231,7 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 	dentry->d_fsdata = NULL;
 	spin_unlock(&dentry->d_lock);
 
-	if (NFS_STALE(inode) || !nfs_call_unlink(dentry, data))
+	if (NFS_STALE(inode) || !nfs_call_unlink(dentry, inode, data))
 		nfs_free_unlinkdata(data);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52b481dfd61e..d3cefe57c2a3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1591,7 +1591,7 @@ struct nfs_rpc_ops {
 	int	(*create)  (struct inode *, struct dentry *,
 			    struct iattr *, int);
 	int	(*remove)  (struct inode *, struct dentry *);
-	void	(*unlink_setup)  (struct rpc_message *, struct dentry *);
+	void	(*unlink_setup)  (struct rpc_message *, struct dentry *, struct inode *);
 	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	void	(*rename_setup)  (struct rpc_message *msg,
-- 
2.17.0

