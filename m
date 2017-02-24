Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:5704 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751312AbdBXWUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:32 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 15/17] SUNRPC SVCAUTH_GSS gss3 create label
Date: Fri, 24 Feb 2017 17:19:51 -0500
Message-ID: <20170224221953.5502-16-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

GSSv3 uses the same rsc fields as GSSv1 to hold GSS context information.
For GSSv3 these 'normal' rsc cache entries are termed parent rsc cache
entries.

A successful RPCSEC_GSS_CREATE call results in a child rsc cache entry,
which piggy-backs off a parent rsc cache entry, using the parent negotiated
crypto for MIC and PRIV calculations.

A child rsc cache entry does not use the cred, seqdata, nor mechctx fields.

New fields for RPCSEC_GSS_CREATE
1) parent_handle: set on a child rsc cache entry to enable the lookup of
   the parent.
2) assertions: set on a child rsc cache entry to hold the
   RPCSEC_GSS_CREATE data to assert.

Use a common "act upon the command' switch case for RPC_GSS_PROC_DATA and
RPC_GSS_PROC_CREATE to enable wrap and unwrap.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h   |   5 +
 net/sunrpc/auth_gss/svcauth_gss.c | 296 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 295 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 59469fc..150e4b7 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -138,6 +138,11 @@ struct gss3_assertion_u {
 	} u;
 };
 
+struct gss3_svc_assert {
+	u32			sa_num;
+	struct gss3_assertion_u	sa_assert;
+};
+
 struct gss3_create_args {
 	struct gss3_mp_auth		*ca_mp_auth;
 	struct gss3_chan_binding	*ca_chan_bind;
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 3a42133..bd7ceab 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -55,6 +55,9 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
+/* Global counter for context handles */
+static atomic64_t ctxhctr;
+
 /* The rpcsec_init cache is used for mapping RPCSEC_GSS_{,CONT_}INIT requests
  * into replies.
  *
@@ -324,23 +327,49 @@ struct gss_svc_seq_data {
 	spinlock_t		sd_lock;
 };
 
+/**
+ * struct rsc:
+ *
+ * GSSv3 uses the same rsc fields as GSSv1 to hold GSS context information.
+ * For GSSv3 these 'normal' rsc cache entries are termed parent rsc cache
+ * entries.
+ *
+ * A successful RPCSEC_GSS_CREATE call results in a child rsc cache entry,
+ * which piggy-backs off a parent rsc cache entry, using the parent negotiated
+ * crypto for MIC and PRIV calculations.
+ *
+ * A child rsc cache entry does not use the cred, seqdata, nor mechctx fields.
+ *
+ * New fields for RPCSEC_GSS_CREATE
+ *     1) parent_handle: set on a child rsc cache entry to enable the lookup of
+ *     the parent.
+ *     2) assertions: set on a child rsc cache entry to hold the
+ *     RPCSEC_GSS_CREATE data to assert.
+ *
+ */
 struct rsc {
 	struct cache_head	h;
 	struct xdr_netobj	handle;
+	struct xdr_netobj	parent_handle;
 	struct svc_cred		cred;
 	struct gss_svc_seq_data	seqdata;
 	struct gss_ctx		*mechctx;
+	struct gss3_svc_assert  *assertions;
 };
 
 static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct rsc *old);
 static struct rsc *rsc_lookup(struct cache_detail *cd, struct rsc *item);
+static void gss3_free_svc_assert(struct gss3_svc_assert *g3a);
 
 static void rsc_free(struct rsc *rsci)
 {
 	kfree(rsci->handle.data);
+	kfree(rsci->parent_handle.data);
 	if (rsci->mechctx)
 		gss_delete_sec_context(&rsci->mechctx);
 	free_svc_cred(&rsci->cred);
+	if (rsci->assertions)
+		gss3_free_svc_assert(rsci->assertions);
 }
 
 static void rsc_put(struct kref *ref)
@@ -376,8 +405,15 @@ rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 	tmp->handle.len = 0;
 	new->handle.data = tmp->handle.data;
 	tmp->handle.data = NULL;
+
+	new->parent_handle.len = tmp->handle.len;
+	tmp->parent_handle.len = 0;
+	new->parent_handle.data = tmp->handle.data;
+	tmp->parent_handle.data = NULL;
+
 	new->mechctx = NULL;
 	init_svc_cred(&new->cred);
+	new->assertions = NULL;
 }
 
 static void
@@ -388,9 +424,15 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 
 	new->mechctx = tmp->mechctx;
 	tmp->mechctx = NULL;
+	new->parent_handle.len = tmp->parent_handle.len;
+	new->parent_handle.data = tmp->parent_handle.data;
+	tmp->parent_handle.len = 0;
+	tmp->parent_handle.data = NULL;
 	memset(&new->seqdata, 0, sizeof(new->seqdata));
 	spin_lock_init(&new->seqdata.sd_lock);
 	new->cred = tmp->cred;
+	new->assertions = tmp->assertions;
+	tmp->assertions = NULL;
 	init_svc_cred(&tmp->cred);
 }
 
@@ -1203,7 +1245,6 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 				uint64_t *handle)
 {
 	struct rsc rsci, *rscp = NULL;
-	static atomic64_t ctxhctr;
 	long long ctxh;
 	struct gss_api_mech *gm = NULL;
 	time_t expiry;
@@ -1447,13 +1488,224 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 
 #endif /* CONFIG_PROC_FS */
 
+/**
+ * for now, support a single au_label per RPCSEC_GSS_CREATE
+ * no checks here, as the checks are in gss3_save_child
+ */
+static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
+{
+	struct gss3_label *glp = &g3a->sa_assert.u.au_label;
+
+	switch (g3a->sa_assert.au_type) {
+	case GSS3_LABEL:
+		kfree(glp->la_label.data);
+		break;
+	case GSS3_PRIVS:
+	default:
+		pr_warn("RPC    %s au_type %d not supported\n",
+			__func__, g3a->sa_assert.au_type);
+	}
+
+	kfree(g3a);
+}
+
+/**
+ * gss3_save_child_rsc()
+ * Create a child handle, set the parent handle, assertions, and add to
+ * the rsc cache.
+ *
+ * @handle - output child handle data
+ * @phandle - input parent handle
+ * @expiry - input parent expiry
+ */
+static struct gss3_svc_assert *
+gss3_save_child_rsc(struct cache_detail *cd, uint64_t *handle,
+		    struct xdr_netobj *phandle, time_t expiry,
+		    struct kvec *argv)
+{
+	struct gss3_svc_assert *g3a, *ret = NULL;
+	struct gss3_label *glp;
+	struct rsc child, *rscp = NULL;
+	unsigned int len;
+	long dummy;
+	long long ctxh;
+
+	memset(&child, 0, sizeof(child));
+
+	/* context handle */
+	ctxh = atomic64_inc_return(&ctxhctr);
+
+	/* make a copy for the caller */
+	*handle = ctxh;
+
+	/* make a copy for the rsc cache */
+	if (dup_to_netobj(&child.handle, (char *)handle, sizeof(uint64_t)))
+		goto out;
+
+	rscp = rsc_lookup(cd, &child);
+	if (!rscp)
+		goto out;
+
+	if (dup_netobj(&child.parent_handle, phandle))
+		goto out;
+	child.h.expiry_time = expiry;
+
+	/* ca_mp_auth */
+	dummy = svc_getnl(argv);
+	if (dummy != 0)
+		goto out;
+
+	/* ca_chan_bind  */
+	dummy = svc_getnl(argv);
+	if (dummy != 0)
+		goto out;
+
+	g3a = kmalloc(sizeof(*g3a), GFP_KERNEL);
+	if (!g3a)
+		goto out;
+
+	/* for now support one assertion per RPCSEC_GSS_CREATE */
+	g3a->sa_num = svc_getnl(argv);
+	if (g3a->sa_num != 1) {
+		pr_warn("RPC    Number gss3 assertions %d not 1\n",
+			g3a->sa_num);
+		goto out;
+	}
+
+	g3a->sa_assert.au_type = svc_getnl(argv);
+	switch (g3a->sa_assert.au_type) {
+	case GSS3_LABEL:
+		glp = &g3a->sa_assert.u.au_label;
+
+		/* XXX need to verify? */
+		glp->la_lfs = svc_getnl(argv);
+		glp->la_pi = svc_getnl(argv);
+
+		/**
+		 * don't use svc_safe_getnetobj as this object needs to live
+		 * in the rsc cache past the nfsd thread request processing.
+		 */
+		glp->la_label.len = svc_getnl(argv);
+		len = round_up_to_quad(glp->la_label.len);
+		if (argv->iov_len < len)
+			goto out;
+
+		if (dup_to_netobj(&glp->la_label, (char *)argv->iov_base,
+				  glp->la_label.len))
+			goto out;
+		break;
+	case GSS3_PRIVS:
+	default:
+		pr_warn("RPC    %s au_type %d not supported\n",
+			__func__, g3a->sa_assert.au_type);
+		goto out;
+	}
+	argv->iov_base += len;
+	argv->iov_len -= len;
+
+	child.assertions = g3a;
+	rscp = rsc_update(cd, &child, rscp);
+
+out:
+	rsc_free(&child);
+	if (rscp) {
+		ret = rscp->assertions;
+		cache_put(&rscp->h, cd);
+	}
+	return ret;
+}
+
+/**
+ * gss3_handle_create_req.
+ *
+ * Create a child rsc record
+ *
+ * Encode the RPCSEC_GSS_CREATE reply as follows:
+ *  4 RPC_SUCCESS
+ *  4 gss3_handle len
+ *  4 rcr_mp_auth
+ *  4 rcr_chan_bind_mic
+ *  4 gss3_num
+ *  4 au_type
+ *
+ * total encode length: 24 + gss_handlelen + au_type assert len
+ */
+static int
+gss3_handle_create_req(struct kvec *resv, struct kvec *argv, struct rsc *rsci,
+		       struct rpc_gss_wire_cred *gc, struct sunrpc_net *sn)
+{
+	struct gss3_svc_assert *g3a;
+	struct gss3_label *glp;
+	u64 c_handle;
+	struct xdr_netobj child_handle;
+	int enc_len, assert_len, ret = 0;
+
+	g3a = gss3_save_child_rsc(sn->rsc_cache, &c_handle, &gc->gc_ctx,
+				  rsci->h.expiry_time, argv);
+	if (!g3a)
+		goto auth_err;
+
+	/* set child handle for encoding */
+	child_handle.data = (u8 *)&c_handle;
+	child_handle.len = sizeof(c_handle);
+
+	/* calculate the assert length. Support one assert per request */
+	switch (g3a->sa_assert.au_type) {
+	case GSS3_LABEL:
+		/* 4 la_lfs, 4 la_pi, 4 la_label len */
+		glp = &g3a->sa_assert.u.au_label;
+		assert_len = 12 + glp->la_label.len;
+		break;
+	case GSS3_PRIVS:
+	default:
+		pr_warn("RPC    Unsupported GSS3 assertion %d\n",
+			g3a->sa_assert.au_type);
+		goto drop;
+	}
+	enc_len = 24 + child_handle.len + assert_len;
+	if (resv->iov_len + enc_len > PAGE_SIZE)
+		goto drop;
+
+	svc_putnl(resv, RPC_SUCCESS);
+
+	/* Encode the RPCSEC_GSS_CREATE payload */
+
+	if (svc_safe_putnetobj(resv, &child_handle))
+		goto auth_err;
+	svc_putnl(resv, 0);  /* NULL rcr_mp_auth */
+	svc_putnl(resv, 0);  /* NULL rcr_chan_bind_mic */
+	svc_putnl(resv, g3a->sa_num); /* the # of assertions (<>) */
+	svc_putnl(resv, g3a->sa_assert.au_type);
+
+	/* sa_num checked to be = 1 in gss3_save_child_rsc */
+	switch (g3a->sa_assert.au_type) {
+	case GSS3_LABEL:
+		svc_putnl(resv, glp->la_lfs);
+		svc_putnl(resv, glp->la_pi);
+		if (svc_safe_putnetobj(resv, &glp->la_label))
+			goto auth_err;
+		break;
+	/* already checked GSS3_PRIVS and default cases above */
+	}
+out:
+	return ret;
+auth_err:
+	ret = SVC_DENIED;
+	goto out;
+drop:
+	ret = SVC_DROP;
+	goto out;
+}
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
  * If data exchange, verify/decrypt
  * If context destruction, handle here
+ * If gssv3 RPCSEC_GSS_CREATE handle here
  * In the context establishment and destruction case we encode
  * response here and return SVC_COMPLETE.
+ * XXXX should punt to user space for RPCSEC_GSS_CREATE payloads.
  */
 static int
 svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
@@ -1462,7 +1714,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
 	struct rpc_gss_wire_cred *gc;
-	struct rsc	*rsci = NULL;
+	struct rsc	*rsci = NULL, *rsci_ch = NULL;
 	__be32		*rpcstart;
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
@@ -1519,11 +1771,25 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 			return svcauth_gss_legacy_init(rqstp, gc, authp);
 	case RPC_GSS_PROC_DATA:
 	case RPC_GSS_PROC_DESTROY:
+	case RPC_GSS_PROC_CREATE:
 		/* Look up the context, and check the verifier: */
 		*authp = rpcsec_gsserr_credproblem;
+
 		rsci = gss_svc_searchbyctx(sn->rsc_cache, &gc->gc_ctx);
-		if (!rsci)
+		if (!rsci) {
+			pr_warn("RPC   gc_ctx handle not found\n");
 			goto auth_err;
+		}
+		if (rsci->parent_handle.len != 0) { /* GSSv3 child handle */
+
+			rsci_ch = rsci;
+			rsci = gss_svc_searchbyctx(sn->rsc_cache,
+						   &rsci_ch->parent_handle);
+			if (!rsci) {
+				pr_warn("RPC    parent handle not found\n");
+				goto auth_err;
+			}
+		}
 		if (rsci->mechctx->gss_version != gc->gc_v) {
 			pr_warn("NFSD:  RPCSEC_GSS version mismatch (%u:%u)\n",
 				rsci->mechctx->gss_version, gc->gc_v);
@@ -1555,6 +1821,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 		svc_putnl(resv, RPC_SUCCESS);
 		goto complete;
 	case RPC_GSS_PROC_DATA:
+	case RPC_GSS_PROC_CREATE:
 		*authp = rpcsec_gsserr_ctxproblem;
 		svcdata->verf_start = resv->iov_base + resv->iov_len;
 		if (gss_write_verf(rqstp, rsci->mechctx, gc, gc->gc_seq))
@@ -1592,8 +1859,22 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 					rsci->mechctx->mech_type,
 					GSS_C_QOP_DEFAULT,
 					gc->gc_svc);
-		ret = SVC_OK;
-		goto out;
+		/* RPC_GSS_PROC_DATA */
+		if (gc->gc_proc == RPC_GSS_PROC_DATA) {
+			ret = SVC_OK;
+			goto out;
+		}
+
+		/* RPC_GSS_PROC_CREATE */
+		ret = gss3_handle_create_req(resv, argv, rsci, gc, sn);
+		switch (ret) {
+		case 0:
+			goto out;
+		case SVC_DENIED:
+			goto auth_err;
+		case SVC_DROP:
+			goto drop;
+		}
 	}
 garbage_args:
 	ret = SVC_GARBAGE;
@@ -1611,6 +1892,8 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 out:
 	if (rsci)
 		cache_put(&rsci->h, sn->rsc_cache);
+	if (rsci_ch)
+		cache_put(&rsci_ch->h, sn->rsc_cache);
 	return ret;
 }
 
@@ -1762,7 +2045,8 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 	int stat = -EINVAL;
 	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
 
-	if (gc->gc_proc != RPC_GSS_PROC_DATA)
+	if (!(gc->gc_proc == RPC_GSS_PROC_DATA ||
+	      gc->gc_proc == RPC_GSS_PROC_CREATE))
 		goto out;
 	/* Release can be called twice, but we only wrap once. */
 	if (gsd->verf_start == NULL)
-- 
2.9.3

