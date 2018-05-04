Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34050 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751706AbeEDUXA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:23:00 -0400
Received: by mail-qk0-f193.google.com with SMTP id p186so17625067qkd.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:22:59 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFS: Move call to nfs4_state_protect() to nfs4_commit_setup()
Date: Fri,  4 May 2018 16:22:49 -0400
Message-Id: <20180504202252.5862-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Rather than doing this in the generic NFS client code.  Let's put this
with the other v4 stuff so it's all in one place.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3proc.c       | 3 ++-
 fs/nfs/nfs4proc.c       | 4 +++-
 fs/nfs/proc.c           | 3 ++-
 fs/nfs/write.c          | 5 +----
 include/linux/nfs_xdr.h | 3 ++-
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 3ffaff471592..6ed6a4195906 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -845,7 +845,8 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return 0;
 }
 
-static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg,
+				   struct rpc_clnt **clnt)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 09be575e9194..50a067018a60 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5028,7 +5028,8 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return data->commit_done_cb(task, data);
 }
 
-static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg,
+				   struct rpc_clnt **clnt)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
@@ -5037,6 +5038,7 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_COMMIT, clnt, msg);
 }
 
 struct nfs4_renewdata {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index aaad337962d0..80c350b6232a 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -632,7 +632,8 @@ static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit
 }
 
 static void
-nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg,
+			struct rpc_clnt **clnt)
 {
 	BUG();
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b633583ca268..a057b4f45a46 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1666,14 +1666,11 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
-	nfs_ops->commit_setup(data, &msg);
+	nfs_ops->commit_setup(data, &msg, &task_setup_data.rpc_client);
 	trace_nfs_initiate_commit(data);
 
 	dprintk("NFS: initiated commit call\n");
 
-	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
-		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
-
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1009269e1a49..52b481dfd61e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1623,7 +1623,8 @@ struct nfs_rpc_ops {
 	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *,
 				struct rpc_clnt **);
 	int	(*write_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
+	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *,
+				struct rpc_clnt **);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
 	int	(*lock)(struct file *, int, struct file_lock *);
-- 
2.17.0

