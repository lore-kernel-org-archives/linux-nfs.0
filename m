Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:30472 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdHDOto (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Aug 2017 10:49:44 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: [RFC v2 2/3] SUNRPC mark user credentials destroyed
Date: Fri, 4 Aug 2017 10:49:38 -0400
Message-ID: <20170804144939.25374-3-kolga@netapp.com>
In-Reply-To: <20170804144939.25374-1-kolga@netapp.com>
References: <20170804144939.25374-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide an API -- rpcauth_key_set_destroy() -- to mark specific
gss user's creds destroyed. Afterwards, these credentials come up
as expired and require new credentials to be established. If
previously the user did a kdestroy, then user has no access to
the nfs mount.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/linux/sunrpc/auth.h    |  5 +++++
 net/sunrpc/auth.c              |  9 +++++++++
 net/sunrpc/auth_generic.c      | 15 +++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |  3 +++
 4 files changed, 32 insertions(+)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 8fd3504..2ab0bc9 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -76,6 +76,7 @@ struct rpc_cred {
 #define RPCAUTH_CRED_UPTODATE	1
 #define RPCAUTH_CRED_HASHED	2
 #define RPCAUTH_CRED_NEGATIVE	3
+#define RPCAUTH_CRED_DESTROYED	4
 
 /* rpc_auth au_flags */
 #define RPCAUTH_AUTH_NO_CRKEY_TIMEOUT	0x0001 /* underlying cred has no key timeout */
@@ -136,6 +137,8 @@ struct rpc_authops {
 						struct rpcsec_gss_info *);
 	int			(*key_timeout)(struct rpc_auth *,
 						struct rpc_cred *);
+	int			(*key_destroy)(struct rpc_auth *,
+						struct rpc_cred *);
 };
 
 struct rpc_credops {
@@ -198,6 +201,8 @@ int			rpcauth_get_gssinfo(rpc_authflavor_t,
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
 int			rpcauth_key_timeout_notify(struct rpc_auth *,
 						struct rpc_cred *);
+int			rpcauth_key_set_destroy(struct rpc_auth *,
+						struct rpc_cred *);
 bool			rpcauth_cred_key_to_expire(struct rpc_auth *, struct rpc_cred *);
 char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index d2623b9..408452c 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -357,6 +357,15 @@ struct rpc_auth *
 }
 EXPORT_SYMBOL_GPL(rpcauth_key_timeout_notify);
 
+int
+rpcauth_key_set_destroy(struct rpc_auth *auth, struct rpc_cred *cred)
+{
+	if (!cred->cr_auth->au_ops->key_destroy)
+		return 0;
+	return cred->cr_auth->au_ops->key_destroy(auth, cred);
+}
+EXPORT_SYMBOL_GPL(rpcauth_key_set_destroy);
+
 bool
 rpcauth_cred_key_to_expire(struct rpc_auth *auth, struct rpc_cred *cred)
 {
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f1df983..f434a03 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -223,6 +223,20 @@ void rpc_destroy_generic_auth(void)
  * on the acred ac_flags and return 0.
  */
 static int
+generic_key_destroy(struct rpc_auth *auth, struct rpc_cred *cred)
+{
+	struct auth_cred *acred = &container_of(cred, struct generic_cred,
+						gc_base)->acred;
+	struct rpc_cred *tcred;
+
+	tcred = auth->au_ops->lookup_cred(auth, acred, 0);
+	if (IS_ERR(tcred))
+		return -EACCES;
+	set_bit(RPCAUTH_CRED_DESTROYED, &tcred->cr_flags);
+	return 1;
+}
+
+static int
 generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
 {
 	struct auth_cred *acred = &container_of(cred, struct generic_cred,
@@ -270,6 +284,7 @@ void rpc_destroy_generic_auth(void)
 	.lookup_cred = generic_lookup_cred,
 	.crcreate = generic_create_cred,
 	.key_timeout = generic_key_timeout,
+	.key_destroy = generic_key_destroy,
 };
 
 static struct rpc_auth generic_auth = {
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4f16953..75f062c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1473,6 +1473,9 @@ static void gss_pipe_free(struct gss_pipe *p)
 	if (ret == 0)
 		return ret;
 
+	if (test_bit(RPCAUTH_CRED_DESTROYED, &rc->cr_flags))
+		return 0;
+
 	/* Notify acred users of GSS context expiration timeout */
 	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
 	    (gss_key_timeout(rc) != 0)) {
-- 
1.8.3.1

