Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:62496 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbdG1UWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:06 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 03/12] SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
Date: Fri, 28 Jul 2017 16:21:49 -0400
Message-ID: <1501273318-14200-4-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Due to the addition of RPC_GSS3_VERSION.  Assign RPC_GSS_VERSION (version 1)
if GSS version is not part of the gssd downcall.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c  | 27 ++++++++++++++++++++-------
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index cf5e694..dbcdcc2 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -70,6 +70,7 @@ struct rpc_gss_init_res {
 
 struct gss_cl_ctx {
 	atomic_t		count;
+	u32			gc_v;
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
 	spinlock_t		gc_seq_lock;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4f16953..3c7fa5d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -209,10 +209,11 @@ struct gss_auth {
 static const void *
 gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct gss_api_mech *gm)
 {
-	const void *q;
+	const void *q, *save;
 	unsigned int seclen;
 	unsigned int timeout;
 	unsigned long now = jiffies;
+	unsigned int gss_v;
 	u32 window_size;
 	int ret;
 
@@ -274,10 +275,22 @@ struct gss_auth {
 	p = simple_get_netobj(q, end, &ctx->gc_acceptor);
 	if (IS_ERR(p))
 		goto err;
+
+	/** Pull in RPCSEC_GSS version if there is one.
+         * Assign RPC_GSS_VERSION (version 1) as the default.
+	 */
+	save = p;
+	p = simple_get_bytes(p, end, &gss_v, sizeof(gss_v));
+	if (IS_ERR(p)) {
+		ctx->gc_v = RPC_GSS_VERSION;
+		p = save;
+	} else {
+		ctx->gc_v = gss_v;
+	}
 done:
-	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u acceptor %.*s\n",
+	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u acceptor %.*s gss version %d\n",
 		__func__, ctx->gc_expiry, now, timeout, ctx->gc_acceptor.len,
-		ctx->gc_acceptor.data);
+		ctx->gc_acceptor.data, ctx->gc_v);
 	return p;
 err:
 	dprintk("RPC:       %s returns error %ld\n", __func__, -PTR_ERR(p));
@@ -1511,10 +1524,10 @@ static void gss_pipe_free(struct gss_pipe *p)
 	req->rq_seqno = ctx->gc_seq++;
 	spin_unlock(&ctx->gc_seq_lock);
 
-	*p++ = htonl((u32) RPC_GSS_VERSION);
-	*p++ = htonl((u32) ctx->gc_proc);
-	*p++ = htonl((u32) req->rq_seqno);
-	*p++ = htonl((u32) gss_cred->gc_service);
+	*p++ = htonl((u32)ctx->gc_v);
+	*p++ = htonl((u32)ctx->gc_proc);
+	*p++ = htonl((u32)req->rq_seqno);
+	*p++ = htonl((u32)gss_cred->gc_service);
 	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
 	*cred_len = htonl((p - (cred_len + 1)) << 2);
 
-- 
1.8.3.1

