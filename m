Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34CF2C0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E28E72086B
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E28E72086B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389177AbeKGNnp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:43:45 -0500
Received: from mx2.suse.de ([195.135.220.15]:56894 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2389172AbeKGNno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:43:44 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 5C0CCB659;
        Wed,  7 Nov 2018 04:15:07 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 15/23] NFS: move credential expiry tracking out of SUNRPC
 into NFS.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395130.24086.3372851803565667069.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

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
index 5b1eee4952b7..aea015743172 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -962,6 +962,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 	nfs_sb_active(dentry->d_sb);
 	ctx->dentry = dget(dentry);
 	ctx->cred = cred;
+	ctx->ll_cred = NULL;
 	ctx->state = NULL;
 	ctx->mode = f_mode;
 	ctx->flags = 0;
@@ -1001,6 +1002,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 		put_rpccred(ctx->cred);
 	dput(ctx->dentry);
 	nfs_sb_deactive(sb);
+	put_rpccred(ctx->ll_cred);
 	kfree(ctx->mdsthreshold);
 	kfree_rcu(ctx, rcu_head);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 586726a590d8..c1452f838131 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1233,9 +1233,12 @@ int
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
@@ -1244,8 +1247,23 @@ nfs_key_timeout_notify(struct file *filp, struct inode *inode)
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
index 6e0417c02279..ecf22c0034d5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -71,6 +71,7 @@ struct nfs_open_context {
 	fl_owner_t flock_owner;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
+	struct rpc_cred *ll_cred;	/* low-level cred - use to check for expiry */
 	struct nfs4_state *state;
 	fmode_t mode;
 
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 28b34c740c43..0bdc2f4957ff 100644
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
@@ -154,7 +146,6 @@ struct rpc_credops {
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
 	int			(*crkey_timeout)(struct rpc_cred *);
-	bool			(*crkey_to_expire)(struct rpc_cred *);
 	char *			(*crstringify_acceptor)(struct rpc_cred *);
 	bool			(*crneed_reencode)(struct rpc_task *);
 };
@@ -198,9 +189,6 @@ int			rpcauth_uptodatecred(struct rpc_task *);
 int			rpcauth_init_credcache(struct rpc_auth *);
 void			rpcauth_destroy_credcache(struct rpc_auth *);
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
-int			rpcauth_key_timeout_notify(struct rpc_auth *,
-						struct rpc_cred *);
-bool			rpcauth_cred_key_to_expire(struct rpc_auth *, struct rpc_cred *);
 char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
 static inline
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 27d90578e7a0..cf23eed01b1c 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -360,29 +360,6 @@ rpcauth_init_credcache(struct rpc_auth *auth)
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
index 8cf5aa515c51..c57e83184d3c 100644
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
 	.au_count = REFCOUNT_INIT(1),
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
index feea8e65797c..7c5311c2f524 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1494,23 +1494,10 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
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


