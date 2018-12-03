Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDED4C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:34:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8815420834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:34:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8815420834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725932AbeLCAeN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:34:13 -0500
Received: from mx2.suse.de ([195.135.220.15]:41460 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725927AbeLCAeN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:34:13 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 9B95BACA8;
        Mon,  3 Dec 2018 00:34:05 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:31 +1100
Subject: [PATCH 20/23] SUNRPC: remove generic cred code.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703101.28598.13493670878841722690.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is no longer used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h |    6 -
 net/sunrpc/Makefile         |    2 
 net/sunrpc/auth.c           |   18 ----
 net/sunrpc/auth_generic.c   |  199 -------------------------------------------
 net/sunrpc/auth_null.c      |    2 
 5 files changed, 2 insertions(+), 225 deletions(-)
 delete mode 100644 net/sunrpc/auth_generic.c

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a43e065a0b07..b9449aa27fed 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -104,7 +104,6 @@ struct rpc_auth_create_args {
 
 /* Flags for rpcauth_lookupcred() */
 #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
-#define RPCAUTH_LOOKUP_RCU		0x02	/* lock-less lookup */
 
 /*
  * Client authentication ops
@@ -151,15 +150,10 @@ extern const struct rpc_authops	authunix_ops;
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
 struct rpc_auth *	rpcauth_create(const struct rpc_auth_create_args *,
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
index ac8f824ec34f..2debbaba7809 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -578,13 +578,6 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
-		if (flags & RPCAUTH_LOOKUP_RCU) {
-			if (test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags) ||
-			    refcount_read(&entry->cr_count) == 0)
-				continue;
-			cred = entry;
-			break;
-		}
 		cred = get_rpccred(entry);
 		if (cred)
 			break;
@@ -594,9 +587,6 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred != NULL)
 		goto found;
 
-	if (flags & RPCAUTH_LOOKUP_RCU)
-		return ERR_PTR(-ECHILD);
-
 	new = auth->au_ops->crcreate(auth, acred, flags, gfp);
 	if (IS_ERR(new)) {
 		cred = new;
@@ -925,15 +915,10 @@ int __init rpcauth_init_module(void)
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
@@ -943,6 +928,5 @@ int __init rpcauth_init_module(void)
 void rpcauth_remove_module(void)
 {
 	rpc_destroy_authunix();
-	rpc_destroy_generic_auth();
 	unregister_shrinker(&rpc_cred_shrinker);
 }
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
deleted file mode 100644
index c57e83184d3c..000000000000
--- a/net/sunrpc/auth_generic.c
+++ /dev/null
@@ -1,199 +0,0 @@
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
-	put_cred(cred->cr_cred);
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
-	.au_count = REFCOUNT_INIT(1),
-};
-
-static const struct rpc_credops generic_credops = {
-	.cr_name = "Generic cred",
-	.crdestroy = generic_destroy_cred,
-	.crbind = generic_bind_cred,
-	.crmatch = generic_match,
-};
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 135c75d6c470..830686e80bed 100644
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
 


