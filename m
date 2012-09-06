Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33647 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757652Ab2IFTyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 15:54:11 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] SUNRPC new rpc_credops to test credential expiry
Date: Thu,  6 Sep 2012 15:54:10 -0400
Message-Id: <1346961251-2554-4-git-send-email-andros@netapp.com>
In-Reply-To: <1346961251-2554-1-git-send-email-andros@netapp.com>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patch provides the RPC layer helper functions to allow NFS to manage
data in the face of expired credentials - such as avoiding buffered WRITEs
and COMMITs when the gss context will expire before the WRITEs are flushed
and COMMITs are sent.

These helper functions enable checking the expiration of an underlying
credential key for a generic rpc credential, e.g. the gss_cred gss context
gc_expiry which for Kerberos is set to the remaining TGT lifetime.

A new rpc_authops key_timeout is only defined for the generic auth.
A new rpc_credops crkey_to_expire is only defined for the generic cred.
A new rpc_credops crkey_timeout is only defined for the gss cred.

Set two credential key expiry watermarks:
1) A high watermark, RPC_KEY_EXPIRE_TIMEO set to 90 seconds.
2) A low watermark, RPC_KEY_EXPIRE_FAIL set to 30 seconds.
NOTE: these timeouts are guesses that work in a VM environment. We may want to
make them adjustable via module parameters.

If key_timeout is called on a credential with an underlying credential key that
will expire within high watermark seconds, we set the RPC_CRED_KEY_EXPIRE_SOON
flag in the generic_cred acred so that the NFS layer can clean up prior to
key expiration.

If key_timeout is called on a credential key that will expire within low
watermark seconds, we return EACCES to allow NFS to stop any new data
operations on the credential key.

Checking a generic credential's underlying credential involves a cred lookup.
To avoid this lookup in the normal case when the underlying credential has
a key that is valid (before the high watermark), a notify flag is set in
the generic credential the first time the key_timeout is called. The
generic credential then stops checking the underlying credential key expiry, and
the underlying credential (gss_cred) match routine then checks the key
expiration upon each normal use and sets a flag in the associated generic
credential only when the key expiration is within the high watermark.
This in turn signals the generic credential key_timeout to perform the extra
credetial lookup thereafter.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth.h    |   27 ++++++++++++
 net/sunrpc/auth.c              |   21 +++++++++
 net/sunrpc/auth_generic.c      |   93 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |   36 ++++++++++++++-
 4 files changed, 175 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index f25ba92..cd01476 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -21,12 +21,30 @@
 /* size of the nodename buffer */
 #define UNX_MAXNODENAME	32
 
+/* Set RPC_CRED_KEY_EXPIRE_SOON auth_cred flag if called RPC_CRED_EXPIRE_TIMEO
+ * miliseconds before the credential key will expire */
+#define RPC_KEY_EXPIRE_TIMEO	(90 * HZ)
+
+/* Return -EACCES if called RPC_CRED_EXPIRE_FAIL
+ * miliseconds before the credential key will expire */
+#define RPC_KEY_EXPIRE_FAIL	 (30 * HZ)
+
+/* auth_cred ac_flags bits */
+enum {
+	RPC_CRED_NO_CRKEY_TIMEOUT = 0, /* underlying cred has no key timeout */
+	RPC_CRED_KEY_EXPIRE_SOON = 1, /* underlying cred key will expire soon */
+	RPC_CRED_NOTIFY_TIMEOUT = 2,   /* nofity generic cred when underlying
+					key will expire soon */
+};
+
+
 /* Work around the lack of a VFS credential */
 struct auth_cred {
 	uid_t	uid;
 	gid_t	gid;
 	struct group_info *group_info;
 	const char *principal;
+	unsigned long ac_flags;
 	unsigned char machine_cred : 1;
 };
 
@@ -102,6 +120,8 @@ struct rpc_authops {
 	int			(*pipes_create)(struct rpc_auth *);
 	void			(*pipes_destroy)(struct rpc_auth *);
 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
+	int			(*key_timeout)(struct rpc_auth *,
+					      struct rpc_cred *);
 };
 
 struct rpc_credops {
@@ -118,6 +138,9 @@ struct rpc_credops {
 						void *, __be32 *, void *);
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
+	int			(*crkey_timeout)(struct rpc_cred *,
+						unsigned long);
+	bool			(*crkey_to_expire)(struct rpc_cred *);
 };
 
 extern const struct rpc_authops	authunix_ops;
@@ -152,6 +175,10 @@ int			rpcauth_uptodatecred(struct rpc_task *);
 int			rpcauth_init_credcache(struct rpc_auth *);
 void			rpcauth_destroy_credcache(struct rpc_auth *);
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
+int			rpcauth_key_timeout_notify(struct rpc_auth *,
+						struct rpc_cred *);
+bool			rpcauth_cred_key_to_expire(struct rpc_cred *);
+
 
 static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..841facb 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -270,6 +270,27 @@ out_nocache:
 EXPORT_SYMBOL_GPL(rpcauth_init_credcache);
 
 /*
+ * Setup a credential key lifetime timeout notification
+ */
+int
+rpcauth_key_timeout_notify(struct rpc_auth *auth, struct rpc_cred *cred)
+{
+	if (!cred->cr_auth->au_ops->key_timeout)
+		return 0;
+	return cred->cr_auth->au_ops->key_timeout(auth, cred);
+}
+EXPORT_SYMBOL_GPL(rpcauth_key_timeout_notify);
+
+bool
+rpcauth_cred_key_to_expire(struct rpc_cred *cred)
+{
+	if (!cred->cr_ops->crkey_to_expire)
+		return false;
+	return cred->cr_ops->crkey_to_expire(cred);
+}
+EXPORT_SYMBOL_GPL(rpcauth_cred_key_to_expire);
+
+/*
  * Destroy a list of credentials
  */
 static inline
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6ed6f20..cc44b70 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -89,6 +89,7 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	gcred->acred.uid = acred->uid;
 	gcred->acred.gid = acred->gid;
 	gcred->acred.group_info = acred->group_info;
+	gcred->acred.ac_flags = 0;
 	if (gcred->acred.group_info != NULL)
 		get_group_info(gcred->acred.group_info);
 	gcred->acred.machine_cred = acred->machine_cred;
@@ -180,11 +181,88 @@ void rpc_destroy_generic_auth(void)
 	rpcauth_destroy_credcache(&generic_auth);
 }
 
+/*
+ * Test the the current time (now) against the underlying credential key expiry
+ * minus a timeout and setup notification.
+ *
+ * The normal case:
+ * If 'now' is before the key expiry minus RPC_KEY_EXPIRE_TIMEO, set
+ * the RPC_CRED_NOTIFY_TIMEOUT flag to setup the underlying credential
+ * rpc_credops crmatch routine to notify this generic cred when it's key
+ * expiration is within RPC_KEY_EXPIRE_TIMEO, and return 0.
+ *
+ * The error case:
+ * If 'now' is within key expiry minus RPC_KEY_EXPIRE_FAIL, or the underlying
+ * cred lookup fails, return -EACCES.
+ *
+ * The 'almost' error case:
+ * If 'now' is within key expiry minus RPC_KEY_EXPIRE_TIMEO, but not within
+ * key expiry minus RPC_KEY_EXPIRE_FAIL, set the RPC_CRED_EXPIRE_SOON bit
+ * on the acred ac_flags and return 0.
+ */
+static int
+generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
+{
+	struct auth_cred *acred = &container_of(cred, struct generic_cred,
+						gc_base)->acred;
+	struct rpc_cred *tcred;
+	int ret = 0;
+
+
+	dprintk("--> %s cred %p acred %p acred->ac_flags %lu\n", __func__,
+		cred, acred, acred->ac_flags);
+
+	/* Fast track for non crkey_timeout (no key) underlying credentials */
+	if (test_bit(RPC_CRED_NO_CRKEY_TIMEOUT, &acred->ac_flags))
+		return 0;
+
+	/* Fast track for the normal case */
+	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags))
+		return 0;
+
+	/* lookup_cred either returns a valid referenced rpc_cred, or PTR_ERR */
+	tcred = auth->au_ops->lookup_cred(auth, acred, 0);
+	if (IS_ERR(tcred))
+		return -EACCES;
+
+	if (!tcred->cr_ops->crkey_timeout) {
+		set_bit(RPC_CRED_NO_CRKEY_TIMEOUT, &acred->ac_flags);
+		ret = 0;
+		goto out_put;
+	}
+
+	/* Test for the error case */
+	ret = tcred->cr_ops->crkey_timeout(tcred, RPC_KEY_EXPIRE_FAIL);
+	if (ret != 0) { /* -EACCESS */
+		ret = -EACCES;
+		goto out_put;
+	}
+
+	/* Test for the almost error case */
+	ret = tcred->cr_ops->crkey_timeout(tcred, RPC_KEY_EXPIRE_TIMEO);
+	if (ret != 0) {
+		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+		ret = 0;
+	} else {
+		/* In case underlying cred key has been reset */
+		test_and_clear_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+		/* set up fasttrack for the normal case */
+		set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
+	}
+
+out_put:
+	put_rpccred(tcred);
+	dprintk("%s return %d acred->ac_flags %lu\n", __func__, ret,
+		acred->ac_flags);
+	return ret;
+}
+
 static const struct rpc_authops generic_auth_ops = {
 	.owner = THIS_MODULE,
 	.au_name = "Generic",
 	.lookup_cred = generic_lookup_cred,
 	.crcreate = generic_create_cred,
+	.key_timeout = generic_key_timeout,
 };
 
 static struct rpc_auth generic_auth = {
@@ -192,9 +270,24 @@ static struct rpc_auth generic_auth = {
 	.au_count = ATOMIC_INIT(0),
 };
 
+static bool generic_key_to_expire(struct rpc_cred *cred)
+{
+	struct auth_cred *acred = &container_of(cred, struct generic_cred,
+						gc_base)->acred;
+	bool ret;
+
+	get_rpccred(cred);
+	ret = test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+	put_rpccred(cred);
+
+	return ret;
+}
+
 static const struct rpc_credops generic_credops = {
 	.cr_name = "Generic cred",
 	.crdestroy = generic_destroy_cred,
 	.crbind = generic_bind_cred,
 	.crmatch = generic_match,
+	.crkey_to_expire = generic_key_to_expire,
 };
+
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c59f5ed..51307a2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1093,10 +1093,24 @@ gss_cred_init(struct rpc_auth *auth, struct rpc_cred *cred)
 	return err;
 }
 
+/* Returns -EACCES if GSS context will expire within timeout (miliseconds) */
+static int
+gss_key_timeout(struct rpc_cred *rc, unsigned long timeout)
+{
+	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
+	unsigned long now = jiffies;
+	unsigned long expire = gss_cred->gc_ctx->gc_expiry - timeout;
+
+	if (time_after(now, expire))
+		return -EACCES;
+	return 0;
+}
+
 static int
 gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
+	int ret;
 
 	if (test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
 		goto out;
@@ -1109,11 +1123,28 @@ out:
 	if (acred->principal != NULL) {
 		if (gss_cred->gc_principal == NULL)
 			return 0;
-		return strcmp(acred->principal, gss_cred->gc_principal) == 0;
+		ret = strcmp(acred->principal, gss_cred->gc_principal) == 0;
+		goto check_expire;
 	}
 	if (gss_cred->gc_principal != NULL)
 		return 0;
-	return rc->cr_uid == acred->uid;
+	ret = rc->cr_uid == acred->uid;
+
+check_expire:
+	if (ret == 0)
+		return ret;
+
+	/* Notify acred users of GSS context expiration timeout */
+	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
+	    (gss_key_timeout(rc, RPC_KEY_EXPIRE_TIMEO) != 0)) {
+		/* test will now be done from generic cred */
+		test_and_clear_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
+		/* tell NFS layer that key will expire soon */
+		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+		pr_warn("RPC: GSS context %p to expire within %d ms.\n",
+			gss_cred->gc_ctx, RPC_KEY_EXPIRE_TIMEO);
+	}
+	return ret;
 }
 
 /*
@@ -1640,6 +1671,7 @@ static const struct rpc_credops gss_credops = {
 	.crvalidate	= gss_validate,
 	.crwrap_req	= gss_wrap_req,
 	.crunwrap_resp	= gss_unwrap_resp,
+	.crkey_timeout	= gss_key_timeout,
 };
 
 static const struct rpc_credops gss_nullops = {
-- 
1.7.7.6

