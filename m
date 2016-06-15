Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:25492 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932772AbcFOQ7A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 12:59:00 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3 3/3] nfsd: implement machine credential support for some operations
Date: Wed, 15 Jun 2016 12:52:09 -0400
Message-Id: <1466009529-3421-4-git-send-email-aweits@rit.edu>
In-Reply-To: <1466009529-3421-1-git-send-email-aweits@rit.edu>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This addresses the conundrum referenced in RFC5661 18.35.3,
and will allow clients to return state to the server using the
machine credentials.

The biggest part of the problem is that we need to allow the client
to send a compound op with integrity/privacy on mounts that don't
have it enabled.

Add server support for properly decoding and using spo_must_enforce
and spo_must_allow bits. Add support for machine credentials to be
used for CLOSE, OPEN_DOWNGRADE, LOCKU, DELEGRETURN,
and TEST/FREE STATEID.
Implement a check so as to not throw WRONGSEC errors when these
operations are used if integrity/privacy isn't turned on.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/export.c    | 10 ++++++++++
 fs/nfsd/nfs4proc.c  | 39 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c | 18 ++++++++++++++++++
 fs/nfsd/nfs4xdr.c   | 51 +++++++++++++++++++++++----------------------------
 fs/nfsd/nfsd.h      |  5 +++++
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      |  3 +++
 7 files changed, 99 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b4d84b579f20..79de2f38dd63 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -954,6 +954,16 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
 		    rqstp->rq_cred.cr_flavor == RPC_AUTH_UNIX)
 			return 0;
 	}
+
+	/* If the compound op contains a spo_must_allowed op,
+	 * it will be sent with integrity/protection which
+	 * will have to be expressly allowed on mounts that
+	 * don't support it
+	 */
+
+	if (nfsd4_spo_must_allow(rqstp))
+		return 0;
+
 	return nfserr_wrongsec;
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index de1ff1d98bb1..b1159b3e9816 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2335,6 +2335,45 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
+/**
+ * nfsd4_spo_must_allow - Determine if the compound op contains an
+ * operation that is allowed to be sent with machine credentials
+ *
+ * @rqstp: a pointer to the struct svc_rqst
+ *
+ * Checks to see if the compound contains a spo_must_allow op
+ * and confirms that it was sent with the proper machine creds.
+ */
+
+bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
+	struct nfsd4_compound_state *cstate = &resp->cstate;
+	struct nfs4_op_map *allow = &cstate->clp->cl_spo_must_allow;
+	u32 opiter;
+
+	if (!cstate->minorversion)
+		return false;
+
+	if (cstate->spo_must_allowed == true)
+		return true;
+
+	opiter = resp->opcnt;
+	while (opiter < argp->opcnt) {
+		this = &argp->ops[opiter++];
+		if (test_bit(this->opnum, allow->u.longs) &&
+			cstate->clp->cl_mach_cred &&
+			nfsd4_mach_creds_match(cstate->clp, rqstp)) {
+			cstate->spo_must_allowed = true;
+			return true;
+		}
+	}
+	cstate->spo_must_allowed = false;
+	return false;
+}
+
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	struct nfsd4_operation *opdesc;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 51db26811a14..313873de1eb7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2388,6 +2388,22 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	switch (exid->spa_how) {
 	case SP4_MACH_CRED:
+		exid->spo_must_enforce[0] = 0;
+		exid->spo_must_enforce[1] = (
+			1 << (OP_BIND_CONN_TO_SESSION - 32) |
+			1 << (OP_EXCHANGE_ID - 32) |
+			1 << (OP_CREATE_SESSION - 32) |
+			1 << (OP_DESTROY_SESSION - 32) |
+			1 << (OP_DESTROY_CLIENTID - 32));
+
+		exid->spo_must_allow[0] &= (1 << (OP_CLOSE) |
+					1 << (OP_OPEN_DOWNGRADE) |
+					1 << (OP_LOCKU) |
+					1 << (OP_DELEGRETURN));
+
+		exid->spo_must_allow[1] &= (
+					1 << (OP_TEST_STATEID - 32) |
+					1 << (OP_FREE_STATEID - 32));
 		if (!svc_rqst_integrity_protected(rqstp)) {
 			status = nfserr_inval;
 			goto out_nolock;
@@ -2473,6 +2489,8 @@ out_new:
 			goto out;
 	}
 	new->cl_minorversion = cstate->minorversion;
+	new->cl_spo_must_allow.u.words[0] = exid->spo_must_allow[0];
+	new->cl_spo_must_allow.u.words[1] = exid->spo_must_allow[1];
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9df898ba648f..84ef94794496 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1299,16 +1299,14 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 		break;
 	case SP4_MACH_CRED:
 		/* spo_must_enforce */
-		READ_BUF(4);
-		dummy = be32_to_cpup(p++);
-		READ_BUF(dummy * 4);
-		p += dummy;
-
+		status = nfsd4_decode_bitmap(argp,
+					exid->spo_must_enforce);
+		if (status)
+			goto out;
 		/* spo_must_allow */
-		READ_BUF(4);
-		dummy = be32_to_cpup(p++);
-		READ_BUF(dummy * 4);
-		p += dummy;
+		status = nfsd4_decode_bitmap(argp, exid->spo_must_allow);
+		if (status)
+			goto out;
 		break;
 	case SP4_SSV:
 		/* ssp_ops */
@@ -3867,14 +3865,6 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 	return nfserr;
 }
 
-static const u32 nfs4_minimal_spo_must_enforce[2] = {
-	[1] = 1 << (OP_BIND_CONN_TO_SESSION - 32) |
-	      1 << (OP_EXCHANGE_ID - 32) |
-	      1 << (OP_CREATE_SESSION - 32) |
-	      1 << (OP_DESTROY_SESSION - 32) |
-	      1 << (OP_DESTROY_CLIENTID - 32)
-};
-
 static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 			 struct nfsd4_exchange_id *exid)
@@ -3885,6 +3875,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	char *server_scope;
 	int major_id_sz;
 	int server_scope_sz;
+	int status = 0;
 	uint64_t minor_id = 0;
 
 	if (nfserr)
@@ -3913,18 +3904,20 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	case SP4_NONE:
 		break;
 	case SP4_MACH_CRED:
-		/* spo_must_enforce, spo_must_allow */
-		p = xdr_reserve_space(xdr, 16);
-		if (!p)
-			return nfserr_resource;
-
 		/* spo_must_enforce bitmap: */
-		*p++ = cpu_to_be32(2);
-		*p++ = cpu_to_be32(nfs4_minimal_spo_must_enforce[0]);
-		*p++ = cpu_to_be32(nfs4_minimal_spo_must_enforce[1]);
-		/* empty spo_must_allow bitmap: */
-		*p++ = cpu_to_be32(0);
-
+		status = nfsd4_encode_bitmap(xdr,
+					exid->spo_must_enforce[0],
+					exid->spo_must_enforce[1],
+					exid->spo_must_enforce[2]);
+		if (status)
+			goto out;
+		/* spo_must_allow bitmap: */
+		status = nfsd4_encode_bitmap(xdr,
+					exid->spo_must_allow[0],
+					exid->spo_must_allow[1],
+					exid->spo_must_allow[2]);
+		if (status)
+			goto out;
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -3951,6 +3944,8 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	/* Implementation id */
 	*p++ = cpu_to_be32(0);	/* zero length nfs_impl_id4 array */
 	return 0;
+out:
+	return status;
 }
 
 static __be32
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index cf980523898b..9446849888d5 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -124,6 +124,7 @@ void nfs4_state_shutdown_net(struct net *net);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 char * nfs4_recoverydir(void);
+bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
 #else
 static inline int nfsd4_init_slabs(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
@@ -134,6 +135,10 @@ static inline void nfs4_state_shutdown_net(struct net *net) { }
 static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
 static inline char * nfs4_recoverydir(void) {return NULL; }
+static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
+{
+	return false;
+}
 #endif
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 986e51e5ceac..7049a8a559c5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -345,6 +345,7 @@ struct nfs4_client {
 	u32			cl_exchange_flags;
 	/* number of rpc's in progress over an associated session: */
 	atomic_t		cl_refcount;
+	struct nfs4_op_map      cl_spo_must_allow;
 
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 74342a7c208a..beea0c5edc51 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -59,6 +59,7 @@ struct nfsd4_compound_state {
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	int			data_offset;
+	bool                    spo_must_allowed;
 	size_t			iovlen;
 	u32			minorversion;
 	__be32			status;
@@ -403,6 +404,8 @@ struct nfsd4_exchange_id {
 	clientid_t	clientid;
 	u32		seqid;
 	int		spa_how;
+	u32             spo_must_enforce[3];
+	u32             spo_must_allow[3];
 };
 
 struct nfsd4_sequence {
-- 
2.6.3

