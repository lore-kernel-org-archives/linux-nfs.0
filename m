Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:52689 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726325AbeI2Jgi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Sep 2018 05:36:38 -0400
Received: by mail-it1-f196.google.com with SMTP id 134-v6so4992506itz.2
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 20:09:56 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x13-v6sm2454479ioa.27.2018.09.28.20.09.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 28 Sep 2018 20:09:54 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Remove rpc_authflavor_lock in favour of RCU locking
Date: Fri, 28 Sep 2018 23:09:31 -0400
Message-Id: <20180929030931.71942-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Module removal is RCU safe by design, so we really have no need to
lock the auth_flavors[] array. Substitute a lockless scheme to
add/remove entries in the array, and then use rcu.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth.c | 128 ++++++++++++++++++++++------------------------
 1 file changed, 62 insertions(+), 66 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 59df5cdba0ac..32985aa515be 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -30,10 +30,9 @@ struct rpc_cred_cache {
 
 static unsigned int auth_hashbits = RPC_CREDCACHE_DEFAULT_HASHBITS;
 
-static DEFINE_SPINLOCK(rpc_authflavor_lock);
-static const struct rpc_authops *auth_flavors[RPC_AUTH_MAXFLAVOR] = {
-	&authnull_ops,		/* AUTH_NULL */
-	&authunix_ops,		/* AUTH_UNIX */
+static const struct rpc_authops __rcu *auth_flavors[RPC_AUTH_MAXFLAVOR] = {
+	[RPC_AUTH_NULL] = (const struct rpc_authops __force __rcu *)&authnull_ops,
+	[RPC_AUTH_UNIX] = (const struct rpc_authops __force __rcu *)&authunix_ops,
 	NULL,			/* others can be loadable modules */
 };
 
@@ -93,39 +92,65 @@ pseudoflavor_to_flavor(u32 flavor) {
 int
 rpcauth_register(const struct rpc_authops *ops)
 {
+	const struct rpc_authops *old;
 	rpc_authflavor_t flavor;
-	int ret = -EPERM;
 
 	if ((flavor = ops->au_flavor) >= RPC_AUTH_MAXFLAVOR)
 		return -EINVAL;
-	spin_lock(&rpc_authflavor_lock);
-	if (auth_flavors[flavor] == NULL) {
-		auth_flavors[flavor] = ops;
-		ret = 0;
-	}
-	spin_unlock(&rpc_authflavor_lock);
-	return ret;
+	old = cmpxchg((const struct rpc_authops ** __force)&auth_flavors[flavor], NULL, ops);
+	if (old == NULL || old == ops)
+		return 0;
+	return -EPERM;
 }
 EXPORT_SYMBOL_GPL(rpcauth_register);
 
 int
 rpcauth_unregister(const struct rpc_authops *ops)
 {
+	const struct rpc_authops *old;
 	rpc_authflavor_t flavor;
-	int ret = -EPERM;
 
 	if ((flavor = ops->au_flavor) >= RPC_AUTH_MAXFLAVOR)
 		return -EINVAL;
-	spin_lock(&rpc_authflavor_lock);
-	if (auth_flavors[flavor] == ops) {
-		auth_flavors[flavor] = NULL;
-		ret = 0;
-	}
-	spin_unlock(&rpc_authflavor_lock);
-	return ret;
+
+	old = cmpxchg((const struct rpc_authops ** __force)&auth_flavors[flavor], ops, NULL);
+	if (old == ops || old == NULL)
+		return 0;
+	return -EPERM;
 }
 EXPORT_SYMBOL_GPL(rpcauth_unregister);
 
+static const struct rpc_authops *
+rpcauth_get_authops(rpc_authflavor_t flavor)
+{
+	const struct rpc_authops *ops;
+
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		return NULL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(auth_flavors[flavor]);
+	if (ops == NULL) {
+		rcu_read_unlock();
+		request_module("rpc-auth-%u", flavor);
+		rcu_read_lock();
+		ops = rcu_dereference(auth_flavors[flavor]);
+		if (ops == NULL)
+			goto out;
+	}
+	if (!try_module_get(ops->owner))
+		ops = NULL;
+out:
+	rcu_read_unlock();
+	return ops;
+}
+
+static void
+rpcauth_put_authops(const struct rpc_authops *ops)
+{
+	module_put(ops->owner);
+}
+
 /**
  * rpcauth_get_pseudoflavor - check if security flavor is supported
  * @flavor: a security flavor
@@ -138,25 +163,16 @@ EXPORT_SYMBOL_GPL(rpcauth_unregister);
 rpc_authflavor_t
 rpcauth_get_pseudoflavor(rpc_authflavor_t flavor, struct rpcsec_gss_info *info)
 {
-	const struct rpc_authops *ops;
+	const struct rpc_authops *ops = rpcauth_get_authops(flavor);
 	rpc_authflavor_t pseudoflavor;
 
-	ops = auth_flavors[flavor];
-	if (ops == NULL)
-		request_module("rpc-auth-%u", flavor);
-	spin_lock(&rpc_authflavor_lock);
-	ops = auth_flavors[flavor];
-	if (ops == NULL || !try_module_get(ops->owner)) {
-		spin_unlock(&rpc_authflavor_lock);
+	if (!ops)
 		return RPC_AUTH_MAXFLAVOR;
-	}
-	spin_unlock(&rpc_authflavor_lock);
-
 	pseudoflavor = flavor;
 	if (ops->info2flavor != NULL)
 		pseudoflavor = ops->info2flavor(info);
 
-	module_put(ops->owner);
+	rpcauth_put_authops(ops);
 	return pseudoflavor;
 }
 EXPORT_SYMBOL_GPL(rpcauth_get_pseudoflavor);
@@ -176,25 +192,15 @@ rpcauth_get_gssinfo(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
 	const struct rpc_authops *ops;
 	int result;
 
-	if (flavor >= RPC_AUTH_MAXFLAVOR)
-		return -EINVAL;
-
-	ops = auth_flavors[flavor];
+	ops = rpcauth_get_authops(flavor);
 	if (ops == NULL)
-		request_module("rpc-auth-%u", flavor);
-	spin_lock(&rpc_authflavor_lock);
-	ops = auth_flavors[flavor];
-	if (ops == NULL || !try_module_get(ops->owner)) {
-		spin_unlock(&rpc_authflavor_lock);
 		return -ENOENT;
-	}
-	spin_unlock(&rpc_authflavor_lock);
 
 	result = -ENOENT;
 	if (ops->flavor2info != NULL)
 		result = ops->flavor2info(pseudoflavor, info);
 
-	module_put(ops->owner);
+	rpcauth_put_authops(ops);
 	return result;
 }
 EXPORT_SYMBOL_GPL(rpcauth_get_gssinfo);
@@ -212,15 +218,13 @@ EXPORT_SYMBOL_GPL(rpcauth_get_gssinfo);
 int
 rpcauth_list_flavors(rpc_authflavor_t *array, int size)
 {
-	rpc_authflavor_t flavor;
-	int result = 0;
+	const struct rpc_authops *ops;
+	rpc_authflavor_t flavor, pseudos[4];
+	int i, len, result = 0;
 
-	spin_lock(&rpc_authflavor_lock);
+	rcu_read_lock();
 	for (flavor = 0; flavor < RPC_AUTH_MAXFLAVOR; flavor++) {
-		const struct rpc_authops *ops = auth_flavors[flavor];
-		rpc_authflavor_t pseudos[4];
-		int i, len;
-
+		ops = rcu_dereference(auth_flavors[flavor]);
 		if (result >= size) {
 			result = -ENOMEM;
 			break;
@@ -245,7 +249,7 @@ rpcauth_list_flavors(rpc_authflavor_t *array, int size)
 			array[result++] = pseudos[i];
 		}
 	}
-	spin_unlock(&rpc_authflavor_lock);
+	rcu_read_unlock();
 
 	dprintk("RPC:       %s returns %d\n", __func__, result);
 	return result;
@@ -255,25 +259,17 @@ EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
 struct rpc_auth *
 rpcauth_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
-	struct rpc_auth		*auth;
+	struct rpc_auth	*auth = ERR_PTR(-EINVAL);
 	const struct rpc_authops *ops;
-	u32			flavor = pseudoflavor_to_flavor(args->pseudoflavor);
+	u32 flavor = pseudoflavor_to_flavor(args->pseudoflavor);
 
-	auth = ERR_PTR(-EINVAL);
-	if (flavor >= RPC_AUTH_MAXFLAVOR)
+	ops = rpcauth_get_authops(flavor);
+	if (ops == NULL)
 		goto out;
 
-	if ((ops = auth_flavors[flavor]) == NULL)
-		request_module("rpc-auth-%u", flavor);
-	spin_lock(&rpc_authflavor_lock);
-	ops = auth_flavors[flavor];
-	if (ops == NULL || !try_module_get(ops->owner)) {
-		spin_unlock(&rpc_authflavor_lock);
-		goto out;
-	}
-	spin_unlock(&rpc_authflavor_lock);
 	auth = ops->create(args, clnt);
-	module_put(ops->owner);
+
+	rpcauth_put_authops(ops);
 	if (IS_ERR(auth))
 		return auth;
 	if (clnt->cl_auth)
-- 
2.17.1
