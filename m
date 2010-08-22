Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr18.xs4all.nl ([194.109.24.38]:3949 "EHLO
	smtp-vbr18.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab0HVSkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Aug 2010 14:40:01 -0400
Date: Sun, 22 Aug 2010 20:31:49 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/03] sunrpc: scale hashtable cache size with memory
Message-ID: <20100822183149.GC26607@xs4all.net>
References: <20100822182848.GA26590@xs4all.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100822182848.GA26590@xs4all.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Set the number of entries of the authcache to 4096 on servers
with 4G of memory or more. Because kmallocing more than a few K
is frowned upon, change the allocator from kmalloc to __get_free_pages.
Since the minimum allocation size of __get_free_pages is 1 page,
set the number of entries in the authcache to PAGE_SIZE / (entry_size)
on servers with < 4G of memory so that exactly one page is used.

Signed-off-by: Miquel van Smoorenburg <mikevs@xs4all.net>

diff -ruN linux-2.6.36-rc1.orig/net/sunrpc/auth.c linux-2.6.36-rc1/net/sunrpc/auth.c
--- linux-2.6.36-rc1.orig/net/sunrpc/auth.c	2010-08-16 02:41:37.000000000 +0200
+++ linux-2.6.36-rc1/net/sunrpc/auth.c	2010-08-22 17:02:27.896009116 +0200
@@ -19,14 +19,15 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define RPC_CREDCACHE_DEFAULT_HASHBITS	(4)
+#define RPC_CREDCACHE_LARGE_HASHBITS	(12)
 struct rpc_cred_cache {
 	struct hlist_head	*hashtable;
 	unsigned int		hashbits;
+	unsigned int		order;
 	spinlock_t		lock;
 };
 
-static unsigned int auth_hashbits = RPC_CREDCACHE_DEFAULT_HASHBITS;
+static unsigned int auth_hashbits;
 
 static DEFINE_SPINLOCK(rpc_authflavor_lock);
 static const struct rpc_authops *auth_flavors[RPC_AUTH_MAXFLAVOR] = {
@@ -195,14 +196,14 @@
 rpcauth_init_credcache(struct rpc_auth *auth)
 {
 	struct rpc_cred_cache *new;
-	unsigned int hashsize;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_nocache;
 	new->hashbits = auth_hashbits;
-	hashsize = 1U << new->hashbits;
-	new->hashtable = kcalloc(hashsize, sizeof(new->hashtable[0]), GFP_KERNEL);
+	new->order = get_order((1U << new->hashbits) * sizeof(new->hashtable[0]));
+	new->hashtable = (struct hlist_head  *)
+			__get_free_pages(GFP_KERNEL|__GFP_ZERO, new->order);
 	if (!new->hashtable)
 		goto out_nohashtbl;
 	spin_lock_init(&new->lock);
@@ -274,7 +275,7 @@
 	if (cache) {
 		auth->au_credcache = NULL;
 		rpcauth_clear_credcache(cache);
-		kfree(cache->hashtable);
+		free_pages((unsigned long)cache->hashtable, cache->order);
 		kfree(cache);
 	}
 }
@@ -642,8 +643,20 @@
 
 int __init rpcauth_init_module(void)
 {
+	struct sysinfo si;
+	unsigned long gb;
 	int err;
 
+	if (auth_hashbits == 0) {
+		 /* auto-size: < 4GB: whatever fits one page, >= 4GB: 12 bits */
+		si_meminfo(&si);
+		gb = (si.totalram - si.totalhigh + 4096) >> (30 - PAGE_SHIFT);
+		if (gb < 4)
+			auth_hashbits = ilog2(PAGE_SIZE / sizeof(struct hlist_head));
+		else
+			auth_hashbits = RPC_CREDCACHE_LARGE_HASHBITS;
+	}
+
 	err = rpc_init_authunix();
 	if (err < 0)
 		goto out1;
