Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:44582 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751031AbeCTUnr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:47 -0400
Received: by mail-io0-f195.google.com with SMTP id h23so4005889iob.11
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFS: Move delegation recall into the NFSv4 callback for rename_setup()
Date: Tue, 20 Mar 2018 16:43:16 -0400
Message-Id: <20180320204320.93656-5-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-4-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
 <20180320204320.93656-4-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the delegation recall out of the generic code, and into the NFSv4
specific callback.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c            |  4 ----
 fs/nfs/nfs3proc.c       |  4 +++-
 fs/nfs/nfs4proc.c       | 13 ++++++++++---
 fs/nfs/proc.c           |  4 +++-
 fs/nfs/unlink.c         |  5 +----
 include/linux/nfs_xdr.h |  4 +++-
 6 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index eb9d782ed674..8001f8c7ad0e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2020,10 +2020,6 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		}
 	}
 
-	NFS_PROTO(old_inode)->return_delegation(old_inode);
-	if (new_inode != NULL)
-		NFS_PROTO(new_inode)->return_delegation(new_inode);
-
 	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
 	if (IS_ERR(task)) {
 		error = PTR_ERR(task);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index f4ead71e4350..08875dc17b52 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -433,7 +433,9 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 }
 
 static void
-nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+nfs3_proc_rename_setup(struct rpc_message *msg,
+		struct dentry *old_dentry,
+		struct dentry *new_dentry)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_RENAME];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 69a2428eef10..f7149028efc7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4267,14 +4267,21 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	return 1;
 }
 
-static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+static void nfs4_proc_rename_setup(struct rpc_message *msg,
+		struct dentry *old_dentry,
+		struct dentry *new_dentry)
 {
-	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs_renameargs *arg = msg->rpc_argp;
 	struct nfs_renameres *res = msg->rpc_resp;
+	struct inode *old_inode = d_inode(old_dentry);
+	struct inode *new_inode = d_inode(new_dentry);
 
+	if (old_inode)
+		nfs4_inode_return_delegation(old_inode);
+	if (new_inode)
+		nfs4_inode_return_delegation(new_inode);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
-	res->server = server;
+	res->server = NFS_SB(old_dentry->d_sb);
 	nfs4_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
 
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b2e81a110133..39dc9276b1f6 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -338,7 +338,9 @@ static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 }
 
 static void
-nfs_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+nfs_proc_rename_setup(struct rpc_message *msg,
+		struct dentry *old_dentry,
+		struct dentry *new_dentry)
 {
 	msg->rpc_proc = &nfs_procedures[NFSPROC_RENAME];
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 630b4a3c1a93..44f101411422 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -386,7 +386,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 
 	nfs_sb_active(old_dir->i_sb);
 
-	NFS_PROTO(data->old_dir)->rename_setup(&msg, old_dir);
+	NFS_PROTO(data->old_dir)->rename_setup(&msg, old_dentry, new_dentry);
 
 	return rpc_run_task(&task_setup_data);
 }
@@ -463,9 +463,6 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	fileid = NFS_FILEID(d_inode(dentry));
 
-	/* Return delegation in anticipation of the rename */
-	NFS_PROTO(d_inode(dentry))->return_delegation(d_inode(dentry));
-
 	sdentry = NULL;
 	do {
 		int slen;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ebf14b3bf0b..4b87e2d726b1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1594,7 +1594,9 @@ struct nfs_rpc_ops {
 	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
 	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
-	void	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
+	void	(*rename_setup)  (struct rpc_message *msg,
+			struct dentry *old_dentry,
+			struct dentry *new_dentry);
 	void	(*rename_rpc_prepare)(struct rpc_task *task, struct nfs_renamedata *);
 	int	(*rename_done) (struct rpc_task *task, struct inode *old_dir, struct inode *new_dir);
 	int	(*link)    (struct inode *, struct inode *, const struct qstr *);
-- 
2.14.3

