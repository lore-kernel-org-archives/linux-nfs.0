Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60912 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab3J1O5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 10:57:36 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [RFC 5/4] NFSD: Add basic CB_OFFLOAD support
Date: Mon, 28 Oct 2013 10:57:27 -0400
Message-ID: <1382972247-1108-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds basic offload support to the WRITE_PLUS operation.
Since I don't implement OFFLOAD_ABORT, OFFLOAD_REVOKE or OFFLOAD_STATUS
this patch is NOT spec compliant and should not be applied without
further work.

I'm including this patch to show how I handled offloading to test client
code.
---
 fs/nfsd/nfs4callback.c | 132 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c     |  56 ++++++++++++++++++---
 fs/nfsd/nfs4state.c    |  11 +++++
 fs/nfsd/state.h        |   4 ++
 fs/nfsd/xdr4.h         |  14 ++++++
 fs/nfsd/xdr4cb.h       |   9 ++++
 6 files changed, 219 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd1..1f6c150 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -35,6 +35,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/slab.h>
 #include "nfsd.h"
+#include "xdr4.h"
 #include "state.h"
 #include "netns.h"
 #include "xdr4cb.h"
@@ -52,6 +53,9 @@ enum {
 	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
 	NFSPROC4_CLNT_CB_SEQUENCE,
+
+	/* NFS v4.2 callback */
+	NFSPROC4_CLNT_CB_OFFLOAD,
 };
 
 struct nfs4_cb_compound_hdr {
@@ -110,6 +114,7 @@ enum nfs_cb_opnum4 {
 	OP_CB_WANTS_CANCELLED		= 12,
 	OP_CB_NOTIFY_LOCK		= 13,
 	OP_CB_NOTIFY_DEVICEID		= 14,
+	OP_CB_OFFLOAD			= 15,
 	OP_CB_ILLEGAL			= 10044
 };
 
@@ -469,6 +474,31 @@ out_default:
 	return nfs_cb_stat_to_errno(nfserr);
 }
 
+static void encode_cb_offload4args(struct xdr_stream *xdr,
+				   const struct nfsd4_cb_offload *offload,
+				   struct nfs4_cb_compound_hdr *hdr)
+{
+	__be32 *p;
+
+	if (hdr->minorversion < 2)
+		return;
+
+	encode_nfs_cb_opnum4(xdr, OP_CB_OFFLOAD);
+	encode_nfs_fh4(xdr, &offload->co_fh);
+	encode_stateid4(xdr, &offload->co_res.wr_stid->sc_stateid);
+
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(1);
+	encode_stateid4(xdr, &offload->co_res.wr_stid->sc_stateid);
+
+	p = xdr_reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
+	p = xdr_encode_hyper(p, offload->co_res.wr_bytes_written);
+	*p++ = cpu_to_be32(offload->co_res.wr_stable_how);
+	xdr_encode_opaque_fixed(p, offload->co_res.wr_verifier.data, NFS4_VERIFIER_SIZE);
+
+	hdr->nops++;
+}
+
 /*
  * NFSv4.0 and NFSv4.1 XDR encode functions
  *
@@ -505,6 +535,23 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_cb_nops(&hdr);
 }
 
+/*
+ * CB_OFFLOAD
+ */
+static void nfs4_xdr_enc_cb_offload(struct rpc_rqst *req, struct xdr_stream *xdr,
+				    const struct nfsd4_callback *cb)
+{
+	const struct nfsd4_cb_offload *args = cb->cb_op;
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
@@ -552,6 +599,36 @@ out:
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
@@ -568,6 +645,7 @@ out:
 static struct rpc_procinfo nfs4_cb_procedures[] = {
 	PROC(CB_NULL,	NULL,		cb_null,	cb_null),
 	PROC(CB_RECALL,	COMPOUND,	cb_recall,	cb_recall),
+	PROC(CB_OFFLOAD, COMPOUND,	cb_offload,	cb_offload),
 };
 
 static struct rpc_version nfs_cb_version4 = {
@@ -1036,3 +1114,57 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 
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
+	struct nfsd4_cb_offload *offload = container_of(cb, struct nfsd4_cb_offload, co_callback);
+
+	if (cb->cb_done) {
+		nfs4_free_offload_stateid(offload->co_res.wr_stid);
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
+void nfsd4_cb_offload(struct nfsd4_cb_offload *offload)
+{
+	struct nfsd4_callback *cb = &offload->co_callback;
+
+	cb->cb_op = offload;
+	cb->cb_clp = offload->co_res.wr_stid->sc_client;
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
index bc45ed2..d56f7fe 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1028,22 +1028,64 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-static __be32
-nfsd4_write_plus_hole(struct file *file, struct nfsd4_write_plus *writeplus,
-		      struct net *net)
+static void
+nfsd4_offload_work(struct nfsd4_cb_offload *offload,
+		   struct nfsd4_compound_state *cstate,
+		   struct nfsd42_write_res *write_res,
+		   void (*offload_func)(struct work_struct *))
+{
+	offload->co_res.wr_stid = nfs4_alloc_offload_stateid(cstate->session->se_client);
+	memcpy(&offload->co_fh, &cstate->current_fh, sizeof(struct knfsd_fh));
+
+	write_res->wr_stid = offload->co_res.wr_stid;
+	write_res->wr_bytes_written = 0;
+	write_res->wr_stable_how = NFS_UNSTABLE;
+
+	nfsd4_init_callback(&offload->co_callback);
+	INIT_WORK(&offload->co_work, offload_func);
+	schedule_work(&offload->co_work);
+}
+
+static void
+nfsd4_write_plus_hole_async(struct work_struct *work)
 {
+	struct nfsd4_cb_offload *offload;
+	struct nfsd4_write_plus *writeplus;
 	__be32 status;
 
-	status = nfsd4_vfs_fallocate(file, writeplus->wp_allocated,
+	offload = container_of(work, struct nfsd4_cb_offload, co_work);
+	writeplus = &offload->co_u.write_plus;
+
+	status = nfsd4_vfs_fallocate(offload->co_file, writeplus->wp_allocated,
 				writeplus->wp_offset, writeplus->wp_length);
 	if (status == nfs_ok) {
 		writeplus->wp_res.wr_stid = NULL;
 		writeplus->wp_res.wr_bytes_written = writeplus->wp_length;
 		writeplus->wp_res.wr_stable_how = NFS_FILE_SYNC;
-		gen_boot_verifier(&writeplus->wp_res.wr_verifier, net);
+		gen_boot_verifier(&writeplus->wp_res.wr_verifier, offload->co_net);
 	}
 
-	return status;
+	fput(offload->co_file);
+	nfsd4_cb_offload(offload);
+}
+
+static __be32
+nfsd4_write_plus_hole(struct file *file, struct nfsd4_write_plus *writeplus,
+		      struct nfsd4_compound_state *cstate, struct net *net)
+{
+	struct nfsd4_cb_offload *offload;
+
+	offload = kmalloc(sizeof(struct nfsd4_cb_offload), GFP_KERNEL);
+	if (!offload)
+		return nfserrno(PTR_ERR(offload));
+
+	memcpy(&offload->co_u.write_plus, writeplus, sizeof(struct nfsd4_write_plus));
+	offload->co_file = get_file(file);
+	offload->co_net  = net;
+
+	nfsd4_offload_work(offload, cstate, &writeplus->wp_res, nfsd4_write_plus_hole_async);
+
+	return 0;
 }
 
 static __be32
@@ -1060,7 +1102,7 @@ nfsd4_write_plus(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 
 	if (writeplus->wp_data_content == NFS4_CONTENT_HOLE)
-		return nfsd4_write_plus_hole(file, writeplus, net);
+		return nfsd4_write_plus_hole(file, writeplus, cstate, net);
 	return nfserr_union_notsupp;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0874998..6342167 100644
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
@@ -613,6 +618,12 @@ static void free_generic_stateid(struct nfs4_ol_stateid *stp)
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
index 424d8f5..a40d29a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -452,6 +452,7 @@ static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
 #define WR_STATE	        0x00000020
 
 struct nfsd4_compound_state;
+struct nfsd4_cb_offload;
 struct nfsd_net;
 
 extern __be32 nfs4_preprocess_stateid_op(struct net *net,
@@ -472,6 +473,7 @@ extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern void nfsd4_cb_offload(struct nfsd4_cb_offload *);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
@@ -480,6 +482,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
+extern struct nfs4_stid *nfs4_alloc_offload_stateid(struct nfs4_client *);
+extern void nfs4_free_offload_stateid(struct nfs4_stid *);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ae9debc..24e2c07 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -451,6 +451,20 @@ struct nfsd4_write_plus {
 	struct nfsd42_write_res	wp_res;
 };
 
+struct nfsd4_cb_offload {
+	union {
+		struct nfsd4_write_plus write_plus;
+	} co_u;
+
+	struct knfsd_fh		co_fh;
+	struct file		*co_file;
+	struct net		*co_net;
+
+	struct nfsd42_write_res	co_res;
+	struct work_struct	co_work;
+	struct nfsd4_callback	co_callback;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
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
1.8.4.1

