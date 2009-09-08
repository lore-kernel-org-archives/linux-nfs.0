From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] SUNRPC: Provide an API to determine what auth flavors are
	supported
Date: Tue, 08 Sep 2009 18:36:24 -0400
Message-ID: <20090908223624.23375.28359.stgit@matisse.1015granger.net>
References: <20090908223433.23375.40342.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:53240
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751952AbZIHWgc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 18:36:32 -0400
In-Reply-To: <20090908223433.23375.40342.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce an external function call that can report whether sunrpc.ko
can support an authentication flavor or not.

A new optional rpc_authops hook is added.  If the hook is not present,
then the flavor is assumed to be supported.  If the hook is present,
it is passed the pseudoflavor to check, and returns an indication of
whether the pseudoflavor is supported or not.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/auth.h    |    2 ++
 net/sunrpc/auth.c              |   33 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |   18 +++++++++++++++++-
 3 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 3f63218..ad9bc97 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -103,6 +103,7 @@ struct rpc_authops {
 
 	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct auth_cred *, int);
 	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int);
+	int			(*is_supported)(const rpc_authflavor_t);
 };
 
 struct rpc_credops {
@@ -134,6 +135,7 @@ struct rpc_cred *	rpc_lookup_cred(void);
 struct rpc_cred *	rpc_lookup_machine_cred(void);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
+int			rpcauth_is_supported(rpc_authflavor_t pseudoflavor);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 0c431c2..ef31ff6 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -72,6 +72,39 @@ rpcauth_unregister(const struct rpc_authops *ops)
 }
 EXPORT_SYMBOL_GPL(rpcauth_unregister);
 
+/**
+ * rpcauth_is_supported - report whether a particular flavor is supported
+ * @pseudoflavor: RPC authentication flavor to check
+ *
+ * Returns 1 if there is built-in support, or a loaded module, which can
+ * handle @pseudoflavor.  Otherwise, zero is returned.
+ */
+int
+rpcauth_is_supported(rpc_authflavor_t pseudoflavor)
+{
+	const rpc_authflavor_t flavor = pseudoflavor_to_flavor(pseudoflavor);
+	const struct rpc_authops *ops;
+	int ret = 0;
+
+	spin_lock(&rpc_authflavor_lock);
+	ops = auth_flavors[flavor];
+	if (ops == NULL || !try_module_get(ops->owner)) {
+		spin_unlock(&rpc_authflavor_lock);
+		goto out;
+	}
+	spin_unlock(&rpc_authflavor_lock);
+
+	ret = 1;
+	if (ops->is_supported)
+		ret = ops->is_supported(pseudoflavor);
+
+	module_put(ops->owner);
+
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpcauth_is_supported);
+
 struct rpc_auth *
 rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
 {
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 66d458f..fe03e0f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -735,6 +735,21 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	}
 }
 
+static int
+gss_is_supported(const rpc_authflavor_t pseudoflavor)
+{
+	struct gss_api_mech *mech;
+	int ret = 0;
+
+	mech = gss_mech_get_by_pseudoflavor(pseudoflavor);
+	if (mech) {
+		ret = 1;
+		gss_mech_put(mech);
+	}
+
+	return ret;
+}
+
 /*
  * NOTE: we have the opportunity to use different
  * parameters based on the input flavor (which must be a pseudoflavor)
@@ -1479,7 +1494,8 @@ static const struct rpc_authops authgss_ops = {
 	.create		= gss_create,
 	.destroy	= gss_destroy,
 	.lookup_cred	= gss_lookup_cred,
-	.crcreate	= gss_create_cred
+	.crcreate	= gss_create_cred,
+	.is_supported	= gss_is_supported,
 };
 
 static const struct rpc_credops gss_credops = {

