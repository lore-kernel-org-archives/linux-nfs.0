Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:27993 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932756AbcECS3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2016 14:29:46 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 1/2] NFS: Call nfs4_state_protect{_write}() from the NFSv4 module
Date: Tue, 3 May 2016 14:29:41 -0400
Message-ID: <1462300182-24738-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic client doesn't need to know about these calls, and we can
handle them from the write and commit setup functions easily enough.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3proc.c       |  7 +++++--
 fs/nfs/nfs4proc.c       | 11 +++++++++--
 fs/nfs/proc.c           |  6 ++++--
 fs/nfs/write.c          | 10 ++--------
 include/linux/nfs_xdr.h |  6 ++++--
 5 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cb28cce..f60ee94 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -838,7 +838,8 @@ static int nfs3_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	return 0;
 }
 
-static void nfs3_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs3_proc_write_setup(struct rpc_clnt **clnt,
+				  struct nfs_pgio_header *hdr,
 				  struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
@@ -860,7 +861,9 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return 0;
 }
 
-static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs3_proc_commit_setup(struct rpc_clnt **clnt,
+				   struct nfs_commit_data *data,
+				   struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bc2676c..9ff6ee8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4448,7 +4448,8 @@ bool nfs4_write_need_cache_consistency_data(struct nfs_pgio_header *hdr)
 	return nfs4_have_delegation(hdr->inode, FMODE_READ) == 0;
 }
 
-static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs4_proc_write_setup(struct rpc_clnt **clnt,
+				  struct nfs_pgio_header *hdr,
 				  struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(hdr->inode);
@@ -4466,6 +4467,8 @@ static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 1);
+	nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
+				 clnt, msg, hdr);
 }
 
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
@@ -4496,7 +4499,9 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return data->commit_done_cb(task, data);
 }
 
-static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs4_proc_commit_setup(struct rpc_clnt **clnt,
+				   struct nfs_commit_data *data,
+				   struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
@@ -4505,6 +4510,8 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_COMMIT, clnt, msg);
 }
 
 struct nfs4_renewdata {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b417bbc..d0164c6 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -614,7 +614,8 @@ static int nfs_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	return 0;
 }
 
-static void nfs_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs_proc_write_setup(struct rpc_clnt **clnt,
+				 struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
@@ -628,7 +629,8 @@ static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit
 }
 
 static void
-nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+nfs_proc_commit_setup(struct rpc_clnt **clnt, struct nfs_commit_data *data,
+		      struct rpc_message *msg)
 {
 	BUG();
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9283a96..88f0796 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1323,10 +1323,7 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
 	int priority = flush_task_priority(how);
 
 	task_setup_data->priority = priority;
-	rpc_ops->write_setup(hdr, msg);
-
-	nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
-				 &task_setup_data->rpc_client, msg, hdr);
+	rpc_ops->write_setup(&task_setup_data->rpc_client, hdr, msg);
 }
 
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
@@ -1609,13 +1606,10 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
-	nfs_ops->commit_setup(data, &msg);
+	nfs_ops->commit_setup(&task_setup_data.rpc_client, data, &msg);
 
 	dprintk("NFS: initiated commit call\n");
 
-	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
-		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
-
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index cb9982d..63eabc9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1555,9 +1555,11 @@ struct nfs_rpc_ops {
 				    struct nfs_pgio_header *);
 	void	(*read_setup)(struct nfs_pgio_header *, struct rpc_message *);
 	int	(*read_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *);
+	void	(*write_setup)(struct rpc_clnt **, struct nfs_pgio_header *,
+			       struct rpc_message *);
 	int	(*write_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
+	void	(*commit_setup) (struct rpc_clnt **, struct nfs_commit_data *,
+				 struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
 	int	(*lock)(struct file *, int, struct file_lock *);
-- 
2.8.2

