Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:44150 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaFVAw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2014 20:52:27 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so4644976qgd.5
        for <linux-nfs@vger.kernel.org>; Sat, 21 Jun 2014 17:52:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] auth_gss: fetch the acceptor name out of the downcall
Date: Sat, 21 Jun 2014 20:52:15 -0400
Message-Id: <1403398337-4174-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403398337-4174-1-git-send-email-jlayton@primarydata.com>
References: <1403398337-4174-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@poochiereds.net>

If rpc.gssd sends us an acceptor name string trailing the context token,
stash it as part of the context.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
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
index b6e440baccc3..e34af68603bd 100644
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
1.9.3

