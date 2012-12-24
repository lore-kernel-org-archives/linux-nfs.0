Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f50.google.com ([209.85.160.50]:61655 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab2LXCPQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Dec 2012 21:15:16 -0500
From: Akinobu Mita <akinobu.mita@gmail.com>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 21/29] net/sunrpc: rename random32() and net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:08 +0900
Message-Id: <1356315256-6572-22-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
 net/sunrpc/cache.c                  | 2 +-
 net/sunrpc/xprt.c                   | 2 +-
 net/sunrpc/xprtsock.c               | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 107c452..daf301f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -130,8 +130,8 @@ gss_krb5_make_confounder(char *p, u32 conflen)
 
 	/* initialize to random value */
 	if (i == 0) {
-		i = random32();
-		i = (i << 32) | random32();
+		i = prandom_u32();
+		i = (i << 32) | prandom_u32();
 	}
 
 	switch (conflen) {
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..0f85674 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -629,7 +629,7 @@ static void cache_limit_defers(void)
 
 	/* Consider removing either the first or the last */
 	if (cache_defer_cnt > DFR_MAX) {
-		if (net_random() & 1)
+		if (prandom_u32() & 1)
 			discard = list_entry(cache_defer_list.next,
 					     struct cache_deferred_req, recent);
 		else
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index bd462a5..0b51154 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1109,7 +1109,7 @@ static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
 {
-	xprt->xid = net_random();
+	xprt->xid = prandom_u32();
 }
 
 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 68b0a81..3b126ae 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1654,7 +1654,7 @@ static void xs_udp_timer(struct rpc_task *task)
 static unsigned short xs_get_random_port(void)
 {
 	unsigned short range = xprt_max_resvport - xprt_min_resvport;
-	unsigned short rand = (unsigned short) net_random() % range;
+	unsigned short rand = (unsigned short) prandom_u32() % range;
 	return rand + xprt_min_resvport;
 }
 
-- 
1.7.11.7

