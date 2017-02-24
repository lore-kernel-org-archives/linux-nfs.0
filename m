Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751435AbdBXWUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:06 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 05/17] SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
Date: Fri, 24 Feb 2017 17:19:41 -0500
Message-ID: <20170224221953.5502-6-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c  | 16 ++++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 8939db4..4ab63a9 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -71,6 +71,7 @@ struct rpc_gss_init_res {
 
 struct gss_cl_ctx {
 	atomic_t		count;
+	u32			gc_v;
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
 	spinlock_t		gc_seq_lock;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d8395ce..216a78e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -213,6 +213,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	unsigned int seclen;
 	unsigned int timeout;
 	unsigned long now = jiffies;
+	unsigned int gss_v;
 	u32 window_size;
 	int ret;
 
@@ -226,6 +227,13 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	if (timeout == 0)
 		timeout = GSSD_MIN_TIMEOUT;
 	ctx->gc_expiry = now + ((unsigned long)timeout * HZ);
+
+	/* RPCSEC_GSS version used to obtain context */
+	p = simple_get_bytes(p, end, &gss_v, sizeof(gss_v));
+	if (IS_ERR(p))
+		goto err;
+	ctx->gc_v = gss_v;
+
 	/* Sequence number window. Determines the maximum number of
 	 * simultaneous requests
 	 */
@@ -1511,10 +1519,10 @@ gss_marshal(struct rpc_task *task, __be32 *p)
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
2.9.3

