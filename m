From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 46/67] nfs41: create_session operation
Date: Thu,  2 Apr 2009 16:57:20 +0300
Message-ID: <1238680640-14841-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31461 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758330AbZDBN50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:57:26 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the create_session operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Set the real fore channel max operations to preserve server resources.
Note: If the server returns < NFS4_MAX_OPS, the client will very soon
get an NFS4ERR_TOO_MANY_OPS. A later patch will handle this.

Set the max_rqst_sz and max_resp_sz to PAGE_SIZE - we preallocate the buffers.

Set the back channel max_resp_sz_cached to zero to force the client to
always set csa_cachethis to FALSE because the current implementation
of the back channel DRC only supports caching the CB_SEQUENCE operation.

The client back channel server supports one slot, and desires 2 operations
per compound.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove extraneous rpc_clnt pointer]
Use the struct nfs_client cl_rpcclient.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_init_channel_attrs, just use nfs41_create_session_args]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use rsize and wsize for session channel attributes]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: set channel max operations]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: set back channel attributes]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: obliterate nfs4_adjust_channel_attrs]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: have create_session work on nfs_client]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: move CONFIG_NFS_V4_1 endif]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: pass *session in seq_args and seq_res]
[moved nfs4_init_slot_table definition here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use kcalloc to allocate slot table]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |  172 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |  189 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |   10 +++
 include/linux/nfs_xdr.h |   12 +++
 4 files changed, 383 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 926a9d6..4381939 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -54,6 +54,7 @@
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
+#include "callback.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -4286,6 +4287,50 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
+/*
+ * Initialize slot table
+ */
+static int nfs4_init_slot_table(struct nfs4_session *session)
+{
+	struct nfs4_slot_table *tbl = &session->fc_slot_table;
+	int i, max_slots = session->fc_attrs.max_reqs;
+	struct nfs4_slot *slot;
+	int ret = -ENOMEM;
+
+	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
+
+	dprintk("--> %s: max_reqs=%u\n", __func__,
+		session->fc_attrs.max_reqs);
+
+	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_KERNEL);
+	if (!slot)
+		goto out;
+	for (i = 0; i < max_slots; ++i)
+		slot[i].seq_nr = 1;
+	ret = 0;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->slots != NULL) {
+		spin_unlock(&tbl->slot_tbl_lock);
+		dprintk("%s: slot table already initialized. tbl=%p slots=%p\n",
+			__func__, tbl, tbl->slots);
+		WARN_ON(1);
+		goto out_free;
+	}
+	tbl->max_slots = max_slots;
+	tbl->slots = slot;
+	tbl->highest_used_slotid = -1;  /* no slot is currently used */
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
+		tbl, tbl->slots, tbl->max_slots);
+out:
+	dprintk("<-- %s: return %d\n", __func__, ret);
+	return ret;
+out_free:
+	kfree(slot);
+	goto out;
+}
+
 /* Destroy the slot table */
 static void nfs4_destroy_slot_table(struct nfs4_session *session)
 {
@@ -4317,6 +4362,133 @@ void nfs4_destroy_session(struct nfs4_session *session)
 	kfree(session);
 }
 
+/*
+ * Initialize the values to be used by the client in CREATE_SESSION
+ * If nfs4_init_session set the fore channel request and response sizes,
+ * use them.
+ *
+ * Set the back channel max_resp_sz_cached to zero to force the client to
+ * always set csa_cachethis to FALSE because the current implementation
+ * of the back channel DRC only supports caching the CB_SEQUENCE operation.
+ */
+static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
+{
+	struct nfs4_session *session = args->client->cl_session;
+	unsigned int mxrqst_sz = session->fc_attrs.max_rqst_sz,
+		     mxresp_sz = session->fc_attrs.max_resp_sz;
+
+	if (mxrqst_sz == 0)
+		mxrqst_sz = NFS_MAX_FILE_IO_SIZE;
+	if (mxresp_sz == 0)
+		mxresp_sz = NFS_MAX_FILE_IO_SIZE;
+	/* Fore channel attributes */
+	args->fc_attrs.headerpadsz = 0;
+	args->fc_attrs.max_rqst_sz = mxrqst_sz;
+	args->fc_attrs.max_resp_sz = mxresp_sz;
+	args->fc_attrs.max_resp_sz_cached = mxresp_sz;
+	args->fc_attrs.max_ops = NFS4_MAX_OPS;
+	args->fc_attrs.max_reqs = session->clp->cl_rpcclient->cl_xprt->max_reqs;
+
+	dprintk("%s: Fore Channel : max_rqst_sz=%u max_resp_sz=%u "
+		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
+		__func__,
+		args->fc_attrs.max_rqst_sz, args->fc_attrs.max_resp_sz,
+		args->fc_attrs.max_resp_sz_cached, args->fc_attrs.max_ops,
+		args->fc_attrs.max_reqs);
+
+	/* Back channel attributes */
+	args->bc_attrs.headerpadsz = 0;
+	args->bc_attrs.max_rqst_sz = PAGE_SIZE;
+	args->bc_attrs.max_resp_sz = PAGE_SIZE;
+	args->bc_attrs.max_resp_sz_cached = 0;
+	args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
+	args->bc_attrs.max_reqs = 1;
+
+	dprintk("%s: Back Channel : max_rqst_sz=%u max_resp_sz=%u "
+		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
+		__func__,
+		args->bc_attrs.max_rqst_sz, args->bc_attrs.max_resp_sz,
+		args->bc_attrs.max_resp_sz_cached, args->bc_attrs.max_ops,
+		args->bc_attrs.max_reqs);
+}
+
+static int _nfs4_proc_create_session(struct nfs_client *clp)
+{
+	struct nfs4_session *session = clp->cl_session;
+	struct nfs41_create_session_args args = {
+		.client = clp,
+		.cb_program = NFS4_CALLBACK,
+	};
+	struct nfs41_create_session_res res = {
+		.client = clp,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE_SESSION],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	nfs4_init_channel_attrs(&args);
+	args.flags = (SESSION4_PERSIST);
+
+	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
+
+	/* Set the negotiated values in the session's channel_attrs struct */
+
+	if (!status) {
+		/* Increment the clientid slot sequence id */
+		clp->cl_seqid++;
+	}
+
+	return status;
+}
+
+/*
+ * Issues a CREATE_SESSION operation to the server.
+ * It is the responsibility of the caller to verify the session is
+ * expired before calling this routine.
+ */
+int nfs4_proc_create_session(struct nfs_client *clp)
+{
+	int status;
+	unsigned *ptr;
+	struct nfs_fsinfo fsinfo;
+	struct nfs4_session *session = clp->cl_session;
+
+	dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
+
+	status = _nfs4_proc_create_session(clp);
+	if (status)
+		goto out;
+
+	/* Init the fore channel */
+	status = nfs4_init_slot_table(session);
+	dprintk("fore channel slot table initialization returned %d\n", status);
+	if (status)
+		goto out;
+
+	ptr = (unsigned *)&session->sess_id.data[0];
+	dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
+		clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	/* Get the lease time */
+	status = nfs4_proc_get_lease_time(clp, &fsinfo);
+	if (status == 0) {
+		/* Update lease time and schedule renewal */
+		spin_lock(&clp->cl_lock);
+		clp->cl_lease_time = fsinfo.lease_time * HZ;
+		clp->cl_last_renewal = jiffies;
+		clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		spin_unlock(&clp->cl_lock);
+
+		nfs4_schedule_state_renewal(clp);
+	}
+out:
+	dprintk("<-- %s\n", __func__);
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3f88a20..11c210f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -246,6 +246,8 @@ static int nfs4_stat_to_errno(int);
 				(0)
 
 #if defined(CONFIG_NFS_V4_1)
+#define NFS4_MAX_MACHINE_NAME_LEN (64)
+
 #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
 				encode_verifier_maxsz + \
 				1 /* co_ownerid.len */ + \
@@ -267,6 +269,31 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
 				1 /* eir_server_impl_id array length */ + \
 				0 /* ignored eir_server_impl_id contents */)
+#define encode_channel_attrs_maxsz  (6 + 1 /* ca_rdma_ird.len (0) */)
+#define decode_channel_attrs_maxsz  (6 + \
+				     1 /* ca_rdma_ird.len */ + \
+				     1 /* ca_rdma_ird */)
+#define encode_create_session_maxsz  (op_encode_hdr_maxsz + \
+				     2 /* csa_clientid */ + \
+				     1 /* csa_sequence */ + \
+				     1 /* csa_flags */ + \
+				     encode_channel_attrs_maxsz + \
+				     encode_channel_attrs_maxsz + \
+				     1 /* csa_cb_program */ + \
+				     1 /* csa_sec_parms.len (1) */ + \
+				     1 /* cb_secflavor (AUTH_SYS) */ + \
+				     1 /* stamp */ + \
+				     1 /* machinename.len */ + \
+				     XDR_QUADLEN(NFS4_MAX_MACHINE_NAME_LEN) + \
+				     1 /* uid */ + \
+				     1 /* gid */ + \
+				     1 /* gids.len (0) */)
+#define decode_create_session_maxsz  (op_decode_hdr_maxsz +	\
+				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				     1 /* csr_sequence */ + \
+				     1 /* csr_flags */ + \
+				     decode_channel_attrs_maxsz + \
+				     decode_channel_attrs_maxsz)
 #define encode_sequence_maxsz	0 /* stub */
 #define decode_sequence_maxsz	0 /* stub */
 #else /* CONFIG_NFS_V4_1 */
@@ -622,6 +649,12 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_exchange_id_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_exchange_id_maxsz)
+#define NFS4_enc_create_session_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_create_session_maxsz)
+#define NFS4_dec_create_session_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_create_session_maxsz)
 #define NFS4_enc_get_lease_time_sz	(compound_encode_hdr_maxsz + \
 					 encode_sequence_maxsz + \
 					 encode_putrootfh_maxsz + \
@@ -712,6 +745,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 
 static void encode_nops(struct compound_hdr *hdr)
 {
+	BUG_ON(hdr->nops > NFS4_MAX_OPS);
 	*hdr->nops_p = htonl(hdr->nops);
 }
 
@@ -1513,6 +1547,68 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_exchange_id_maxsz;
 }
+
+static void encode_create_session(struct xdr_stream *xdr,
+				  struct nfs41_create_session_args *args,
+				  struct compound_hdr *hdr)
+{
+	uint32_t *p;
+	char machine_name[NFS4_MAX_MACHINE_NAME_LEN];
+	uint32_t len;
+	struct nfs_client *clp = args->client;
+
+	RESERVE_SPACE(4);
+	WRITE32(OP_CREATE_SESSION);
+
+	RESERVE_SPACE(8);
+	WRITE64(clp->cl_ex_clid);
+
+	RESERVE_SPACE(8);
+	WRITE32(clp->cl_seqid);			/*Sequence id */
+	WRITE32(args->flags);			/*flags */
+
+	RESERVE_SPACE(2*28);			/* 2 channel_attrs */
+	/* Fore Channel */
+	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
+	WRITE32(args->fc_attrs.max_rqst_sz);	/* max req size */
+	WRITE32(args->fc_attrs.max_resp_sz);	/* max resp size */
+	WRITE32(args->fc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	WRITE32(args->fc_attrs.max_ops);	/* max operations */
+	WRITE32(args->fc_attrs.max_reqs);	/* max requests */
+	WRITE32(0);				/* rdmachannel_attrs */
+
+	/* Back Channel */
+	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
+	WRITE32(args->bc_attrs.max_rqst_sz);	/* max req size */
+	WRITE32(args->bc_attrs.max_resp_sz);	/* max resp size */
+	WRITE32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	WRITE32(args->bc_attrs.max_ops);	/* max operations */
+	WRITE32(args->bc_attrs.max_reqs);	/* max requests */
+	WRITE32(0);				/* rdmachannel_attrs */
+
+	RESERVE_SPACE(4);
+	WRITE32(args->cb_program);		/* cb_program */
+
+	RESERVE_SPACE(4);			/* # of security flavors */
+	WRITE32(1);
+
+	RESERVE_SPACE(4);
+	WRITE32(RPC_AUTH_UNIX);			/* auth_sys */
+
+	/* authsys_parms rfc1831 */
+	RESERVE_SPACE(4);
+	WRITE32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	len = scnprintf(machine_name, sizeof(machine_name), "%s",
+			clp->cl_ipaddr);
+	RESERVE_SPACE(16 + len);
+	WRITE32(len);
+	WRITEMEM(machine_name, len);
+	WRITE32(0);				/* UID */
+	WRITE32(0);				/* GID */
+	WRITE32(0);				/* No more gids */
+	hdr->nops++;
+	hdr->replen += decode_create_session_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void encode_sequence(struct xdr_stream *xdr,
@@ -2241,6 +2337,24 @@ static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a CREATE_SESSION request
+ */
+static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
+				       struct nfs41_create_session_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = args->client->cl_minorversion,
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_create_session(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4023,6 +4137,63 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 
 	return 0;
 }
+
+static int decode_create_session(struct xdr_stream *xdr,
+				 struct nfs41_create_session_res *res)
+{
+	uint32_t *p;
+	int status;
+	u32 nr_attrs;
+	struct nfs_client *clp = res->client;
+	struct nfs4_session *session = clp->cl_session;
+
+	status = decode_op_hdr(xdr, OP_CREATE_SESSION);
+
+	if (status)
+		return status;
+
+	/* sessionid */
+	READ_BUF(NFS4_MAX_SESSIONID_LEN);
+	COPYMEM(&session->sess_id, NFS4_MAX_SESSIONID_LEN);
+
+	/* seqid, flags */
+	READ_BUF(8);
+	READ32(clp->cl_seqid);
+	READ32(session->flags);
+
+	/* Channel attributes */
+	/* fore channel */
+	READ_BUF(24);
+	READ32(session->fc_attrs.headerpadsz);
+	READ32(session->fc_attrs.max_rqst_sz);
+	READ32(session->fc_attrs.max_resp_sz);
+	READ32(session->fc_attrs.max_resp_sz_cached);
+	READ32(session->fc_attrs.max_ops);
+	READ32(session->fc_attrs.max_reqs);
+	READ_BUF(4);
+	READ32(nr_attrs);
+	if (nr_attrs == 1) {
+		READ_BUF(4);
+		p++; /* skip rdma_attrs */
+	}
+
+	/* back channel */
+	READ_BUF(24);
+	READ32(session->bc_attrs.headerpadsz);
+	READ32(session->bc_attrs.max_rqst_sz);
+	READ32(session->bc_attrs.max_resp_sz);
+	READ32(session->bc_attrs.max_resp_sz_cached);
+	READ32(session->bc_attrs.max_ops);
+	READ32(session->bc_attrs.max_reqs);
+	READ_BUF(4);
+	READ32(nr_attrs);
+	if (nr_attrs == 1) {
+		READ_BUF(4);
+		p++; /* skip rdma_attrs */
+	}
+
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static int decode_sequence(struct xdr_stream *xdr,
@@ -4941,6 +5112,23 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a CREATE_SESSION request
+ */
+static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
+				       struct nfs41_create_session_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_create_session(&xdr, res);
+	return status;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
@@ -5133,6 +5321,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+  PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7dc6fa0..d2d6a1b 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -131,6 +131,16 @@
 
 #define NFS4_MAX_UINT64	(~(u64)0)
 
+/* An NFS4 sessions server must support at least NFS4_MAX_OPS operations.
+ * If a compound requires more operations, adjust NFS4_MAX_OPS accordingly.
+ */
+#define NFS4_MAX_OPS   8
+
+/* Our NFS4 client back channel server only wants the cb_sequene and the
+ * actual operation per compound
+ */
+#define NFS4_MAX_BACK_CHANNEL_OPS 2
+
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
 	NFS4_ACL_WHO_OWNER,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6c75c63..d8bc445 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -929,6 +929,18 @@ struct nfs41_exchange_id_res {
 	struct server_scope		server_scope;
 	struct nfs_impl_id4		impl_id;
 };
+
+struct nfs41_create_session_args {
+	struct nfs_client	       *client;
+	uint32_t			flags;
+	uint32_t			cb_program;
+	struct nfs4_channel_attrs	fc_attrs;	/* Fore Channel */
+	struct nfs4_channel_attrs	bc_attrs;	/* Back Channel */
+};
+
+struct nfs41_create_session_res {
+	struct nfs_client	       *client;
+};
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
-- 
1.6.2.1

