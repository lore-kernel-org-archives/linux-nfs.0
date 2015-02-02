Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:55456 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbbBBWjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:39:54 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so87823396pab.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:39:54 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 13/53] nfs4: pass slot table to nfs40_setup_sequence
Date: Mon,  2 Feb 2015 14:38:27 -0800
Message-Id: <1422916747-86649-14-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

flexclient needs this as there is no nfs_server to DS connection.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4_fs.h  |  4 ++++
 fs/nfs/nfs4proc.c | 24 +++++++++++++-----------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a081787..90c4ffe 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -443,6 +443,10 @@ extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_release_seqid(struct nfs_seqid *seqid);
 extern void nfs_free_seqid(struct nfs_seqid *seqid);
+extern int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
+				struct nfs4_sequence_args *args,
+				struct nfs4_sequence_res *res,
+				struct rpc_task *task);
 
 extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c347705..e98dda7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -495,12 +495,11 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
 	args->sa_privileged = 1;
 }
 
-static int nfs40_setup_sequence(const struct nfs_server *server,
-				struct nfs4_sequence_args *args,
-				struct nfs4_sequence_res *res,
-				struct rpc_task *task)
+int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
+			 struct nfs4_sequence_args *args,
+			 struct nfs4_sequence_res *res,
+			 struct rpc_task *task)
 {
-	struct nfs4_slot_table *tbl = server->nfs_client->cl_slot_tbl;
 	struct nfs4_slot *slot;
 
 	/* slot already allocated? */
@@ -535,6 +534,7 @@ out_sleep:
 	spin_unlock(&tbl->slot_tbl_lock);
 	return -EAGAIN;
 }
+EXPORT_SYMBOL_GPL(nfs40_setup_sequence);
 
 static int nfs40_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)
@@ -777,7 +777,8 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 	int ret = 0;
 
 	if (!session)
-		return nfs40_setup_sequence(server, args, res, task);
+		return nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
+					    args, res, task);
 
 	dprintk("--> %s clp %p session %p sr_slot %u\n",
 		__func__, session->clp, session, res->sr_slot ?
@@ -818,7 +819,8 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	return nfs40_setup_sequence(server, args, res, task);
+	return nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
+				    args, res, task);
 }
 
 static int nfs4_sequence_done(struct rpc_task *task,
@@ -1679,8 +1681,8 @@ static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 
-	nfs40_setup_sequence(data->o_arg.server, &data->c_arg.seq_args,
-				&data->c_res.seq_res, task);
+	nfs40_setup_sequence(data->o_arg.server->nfs_client->cl_slot_tbl,
+			     &data->c_arg.seq_args, &data->c_res.seq_res, task);
 }
 
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
@@ -5974,8 +5976,8 @@ static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata
 {
 	struct nfs_release_lockowner_data *data = calldata;
 	struct nfs_server *server = data->server;
-	nfs40_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, task);
+	nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
+			     &data->args.seq_args, &data->res.seq_res, task);
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->timestamp = jiffies;
 }
-- 
1.9.3

