From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/6] SUNRPC: Fix a bug in rpcauth_lookup_credcache()
Date: Thu, 13 Mar 2008 13:48:07 -0400
Message-ID: <20080313174806.13840.26367.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46691 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363AbYCMSCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:02:06 -0400
In-Reply-To: <20080313174806.13840.90325.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The hash bucket is for some reason always being set to zero.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/auth.h |    4 ++--
 net/sunrpc/auth.c           |    5 ++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 7a69ca3..84d5f3a 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -59,8 +59,8 @@ struct rpc_cred {
 /*
  * Client authentication handle
  */
-#define RPC_CREDCACHE_NR	8
-#define RPC_CREDCACHE_MASK	(RPC_CREDCACHE_NR - 1)
+#define RPC_CREDCACHE_HASHBITS	4
+#define RPC_CREDCACHE_NR	(1 << RPC_CREDCACHE_HASHBITS)
 struct rpc_cred_cache {
 	struct hlist_head	hashtable[RPC_CREDCACHE_NR];
 	spinlock_t		lock;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index eca941c..b38f6ee 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/errno.h>
+#include <linux/hash.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/spinlock.h>
 
@@ -280,7 +281,9 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	struct hlist_node *pos;
 	struct rpc_cred	*cred = NULL,
 			*entry, *new;
-	int		nr = 0;
+	unsigned int nr;
+
+	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
 
 	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
 		nr = acred->uid & RPC_CREDCACHE_MASK;

