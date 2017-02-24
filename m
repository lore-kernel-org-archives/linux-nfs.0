Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5726 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751451AbdBXWUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:10 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 10/17] SUNRPC AUTH_GSS store and use gss3 label assertion
Date: Fri, 24 Feb 2017 17:19:46 -0500
Message-ID: <20170224221953.5502-11-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Store gss3 assertions in the parent gss_cl_ctx. Choose to use a child
or parent context handle in gss_marshal and in gss3_reply_verifier.

Note: Need to add a test for full mode labeling. Current code only tests
for the GSS version == 3 and selinx enabled.

Perhaps an auth_rpcgss module parameter?

In gss_cred_set_ctx() after assigning a new gss context to a credential,
call gss3_create_label which will kick off an RPCSED_GSS_CREATE for the
thread's label if selinux is enabled.

In gss_match(), check if the current threads SeLinux label (sid)  has
a matching label assertion. If not, kick off an RPCSEC_GSS_CREATE for
the thread's label.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/svcauth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c     | 69 ++++++++++++++++++++++++++++++++++++--
 net/sunrpc/auth_gss/svcauth_gss.c  |  2 +-
 3 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 726aff1..af45bff 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -22,6 +22,7 @@ int gss_svc_init_net(struct net *net);
 void gss_svc_shutdown_net(struct net *net);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 u32 svcauth_gss_flavor(struct auth_domain *dom);
+int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 18b97a7..0b925fb 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -57,6 +57,8 @@
 #include "../netns.h"
 
 static int gss3_create_label(struct rpc_cred *cred, int gss_vers);
+static struct gss3_assert *gss3_use_child_handle(struct gss_cl_ctx *ctx);
+static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -1472,13 +1474,16 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
+	struct gss3_assert *g3a;
 	int ret;
+	bool gss3_label_enabled = false;
 
 	if (test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
 		goto out;
 	/* Don't match with creds that have expired. */
 	rcu_read_lock();
 	ctx = rcu_dereference(gss_cred->gc_ctx);
+	gss3_label_enabled = gss3_label_assertion_is_enabled(ctx->gc_v);
 	if (!ctx || time_after(jiffies, ctx->gc_expiry)) {
 		rcu_read_unlock();
 		return 0;
@@ -1509,6 +1514,13 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 		/* tell NFS layer that key will expire soon */
 		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
 	}
+	if (ret && gss3_label_enabled) {
+		ctx = gss_cred_get_ctx(rc);
+		g3a = gss3_match_label(&ctx->gc_alist);
+		if (!g3a)
+			gss3_create_label(rc, ctx->gc_v);
+		gss_put_ctx(ctx);
+	}
 	return ret;
 }
 
@@ -1529,6 +1541,7 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	struct xdr_netobj mic;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
+	struct gss3_assert *g3a;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
@@ -1543,7 +1556,11 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	*p++ = htonl((u32)ctx->gc_proc);
 	*p++ = htonl((u32)req->rq_seqno);
 	*p++ = htonl((u32)gss_cred->gc_service);
-	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(ctx);
+	if (g3a)
+		p = xdr_encode_netobj(p, &g3a->gss3_handle);
+	else
+		p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
 	*cred_len = htonl((p - (cred_len + 1)) << 2);
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
@@ -1640,6 +1657,49 @@ gss3_insert_assertion(struct gss3_assert_list *alist, struct gss3_assert *g3a)
 	spin_unlock(&alist->assert_lock);
 }
 
+static struct gss3_assert *
+gss3_match_label(struct gss3_assert_list *in)
+{
+	struct gss3_assert *found;
+	struct xdr_netobj label;
+	int ret;
+
+	/* Need a Full Mode stanza in /etc/selinux/config to check */
+	if (!gss3_label_assertion_is_enabled(RPC_GSS3_VERSION))
+		return NULL;
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
+gss3_use_child_handle(struct gss_cl_ctx *ctx)
+{
+	struct gss3_assert *g3a = NULL;
+
+	if (gss3_label_assertion_is_enabled(ctx->gc_v) &&
+	    ctx->gc_proc == RPC_GSS_PROC_DATA)
+		g3a = gss3_match_label(&ctx->gc_alist);
+	return g3a;
+}
+
 /**
  * GSS3_createargs_maxsz and GSS3_createres_maxsz
  * include no rgss3_assertion_u payload.
@@ -1991,6 +2051,7 @@ gss3_reply_verifier(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 {
 	struct gss_cred *g_cred = container_of(cred, struct gss_cred, gc_base);
 	void	*gss3_buf = NULL;
+	struct gss3_assert *g3a;
 	__be32 *crlen, *ptr = NULL;
 	int len;
 
@@ -2017,7 +2078,11 @@ gss3_reply_verifier(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	*ptr++ = htonl(ctx->gc_proc);
 	*ptr++ = *seq;
 	*ptr++ = htonl(g_cred->gc_service);
-	ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(ctx);
+	if (g3a)
+		ptr = xdr_encode_netobj(ptr, &g3a->gss3_handle);
+	else
+		ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
 
 	/* backfill cred length */
 	*crlen = htonl((ptr - (crlen + 1)) << 2);
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
2.9.3

