Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:55666 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752914AbdAKSzI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:08 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/11] NFS: Change nfs4_get_session() to take an nfs_client structure
Date: Wed, 11 Jan 2017 13:54:45 -0500
Message-ID: <20170111185454.9315-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

pNFS only has access to the nfs_client structure, and not the
nfs_server, so we need to make this change so the function can be used
by pNFS as well.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c   |  5 ++---
 fs/nfs/nfs4proc.c    | 10 +++++-----
 fs/nfs/nfs4session.h |  4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index b752d85ad8c6..b03010eebafd 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -332,9 +332,8 @@ nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
 	}
 	nfs4_stateid_copy(&data->args.stateid, &lo->plh_stateid);
 	spin_unlock(&inode->i_lock);
-	nfs41_setup_sequence(nfs4_get_session(server), &data->args.seq_args,
-			     &data->res.seq_res, task);
-
+	nfs41_setup_sequence(nfs4_get_session(server->nfs_client),
+			     &data->args.seq_args, &data->res.seq_res, task);
 }
 
 static void
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6dcbc5defb7a..d1fde35bfd7e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -953,7 +953,7 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	struct nfs4_session *session = nfs4_get_session(server);
+	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
 	int ret = 0;
 
 	if (!session)
@@ -973,7 +973,7 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
-	struct nfs4_session *session = nfs4_get_session(data->seq_server);
+	struct nfs4_session *session = nfs4_get_session(data->seq_server->nfs_client);
 
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
 
@@ -8389,7 +8389,7 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
-	struct nfs4_session *session = nfs4_get_session(server);
+	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
 
 	dprintk("--> %s\n", __func__);
 	nfs41_setup_sequence(session, &lgp->args.seq_args,
@@ -8785,7 +8785,7 @@ static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
-	struct nfs4_session *session = nfs4_get_session(server);
+	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
 
 	nfs41_setup_sequence(session,
 			&data->args.seq_args,
@@ -9111,7 +9111,7 @@ struct nfs_free_stateid_data {
 static void nfs41_free_stateid_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_free_stateid_data *data = calldata;
-	nfs41_setup_sequence(nfs4_get_session(data->server),
+	nfs41_setup_sequence(nfs4_get_session(data->server->nfs_client),
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 22cb55015b2b..f6378d95b1b5 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -103,9 +103,9 @@ static inline bool nfs4_test_locked_slot(const struct nfs4_slot_table *tbl,
 	return !!test_bit(slotid, tbl->used_slots);
 }
 
-static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
+static inline struct nfs4_session *nfs4_get_session(const struct nfs_client *clp)
 {
-	return server->nfs_client->cl_session;
+	return clp->cl_session;
 }
 
 #if defined(CONFIG_NFS_V4_1)
-- 
2.11.0

