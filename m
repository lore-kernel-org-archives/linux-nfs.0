Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57029 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752704Ab0LOGtK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 01:49:10 -0500
Message-ID: <4D086478.7090106@cn.fujitsu.com>
Date: Wed, 15 Dec 2010 14:47:20 +0800
From: Shan Wei <shanwei@cn.fujitsu.com>
To: bfields@fieldses.org, neilb@suse.de, Trond.Myklebust@netapp.com,
        steved@redhat.com, tj@kernel.org
CC: David Miller <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        Network-Maillist <netdev@vger.kernel.org>
Subject: [PATCH 2/3] net: sunrpc: kill unused macros
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These macros never be used for several years.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |    2 --
 net/sunrpc/svcauth.c              |    1 -
 net/sunrpc/svcauth_unix.c         |    2 --
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index dec2a6f..bcdae78 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -67,7 +67,6 @@ static int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
 
 #define	RSI_HASHBITS	6
 #define	RSI_HASHMAX	(1<<RSI_HASHBITS)
-#define	RSI_HASHMASK	(RSI_HASHMAX-1)
 
 struct rsi {
 	struct cache_head	h;
@@ -319,7 +318,6 @@ static struct rsi *rsi_update(struct rsi *new, struct rsi *old)
 
 #define	RSC_HASHBITS	10
 #define	RSC_HASHMAX	(1<<RSC_HASHBITS)
-#define	RSC_HASHMASK	(RSC_HASHMAX-1)
 
 #define GSS_SEQ_WIN	128
 
diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index 4e9393c..7963569 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -118,7 +118,6 @@ EXPORT_SYMBOL_GPL(svc_auth_unregister);
 
 #define	DN_HASHBITS	6
 #define	DN_HASHMAX	(1<<DN_HASHBITS)
-#define	DN_HASHMASK	(DN_HASHMAX-1)
 
 static struct hlist_head	auth_domain_table[DN_HASHMAX];
 static spinlock_t	auth_domain_lock =
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 560677d..a04ac91 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -85,7 +85,6 @@ static void svcauth_unix_domain_release(struct auth_domain *dom)
  */
 #define	IP_HASHBITS	8
 #define	IP_HASHMAX	(1<<IP_HASHBITS)
-#define	IP_HASHMASK	(IP_HASHMAX-1)
 
 struct ip_map {
 	struct cache_head	h;
@@ -497,7 +496,6 @@ svcauth_unix_info_release(struct svc_xprt *xpt)
  */
 #define	GID_HASHBITS	8
 #define	GID_HASHMAX	(1<<GID_HASHBITS)
-#define	GID_HASHMASK	(GID_HASHMAX - 1)
 
 struct unix_gid {
 	struct cache_head	h;
-- 
1.6.3.3
