Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342Ab3GSVD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:03:57 -0400
From: <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC 4/5] NFSD: Defer copying
Date: Fri, 19 Jul 2013 17:03:49 -0400
Message-ID: <1374267830-30154-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Rather than performing the copy right away, schedule it to run later and
reply to the client.  Later, send a callback to notify the client that
the copy has finished.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4callback.c | 136 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c     |  59 +++++++++++++++------
 fs/nfsd/nfs4state.c    |  11 ++++
 fs/nfsd/state.h        |  21 ++++++++
 fs/nfsd/xdr4cb.h       |   9 ++++
 5 files changed, 221 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd1..8f797e1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -52,6 +52,9 @@ enum {
 	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
 	NFSPROC4_CLNT_CB_SEQUENCE,
+
+	/* NFS v4.2 callback */
+	NFSPROC4_CLNT_CB_OFFLOAD,
 };
 
 struct nfs4_cb_compound_hdr {
@@ -110,6 +113,7 @@ enum nfs_cb_opnum4 {
 	OP_CB_WANTS_CANCELLED		= 12,
 	OP_CB_NOTIFY_LOCK		= 13,
 	OP_CB_NOTIFY_DEVICEID		= 14,
+	OP_CB_OFFLOAD			= 15,
 	OP_CB_ILLEGAL			= 10044
 };
 
@@ -469,6 +473,31 @@ out_default:
 	return nfs_cb_stat_to_errno(nfserr);
 }
 
+static void encode_cb_offload4args(struct xdr_stream *xdr,
+				   const struct nfs4_cb_offload *offload,
+				   struct nfs4_cb_compound_hdr *hdr)
+{
+	__be32 *p;
+
+	if (hdr->minorversion < 2)
+		return;
+
+	encode_nfs_cb_opnum4(xdr, OP_CB_OFFLOAD);
+	encode_nfs_fh4(xdr, &offload->co_dst_fh);
+	encode_stateid4(xdr, &offload->co_stid->sc_stateid);
+
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(1);
+	encode_stateid4(xdr, &offload->co_stid->sc_stateid);
+
+	p = xdr_reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
+	p = xdr_encode_hyper(p, offload->co_count);
+	*p++ = cpu_to_be32(offload->co_stable_how);
+	xdr_encode_opaque_fixed(p, offload->co_verifier.data, NFS4_VERIFIER_SIZE);
+
+	hdr->nops++;
+}
+
 /*
  * NFSv4.0 and NFSv4.1 XDR encode functions
  *
@@ -505,6 +534,23 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_cb_nops(&hdr);
 }
 
+/*
+ * CB_OFFLOAD
+ */
+static void nfs4_xdr_enc_cb_offload(struct rpc_rqst *req, struct xdr_stream *xdr,
+				    const struct nfsd4_callback *cb)
+{
+	const struct nfs4_cb_offload *args = cb->cb_op;
+	struct nfs4_cb_compound_hdr hdr = {
+		.ident = cb->cb_clp->cl_cb_ident,
+		.minorversion = cb->cb_minorversion,
+	};
+
+	encode_cb_compound4args(xdr, &hdr);
+	encode_cb_sequence4args(xdr, cb, &hdr);
+	encode_cb_offload4args(xdr, args, &hdr);
+	encode_cb_nops(&hdr);
+}
 
 /*
  * NFSv4.0 and NFSv4.1 XDR decode functions
@@ -552,6 +598,36 @@ out:
 }
 
 /*
+ * CB_OFFLOAD
+ */
+static int nfs4_xdr_dec_cb_offload(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+				   struct nfsd4_callback *cb)
+{
+	struct nfs4_cb_compound_hdr hdr;
+	enum nfsstat4 nfserr;
+	int status;
+
+	status = decode_cb_compound4res(xdr, &hdr);
+	if (unlikely(status))
+		goto out;
+
+	if (cb != NULL) {
+		status = decode_cb_sequence4res(xdr, cb);
+		if (unlikely(status))
+			goto out;
+	}
+
+	status = decode_cb_op_status(xdr, OP_CB_OFFLOAD, &nfserr);
+	if (unlikely(status))
+		goto out;
+	if (unlikely(nfserr != NFS4_OK))
+		status = nfs_cb_stat_to_errno(nfserr);
+
+out:
+	return status;
+}
+
+/*
  * RPC procedure tables
  */
 #define PROC(proc, call, argtype, restype)				\
@@ -568,6 +644,7 @@ out:
 static struct rpc_procinfo nfs4_cb_procedures[] = {
 	PROC(CB_NULL,	NULL,		cb_null,	cb_null),
 	PROC(CB_RECALL,	COMPOUND,	cb_recall,	cb_recall),
+	PROC(CB_OFFLOAD, COMPOUND,	cb_offload,	cb_offload),
 };
 
 static struct rpc_version nfs_cb_version4 = {
@@ -1017,6 +1094,11 @@ void nfsd4_init_callback(struct nfsd4_callback *cb)
 	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
 }
 
+void nfsd4_init_delayed_callback(struct nfsd4_callback *cb)
+{
+	INIT_DELAYED_WORK(&cb->cb_delay, nfsd4_do_callback_rpc);
+}
+
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
@@ -1036,3 +1118,57 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 
 	run_nfsd4_cb(&dp->dl_recall);
 }
+
+static void nfsd4_cb_offload_done(struct rpc_task *task, void *calldata)
+{
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_client *clp = cb->cb_clp;
+	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
+
+	nfsd4_cb_done(task, calldata);
+
+	if (current_rpc_client != task->tk_client)
+		return;
+
+	if (cb->cb_done)
+		return;
+
+	if (task->tk_status != 0)
+		nfsd4_mark_cb_down(clp, task->tk_status);
+	cb->cb_done = true;
+}
+
+static void nfsd4_cb_offload_release(void *calldata)
+{
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_cb_offload *offload = container_of(cb, struct nfs4_cb_offload, co_callback);
+
+	if (cb->cb_done) {
+		nfs4_free_offload_stateid(offload->co_stid);
+		kfree(offload);
+	}
+}
+
+static const struct rpc_call_ops nfsd4_cb_offload_ops = {
+	.rpc_call_prepare = nfsd4_cb_prepare,
+	.rpc_call_done    = nfsd4_cb_offload_done,
+	.rpc_release      = nfsd4_cb_offload_release,
+};
+
+void nfsd4_cb_offload(struct nfs4_cb_offload *offload)
+{
+	struct nfsd4_callback *cb = &offload->co_callback;
+
+	cb->cb_op = offload;
+	cb->cb_clp = offload->co_stid->sc_client;
+	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_OFFLOAD];
+	cb->cb_msg.rpc_argp = cb;
+	cb->cb_msg.rpc_resp = cb;
+
+	cb->cb_ops = &nfsd4_cb_offload_ops;
+
+	INIT_LIST_HEAD(&cb->cb_per_client);
+	cb->cb_done = true;
+
+	run_nfsd4_cb(cb);
+}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d4584ea..66a787f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,6 +35,7 @@
 #include <linux/file.h>
 #include <linux/slab.h>
 
+#include "state.h"
 #include "idmap.h"
 #include "cache.h"
 #include "xdr4.h"
@@ -1062,29 +1063,57 @@ out:
 	return status;
 }
 
+static void
+nfsd4_copy_async(struct work_struct *w)
+{
+	__be32 status;
+	struct nfs4_cb_offload *offload;
+
+	offload = container_of(w, struct nfs4_cb_offload, co_work);
+	status  = nfsd_copy_range(offload->co_src_file, offload->co_src_pos,
+				  offload->co_dst_file, offload->co_dst_pos,
+				  offload->co_count);
+
+	if (status == nfs_ok) {
+		offload->co_stable_how = NFS_FILE_SYNC;
+		gen_boot_verifier(&offload->co_verifier, offload->co_net);
+		fput(offload->co_src_file);
+		fput(offload->co_dst_file);
+	}
+	nfsd4_cb_offload(offload);
+}
+
 static __be32
 nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_copy *copy)
 {
-	__be32 status;
 	struct file *src = NULL, *dst = NULL;
+	struct nfs4_cb_offload *offload;
 
-	status = nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst);
-	if (status)
-		return status;
-
-	status = nfsd_copy_range(src, copy->cp_src_pos,
-				 dst, copy->cp_dst_pos,
-				 copy->cp_count);
+	if (nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst))
+		return nfserr_jukebox;
 
-	if (status == nfs_ok) {
-		copy->cp_res.wr_stateid = NULL;
-		copy->cp_res.wr_bytes_written = copy->cp_count;
-		copy->cp_res.wr_stable_how = NFS_FILE_SYNC;
-		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
-	}
+	offload = kmalloc(sizeof(struct nfs4_cb_offload), GFP_KERNEL);
+	if (!offload)
+		return nfserr_jukebox;
 
-	return status;
+	offload->co_src_file = get_file(src);
+	offload->co_dst_file = get_file(dst);
+	offload->co_src_pos  = copy->cp_src_pos;
+	offload->co_dst_pos  = copy->cp_dst_pos;
+	offload->co_count    = copy->cp_count;
+	offload->co_stid     = nfs4_alloc_offload_stateid(cstate->session->se_client);
+	offload->co_net      = SVC_NET(rqstp);
+	INIT_WORK(&offload->co_work, nfsd4_copy_async);
+	nfsd4_init_callback(&offload->co_callback);
+	memcpy(&offload->co_dst_fh, &cstate->current_fh, sizeof(struct knfsd_fh));
+
+	copy->cp_res.wr_stateid = &offload->co_stid->sc_stateid;
+	copy->cp_res.wr_bytes_written = 0;
+	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
+
+	schedule_work(&offload->co_work);
+	return nfs_ok;
 }
 
 /* This routine never returns NFS_OK!  If there are no other errors, it
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c4e270e..582edb5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -364,6 +364,11 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
 }
 
+struct nfs4_stid *nfs4_alloc_offload_stateid(struct nfs4_client *clp)
+{
+	return nfs4_alloc_stid(clp, stateid_slab);
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
 {
@@ -617,6 +622,12 @@ static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 	kmem_cache_free(stateid_slab, stp);
 }
 
+void nfs4_free_offload_stateid(struct nfs4_stid *stid)
+{
+	remove_stid(stid);
+	kmem_cache_free(stateid_slab, stid);
+}
+
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct file *file;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2478805..56682fb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -70,6 +70,7 @@ struct nfsd4_callback {
 	struct rpc_message cb_msg;
 	const struct rpc_call_ops *cb_ops;
 	struct work_struct cb_work;
+	struct delayed_work cb_delay;
 	bool cb_done;
 };
 
@@ -101,6 +102,22 @@ struct nfs4_delegation {
 	struct nfsd4_callback	dl_recall;
 };
 
+struct nfs4_cb_offload {
+	struct file	*co_src_file;
+	struct file	*co_dst_file;
+	u64		co_src_pos;
+	u64		co_dst_pos;
+	u64		co_count;
+	u32		co_stable_how;
+	struct knfsd_fh	co_dst_fh;
+	nfs4_verifier	co_verifier;
+	struct net	*co_net;
+
+	struct nfs4_stid		*co_stid;
+	struct work_struct		co_work;
+	struct nfsd4_callback		co_callback;
+};
+
 /* client delegation callback info */
 struct nfs4_cb_conn {
 	/* SETCLIENTID info */
@@ -468,10 +485,12 @@ extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
 extern void nfsd4_init_callback(struct nfsd4_callback *);
+extern void nfsd4_init_delayed_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern void nfsd4_cb_offload(struct nfs4_cb_offload *);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
@@ -480,6 +499,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
+extern struct nfs4_stid *nfs4_alloc_offload_stateid(struct nfs4_client *);
+extern void nfs4_free_offload_stateid(struct nfs4_stid *);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index c5c55df..75b0ef7 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -21,3 +21,12 @@
 #define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
+
+#define NFS4_enc_cb_offload_sz		(cb_compound_enc_hdr_sz +      \
+					 cb_sequence_enc_sz +          \
+					 1 + enc_stateid_sz + 2 + 1 +  \
+					 XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+
+#define NFS4_dec_cb_offload_sz		(cb_compound_dec_hdr_sz +  \
+					 cb_sequence_dec_sz +      \
+					 op_dec_sz)
-- 
1.8.3.3

