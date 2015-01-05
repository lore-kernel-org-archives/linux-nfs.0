Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59677 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624AbbAETR3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 14:17:29 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] nfs: Call nfs4_state_protect_write() from nfs4_proc_write_setup()
Date: Mon, 5 Jan 2015 14:17:23 -0500
Message-ID: <1420485444-20101-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes the function call internal to the NFS v4 module, so the
generic client no longer needs a macro for the case where NFS v4 is
compiled out.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3proc.c       | 3 ++-
 fs/nfs/nfs4_fs.h        | 1 -
 fs/nfs/nfs4proc.c       | 4 +++-
 fs/nfs/proc.c           | 3 ++-
 fs/nfs/write.c          | 5 +----
 include/linux/nfs_xdr.h | 3 ++-
 6 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index f6e6ee3..f9b2a9d 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -832,7 +832,8 @@ static int nfs3_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	return 0;
 }
 
-static void nfs3_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs3_proc_write_setup(struct rpc_clnt *clnt,
+				  struct nfs_pgio_header *hdr,
 				  struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5cc2edb..3694895 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -513,7 +513,6 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 
 #define nfs4_close_state(a, b) do { } while (0)
 #define nfs4_close_sync(a, b) do { } while (0)
-#define nfs4_state_protect_write(a, b, c, d) do { } while (0)
 
 #endif /* CONFIG_NFS_V4 */
 #endif /* __LINUX_FS_NFS_NFS4_FS.H */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9a872d8..ff3c36f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4239,7 +4239,8 @@ bool nfs4_write_need_cache_consistency_data(struct nfs_pgio_header *hdr)
 	return nfs4_have_delegation(hdr->inode, FMODE_READ) == 0;
 }
 
-static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs4_proc_write_setup(struct rpc_clnt *clnt,
+				  struct nfs_pgio_header *hdr,
 				  struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(hdr->inode);
@@ -4257,6 +4258,7 @@ static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 1);
+	nfs4_state_protect_write(server->nfs_client, &clnt, msg, hdr);
 }
 
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ae8e0f2..18ead52 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -616,7 +616,8 @@ static int nfs_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	return 0;
 }
 
-static void nfs_proc_write_setup(struct nfs_pgio_header *hdr,
+static void nfs_proc_write_setup(struct rpc_clnt *clnt,
+				 struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1c6d52b..0d37c5d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1246,10 +1246,7 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
 	int priority = flush_task_priority(how);
 
 	task_setup_data->priority = priority;
-	NFS_PROTO(inode)->write_setup(hdr, msg);
-
-	nfs4_state_protect_write(NFS_SERVER(inode)->nfs_client,
-				 &task_setup_data->rpc_client, msg, hdr);
+	NFS_PROTO(inode)->write_setup(task_setup_data->rpc_client, hdr, msg);
 }
 
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f01b9a1..96c9fdf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1464,7 +1464,8 @@ struct nfs_rpc_ops {
 				    struct nfs_pgio_header *);
 	void	(*read_setup)(struct nfs_pgio_header *, struct rpc_message *);
 	int	(*read_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *);
+	void	(*write_setup)(struct rpc_clnt *, struct nfs_pgio_header *,
+			       struct rpc_message *);
 	int	(*write_done)(struct rpc_task *, struct nfs_pgio_header *);
 	void	(*commit_setup) (struct rpc_clnt *clnt, struct nfs_commit_data *,
 				 struct rpc_message *);
-- 
2.2.1

