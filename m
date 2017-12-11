Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40318 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752349AbdLKEmL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 10 Dec 2017 23:42:11 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 136D7AAB5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Dec 2017 04:42:10 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 11 Dec 2017 15:40:18 +1100
Subject: [PATCH 17/19] SUNRPC: remove crbind rpc_cred operation
Message-ID: <151296721810.24753.6815163977545372832.stgit@noble>
In-Reply-To: <151296579813.24753.5905981862981613395.stgit@noble>
References: <151296579813.24753.5905981862981613395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This now always just does get_rpccred(), so we
don't need an operation pointer to know to do that.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    2 --
 net/sunrpc/auth.c              |   14 ++------------
 net/sunrpc/auth_gss/auth_gss.c |    2 --
 net/sunrpc/auth_null.c         |    1 -
 net/sunrpc/auth_unix.c         |    1 -
 5 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 33d8ca8bb558..a98ce75b1994 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -132,7 +132,6 @@ struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
-	struct rpc_cred *	(*crbind)(struct rpc_task *, struct rpc_cred *, int);
 	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
@@ -165,7 +164,6 @@ int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int, gfp_t);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
-struct rpc_cred *	rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *, int);
 void			put_rpccred(struct rpc_cred *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index cfe9d2dd6aa3..7ffc2b100356 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -634,15 +634,6 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
-struct rpc_cred *
-rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred, int lookupflags)
-{
-	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
-			cred->cr_auth->au_ops->au_name, cred);
-	return get_rpccred(cred);
-}
-EXPORT_SYMBOL_GPL(rpcauth_generic_bind_cred);
-
 static struct rpc_cred *
 rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
@@ -700,9 +691,8 @@ rpcauth_bindcred(struct rpc_task *task, const struct cred *cred, int flags)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
 	if (task->tk_op_cred)
 		/* Task must use exactly this rpc_cred */
-		new = task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
-						       lookupflags);
-	if (cred != NULL && cred != &machine_cred)
+		new = get_rpccred(task->tk_op_cred);
+	else if (cred != NULL && cred != &machine_cred)
 		new = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 	else if (cred == &machine_cred)
 		new = rpcauth_bind_machine_cred(task, lookupflags);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e68693d6d53e..24e40745810f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1994,7 +1994,6 @@ static const struct rpc_credops gss_credops = {
 	.cr_name		= "AUTH_GSS",
 	.crdestroy		= gss_destroy_cred,
 	.cr_init		= gss_cred_init,
-	.crbind			= rpcauth_generic_bind_cred,
 	.crmatch		= gss_match,
 	.crmarshal		= gss_marshal,
 	.crrefresh		= gss_refresh,
@@ -2008,7 +2007,6 @@ static const struct rpc_credops gss_credops = {
 static const struct rpc_credops gss_nullops = {
 	.cr_name		= "AUTH_GSS",
 	.crdestroy		= gss_destroy_nullcred,
-	.crbind			= rpcauth_generic_bind_cred,
 	.crmatch		= gss_match,
 	.crmarshal		= gss_marshal,
 	.crrefresh		= gss_refresh_null,
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index b5cc89f63162..584aeb8f9440 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -123,7 +123,6 @@ static
 const struct rpc_credops null_credops = {
 	.cr_name	= "AUTH_NULL",
 	.crdestroy	= nul_destroy_cred,
-	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= nul_match,
 	.crmarshal	= nul_marshal,
 	.crrefresh	= nul_refresh,
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 80b366ecb2fe..3409a1426980 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -245,7 +245,6 @@ static
 const struct rpc_credops unix_credops = {
 	.cr_name	= "AUTH_UNIX",
 	.crdestroy	= unx_destroy_cred,
-	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= unx_match,
 	.crmarshal	= unx_marshal,
 	.crrefresh	= unx_refresh,


