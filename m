Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50474 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759317Ab3GRTfl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 15:35:41 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 3/5] SUNRPC new rpc_credops to test credential expiry
Date: Thu, 18 Jul 2013 15:35:28 -0400
Message-ID: <1374176130-11657-4-git-send-email-andros@netapp.com>
In-Reply-To: <1374176130-11657-1-git-send-email-andros@netapp.com>
References: <1374176130-11657-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
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

Set a credential key expiry watermark, RPC_KEY_EXPIRE_TIMEO set to 240 seconds
as a default and can be set via a module parameter as we need to ensure there
is time for any dirty data to be flushed.

If key_timeout is called on a credential with an underlying credential key that
will expire within watermark seconds, we set the RPC_CRED_KEY_EXPIRE_SOON
flag in the generic_cred acred so that the NFS layer can clean up prior to
key expiration.

Checking a generic credential's underlying credential involves a cred lookup.
To avoid this lookup in the normal case when the underlying credential has
a key that is valid (before the watermark), a notify flag is set in
the generic credential the first time the key_timeout is called. The
generic credential then stops checking the underlying credential key expiry, and
the underlying credential (gss_cred) match routine then checks the key
expiration upon each normal use and sets a flag in the associated generic
credential only when the key expiration is within the watermark.
This in turn signals the generic credential key_timeout to perform the extra
credential lookup thereafter.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth.h    | 16 +++++++++
 net/sunrpc/auth.c              | 21 +++++++++++
 net/sunrpc/auth_generic.c      | 82 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c | 54 ++++++++++++++++++++++++++--
 4 files changed, 171 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 0dd00f4..a79d042 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -24,12 +24,21 @@
 
 struct rpcsec_gss_info;
 
+/* auth_cred ac_flags bits */
+enum {
+	RPC_CRED_NO_CRKEY_TIMEOUT = 0, /* underlying cred has no key timeout */
+	RPC_CRED_KEY_EXPIRE_SOON = 1, /* underlying cred key will expire soon */
+	RPC_CRED_NOTIFY_TIMEOUT = 2,   /* nofity generic cred when underlying
+					key will expire soon */
+};
+
 /* Work around the lack of a VFS credential */
 struct auth_cred {
 	kuid_t	uid;
 	kgid_t	gid;
 	struct group_info *group_info;
 	const char *principal;
+	unsigned long ac_flags;
 	unsigned char machine_cred : 1;
 };
 
@@ -108,6 +117,8 @@ struct rpc_authops {
 	rpc_authflavor_t	(*info2flavor)(struct rpcsec_gss_info *);
 	int			(*flavor2info)(rpc_authflavor_t,
 						struct rpcsec_gss_info *);
+	int			(*key_timeout)(struct rpc_auth *,
+						struct rpc_cred *);
 };
 
 struct rpc_credops {
@@ -124,6 +135,8 @@ struct rpc_credops {
 						void *, __be32 *, void *);
 	int			(*crunwrap_resp)(struct rpc_task *, kxdrdproc_t,
 						void *, __be32 *, void *);
+	int			(*crkey_timeout)(struct rpc_cred *);
+	bool			(*crkey_to_expire)(struct rpc_cred *);
 };
 
 extern const struct rpc_authops	authunix_ops;
@@ -162,6 +175,9 @@ int			rpcauth_uptodatecred(struct rpc_task *);
 int			rpcauth_init_credcache(struct rpc_auth *);
 void			rpcauth_destroy_credcache(struct rpc_auth *);
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
+int			rpcauth_key_timeout_notify(struct rpc_auth *,
+						struct rpc_cred *);
+bool			rpcauth_cred_key_to_expire(struct rpc_cred *);
 
 static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ed2fdd2..1741370 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -343,6 +343,27 @@ out_nocache:
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
index b6badaf..7430d38 100644
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
@@ -182,11 +183,78 @@ void rpc_destroy_generic_auth(void)
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
+ * If the underlying cred lookup fails, return -EACCES.
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
+	/* Test for the almost error case */
+	ret = tcred->cr_ops->crkey_timeout(tcred);
+	if (ret != 0) {
+		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+		ret = 0;
+	} else {
+		/* In case underlying cred key has been reset */
+		if (test_and_clear_bit(RPC_CRED_KEY_EXPIRE_SOON,
+					&acred->ac_flags))
+			pr_warn("RPC: UID %d Credential key reset\n",
+				tcred->cr_uid);
+		/* set up fasttrack for the normal case */
+		set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
+	}
+
+out_put:
+	put_rpccred(tcred);
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
@@ -194,9 +262,23 @@ static struct rpc_auth generic_auth = {
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
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index fc2f78d..e1f4735 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -62,6 +62,9 @@ static const struct rpc_credops gss_nullops;
 #define GSS_RETRY_EXPIRED 5
 static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
 
+#define GSS_KEY_EXPIRE_TIMEO 240
+static unsigned int gss_key_expire_timeo = GSS_KEY_EXPIRE_TIMEO;
+
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -1126,10 +1129,32 @@ gss_cred_init(struct rpc_auth *auth, struct rpc_cred *cred)
 	return err;
 }
 
+/*
+ * Returns -EACCES if GSS context is NULL or will expire within the
+ * timeout (miliseconds)
+ */
+static int
+gss_key_timeout(struct rpc_cred *rc)
+{
+	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
+	unsigned long now = jiffies;
+	unsigned long expire;
+
+	if (gss_cred->gc_ctx == NULL)
+		return -EACCES;
+
+	expire = gss_cred->gc_ctx->gc_expiry - (gss_key_expire_timeo * HZ);
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
@@ -1142,11 +1167,28 @@ out:
 	if (acred->principal != NULL) {
 		if (gss_cred->gc_principal == NULL)
 			return 0;
-		return strcmp(acred->principal, gss_cred->gc_principal) == 0;
+		ret = strcmp(acred->principal, gss_cred->gc_principal) == 0;
+		goto check_expire;
 	}
 	if (gss_cred->gc_principal != NULL)
 		return 0;
-	return uid_eq(rc->cr_uid, acred->uid);
+	ret = uid_eq(rc->cr_uid, acred->uid);
+
+check_expire:
+	if (ret == 0)
+		return ret;
+
+	/* Notify acred users of GSS context expiration timeout */
+	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
+	    (gss_key_timeout(rc) != 0)) {
+		/* test will now be done from generic cred */
+		test_and_clear_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
+		/* tell NFS layer that key will expire soon */
+		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+		pr_warn("RPC: UID %d GSS context to expire within %d seconds\n",
+			rc->cr_uid, gss_key_expire_timeo);
+	}
+	return ret;
 }
 
 /*
@@ -1675,6 +1717,7 @@ static const struct rpc_credops gss_credops = {
 	.crvalidate	= gss_validate,
 	.crwrap_req	= gss_wrap_req,
 	.crunwrap_resp	= gss_unwrap_resp,
+	.crkey_timeout	= gss_key_timeout,
 };
 
 static const struct rpc_credops gss_nullops = {
@@ -1762,5 +1805,12 @@ module_param_named(expired_cred_retry_delay,
 MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
 		"the RPC engine retries an expired credential");
 
+module_param_named(key_expire_timeo,
+		   gss_key_expire_timeo,
+		   uint, 0644);
+MODULE_PARM_DESC(key_expire_timeo, "Time (in seconds) at the end of a "
+		"credential keys lifetime where the NFS layer cleans up "
+		"prior to key expiration");
+
 module_init(init_rpcsec_gss)
 module_exit(exit_rpcsec_gss)
-- 
1.8.3.1

