Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:62496 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752633AbdG1UWJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:09 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 06/12] SUNRPC AUTH_GSS store and use gss3 label assertion
Date: Fri, 28 Jul 2017 16:21:52 -0400
Message-ID: <1501273318-14200-7-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

After assigning a new gss context to a credential,
call gss3_create_label which will kick off an RPCSED_GSS_CREATE for the
thread's label if selinux is enabled.

In gss_match(), check if the current threads SeLinux label (sid)  has
a matching label assertion. If not, kick off an RPCSEC_GSS_CREATE for
the thread's label.

Choose to use a child or parent context handle in gss_marshal and in
gss3_reply_verifier.

Add the RPC_GSS_PROC_CREATE case for wrap and unwrap

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/svcauth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c     | 74 +++++++++++++++++++++++++++++++++++---
 net/sunrpc/auth_gss/svcauth_gss.c  |  2 +-
 3 files changed, 72 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 726aff1..af45bff 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -22,6 +22,7 @@
 void gss_svc_shutdown_net(struct net *net);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 u32 svcauth_gss_flavor(struct auth_domain *dom);
+int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 46c0068..1014521 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -57,6 +57,9 @@
 #include "../netns.h"
 
 static int gss3_create_label(struct rpc_cred *cred);
+static struct gss3_assert *gss3_use_child_handle(struct rpc_cred *cred,
+						 struct gss_cl_ctx *ctx);
+static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -1480,6 +1483,9 @@ static void gss_pipe_free(struct gss_pipe *p)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
+	struct gss3_assert *g3a;
+	rpc_authflavor_t flavor = rc->cr_auth->au_flavor;
+	bool use_labels = false;
 	int ret;
 
 	if (test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
@@ -1491,6 +1497,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 		rcu_read_unlock();
 		return 0;
 	}
+	use_labels = gss3_label_assertion_is_enabled(ctx->gc_v, flavor);
 	rcu_read_unlock();
 	if (!test_bit(RPCAUTH_CRED_UPTODATE, &rc->cr_flags))
 		return 0;
@@ -1517,6 +1524,13 @@ static void gss_pipe_free(struct gss_pipe *p)
 		/* tell NFS layer that key will expire soon */
 		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
 	}
+	if (ret && use_labels) {
+		ctx = gss_cred_get_ctx(rc);
+		g3a = gss3_match_label(&ctx->gc_alist);
+		if (!g3a)
+			gss3_create_label(rc);
+		gss_put_ctx(ctx);
+	}
 	return ret;
 }
 
@@ -1537,6 +1551,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 	struct xdr_netobj mic;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
+	struct gss3_assert *g3a;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
@@ -1551,7 +1566,11 @@ static void gss_pipe_free(struct gss_pipe *p)
 	*p++ = htonl((u32)ctx->gc_proc);
 	*p++ = htonl((u32)req->rq_seqno);
 	*p++ = htonl((u32)gss_cred->gc_service);
-	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(cred, ctx);
+	if (g3a)
+		p = xdr_encode_netobj(p, &g3a->gss3_handle);
+	else
+		p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
 	*cred_len = htonl((p - (cred_len + 1)) << 2);
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
@@ -1653,6 +1672,46 @@ static void gss3_free_label(struct gss3_label *gl)
 	kfree(gl->la_label.data);
 }
 
+static struct gss3_assert *
+gss3_match_label(struct gss3_assert_list *in)
+{
+	struct gss3_assert *found;
+	struct xdr_netobj label;
+	int ret;
+
+	/* grab the current threads subject label */
+	ret = security_current_sid_to_context((char **)&label.data, &label.len);
+	if (ret)
+		return NULL;
+	rcu_read_lock();
+	list_for_each_entry_rcu(found, &in->assert_list, gss3_list) {
+		struct gss3_label *gl;
+
+		if (found->gss3_assertion->au_type != GSS3_LABEL)
+			continue;
+		gl = &found->gss3_assertion->u.au_label;
+		if (netobj_equal(&gl->la_label, &label))
+			goto out;
+	}
+	found = NULL;
+out:
+	rcu_read_lock();
+	kfree(label.data);
+	return found;
+}
+
+static struct gss3_assert *
+gss3_use_child_handle(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
+{
+	struct gss3_assert *g3a = NULL;
+	rpc_authflavor_t flavor = cred->cr_auth->au_flavor;
+
+	if (gss3_label_assertion_is_enabled(ctx->gc_v, flavor) &&
+	    ctx->gc_proc == RPC_GSS_PROC_DATA)
+		g3a = gss3_match_label(&ctx->gc_alist);
+	return g3a;
+}
+
 /**
  * GSS3_createargs_maxsz and GSS3_createres_maxsz
  * include no rgss3_assertion_u payload.
@@ -2036,6 +2095,7 @@ struct rpc_procinfo gss3_ops[] = {
 {
 	struct gss_cred *g_cred = container_of(cred, struct gss_cred, gc_base);
 	void	*gss3_buf = NULL;
+	struct gss3_assert *g3a;
 	__be32 *crlen, *ptr = NULL;
 	int len;
 
@@ -2062,7 +2122,11 @@ struct rpc_procinfo gss3_ops[] = {
 	*ptr++ = htonl(ctx->gc_proc);
 	*ptr++ = *seq;
 	*ptr++ = htonl(g_cred->gc_service);
-	ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(cred, ctx);
+	if (g3a)
+		ptr = xdr_encode_netobj(ptr, &g3a->gss3_handle);
+	else
+		ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
 
 	/* backfill cred length */
 	*crlen = htonl((ptr - (crlen + 1)) << 2);
@@ -2315,7 +2379,8 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	int             status = -EIO;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE)) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
@@ -2429,7 +2494,8 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	int		savedlen = head->iov_len;
 	int             status = -EIO;
 
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE))
 		goto out_decode;
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index a54a7a3..aa7cb3b 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -63,7 +63,7 @@
  *
  */
 
-static int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
+int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
 {
 	return a->len == b->len && 0 == memcmp(a->data, b->data, a->len);
 }
-- 
1.8.3.1

