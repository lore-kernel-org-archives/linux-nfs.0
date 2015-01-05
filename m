Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:20552 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbbAETR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 14:17:28 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] nfs: Call nfs4_state_protect() from nfs4_proc_commit_setup()
Date: Mon, 5 Jan 2015 14:17:22 -0500
Message-ID: <1420485444-20101-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This keeps the function call internal to NFS v4, so the generic client
doesn't need to have a macro for the case that NFS v4 is compiled out.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3proc.c       | 4 +++-
 fs/nfs/nfs4_fs.h        | 1 -
 fs/nfs/nfs4proc.c       | 5 ++++-
 fs/nfs/proc.c           | 3 ++-
 fs/nfs/write.c          | 5 +----
 include/linux/nfs_xdr.h | 3 ++-
 6 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 524f9f8..f6e6ee3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -851,7 +851,9 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return 0;
 }
 
-static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs3_proc_commit_setup(struct rpc_clnt *clnt,
+				   struct nfs_commit_data *data,
+				   struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a081787..5cc2edb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -513,7 +513,6 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 
 #define nfs4_close_state(a, b) do { } while (0)
 #define nfs4_close_sync(a, b) do { } while (0)
-#define nfs4_state_protect(a, b, c, d) do { } while (0)
 #define nfs4_state_protect_write(a, b, c, d) do { } while (0)
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e7f8d5f..9a872d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4287,7 +4287,9 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return data->commit_done_cb(task, data);
 }
 
-static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+static void nfs4_proc_commit_setup(struct rpc_clnt *clnt,
+				   struct nfs_commit_data *data,
+				   struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
@@ -4296,6 +4298,7 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_COMMIT, &clnt, msg);
 }
 
 struct nfs4_renewdata {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b09cc23..ae8e0f2 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -630,7 +630,8 @@ static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit
 }
 
 static void
-nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
+nfs_proc_commit_setup(struct rpc_clnt *clnt, struct nfs_commit_data *data,
+		      struct rpc_message *msg)
 {
 	BUG();
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af3af68..1c6d52b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1486,13 +1486,10 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
-	NFS_PROTO(data->inode)->commit_setup(data, &msg);
+	NFS_PROTO(data->inode)->commit_setup(clnt, data, &msg);
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
-	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
-		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
-
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 467c84e..f01b9a1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1466,7 +1466,8 @@ struct nfs_rpc_ops {
 	int	(*read_done)(struct rpc_task *, struct nfs_pgio_header *);
 	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *);
 	int	(*write_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
+	void	(*commit_setup) (struct rpc_clnt *clnt, struct nfs_commit_data *,
+				 struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
 	int	(*lock)(struct file *, int, struct file_lock *);
-- 
2.2.1

