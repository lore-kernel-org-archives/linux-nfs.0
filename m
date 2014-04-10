Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:51844 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758550AbaDJUaD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:30:03 -0400
Received: by mail-qc0-f175.google.com with SMTP id e16so5019605qcx.34
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:30:02 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] auth_gss: fetch the acceptor name out of the downcall
Date: Thu, 10 Apr 2014 16:29:49 -0400
Message-Id: <1397161791-29144-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
References: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If rpc.gssd sends us an acceptor name string trailing the context token,
stash it as part of the context.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c  | 20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index f1cfd4c85cd0..cbc6875fb9cf 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -71,6 +71,7 @@ struct gss_cl_ctx {
 	spinlock_t		gc_seq_lock;
 	struct gss_ctx __rcu	*gc_gss_ctx;
 	struct xdr_netobj	gc_wire_ctx;
+	struct xdr_netobj	gc_acceptor;
 	u32			gc_win;
 	unsigned long		gc_expiry;
 	struct rcu_head		gc_rcu;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 36e431ee1c90..f341aabb92db 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -262,9 +262,22 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		p = ERR_PTR(ret);
 		goto err;
 	}
-	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u\n",
-		__func__, ctx->gc_expiry, now, timeout);
-	return q;
+
+	/* is there any trailing data? */
+	if (q == end) {
+		p = q;
+		goto done;
+	}
+
+	/* pull in acceptor name (if there is one) */
+	p = simple_get_netobj(q, end, &ctx->gc_acceptor);
+	if (IS_ERR(p))
+		goto err;
+done:
+	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u acceptor %.*s\n",
+		__func__, ctx->gc_expiry, now, timeout, ctx->gc_acceptor.len,
+		ctx->gc_acceptor.data);
+	return p;
 err:
 	dprintk("RPC:       %s returns error %ld\n", __func__, -PTR_ERR(p));
 	return p;
@@ -1225,6 +1238,7 @@ gss_do_free_ctx(struct gss_cl_ctx *ctx)
 
 	gss_delete_sec_context(&ctx->gc_gss_ctx);
 	kfree(ctx->gc_wire_ctx.data);
+	kfree(ctx->gc_acceptor.data);
 	kfree(ctx);
 }
 
-- 
1.9.0

