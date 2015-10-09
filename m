Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:51409 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbbJIOOU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 10:14:20 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Subject: [PATCH] sunrpc: avoid warning in gss_key_timeout
Date: Fri, 09 Oct 2015 16:13:45 +0200
Message-ID: <6995148.OQIKcAcqHW@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gss_key_timeout() function causes a harmless warning in some
configurations, e.g. ARM imx_v6_v7_defconfig with gcc-5.2, if the
compiler cannot figure out the state of the 'expire' variable across
an rcu_read_unlock():

net/sunrpc/auth_gss/auth_gss.c: In function 'gss_key_timeout':
net/sunrpc/auth_gss/auth_gss.c:1422:211: warning: 'expire' may be used uninitialized in this function [-Wmaybe-uninitialized]

To avoid this warning without adding a bogus initialization, this
rewrites the function so the comparison is done inside of the
critical section. As a side-effect, it also becomes slightly
easier to understand because the implementation now more closely
resembles the comment above it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: c5e6aecd034e7 ("sunrpc: fix RCU handling of gc_ctx field")

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index dace13d7638e..799e65b944b9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1411,17 +1411,16 @@ gss_key_timeout(struct rpc_cred *rc)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
-	unsigned long now = jiffies;
-	unsigned long expire;
+	unsigned long timeout = jiffies + (gss_key_expire_timeo * HZ);
+	int ret = 0;
 
 	rcu_read_lock();
 	ctx = rcu_dereference(gss_cred->gc_ctx);
-	if (ctx)
-		expire = ctx->gc_expiry - (gss_key_expire_timeo * HZ);
+	if (!ctx || time_after(timeout, ctx->gc_expiry))
+		ret = -EACCES;
 	rcu_read_unlock();
-	if (!ctx || time_after(now, expire))
-		return -EACCES;
-	return 0;
+
+	return ret;
 }
 
 static int

