Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36046 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285AbcFGTsX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:48:23 -0400
Subject: [PATCH v1 15/20] xprtrdma: No direct data placement with krb5i and
 krb5p
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:48:21 -0400
Message-ID: <20160607194821.18401.3116.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Direct data placement is not allowed when using flavors that
guarantee integrity or privacy. When such security flavors are in
effect, don't allow the use of Read and Write chunks for moving
individual data items. All messages larger than the inline threshold
are sent via Long Call or Long Reply.

On my systems (CX-3 Pro on FDR), for small I/O operations, the use
of Long messages adds only around 5 usecs of latency in each
direction.

Note that when integrity or encryption is used, the host CPU touches
every byte in these messages. Even if it could be used, data
movement offload doesn't buy much in this case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth.h           |    5 ++++-
 include/linux/sunrpc/gss_api.h        |    2 ++
 net/sunrpc/auth_gss/auth_gss.c        |    5 ++++-
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    2 ++
 net/sunrpc/auth_gss/gss_mech_switch.c |   12 ++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c        |   12 ++++++++++--
 6 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 8997915..a7d52eb 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -95,7 +95,7 @@ struct rpc_auth {
 				/* for gss, used to calculate au_rslack: */
 	unsigned int		au_verfsize;
 
-	unsigned int		au_flags;	/* various flags */
+	unsigned long		au_flags;	/* various flags */
 	const struct rpc_authops *au_ops;		/* operations */
 	rpc_authflavor_t	au_flavor;	/* pseudoflavor (note may
 						 * differ from the flavor in
@@ -107,6 +107,9 @@ struct rpc_auth {
 	/* per-flavor data */
 };
 
+/* au_flags */
+#define RPCAUTH_AUTH_DATATOUCH	0
+
 struct rpc_auth_create_args {
 	rpc_authflavor_t pseudoflavor;
 	const char *target_name;
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 1f911cc..68ec78c 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -73,6 +73,7 @@ u32 gss_delete_sec_context(
 rpc_authflavor_t gss_svc_to_pseudoflavor(struct gss_api_mech *, u32 qop,
 					u32 service);
 u32 gss_pseudoflavor_to_service(struct gss_api_mech *, u32 pseudoflavor);
+bool gss_pseudoflavor_to_datatouch(struct gss_api_mech *, u32 pseudoflavor);
 char *gss_service_to_auth_domain_name(struct gss_api_mech *, u32 service);
 
 struct pf_desc {
@@ -81,6 +82,7 @@ struct pf_desc {
 	u32	service;
 	char	*name;
 	char	*auth_domain_name;
+	bool	datatouch;
 };
 
 /* Different mechanisms (e.g., krb5 or spkm3) may implement gss-api, and
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e64ae93..aa2c69e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -990,7 +990,8 @@ gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 
 	if (!try_module_get(THIS_MODULE))
 		return ERR_PTR(err);
-	if (!(gss_auth = kmalloc(sizeof(*gss_auth), GFP_KERNEL)))
+	gss_auth = kzalloc(sizeof(*gss_auth), GFP_KERNEL);
+	if (!gss_auth)
 		goto out_dec;
 	INIT_HLIST_NODE(&gss_auth->hash);
 	gss_auth->target_name = NULL;
@@ -1017,6 +1018,8 @@ gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
 	auth->au_ops = &authgss_ops;
 	auth->au_flavor = flavor;
+	if (gss_pseudoflavor_to_datatouch(gss_auth->mech, flavor))
+		set_bit(RPCAUTH_AUTH_DATATOUCH, &auth->au_flags);
 	atomic_set(&auth->au_count, 1);
 	kref_init(&gss_auth->kref);
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 6542749..6059583 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -745,12 +745,14 @@ static struct pf_desc gss_kerberos_pfs[] = {
 		.qop = GSS_C_QOP_DEFAULT,
 		.service = RPC_GSS_SVC_INTEGRITY,
 		.name = "krb5i",
+		.datatouch = true,
 	},
 	[2] = {
 		.pseudoflavor = RPC_AUTH_GSS_KRB5P,
 		.qop = GSS_C_QOP_DEFAULT,
 		.service = RPC_GSS_SVC_PRIVACY,
 		.name = "krb5p",
+		.datatouch = true,
 	},
 };
 
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 7063d85..5fec3ab 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -361,6 +361,18 @@ gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 }
 EXPORT_SYMBOL(gss_pseudoflavor_to_service);
 
+bool
+gss_pseudoflavor_to_datatouch(struct gss_api_mech *gm, u32 pseudoflavor)
+{
+	int i;
+
+	for (i = 0; i < gm->gm_pf_num; i++) {
+		if (gm->gm_pfs[i].pseudoflavor == pseudoflavor)
+			return gm->gm_pfs[i].datatouch;
+	}
+	return false;
+}
+
 char *
 gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
 {
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 34a5df9..aa7951a 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -570,6 +570,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
+	bool ddp_allowed;
 	ssize_t hdrlen;
 	size_t rpclen;
 	__be32 *iptr;
@@ -586,6 +587,13 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
 	headerp->rm_type = rdma_msg;
 
+	/* When the ULP employs a GSS flavor that guarantees integrity
+	 * or privacy, direct data placement of individual data items
+	 * is not allowed.
+	 */
+	ddp_allowed = !test_bit(RPCAUTH_AUTH_DATATOUCH,
+				&rqst->rq_cred->cr_auth->au_flags);
+
 	/*
 	 * Chunks needed for results?
 	 *
@@ -597,7 +605,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 */
 	if (rpcrdma_results_inline(r_xprt, rqst))
 		wtype = rpcrdma_noch;
-	else if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
+	else if (ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ)
 		wtype = rpcrdma_writech;
 	else
 		wtype = rpcrdma_replych;
@@ -620,7 +628,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		rtype = rpcrdma_noch;
 		rpcrdma_inline_pullup(rqst);
 		rpclen = rqst->rq_svec[0].iov_len;
-	} else if (rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
+	} else if (ddp_allowed && rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
 		rpclen = rqst->rq_svec[0].iov_len;
 		rpclen += rpcrdma_tail_pullup(&rqst->rq_snd_buf);

