Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913Ab2KZURA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:00 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/28] NFSv4.1: Shrink struct nfs4_sequence_res by moving the session pointer
Date: Mon, 26 Nov 2012 15:16:25 -0500
Message-Id: <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the session pointer into the slot table, then have struct nfs4_slot
point to that slot table.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h          |  3 ++-
 fs/nfs/nfs4proc.c         | 34 ++++++++++++++++++++++++----------
 fs/nfs/nfs4state.c        |  2 +-
 fs/nfs/nfs4xdr.c          |  8 +++++---
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  2 +-
 6 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 36880b9..42c5869 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -258,7 +258,8 @@ extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				  bool sync);
 
-extern struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags);
+extern struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
+		u32 max_slots, gfp_t gfp_flags);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 14b3974..f8cb60b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -467,25 +467,29 @@ void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
+	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
 
-	tbl = &res->sr_session->fc_slot_table;
 	if (!res->sr_slot) {
 		/* just wake up the next guy waiting since
 		 * we may have not consumed a slot after all */
 		dprintk("%s: No slot\n", __func__);
 		return;
 	}
+	tbl = res->sr_slot->table;
+	session = tbl->session;
+	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slot - tbl->slots);
-	nfs4_check_drain_fc_complete(res->sr_session);
+	nfs4_check_drain_fc_complete(session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 }
 
 static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
+	struct nfs4_session *session;
 	struct nfs4_slot *slot;
 	unsigned long timestamp;
 	struct nfs_client *clp;
@@ -504,6 +508,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		goto out;
 
 	slot = res->sr_slot;
+	session = slot->table->session;
 
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
@@ -511,7 +516,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		/* Update the slot's sequence and clientid lease timer */
 		++slot->seq_nr;
 		timestamp = slot->renewal_time;
-		clp = res->sr_session->clp;
+		clp = session->clp;
 		do_renew_lease(clp, timestamp);
 		/* Check sequence flags */
 		if (res->sr_status_flags != 0)
@@ -524,7 +529,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 */
 		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
 			__func__,
-			slot - res->sr_session->fc_slot_table.slots,
+			slot - session->fc_slot_table.slots,
 			slot->seq_nr);
 		goto out_retry;
 	default:
@@ -546,7 +551,7 @@ out_retry:
 static int nfs4_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)
 {
-	if (res->sr_session == NULL)
+	if (res->sr_slot == NULL)
 		return 1;
 	return nfs41_sequence_done(task, res);
 }
@@ -591,7 +596,6 @@ static void nfs41_init_sequence(struct nfs4_sequence_args *args,
 	args->sa_cache_this = 0;
 	if (cache_reply)
 		args->sa_cache_this = 1;
-	res->sr_session = NULL;
 	res->sr_slot = NULL;
 }
 
@@ -646,7 +650,6 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
 
-	res->sr_session = session;
 	res->sr_slot = slot;
 	res->sr_status_flags = 0;
 	/*
@@ -5659,9 +5662,18 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
-struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
+struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
+		u32 max_slots, gfp_t gfp_flags)
 {
-	return kmalloc_array(max_slots, sizeof(struct nfs4_slot), gfp_flags);
+	struct nfs4_slot *tbl;
+	u32 i;
+
+	tbl = kmalloc_array(max_slots, sizeof(*tbl), gfp_flags);
+	if (tbl != NULL) {
+		for (i = 0; i < max_slots; i++)
+			tbl[i].table = table;
+	}
+	return tbl;
 }
 
 static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
@@ -5699,7 +5711,7 @@ static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
 
 	/* Does the newly negotiated max_reqs match the existing slot table? */
 	if (max_reqs != tbl->max_slots) {
-		new = nfs4_alloc_slots(max_reqs, GFP_NOFS);
+		new = nfs4_alloc_slots(tbl, max_reqs, GFP_NOFS);
 		if (!new)
 			goto out;
 	}
@@ -5738,11 +5750,13 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	dprintk("--> %s\n", __func__);
 	/* Fore channel */
 	tbl = &ses->fc_slot_table;
+	tbl->session = ses;
 	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
 	if (status) /* -ENOMEM */
 		return status;
 	/* Back channel */
 	tbl = &ses->bc_slot_table;
+	tbl->session = ses;
 	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
 	if (status && tbl->slots == NULL)
 		/* Fore and back channel share a connection so get
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 96fcbb9..9495789 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2033,7 +2033,7 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 		return 0;
 	nfs4_begin_drain_session(clp);
 	fc_tbl = &clp->cl_session->fc_slot_table;
-	new = nfs4_alloc_slots(fc_tbl->target_max_slots, GFP_NOFS);
+	new = nfs4_alloc_slots(fc_tbl, fc_tbl->target_max_slots, GFP_NOFS);
         if (!new)
 		return -ENOMEM;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 672d9b0..4126f05 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5507,12 +5507,13 @@ static int decode_sequence(struct xdr_stream *xdr,
 			   struct rpc_rqst *rqstp)
 {
 #if defined(CONFIG_NFS_V4_1)
+	struct nfs4_session *session;
 	struct nfs4_sessionid id;
 	u32 dummy;
 	int status;
 	__be32 *p;
 
-	if (!res->sr_session)
+	if (res->sr_slot == NULL)
 		return 0;
 
 	status = decode_op_hdr(xdr, OP_SEQUENCE);
@@ -5526,8 +5527,9 @@ static int decode_sequence(struct xdr_stream *xdr,
 	 * sequence number, the server is looney tunes.
 	 */
 	status = -EREMOTEIO;
+	session = res->sr_slot->table->session;
 
-	if (memcmp(id.data, res->sr_session->sess_id.data,
+	if (memcmp(id.data, session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out_err;
@@ -5545,7 +5547,7 @@ static int decode_sequence(struct xdr_stream *xdr,
 	}
 	/* slot id */
 	dummy = be32_to_cpup(p++);
-	if (dummy != res->sr_slot - res->sr_session->fc_slot_table.slots) {
+	if (dummy != res->sr_slot - session->fc_slot_table.slots) {
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 97c8f91..b041287 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -209,6 +209,7 @@ struct nfs_server {
 /* Sessions */
 #define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
 struct nfs4_slot_table {
+	struct nfs4_session *session;		/* Parent session */
 	struct nfs4_slot *slots;		/* seqid per slot */
 	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
 	spinlock_t	slot_tbl_lock;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9cb1c63..0fd88ab 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -187,6 +187,7 @@ struct nfs4_channel_attrs {
 
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
+	struct nfs4_slot_table	*table;
 	unsigned long		renewal_time;
 	u32		 	seq_nr;
 };
@@ -198,7 +199,6 @@ struct nfs4_sequence_args {
 };
 
 struct nfs4_sequence_res {
-	struct nfs4_session	*sr_session;
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 	int			sr_status;	/* sequence operation status */
 	u32			sr_status_flags;
-- 
1.7.11.7

