Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26873 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab3JVOVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:24 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/5] SUNRPC: invalidate gss_context upon gss-ctx keyring key destruction
Date: Tue, 22 Oct 2013 10:21:14 -0400
Message-ID: <1382451676-2963-4-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-1-git-send-email-andros@netapp.com>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Lookup all gss_contexts matching the key-serial and set the
gss_cred->base (rpc_cred) cr_flags RPCAUTH_CRED_KEY_DESTROYED bit.

In gss_match, which is called prior to any use of the gss_cred,
if the RPCAUTH_CRED_KEY_DESTROYED rpc_cred bit is set, return no match.

A future patch will make an exception, returning a match for any buffered
writes setup before the RPCAUTH_CRED_KEY_DESTROYED flag was set.

When crmatch fails, the rpc code will then try to create a new
gss_cred + context, which will fail due to destroyed kerberos credentials.

Note: Currently we leave the RPCAUTH_CRED_KEY_DESTROYED cred in the
unused lru list to be garbage collected.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth.h    |  1 +
 net/sunrpc/auth_gss/auth_gss.c | 45 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 790be14..f1151e3 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -68,6 +68,7 @@ struct rpc_cred {
 #define RPCAUTH_CRED_UPTODATE	1
 #define RPCAUTH_CRED_HASHED	2
 #define RPCAUTH_CRED_NEGATIVE	3
+#define RPCAUTH_CRED_KEY_DESTROYED 4
 
 #define RPCAUTH_CRED_MAGIC	0x0f4aa4f0
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 10d6e53..b7365b9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -115,12 +115,52 @@ static void gss_free_ctx(struct gss_cl_ctx *);
 static const struct rpc_pipe_ops gss_upcall_ops_v0;
 static const struct rpc_pipe_ops gss_upcall_ops_v1;
 
+/**
+ * The UID Kerberos credential has been destroyed. Search all gss_auth
+ * credential caches and mark all UID gss_creds RPCAUTH_CRED_KEY_DESTROYED.
+ */
+static void
+gss_mark_cred_destroy(uid_t uid, key_serial_t serial)
+{
+	struct gss_auth *ga;
+	struct rpc_cred *cr;
+	struct gss_cred *gc;
+	struct auth_cred ac = {
+		.uid = uid,
+	};
+	int i;
+
+	spin_lock(&gss_auth_hash_lock);
+	hash_for_each(gss_auth_hash_table, i, ga, hash) {
+		/* check all supported pseudoflavors */
+		if (ga->rpc_auth.au_flavor > RPC_AUTH_MAXFLAVOR) {
+			cr = rpcauth_lookup_credcache(&ga->rpc_auth, &ac, 0);
+			if (IS_ERR(cr) || cr == NULL)
+				continue;
+			gc = container_of(cr, struct gss_cred, gc_base);
+			if (gc->gc_serial == serial) {
+				set_bit(RPCAUTH_CRED_KEY_DESTROYED,
+					&cr->cr_flags);
+			}
+			put_rpccred(cr); /* balance get in lookup credcache */
+		}
+	}
+	spin_unlock(&gss_auth_hash_lock);
+}
+
+static void
+gss_user_destroy(struct key *key)
+{
+	gss_mark_cred_destroy(key->uid, key->serial);
+	return user_destroy(key);
+}
+
 static struct key_type key_type_gss_ctx = {
 	.name		= "gss-ctx",
 	.instantiate	= user_instantiate,
 	.match		= user_match,
 	.revoke		= user_revoke,
-	.destroy	= user_destroy,
+	.destroy	= gss_user_destroy,
 	.describe	= user_describe,
 	.read		= user_read,
 };
@@ -1471,6 +1511,9 @@ check_expire:
 	if (ret == 0)
 		return ret;
 
+	if (test_bit(RPCAUTH_CRED_KEY_DESTROYED, &rc->cr_flags))
+		return 0;
+
 	/* Notify acred users of GSS context expiration timeout */
 	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
 	    (gss_key_timeout(rc) != 0)) {
-- 
1.8.3.1

