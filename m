From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 38/44] nfsd41: Backchannel: callback infrastructure
Date: Tue, 16 Jun 2009 04:21:02 +0300
Message-ID: <1245115262-8056-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2723
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752387AbZFPBVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:21:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Keep the xprt used for create_session in cl_cb_xprt.
Mark cl_callback.cb_minorversion = 1 and remember
the client provided cl_callback.cb_prog rpc program number.
Use it to probe the callback path.

Define xdr sizes and code nfs4_cb_compound header to be able
to send a null callback rpc.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[get callback minorversion from fore channel's]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   27 ++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c    |   11 +++++++++++
 2 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3fd23f7..f75750e 100644
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
@@ -52,16 +53,19 @@
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
+#define NFS4_STATEID_SIZE 16
 
 /* Index of predefined Linux callback client operations */
 
 enum {
-        NFSPROC4_CLNT_CB_NULL = 0,
+	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
+	NFSPROC4_CLNT_CB_SEQUENCE,
 };
 
 enum nfs_cb_opnum4 {
 	OP_CB_RECALL            = 4,
+	OP_CB_SEQUENCE          = 11,
 };
 
 #define NFS4_MAXTAGLEN		20
@@ -70,15 +74,22 @@ enum nfs_cb_opnum4 {
 #define NFS4_dec_cb_null_sz		0
 #define cb_compound_enc_hdr_sz		4
 #define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
+#define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
+#define cb_sequence_enc_sz		(sessionid_sz + 4 +             \
+					1 /* no referring calls list yet */)
+#define cb_sequence_dec_sz		(op_dec_sz + sessionid_sz + 4)
+
 #define op_enc_sz			1
 #define op_dec_sz			2
 #define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
 #define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)
 #define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
+					cb_sequence_enc_sz +            \
 					1 + enc_stateid_sz +            \
 					enc_nfs4_fh_sz)
 
 #define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
+					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
 /*
@@ -137,11 +148,13 @@ xdr_error:                                      \
 } while (0)
 
 struct nfs4_cb_compound_hdr {
-	int		status;
-	u32		ident;
+	/* args */
+	u32		ident;	/* minorversion 0 only */
 	u32		nops;
 	__be32		*nops_p;
 	u32		minorversion;
+	/* res */
+	int		status;
 	u32		taglen;
 	char		*tag;
 };
@@ -405,6 +418,14 @@ int setup_callback_client(struct nfs4_client *clp)
 	addr.sin_family = AF_INET;
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
+	if (cb->cb_minorversion) {
+		args.bc_sock = container_of(clp->cl_cb_xprt, struct svc_sock,
+					    sk_xprt);
+	}
+
+	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
+		__func__, args.program->name, args.prognumber,
+		args.program->nrvers, args.version, cb->cb_minorversion);
 
 	/* Create RPC client */
 	client = rpc_create(&args);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ce6631d..afb0f61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -658,6 +658,8 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
+	if (clp->cl_cb_xprt)
+		svc_xprt_put(clp->cl_cb_xprt);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1324,6 +1326,15 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_PERSIST;
 		cr_ses->flags &= ~SESSION4_RDMA;
 
+		if (cr_ses->flags & SESSION4_BACK_CHAN) {
+			unconf->cl_cb_xprt = rqstp->rq_xprt;
+			svc_xprt_get(unconf->cl_cb_xprt);
+			unconf->cl_cb_conn.cb_minorversion =
+				cstate->minorversion;
+			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
+			unconf->cl_cb_seq_nr = 1;
+			nfsd4_probe_callback(unconf);
+		}
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
-- 
1.6.3

