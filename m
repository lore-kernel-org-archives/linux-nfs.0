Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33881 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753786AbeAHFcZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 00:32:25 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 08 Jan 2018 16:26:19 +1100
Subject: [PATCH 17/20] SUNRPC: remove generic cred code.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151538917936.25812.8286111391105756715.stgit@noble>
In-Reply-To: <151538903497.25812.13293229343061416612.stgit@noble>
References: <151538903497.25812.13293229343061416612.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is no longer used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h |    6 -
 net/sunrpc/Makefile         |    2 
 net/sunrpc/auth.c           |   17 ----
 net/sunrpc/auth_generic.c   |  198 -------------------------------------------
 net/sunrpc/auth_null.c      |    2 
 5 files changed, 2 insertions(+), 223 deletions(-)
 delete mode 100644 net/sunrpc/auth_generic.c

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index ff289e8b24c0..33d8ca8bb558 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -104,7 +104,6 @@ struct rpc_auth_create_args {
 
 /* Flags for rpcauth_lookupcred() */
 #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
-#define RPCAUTH_LOOKUP_RCU		0x02	/* lock-less lookup */
 
 /*
  * Client authentication ops
@@ -149,15 +148,10 @@ extern const struct rpc_authops	authunix_ops;
 extern const struct rpc_authops	authnull_ops;
 
 int __init		rpc_init_authunix(void);
-int __init		rpc_init_generic_auth(void);
 int __init		rpcauth_init_module(void);
 void			rpcauth_remove_module(void);
-void			rpc_destroy_generic_auth(void);
 void 			rpc_destroy_authunix(void);
 
-struct rpc_cred *	rpc_lookup_cred(void);
-struct rpc_cred *	rpc_lookup_cred_nonblock(void);
-struct rpc_cred *	rpc_lookup_generic_cred(struct auth_cred *, int, gfp_t);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(struct rpc_auth_create_args *,
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 090658c3da12..9488600451e8 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
 
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
-	    auth.o auth_null.o auth_unix.o auth_generic.o \
+	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 6121eaa94e0e..cfe9d2dd6aa3 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -551,12 +551,6 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
-		if (flags & RPCAUTH_LOOKUP_RCU) {
-			if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) &&
-			    !test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags))
-				cred = entry;
-			break;
-		}
 		spin_lock(&cache->lock);
 		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
 			spin_unlock(&cache->lock);
@@ -571,9 +565,6 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred != NULL)
 		goto found;
 
-	if (flags & RPCAUTH_LOOKUP_RCU)
-		return ERR_PTR(-ECHILD);
-
 	new = auth->au_ops->crcreate(auth, acred, flags, gfp);
 	if (IS_ERR(new)) {
 		cred = new;
@@ -902,15 +893,10 @@ int __init rpcauth_init_module(void)
 	err = rpc_init_authunix();
 	if (err < 0)
 		goto out1;
-	err = rpc_init_generic_auth();
-	if (err < 0)
-		goto out2;
 	err = register_shrinker(&rpc_cred_shrinker);
 	if (err < 0)
-		goto out3;
+		goto out2;
 	return 0;
-out3:
-	rpc_destroy_generic_auth();
 out2:
 	rpc_destroy_authunix();
 out1:
@@ -920,6 +906,5 @@ int __init rpcauth_init_module(void)
 void rpcauth_remove_module(void)
 {
 	rpc_destroy_authunix();
-	rpc_destroy_generic_auth();
 	unregister_shrinker(&rpc_cred_shrinker);
 }
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
deleted file mode 100644
index 0cf564139815..000000000000
--- a/net/sunrpc/auth_generic.c
+++ /dev/null
@@ -1,198 +0,0 @@
-/*
- * Generic RPC credential
- *
- * Copyright (C) 2008, Trond Myklebust <Trond.Myklebust@netapp.com>
- */
-
-#include <linux/err.h>
-#include <linux/slab.h>
-#include <linux/types.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/sunrpc/auth.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/debug.h>
-#include <linux/sunrpc/sched.h>
-
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY	RPCDBG_AUTH
-#endif
-
-struct generic_cred {
-	struct rpc_cred gc_base;
-	struct auth_cred acred;
-};
-
-static struct rpc_auth generic_auth;
-static const struct rpc_credops generic_credops;
-
-/*
- * Public call interface
- */
-struct rpc_cred *rpc_lookup_cred(void)
-{
-	return rpcauth_lookupcred(&generic_auth, 0);
-}
-EXPORT_SYMBOL_GPL(rpc_lookup_cred);
-
-struct rpc_cred *
-rpc_lookup_generic_cred(struct auth_cred *acred, int flags, gfp_t gfp)
-{
-	return rpcauth_lookup_credcache(&generic_auth, acred, flags, gfp);
-}
-EXPORT_SYMBOL_GPL(rpc_lookup_generic_cred);
-
-struct rpc_cred *rpc_lookup_cred_nonblock(void)
-{
-	return rpcauth_lookupcred(&generic_auth, RPCAUTH_LOOKUP_RCU);
-}
-EXPORT_SYMBOL_GPL(rpc_lookup_cred_nonblock);
-
-static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
-		struct rpc_cred *cred, int lookupflags)
-{
-	struct rpc_auth *auth = task->tk_client->cl_auth;
-	struct auth_cred *acred = &container_of(cred, struct generic_cred, gc_base)->acred;
-
-	return auth->au_ops->lookup_cred(auth, acred, lookupflags);
-}
-
-static int
-generic_hash_cred(struct auth_cred *acred, unsigned int hashbits)
-{
-	return hash_64(from_kgid(&init_user_ns, acred->cred->fsgid) |
-		((u64)from_kuid(&init_user_ns, acred->cred->fsuid) <<
-			(sizeof(gid_t) * 8)), hashbits);
-}
-
-/*
- * Lookup generic creds for current process
- */
-static struct rpc_cred *
-generic_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
-{
-	return rpcauth_lookup_credcache(&generic_auth, acred, flags, GFP_KERNEL);
-}
-
-static struct rpc_cred *
-generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t gfp)
-{
-	struct generic_cred *gcred;
-
-	gcred = kmalloc(sizeof(*gcred), gfp);
-	if (gcred == NULL)
-		return ERR_PTR(-ENOMEM);
-
-	rpcauth_init_cred(&gcred->gc_base, acred, &generic_auth, &generic_credops);
-	gcred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
-
-	gcred->acred.cred = gcred->gc_base.cr_cred;
-	gcred->acred.principal = acred->principal;
-
-	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
-			gcred->acred.principal ? "machine" : "generic",
-			gcred,
-			from_kuid(&init_user_ns, acred->cred->fsuid),
-			from_kgid(&init_user_ns, acred->cred->fsgid));
-	return &gcred->gc_base;
-}
-
-static void
-generic_free_cred(struct rpc_cred *cred)
-{
-	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
-
-	dprintk("RPC:       generic_free_cred %p\n", gcred);
-	kfree(gcred);
-}
-
-static void
-generic_free_cred_callback(struct rcu_head *head)
-{
-	struct rpc_cred *cred = container_of(head, struct rpc_cred, cr_rcu);
-	generic_free_cred(cred);
-}
-
-static void
-generic_destroy_cred(struct rpc_cred *cred)
-{
-	call_rcu(&cred->cr_rcu, generic_free_cred_callback);
-}
-
-static int
-machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flags)
-{
-	if (!gcred->acred.principal ||
-	    gcred->acred.principal != acred->principal ||
-	    !uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
-	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid))
-		return 0;
-	return 1;
-}
-
-/*
- * Match credentials against current process creds.
- */
-static int
-generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
-{
-	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
-	int i;
-	struct group_info *a, *g;
-
-	if (acred->principal)
-		return machine_cred_match(acred, gcred, flags);
-
-	if (!uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
-	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid) ||
-	    gcred->acred.principal != NULL)
-		goto out_nomatch;
-
-	a = acred->cred->group_info;
-	g = gcred->acred.cred->group_info;
-	/* Optimisation in the case where pointers are identical... */
-	if (a == g)
-		goto out_match;
-
-	/* Slow path... */
-	if (g->ngroups != a->ngroups)
-		goto out_nomatch;
-	for (i = 0; i < g->ngroups; i++) {
-		if (!gid_eq(g->gid[i], a->gid[i]))
-			goto out_nomatch;
-	}
-out_match:
-	return 1;
-out_nomatch:
-	return 0;
-}
-
-int __init rpc_init_generic_auth(void)
-{
-	return rpcauth_init_credcache(&generic_auth);
-}
-
-void rpc_destroy_generic_auth(void)
-{
-	rpcauth_destroy_credcache(&generic_auth);
-}
-
-static const struct rpc_authops generic_auth_ops = {
-	.owner = THIS_MODULE,
-	.au_name = "Generic",
-	.hash_cred = generic_hash_cred,
-	.lookup_cred = generic_lookup_cred,
-	.crcreate = generic_create_cred,
-};
-
-static struct rpc_auth generic_auth = {
-	.au_ops = &generic_auth_ops,
-	.au_count = ATOMIC_INIT(0),
-};
-
-static const struct rpc_credops generic_credops = {
-	.cr_name = "Generic cred",
-	.crdestroy = generic_destroy_cred,
-	.crbind = generic_bind_cred,
-	.crmatch = generic_match,
-};
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index c3d126adad4d..b5cc89f63162 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -36,8 +36,6 @@ nul_destroy(struct rpc_auth *auth)
 static struct rpc_cred *
 nul_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 {
-	if (flags & RPCAUTH_LOOKUP_RCU)
-		return &null_cred;
 	return get_rpccred(&null_cred);
 }
 


