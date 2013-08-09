Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f43.google.com ([209.85.213.43]:41820 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:23 -0400
Received: by mail-yh0-f43.google.com with SMTP id z12so1539887yhz.30
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:22 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id y70sm20675916yhe.15.2013.08.09.09.49.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:21 -0700 (PDT)
Subject: [PATCH v2 11/33] NFS: NFSv4.0 transport blocking
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:19 -0400
Message-ID: <20130809164919.5362.82216.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Plumb in a mechanism for plugging an NFSv4.0 mount, using the
same infrastructure as NFSv4.1 sessions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfs4xdr.c  |   13 +++++---
 2 files changed, 79 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4352d51..51f4272 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -468,6 +468,67 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
 	args->sa_privileged = 1;
 }
 
+static int nfs40_setup_sequence(const struct nfs_server *server,
+				struct nfs4_sequence_args *args,
+				struct nfs4_sequence_res *res,
+				struct rpc_task *task)
+{
+	struct nfs4_slot_table *tbl = server->nfs_client->cl_slot_tbl;
+	struct nfs4_slot *slot;
+
+	/* slot already allocated? */
+	if (res->sr_slot != NULL)
+		goto out_start;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
+		goto out_sleep;
+
+	slot = nfs4_alloc_slot(tbl);
+	if (IS_ERR(slot)) {
+		if (slot == ERR_PTR(-ENOMEM))
+			task->tk_timeout = HZ >> 2;
+		goto out_sleep;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+
+	args->sa_slot = slot;
+	res->sr_slot = slot;
+
+out_start:
+	rpc_call_start(task);
+	return 0;
+
+out_sleep:
+	if (args->sa_privileged)
+		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
+				NULL, RPC_PRIORITY_PRIVILEGED);
+	else
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+	spin_unlock(&tbl->slot_tbl_lock);
+	return -EAGAIN;
+}
+
+static int nfs40_sequence_done(struct rpc_task *task,
+			       struct nfs4_sequence_res *res)
+{
+	struct nfs4_slot *slot = res->sr_slot;
+	struct nfs4_slot_table *tbl;
+
+	if (!RPC_WAS_SENT(task))
+		goto out;
+
+	tbl = slot->table;
+	spin_lock(&tbl->slot_tbl_lock);
+	if (!nfs41_wake_and_assign_slot(tbl, slot))
+		nfs4_free_slot(tbl, slot);
+	spin_unlock(&tbl->slot_tbl_lock);
+
+	res->sr_slot = NULL;
+out:
+	return 1;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -612,6 +673,8 @@ static int nfs4_sequence_done(struct rpc_task *task,
 {
 	if (res->sr_slot == NULL)
 		return 1;
+	if (!res->sr_slot->table->session)
+		return nfs40_sequence_done(task, res);
 	return nfs41_sequence_done(task, res);
 }
 
@@ -686,17 +749,15 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 	struct nfs4_session *session = nfs4_get_session(server);
 	int ret = 0;
 
-	if (session == NULL) {
-		rpc_call_start(task);
-		goto out;
-	}
+	if (!session)
+		return nfs40_setup_sequence(server, args, res, task);
 
 	dprintk("--> %s clp %p session %p sr_slot %u\n",
 		__func__, session->clp, session, res->sr_slot ?
 			res->sr_slot->slot_nr : NFS4_NO_SLOT);
 
 	ret = nfs41_setup_sequence(session, args, res, task);
-out:
+
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
 }
@@ -723,22 +784,23 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 	.rpc_call_done = nfs41_call_sync_done,
 };
 
-#else
+#else	/* !CONFIG_NFS_V4_1 */
+
 static int nfs4_setup_sequence(const struct nfs_server *server,
 			       struct nfs4_sequence_args *args,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	rpc_call_start(task);
-	return 0;
+	return nfs40_setup_sequence(server, args, res, task);
 }
 
 static int nfs4_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)
 {
-	return 1;
+	return nfs40_sequence_done(task, res);
 }
-#endif /* CONFIG_NFS_V4_1 */
+
+#endif	/* !CONFIG_NFS_V4_1 */
 
 static void nfs40_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3850b01..9b195fb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1877,11 +1877,10 @@ static void encode_sequence(struct xdr_stream *xdr,
 	struct nfs4_slot *slot = args->sa_slot;
 	__be32 *p;
 
-	if (slot == NULL)
-		return;
-
 	tp = slot->table;
 	session = tp->session;
+	if (!session)
+		return;
 
 	encode_op_hdr(xdr, OP_SEQUENCE, decode_sequence_maxsz, hdr);
 
@@ -2062,9 +2061,9 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
 {
 #if defined(CONFIG_NFS_V4_1)
-
-	if (args->sa_slot)
-		return args->sa_slot->table->session->clp->cl_mvops->minor_version;
+	struct nfs4_session *session = args->sa_slot->table->session;
+	if (session)
+		return session->clp->cl_mvops->minor_version;
 #endif /* CONFIG_NFS_V4_1 */
 	return 0;
 }
@@ -5614,6 +5613,8 @@ static int decode_sequence(struct xdr_stream *xdr,
 
 	if (res->sr_slot == NULL)
 		return 0;
+	if (!res->sr_slot->table->session)
+		return 0;
 
 	status = decode_op_hdr(xdr, OP_SEQUENCE);
 	if (!status)

