Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:61282 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752914AbdAKSzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:12 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/11] NFS: Use nfs4_setup_sequence() everywhere
Date: Wed, 11 Jan 2017 13:54:47 -0500
Message-ID: <20170111185454.9315-5-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This does the right thing depending on if we have a session, rather than
needing to handle this manually in multiple places.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/filelayout/filelayout.c         |  6 ++---
 fs/nfs/flexfilelayout/flexfilelayout.c | 40 ++++++++++------------------------
 fs/nfs/nfs42proc.c                     |  4 ++--
 fs/nfs/nfs4_fs.h                       |  5 +----
 fs/nfs/nfs4proc.c                      | 30 ++++++++++++-------------
 5 files changed, 33 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index a3fc48ba4931..7aff350f15b1 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -305,7 +305,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 	}
 	hdr->pgio_done_cb = filelayout_read_done_cb;
 
-	if (nfs41_setup_sequence(hdr->ds_clp->cl_session,
+	if (nfs4_setup_sequence(hdr->ds_clp,
 			&hdr->args.seq_args,
 			&hdr->res.seq_res,
 			task))
@@ -403,7 +403,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 		rpc_exit(task, 0);
 		return;
 	}
-	if (nfs41_setup_sequence(hdr->ds_clp->cl_session,
+	if (nfs4_setup_sequence(hdr->ds_clp,
 			&hdr->args.seq_args,
 			&hdr->res.seq_res,
 			task))
@@ -438,7 +438,7 @@ static void filelayout_commit_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *wdata = data;
 
-	nfs41_setup_sequence(wdata->ds_clp->cl_session,
+	nfs4_setup_sequence(wdata->ds_clp,
 			&wdata->args.seq_args,
 			&wdata->res.seq_res,
 			task);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0ca4af8cca5d..cc9064974104 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1384,30 +1384,14 @@ static void ff_layout_read_prepare_v3(struct rpc_task *task, void *data)
 	rpc_call_start(task);
 }
 
-static int ff_layout_setup_sequence(struct nfs_client *ds_clp,
-				    struct nfs4_sequence_args *args,
-				    struct nfs4_sequence_res *res,
-				    struct rpc_task *task)
-{
-	if (ds_clp->cl_session)
-		return nfs41_setup_sequence(ds_clp->cl_session,
-					   args,
-					   res,
-					   task);
-	return nfs40_setup_sequence(ds_clp->cl_slot_tbl,
-				   args,
-				   res,
-				   task);
-}
-
 static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	if (ff_layout_setup_sequence(hdr->ds_clp,
-				     &hdr->args.seq_args,
-				     &hdr->res.seq_res,
-				     task))
+	if (nfs4_setup_sequence(hdr->ds_clp,
+				&hdr->args.seq_args,
+				&hdr->res.seq_res,
+				task))
 		return;
 
 	if (ff_layout_read_prepare_common(task, hdr))
@@ -1578,10 +1562,10 @@ static void ff_layout_write_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	if (ff_layout_setup_sequence(hdr->ds_clp,
-				     &hdr->args.seq_args,
-				     &hdr->res.seq_res,
-				     task))
+	if (nfs4_setup_sequence(hdr->ds_clp,
+				&hdr->args.seq_args,
+				&hdr->res.seq_res,
+				task))
 		return;
 
 	if (ff_layout_write_prepare_common(task, hdr))
@@ -1667,10 +1651,10 @@ static void ff_layout_commit_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *wdata = data;
 
-	if (ff_layout_setup_sequence(wdata->ds_clp,
-				 &wdata->args.seq_args,
-				 &wdata->res.seq_res,
-				 task))
+	if (nfs4_setup_sequence(wdata->ds_clp,
+				&wdata->args.seq_args,
+				&wdata->res.seq_res,
+				task))
 		return;
 	ff_layout_commit_prepare_common(task, data);
 }
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index b03010eebafd..98cf58341066 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -332,8 +332,8 @@ nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
 	}
 	nfs4_stateid_copy(&data->args.stateid, &lo->plh_stateid);
 	spin_unlock(&inode->i_lock);
-	nfs41_setup_sequence(nfs4_get_session(server->nfs_client),
-			     &data->args.seq_args, &data->res.seq_res, task);
+	nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+			    &data->res.seq_res, task);
 }
 
 static void
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 04ffea093d56..af285cc27ccf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -273,9 +273,6 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
-extern int nfs41_setup_sequence(struct nfs4_session *session,
-		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		struct rpc_task *task);
 extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
 extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
@@ -456,7 +453,7 @@ extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_release_seqid(struct nfs_seqid *seqid);
 extern void nfs_free_seqid(struct nfs_seqid *seqid);
-extern int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
+extern int nfs4_setup_sequence(const struct nfs_client *client,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
 				struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a2e5c6f39182..3f7199a0b784 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -623,10 +623,10 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
 	args->sa_privileged = 1;
 }
 
-int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
-			 struct nfs4_sequence_args *args,
-			 struct nfs4_sequence_res *res,
-			 struct rpc_task *task)
+static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
+				struct nfs4_sequence_args *args,
+				struct nfs4_sequence_res *res,
+				struct rpc_task *task)
 {
 	struct nfs4_slot *slot;
 
@@ -663,7 +663,6 @@ int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 	spin_unlock(&tbl->slot_tbl_lock);
 	return -EAGAIN;
 }
-EXPORT_SYMBOL_GPL(nfs40_setup_sequence);
 
 static void nfs40_sequence_free_slot(struct nfs4_sequence_res *res)
 {
@@ -883,7 +882,7 @@ int nfs4_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 }
 EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
-int nfs41_setup_sequence(struct nfs4_session *session,
+static int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
 				struct rpc_task *task)
@@ -946,12 +945,11 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	spin_unlock(&tbl->slot_tbl_lock);
 	return -EAGAIN;
 }
-EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 
-static int nfs4_setup_sequence(const struct nfs_client *client,
-			       struct nfs4_sequence_args *args,
-			       struct nfs4_sequence_res *res,
-			       struct rpc_task *task)
+int nfs4_setup_sequence(const struct nfs_client *client,
+			struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res,
+			struct rpc_task *task)
 {
 	struct nfs4_session *session = nfs4_get_session(client);
 	int ret = 0;
@@ -969,6 +967,7 @@ static int nfs4_setup_sequence(const struct nfs_client *client,
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
 
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
@@ -994,13 +993,14 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 
 #else	/* !CONFIG_NFS_V4_1 */
 
-static int nfs4_setup_sequence(const struct nfs_client *client,
-			       struct nfs4_sequence_args *args,
-			       struct nfs4_sequence_res *res,
-			       struct rpc_task *task)
+int nfs4_setup_sequence(const struct nfs_client *client,
+			struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res,
+			struct rpc_task *task)
 {
 	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
 }
+EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
 
 static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
-- 
2.11.0

