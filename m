Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38528 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbeBSFEl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:41 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 15/23] NFS: move credential expiry tracking out of SUNRPC
 into NFS.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654928.17421.6790131207603694901.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS needs to know when a credential is about to expire so that
it can modify write-back behaviour to finish the write inside the
expiry time.
It currently uses functions in SUNRPC code which make use of a
fairly complex callback scheme and flags in the generic credientials.

As I am working to discard the generic credentials, this has to change.

This patch moves the logic into NFS, in part by finding and caching
the low-level credential in the open_context.  We then make direct
cred-api calls on that.

This makes the code much simpler and removes a dependency on generic
rpc credentials.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/inode.c                 |    2 +
 fs/nfs/write.c                 |   24 +++++++++++--
 include/linux/nfs_fs.h         |    1 +
 include/linux/sunrpc/auth.h    |   12 ------
 net/sunrpc/auth.c              |   23 ------------
 net/sunrpc/auth_generic.c      |   75 ----------------------------------------
 net/sunrpc/auth_gss/auth_gss.c |   21 ++---------
 7 files changed, 28 insertions(+), 130 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d893543cf3b..38de9a06fc33 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -923,6 +923,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 	nfs_sb_active(dentry->d_sb);
 	ctx->dentry = dget(dentry);
 	ctx->cred = cred;
+	ctx->ll_cred = NULL;
 	ctx->state = NULL;
 	ctx->mode = f_mode;
 	ctx->flags = 0;
@@ -962,6 +963,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 		put_rpccred(ctx->cred);
 	dput(ctx->dentry);
 	nfs_sb_deactive(sb);
+	put_rpccred(ctx->ll_cred);
 	kfree(ctx->mdsthreshold);
 	kfree(ctx);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7428a669d7a7..37161574e36b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1232,9 +1232,12 @@ int
 nfs_key_timeout_notify(struct file *filp, struct inode *inode)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(filp);
-	struct rpc_auth *auth = NFS_SERVER(inode)->client->cl_auth;
 
-	return rpcauth_key_timeout_notify(auth, ctx->cred);
+	if (nfs_ctx_key_to_expire(ctx, inode) &&
+	    !ctx->ll_cred)
+		/* Already expired! */
+		return -EACCES;
+	return 0;
 }
 
 /*
@@ -1243,8 +1246,23 @@ nfs_key_timeout_notify(struct file *filp, struct inode *inode)
 bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx, struct inode *inode)
 {
 	struct rpc_auth *auth = NFS_SERVER(inode)->client->cl_auth;
+	struct rpc_cred *cred = ctx->ll_cred;
+	struct auth_cred acred = {
+		.cred = ctx->cred->cr_cred,
+	};
 
-	return rpcauth_cred_key_to_expire(auth, ctx->cred);
+	if (cred && !cred->cr_ops->crmatch(&acred, cred, 0)) {
+		put_rpccred(cred);
+		ctx->ll_cred = NULL;
+		cred = NULL;
+	}
+	if (!cred)
+		cred = auth->au_ops->lookup_cred(auth, &acred, 0);
+	if (!cred || IS_ERR(cred))
+		return true;
+	ctx->ll_cred = cred;
+	return !!(cred->cr_ops->crkey_timeout &&
+		  cred->cr_ops->crkey_timeout(cred));
 }
 
 /*
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 38187c68063d..b5a3bea20ca3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -70,6 +70,7 @@ struct nfs_open_context {
 	fl_owner_t flock_owner;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
+	struct rpc_cred *ll_cred;	/* low-level cred - use to check for expiry */
 	struct nfs4_state *state;
 	fmode_t mode;
 
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 15027adb9e32..84614cb08ab1 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -37,17 +37,9 @@
 
 struct rpcsec_gss_info;
 
-/* auth_cred ac_flags bits */
-enum {
-	RPC_CRED_KEY_EXPIRE_SOON = 1, /* underlying cred key will expire soon */
-	RPC_CRED_NOTIFY_TIMEOUT = 2,   /* nofity generic cred when underlying
-					key will expire soon */
-};
-
 struct auth_cred {
 	const struct cred *cred;
 	const char *principal;	/* If present, this is a machine credential */
-	unsigned long ac_flags;
 };
 
 /*
@@ -153,7 +145,6 @@ struct rpc_credops {
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
 	int			(*crkey_timeout)(struct rpc_cred *);
-	bool			(*crkey_to_expire)(struct rpc_cred *);
 	char *			(*crstringify_acceptor)(struct rpc_cred *);
 };
 
@@ -195,9 +186,6 @@ int			rpcauth_uptodatecred(struct rpc_task *);
 int			rpcauth_init_credcache(struct rpc_auth *);
 void			rpcauth_destroy_credcache(struct rpc_auth *);
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
-int			rpcauth_key_timeout_notify(struct rpc_auth *,
-						struct rpc_cred *);
-bool			rpcauth_cred_key_to_expire(struct rpc_auth *, struct rpc_cred *);
 char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
 static inline
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 0130d0151623..eabe721d6a99 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -359,29 +359,6 @@ rpcauth_init_credcache(struct rpc_auth *auth)
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_credcache);
 
-/*
- * Setup a credential key lifetime timeout notification
- */
-int
-rpcauth_key_timeout_notify(struct rpc_auth *auth, struct rpc_cred *cred)
-{
-	if (!cred->cr_auth->au_ops->key_timeout)
-		return 0;
-	return cred->cr_auth->au_ops->key_timeout(auth, cred);
-}
-EXPORT_SYMBOL_GPL(rpcauth_key_timeout_notify);
-
-bool
-rpcauth_cred_key_to_expire(struct rpc_auth *auth, struct rpc_cred *cred)
-{
-	if (auth->au_flags & RPCAUTH_AUTH_NO_CRKEY_TIMEOUT)
-		return false;
-	if (!cred->cr_ops->crkey_to_expire)
-		return false;
-	return cred->cr_ops->crkey_to_expire(cred);
-}
-EXPORT_SYMBOL_GPL(rpcauth_cred_key_to_expire);
-
 char *
 rpcauth_stringify_acceptor(struct rpc_cred *cred)
 {
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f1379301060f..fa6ed0159456 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -87,7 +87,6 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 	gcred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
 
 	gcred->acred.cred = gcred->gc_base.cr_cred;
-	gcred->acred.ac_flags = 0;
 	gcred->acred.principal = acred->principal;
 
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
@@ -179,72 +178,12 @@ void rpc_destroy_generic_auth(void)
 	rpcauth_destroy_credcache(&generic_auth);
 }
 
-/*
- * Test the the current time (now) against the underlying credential key expiry
- * minus a timeout and setup notification.
- *
- * The normal case:
- * If 'now' is before the key expiry minus RPC_KEY_EXPIRE_TIMEO, set
- * the RPC_CRED_NOTIFY_TIMEOUT flag to setup the underlying credential
- * rpc_credops crmatch routine to notify this generic cred when it's key
- * expiration is within RPC_KEY_EXPIRE_TIMEO, and return 0.
- *
- * The error case:
- * If the underlying cred lookup fails, return -EACCES.
- *
- * The 'almost' error case:
- * If 'now' is within key expiry minus RPC_KEY_EXPIRE_TIMEO, but not within
- * key expiry minus RPC_KEY_EXPIRE_FAIL, set the RPC_CRED_EXPIRE_SOON bit
- * on the acred ac_flags and return 0.
- */
-static int
-generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
-{
-	struct auth_cred *acred = &container_of(cred, struct generic_cred,
-						gc_base)->acred;
-	struct rpc_cred *tcred;
-	int ret = 0;
-
-
-	/* Fast track for non crkey_timeout (no key) underlying credentials */
-	if (auth->au_flags & RPCAUTH_AUTH_NO_CRKEY_TIMEOUT)
-		return 0;
-
-	/* Fast track for the normal case */
-	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags))
-		return 0;
-
-	/* lookup_cred either returns a valid referenced rpc_cred, or PTR_ERR */
-	tcred = auth->au_ops->lookup_cred(auth, acred, 0);
-	if (IS_ERR(tcred))
-		return -EACCES;
-
-	/* Test for the almost error case */
-	ret = tcred->cr_ops->crkey_timeout(tcred);
-	if (ret != 0) {
-		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
-		ret = 0;
-	} else {
-		/* In case underlying cred key has been reset */
-		if (test_and_clear_bit(RPC_CRED_KEY_EXPIRE_SOON,
-					&acred->ac_flags))
-			dprintk("RPC:        UID %d Credential key reset\n",
-				from_kuid(&init_user_ns, tcred->cr_uid));
-		/* set up fasttrack for the normal case */
-		set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
-	}
-
-	put_rpccred(tcred);
-	return ret;
-}
-
 static const struct rpc_authops generic_auth_ops = {
 	.owner = THIS_MODULE,
 	.au_name = "Generic",
 	.hash_cred = generic_hash_cred,
 	.lookup_cred = generic_lookup_cred,
 	.crcreate = generic_create_cred,
-	.key_timeout = generic_key_timeout,
 };
 
 static struct rpc_auth generic_auth = {
@@ -252,23 +191,9 @@ static struct rpc_auth generic_auth = {
 	.au_count = ATOMIC_INIT(0),
 };
 
-static bool generic_key_to_expire(struct rpc_cred *cred)
-{
-	struct auth_cred *acred = &container_of(cred, struct generic_cred,
-						gc_base)->acred;
-	bool ret;
-
-	get_rpccred(cred);
-	ret = test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
-	put_rpccred(cred);
-
-	return ret;
-}
-
 static const struct rpc_credops generic_credops = {
 	.cr_name = "Generic cred",
 	.crdestroy = generic_destroy_cred,
 	.crbind = generic_bind_cred,
 	.crmatch = generic_match,
-	.crkey_to_expire = generic_key_to_expire,
 };
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8d210ba1e13b..d8feb9d55b17 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1462,23 +1462,10 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 		if (gss_cred->gc_principal == NULL)
 			return 0;
 		ret = strcmp(acred->principal, gss_cred->gc_principal) == 0;
-		goto check_expire;
-	}
-	if (gss_cred->gc_principal != NULL)
-		return 0;
-	ret = uid_eq(rc->cr_uid, acred->cred->fsuid);
-
-check_expire:
-	if (ret == 0)
-		return ret;
-
-	/* Notify acred users of GSS context expiration timeout */
-	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
-	    (gss_key_timeout(rc) != 0)) {
-		/* test will now be done from generic cred */
-		test_and_clear_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
-		/* tell NFS layer that key will expire soon */
-		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+	} else {
+		if (gss_cred->gc_principal != NULL)
+			return 0;
+		ret = uid_eq(rc->cr_uid, acred->cred->fsuid);
 	}
 	return ret;
 }


