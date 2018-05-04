Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34050 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbeEDUW7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:22:59 -0400
Received: by mail-qk0-f196.google.com with SMTP id p186so17625042qkd.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:22:58 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFS: Move call to nfs4_state_protect_write() to nfs4_write_setup()
Date: Fri,  4 May 2018 16:22:48 -0400
Message-Id: <20180504202252.5862-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This doesn't really need to be in the generic NFS client code, and I
think it makes more sense to keep the v4 code in one place.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs3proc.c       | 3 ++-
 fs/nfs/nfs4proc.c       | 4 +++-
 fs/nfs/proc.c           | 3 ++-
 fs/nfs/write.c          | 5 +----
 include/linux/nfs_xdr.h | 3 ++-
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index eadf1ab31d16..3ffaff471592 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -823,7 +823,8 @@ static int nfs3_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 }
 
 static void nfs3_proc_write_setup(struct nfs_pgio_header *hdr,
-				  struct rpc_message *msg)
+				  struct rpc_message *msg,
+				  struct rpc_clnt **clnt)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b71757e85066..09be575e9194 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4979,7 +4979,8 @@ bool nfs4_write_need_cache_consistency_data(struct nfs_pgio_header *hdr)
 }
 
 static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
-				  struct rpc_message *msg)
+				  struct rpc_message *msg,
+				  struct rpc_clnt **clnt)
 {
 	struct nfs_server *server = NFS_SERVER(hdr->inode);
 
@@ -4996,6 +4997,7 @@ static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 1);
+	nfs4_state_protect_write(server->nfs_client, clnt, msg, hdr);
 }
 
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4e93d6308733..aaad337962d0 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -618,7 +618,8 @@ static int nfs_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 }
 
 static void nfs_proc_write_setup(struct nfs_pgio_header *hdr,
-				 struct rpc_message *msg)
+				 struct rpc_message *msg,
+				 struct rpc_clnt **clnt)
 {
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
 	hdr->args.stable = NFS_FILE_SYNC;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0193053bc139..b633583ca268 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1375,12 +1375,9 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
 	int priority = flush_task_priority(how);
 
 	task_setup_data->priority = priority;
-	rpc_ops->write_setup(hdr, msg);
+	rpc_ops->write_setup(hdr, msg, &task_setup_data->rpc_client);
 	trace_nfs_initiate_write(hdr->inode, hdr->io_start, hdr->good_bytes,
 				 hdr->args.stable);
-
-	nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
-				 &task_setup_data->rpc_client, msg, hdr);
 }
 
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 34d28564ecf3..1009269e1a49 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1620,7 +1620,8 @@ struct nfs_rpc_ops {
 				    struct nfs_pgio_header *);
 	void	(*read_setup)(struct nfs_pgio_header *, struct rpc_message *);
 	int	(*read_done)(struct rpc_task *, struct nfs_pgio_header *);
-	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *);
+	void	(*write_setup)(struct nfs_pgio_header *, struct rpc_message *,
+				struct rpc_clnt **);
 	int	(*write_done)(struct rpc_task *, struct nfs_pgio_header *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
-- 
2.17.0

