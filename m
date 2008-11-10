From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 32/51] nfsd41: callback infrastructure
Date: Mon, 10 Nov 2008 22:51:39 +0200
Message-ID: <1226350299-11302-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57380 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbYKJUvx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:51:53 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep the xprt used for create_session in cl_cb_xprt.
Mark cl_callback.cb_minorversion = 1 and remember
the client provided cl_callback.cb_prog rpc program number.
Use it to probe the callback path.

Define xdr sizes and code nfs41 cb_compound header to be able
to send a null callback rpc.

Define stubs for other nfs41 callbacks.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |  189 +++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c        |   14 +++
 include/linux/nfsd/state.h |    3 +-
 3 files changed, 186 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e198ead..b1d2299 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -43,6 +43,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/state.h>
 #include <linux/sunrpc/sched.h>
@@ -52,16 +53,24 @@
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
+#define NFS4_STATEID_SIZE 16
+
+#if defined(CONFIG_NFSD_V4_1)
+#define NFS4_CB_PROGRAM 0x40000000
+#endif
 
 /* Index of predefined Linux callback client operations */
 
 enum {
-        NFSPROC4_CLNT_CB_NULL = 0,
+	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
+	NFSPROC4_CLNT_CB_SEQUENCE,
 };
 
 enum nfs_cb_opnum4 {
 	OP_CB_RECALL            = 4,
+	OP_CB_LAYOUT            = 5,
+	OP_CB_SEQUENCE          = 11,
 };
 
 #define NFS4_MAXTAGLEN		20
@@ -77,10 +86,40 @@ enum nfs_cb_opnum4 {
 #define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
 					1 + enc_stateid_sz +            \
 					enc_nfs4_fh_sz)
-
 #define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
 					op_dec_sz)
 
+#if defined(CONFIG_NFSD_V4_1)
+#define NFS41_enc_cb_null_sz		0
+#define NFS41_dec_cb_null_sz		0
+#define cb_compound41_enc_hdr_sz	4
+#define cb_compound41_dec_hdr_sz	(3 + (NFS4_MAXTAGLEN >> 2))
+#define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
+#define cb_sequence41_enc_sz		(sessionid_sz + 4 +             \
+					1 /* no referring calls list yet */)
+#define cb_sequence41_dec_sz		(op_dec_sz + sessionid_sz + 4)
+#define NFS41_enc_cb_recall_sz		(cb_compound41_enc_hdr_sz +     \
+					cb_sequence41_enc_sz +          \
+					1 + enc_stateid_sz +            \
+					enc_nfs4_fh_sz)
+#define NFS41_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
+					cb_sequence41_dec_sz +          \
+					op_dec_sz)
+#else /* defined(CONFIG_NFSD_V4_1) */
+
+struct nfs41_cb_sequence;
+
+#endif /* defined(CONFIG_NFSD_V4_1) */
+
+struct nfs4_rpc_args {
+	void                     *args_op;
+	struct nfs41_cb_sequence *args_seq;
+};
+
+struct nfs4_rpc_res {
+	struct nfs41_cb_sequence *res_seq;
+};
+
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
@@ -135,11 +174,18 @@ xdr_error:                                      \
 		return -EIO; \
 	} \
 } while (0)
+#define COPYMEM(x,nbytes) do {			\
+	memcpy((x), p, nbytes);			\
+	p += XDR_QUADLEN(nbytes);		\
+} while (0)
 
 struct nfs4_cb_compound_hdr {
-	int		status;
-	u32		ident;
+	/* args */
+	u32		ident;		/* minorversion 0 only */
 	u32		nops;
+
+	/* res */
+	int		status;
 	u32		taglen;
 	char *		tag;
 };
@@ -208,7 +254,7 @@ encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 
 	RESERVE_SPACE(16);
 	WRITE32(0);            /* tag length is always 0 */
-	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(0);		/* minorversion */
 	WRITE32(hdr->ident);
 	WRITE32(hdr->nops);
 	return 0;
@@ -230,6 +276,14 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
 	return 0;
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+static int
+encode_cb_sequence(struct xdr_stream *xdr, struct nfs41_cb_sequence *args)
+{
+	return -1;	/* stub */
+}
+#endif /* defined(CONFIG_NFSD_V4_1) */
+
 static int
 nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 {
@@ -255,6 +309,29 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *a
 }
 
 
+#if defined(CONFIG_NFSD_V4_1)
+static int
+encode_cb_compound41_hdr(struct xdr_stream *xdr,
+			 struct nfs4_cb_compound_hdr *hdr)
+{
+	u32 *p;
+
+	RESERVE_SPACE(16);
+	WRITE32(0);		/* tag length is always 0 */
+	WRITE32(1);		/* minorversion */
+	WRITE32(0);		/* callback_ident not used in 4.1 */
+	WRITE32(hdr->nops);
+	return 0;
+}
+
+static int
+nfs41_xdr_enc_cb_recall(struct rpc_rqst *req, u32 *p,
+			struct nfs4_rpc_args *rpc_args)
+{
+	return -1;	/* stub */
+}
+#endif /* defined(CONFIG_NFSD_V4_1) */
+
 static int
 decode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr){
         __be32 *p;
@@ -312,6 +389,21 @@ out:
 	return status;
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+static int
+decode_cb_sequence(struct xdr_stream *xdr, struct nfs41_cb_sequence *res)
+{
+	return -1;	/* stub */
+}
+
+static int
+nfs41_xdr_dec_cb_recall(struct rpc_rqst *rqstp, u32 *p,
+			struct nfs4_rpc_res *rpc_res)
+{
+	return -1;	/* stub */
+}
+#endif /* defined(CONFIG_NFSD_V4_1) */
+
 /*
  * RPC procedure tables
  */
@@ -331,32 +423,76 @@ static struct rpc_procinfo     nfs4_cb_procedures[] = {
     PROC(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
 };
 
-static struct rpc_version       nfs_cb_version4 = {
+static struct rpc_version       nfs4_cb_version1 = {
         .number                 = 1,
         .nrprocs                = ARRAY_SIZE(nfs4_cb_procedures),
         .procs                  = nfs4_cb_procedures
 };
 
-static struct rpc_version *	nfs_cb_version[] = {
+static struct rpc_version *nfs4_cb_version[] = {
 	NULL,
-	&nfs_cb_version4,
+	&nfs4_cb_version1,
 };
 
-static struct rpc_program cb_program;
+static struct rpc_program nfs4_cb_program;
 
-static struct rpc_stat cb_stats = {
-		.program	= &cb_program
+static struct rpc_stat nfs4_cb_stats = {
+	.program	= &nfs4_cb_program
 };
 
 #define NFS4_CALLBACK 0x40000000
-static struct rpc_program cb_program = {
-		.name 		= "nfs4_cb",
-		.number		= NFS4_CALLBACK,
-		.nrvers		= ARRAY_SIZE(nfs_cb_version),
-		.version	= nfs_cb_version,
-		.stats		= &cb_stats,
+static struct rpc_program nfs4_cb_program = {
+	.name 		= "nfs4_cb",
+	.number		= NFS4_CALLBACK,
+	.nrvers		= ARRAY_SIZE(nfs4_cb_version),
+	.version	= nfs4_cb_version,
+	.stats		= &nfs4_cb_stats,
+};
+
+#if defined(CONFIG_NFSD_V4_1)
+#define PROC41(proc, call, argtype, restype)                            \
+[NFSPROC4_CLNT_##proc] = {                                              \
+	.p_proc   = NFSPROC4_CB_##call,                                 \
+	.p_encode = (kxdrproc_t) nfs41_xdr_##argtype,                   \
+	.p_decode = (kxdrproc_t) nfs41_xdr_##restype,                   \
+	.p_arglen = NFS41_##argtype##_sz,                               \
+	.p_replen = NFS41_##restype##_sz,                               \
+	.p_statidx = NFSPROC4_CB_##call,                                \
+	.p_name   = #proc,                                              \
+}
+
+static struct rpc_procinfo     nfs41_cb_procedures[] = {
+	PROC(CB_NULL,        NULL,       enc_cb_null,        dec_cb_null),
+	PROC41(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
 };
 
+static struct rpc_version       nfs41_cb_version1 = {
+	.number                 = 1,
+	.nrprocs                = ARRAY_SIZE(nfs41_cb_procedures),
+	.procs                  = nfs41_cb_procedures
+};
+
+static struct rpc_version *nfs41_cb_version[] = {
+	NULL,
+	&nfs41_cb_version1,
+};
+
+static struct rpc_program nfs41_cb_program;
+
+static struct rpc_stat nfs41_cb_stats = {
+	.program	= &nfs41_cb_program
+};
+
+static struct rpc_program nfs41_cb_program = {
+	.name 		= "nfs41_cb",
+	.number		= NFS4_CALLBACK,
+	.nrvers		= ARRAY_SIZE(nfs41_cb_version),
+	.version	= nfs41_cb_version,
+	.stats		= &nfs41_cb_stats,
+};
+
+#endif /* defined(CONFIG_NFSD_V4_1) */
+
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
@@ -376,9 +512,9 @@ static int do_probe_callback(void *data)
 		.address	= (struct sockaddr *)&addr,
 		.addrsize	= sizeof(addr),
 		.timeout	= &timeparms,
-		.program	= &cb_program,
+		.program	= &nfs4_cb_program,
 		.prognumber	= cb->cb_prog,
-		.version	= nfs_cb_version[1]->number,
+		.version	= nfs4_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
@@ -395,6 +531,20 @@ static int do_probe_callback(void *data)
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
 
+#if defined(CONFIG_NFSD_V4_1)
+	if (cb->cb_minorversion) {
+		BUG_ON(cb->cb_minorversion != 1);
+		args.program = &nfs41_cb_program;
+		args.version = nfs41_cb_version[1]->number;
+		args.bc_sock = container_of(clp->cl_cb_xprt, struct svc_sock,
+					    sk_xprt);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
+
+	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
+		__func__, args.program->name, args.prognumber,
+		args.program->nrvers, args.version, cb->cb_minorversion);
+
 	/* Create RPC client */
 	client = rpc_create(&args);
 	if (IS_ERR(client)) {
@@ -413,6 +563,7 @@ static int do_probe_callback(void *data)
 	put_nfs4_client(clp);
 	return 0;
 out_release_client:
+	dprintk("NFSD: synchronous CB_NULL failed. status=%d\n", status);
 	rpc_shutdown_client(client);
 out_err:
 	dprintk("NFSD: warning: no callback path to client %.*s\n",
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 55fd003..edac97a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -39,6 +39,7 @@
 #include <linux/slab.h>
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/file.h>
@@ -544,6 +545,10 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
+#if defined(CONFIG_NFSD_V4_1)
+	if (clp->cl_cb_xprt)
+		svc_xprt_put(clp->cl_cb_xprt);
+#endif /* CONFIG_NFSD_V4_1 */
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_name.data);
@@ -856,6 +861,8 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
 	                 &cb->cb_addr, &cb->cb_port)))
 		goto out_err;
+
+	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	return;
@@ -1042,6 +1049,13 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_PERSIST;
 		cr_ses->flags &= ~SESSION4_RDMA;
 
+		if (cr_ses->flags & SESSION4_BACK_CHAN) {
+			unconf->cl_cb_xprt = rqstp->rq_xprt;
+			svc_xprt_get(unconf->cl_cb_xprt);
+			unconf->cl_callback.cb_minorversion = 1;
+			unconf->cl_callback.cb_prog = cr_ses->callback_prog;
+			nfsd4_probe_callback(unconf);
+		}
 		conf = unconf;
 	}
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 94b5366..918adde 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -94,7 +94,8 @@ struct nfs4_callback {
 	u32                     cb_addr;
 	unsigned short          cb_port;
 	u32                     cb_prog;
-	u32                     cb_ident;
+	u32			cb_minorversion;
+	u32			cb_ident;	/* minorversion 0 only */
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
 	struct rpc_clnt *       cb_client;
-- 
1.6.0.2

