From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 34/85] nfs41: exchange_id operation
Date: Mon, 10 Nov 2008 22:24:10 +0200
Message-ID: <1226348650-8356-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48804 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbYKJUYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:19 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the exchange_id operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Unlike NFSv4.0, NFSv4.1 requires machine credentials. RPC_AUTH_GSS machine
credentials will be passed into the kernel at mount time to be available for
the exchange_id operation.

RPC_AUTH_UNIX root mounts can use the UNIX root credential. Store the root
credential in the nfs_client struct.

Without a credential, NFSv4.1 state renewal fails.

nfs41: establish clientid via exchange id only if cred != NULL

>From 2.6.26 reclaimer() uses machine cred for setting up the client id
therefore it is never expected to be NULL.

Note: NFS4_OPAQUE_LIMIT moved from include/linux/nfsd/state.h
to include/linux/nfs4.h since it's now used also for client side
exchange_id xdr data type.

Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c          |   63 +++++++++++++++++++-
 fs/nfs/nfs4xdr.c           |  143 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h       |    1 +
 include/linux/nfs_fs_sb.h  |    6 ++
 include/linux/nfs_xdr.h    |   42 +++++++++++++
 include/linux/nfsd/state.h |    1 -
 6 files changed, 254 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 19ed79c..d2e11c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -48,6 +48,7 @@
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/module.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -4175,9 +4176,69 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 }
 
 #ifdef CONFIG_NFS_V4_1
+/*
+ * nfs4_proc_exchange_id()
+ *
+ * Since the clientid has expired, all compounds using sessions
+ * associated with the stale clientid will be returning
+ * NFS4ERR_BADSESSION in the sequence operation, and will therefore
+ * be in some phase of session reset.
+ */
 static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 {
-	return -1;	/* stub */
+	nfs4_verifier verifier;
+	struct nfs41_exchange_id_args args = {
+		.flags = clp->cl_exchange_flags,
+	};
+	struct nfs41_exchange_id_res res = {
+		.client = clp,
+	};
+	int status;
+	int loop = 0;
+	struct rpc_message msg = {
+		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_EXCHANGE_ID),
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+		.rpc_cred = cred,
+	};
+	__be32 *p;
+
+	dprintk("--> %s\n", __func__);
+	BUG_ON(clp == NULL);
+	p = (u32 *)verifier.data;
+	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
+	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
+	args.verifier = &verifier;
+
+	while (1) {
+		args.id_len = scnprintf(args.id, sizeof(args.id),
+					"%s/%s %u",
+					clp->cl_ipaddr,
+					rpc_peeraddr2str(clp->cl_rpcclient,
+							 RPC_DISPLAY_ADDR),
+					clp->cl_id_uniquifier);
+
+		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+
+		if (status != NFS4ERR_CLID_INUSE)
+			break;
+
+		if (signalled())
+			break;
+
+		/* Andy Adamson <andros at netapp.com>: Waiting a lease period
+		 * allows the server to throw away a clientid previously
+		 * established by this client. Of course, it doesn't help when
+		 * the conflicting clientid was established by another client.
+		 */
+		if (loop++ & 1)
+			ssleep(clp->cl_lease_time + 1);
+		else if (++clp->cl_id_uniquifier == 0)
+			break;
+	}
+
+	dprintk("<-- %s status= %d\n", __func__, status);
+	return status;
 }
 
 /*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d3da7a5..31ca211 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -242,6 +242,27 @@ static int nfs4_stat_to_errno(int);
 				(0)
 
 #if defined(CONFIG_NFS_V4_1)
+#define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
+				encode_verifier_maxsz + \
+				1 /* co_ownerid.len */ + \
+				XDR_QUADLEN(NFS4_EXCHANGE_ID_LEN) + \
+				1 /* flags */ + \
+				1 /* spa_how */ + \
+				0 /* SP4_NONE (for now) */ + \
+				1 /* zero implemetation id array */)
+#define decode_exchange_id_maxsz (op_decode_hdr_maxsz + \
+				2 /* eir_clientid */ + \
+				1 /* eir_sequenceid */ + \
+				1 /* eir_flags */ + \
+				1 /* spr_how */ + \
+				0 /* SP4_NONE (for now) */ + \
+				2 /* eir_server_owner.so_minor_id */ + \
+				/* eir_server_owner.so_major_id<> */ \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				/* eir_server_scope<> */ \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				1 /* eir_server_impl_id array length */ + \
+				0 /* ignored eir_server_impl_id contents */)
 #define encode_sequence_maxsz	0 /* stub */
 #define decode_sequence_maxsz	0 /* stub */
 #else /* CONFIG_NFS_V4_1 */
@@ -590,6 +611,14 @@ static int nfs4_stat_to_errno(int);
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
+#if defined(CONFIG_NFS_V4_1)
+#define NFS4_enc_exchange_id_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_exchange_id_maxsz)
+#define NFS4_dec_exchange_id_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_exchange_id_maxsz)
+#endif /* CONFIG_NFS_V4_1 */
 
 static struct {
 	unsigned int	mode;
@@ -1542,6 +1571,28 @@ encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid,
 
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
+static int encode_exchange_id(struct xdr_stream *xdr,
+			      struct nfs41_exchange_id_args *args,
+			      struct compound_hdr *hdr)
+{
+
+	uint32_t *p;
+
+	RESERVE_SPACE(4 + sizeof(args->verifier->data));
+	WRITE32(OP_EXCHANGE_ID);
+	WRITEMEM(args->verifier->data, sizeof(args->verifier->data));
+
+	encode_string(xdr, args->id_len, args->id);
+
+	RESERVE_SPACE(12);
+	WRITE32(args->flags);
+	WRITE32(0);	/* zero length state_protect4_a */
+	WRITE32(0);	/* zero length implementation id array */
+	hdr->nops++;
+
+	return 0;
+}
+
 static int encode_sequence(struct xdr_stream *xdr,
 			   const struct nfs41_sequence_args *args,
 			   struct compound_hdr *hdr)
@@ -2485,6 +2536,29 @@ out:
 	return status;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * EXCHANGE_ID request
+ */
+static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
+				     void *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
+	__be32 *nops;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+
+	encode_exchange_id(&xdr, args, &hdr);
+
+	encode_nops(nops, &hdr);
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * START OF "GENERIC" DECODE ROUTINES.
  *   These may look a little ugly since they are imported from a "generic"
@@ -4116,6 +4190,52 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 }
 
 #if defined(CONFIG_NFS_V4_1)
+static int decode_exchange_id(struct xdr_stream *xdr,
+			      struct nfs41_exchange_id_res *res)
+{
+	uint32_t *p;
+	int status, dummy;
+	struct nfs_client *clp = res->client;
+
+	status = decode_op_hdr(xdr, OP_EXCHANGE_ID);
+	if (status)
+		return status;
+
+	READ_BUF(8);
+	READ64(clp->cl_ex_clid);
+	READ_BUF(12);
+	READ32(clp->cl_seqid);
+	READ32(clp->cl_exchange_flags);
+
+	/* We ask for SP4_NONE */
+	READ32(dummy);
+	if (dummy != SP4_NONE)
+		return -EIO;
+
+	/* minor_id */
+	READ_BUF(8);
+	READ64(res->server_owner.minor_id);
+
+	/* Major id */
+	READ_BUF(4);
+	READ32(res->server_owner.major_id_sz);
+	READ_BUF(res->server_owner.major_id_sz);
+	COPYMEM(res->server_owner.major_id, res->server_owner.major_id_sz);
+
+	/* server_scope */
+	READ_BUF(4);
+	READ32(res->server_scope.server_scope_sz);
+	READ_BUF(res->server_scope.server_scope_sz);
+	COPYMEM(res->server_scope.server_scope,
+		res->server_scope.server_scope_sz);
+	/* Throw away Implementation id array */
+	READ_BUF(4);
+	READ32(dummy);
+	p += XDR_QUADLEN(dummy);
+
+	return 0;
+}
+
 static int decode_sequence(struct xdr_stream *xdr,
 			   struct nfs41_sequence_res *res,
 			   struct rpc_rqst *rqstp)
@@ -4974,6 +5094,26 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	return status;
 }
 
+/* FIXME: move down at the bottom after all nfs40 funcs */
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * EXCHANGE_ID request
+ */
+static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
+				     void *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_exchange_id(&xdr, res);
+	return status;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * a SETCLIENTID_CONFIRM request
  */
@@ -5217,6 +5357,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(GETACL,		enc_getacl,	dec_getacl),
   PROC(SETACL,		enc_setacl,	dec_setacl),
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
+#if defined(CONFIG_NFS_V4_1)
+  PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 struct rpc_version      nfs_version4 = {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a69bbfa..be4af09 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -21,6 +21,7 @@
 #define NFS4_FHSIZE		128
 #define NFS4_MAXPATHLEN		PATH_MAX
 #define NFS4_MAXNAMLEN		NAME_MAX
+#define NFS4_OPAQUE_LIMIT	1024
 #define NFS4_MAX_SESSIONID_LEN	16
 
 #define NFS4_ACCESS_READ        0x0001
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 15c0aa5..9917c09 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -75,6 +75,12 @@ struct nfs_client {
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V4_1
+	/* clientid returned from EXCHANGE_ID, used by session operations */
+	u64			cl_ex_clid;
+	/* The sequence id to use for the next CREATE_SESSION */
+	u32			cl_seqid;
+	/* The flags used for obtaining the clientid during EXCHANGE_ID */
+	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 #endif /* CONFIG_NFS_V4_1 */
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e932b0d..976ced7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -859,6 +859,48 @@ struct nfs4_fs_locations_res {
 
 #endif /* CONFIG_NFS_V4 */
 
+#ifdef CONFIG_NFS_V4_1
+struct nfstime4 {
+	u64	seconds;
+	u32	nseconds;
+};
+
+struct nfs_impl_id4 {
+	u32		domain_len;
+	char		*domain;
+	u32		name_len;
+	char		*name;
+	struct nfstime4	date;
+};
+
+#define NFS4_EXCHANGE_ID_LEN	(48)
+struct nfs41_exchange_id_args {
+	nfs4_verifier			*verifier;
+	unsigned int 			id_len;
+	char 				id[NFS4_EXCHANGE_ID_LEN];
+	u32				flags;
+};
+
+struct server_owner {
+	uint64_t			minor_id;
+	uint32_t			major_id_sz;
+	char				major_id[NFS4_OPAQUE_LIMIT];
+};
+
+struct server_scope {
+	uint32_t			server_scope_sz;
+	char 				server_scope[NFS4_OPAQUE_LIMIT];
+};
+
+struct nfs41_exchange_id_res {
+	struct nfs_client		*client;
+	u32				flags;
+	struct server_owner		server_owner;
+	struct server_scope		server_scope;
+	struct nfs_impl_id4		impl_id;
+};
+#endif /* CONFIG_NFS_V4_1 */
+
 struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index d0fe2e3..8f492e3 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -41,7 +41,6 @@
 #include <linux/kref.h>
 #include <linux/sunrpc/clnt.h>
 
-#define NFS4_OPAQUE_LIMIT 1024
 typedef struct {
 	u32             cl_boot;
 	u32             cl_id;
-- 
1.6.0.2

