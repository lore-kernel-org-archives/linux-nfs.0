Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f180.google.com ([209.85.210.180]:33243 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab3A3Xmf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 18:42:35 -0500
Received: by mail-ia0-f180.google.com with SMTP id f27so3124519iae.39
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 15:42:35 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 4/9] SUNRPC: Introduce rpcauth_get_pseudoflavor()
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 30 Jan 2013 18:42:33 -0500
Message-ID: <20130130234233.47786.90394.stgit@seurat.1015granger.net>
In-Reply-To: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_find_best_sec() now verifies all flavors requested in a SECINFO
reply against those that have been explicitly registered via
rpcauth_register().  For GSS pseudoflavors, these are verified
against the list of GSS pseudoflavors registered via
gss_mech_register().

Note that the current version of nfs_find_best_sec() can return
RPC_AUTH_MAXFLAVOR if the server returns a recognized OID but an
unsupported "service" value.  The new code returns RPC_AUTH_UNIX in
this case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c                |   41 +++++++++++++++++++--------------
 include/linux/sunrpc/auth.h           |    4 +++
 include/linux/sunrpc/gss_api.h        |    5 ++--
 net/sunrpc/auth.c                     |   34 +++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   28 +++++++++++++++++++----
 6 files changed, 87 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index f97b0a8..2187ae7 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -133,33 +133,38 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 	return ret;
 }
 
+/**
+ * nfs_find_best_sec - Find a security mechanism supported locally
+ * @flavors: List of security tuples returned by SECINFO procedure
+ *
+ * Return the pseudoflavor of the first security mechanism in
+ * "flavors" that is locally supported.  Return RPC_AUTH_UNIX if
+ * no matching flavor is found in the array.  The "flavors" array
+ * is searched in the order returned from the server, per RFC 3530
+ * recommendation.
+ */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
-	struct gss_api_mech *mech;
-	struct xdr_netobj oid;
+	rpc_authflavor_t pseudoflavor;
+	struct nfs4_secinfo4 *secinfo;
 	unsigned int i;
-	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
 
 	for (i = 0; i < flavors->num_flavors; i++) {
-		struct nfs4_secinfo4 *flavor = &flavors->flavors[i];
-
-		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
-			pseudoflavor = flavor->flavor;
-			break;
-		} else if (flavor->flavor == RPC_AUTH_GSS) {
-			oid.len  = flavor->flavor_info.oid.len;
-			oid.data = flavor->flavor_info.oid.data;
-			mech = gss_mech_get_by_OID(&oid);
-			if (!mech)
-				continue;
-			pseudoflavor = gss_svc_to_pseudoflavor(mech,
-						flavor->flavor_info.service);
-			gss_mech_put(mech);
+		secinfo = &flavors->flavors[i];
+
+		switch (secinfo->flavor) {
+		case RPC_AUTH_NULL:
+		case RPC_AUTH_UNIX:
+		case RPC_AUTH_GSS:
+			pseudoflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
+							&secinfo->flavor_info);
+			if (pseudoflavor != RPC_AUTH_MAXFLAVOR)
+				return pseudoflavor;
 			break;
 		}
 	}
 
-	return pseudoflavor;
+	return RPC_AUTH_UNIX;
 }
 
 static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index f25ba92..476e97c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -21,6 +21,8 @@
 /* size of the nodename buffer */
 #define UNX_MAXNODENAME	32
 
+struct rpcsec_gss_info;
+
 /* Work around the lack of a VFS credential */
 struct auth_cred {
 	uid_t	uid;
@@ -102,6 +104,7 @@ struct rpc_authops {
 	int			(*pipes_create)(struct rpc_auth *);
 	void			(*pipes_destroy)(struct rpc_auth *);
 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
+	rpc_authflavor_t	(*info2flavor)(struct rpcsec_gss_info *);
 };
 
 struct rpc_credops {
@@ -136,6 +139,7 @@ int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
+rpc_authflavor_t	rpcauth_get_pseudoflavor(rpc_authflavor_t, struct rpcsec_gss_info *);
 int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 98950e5..aba7687 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -127,9 +127,8 @@ struct gss_api_ops {
 int gss_mech_register(struct gss_api_mech *);
 void gss_mech_unregister(struct gss_api_mech *);
 
-/* returns a mechanism descriptor given an OID, and increments the mechanism's
- * reference count. */
-struct gss_api_mech * gss_mech_get_by_OID(struct xdr_netobj *);
+/* Given a GSS security tuple, look up a pseudoflavor */
+rpc_authflavor_t gss_mech_info2flavor(struct rpcsec_gss_info *);
 
 /* Returns a reference to a mechanism, given a name like "krb5" etc. */
 struct gss_api_mech *gss_mech_get_by_name(const char *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..ec18827 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -124,6 +124,40 @@ rpcauth_unregister(const struct rpc_authops *ops)
 EXPORT_SYMBOL_GPL(rpcauth_unregister);
 
 /**
+ * rpcauth_get_pseudoflavor - check if security flavor is supported
+ * @flavor: a security flavor
+ * @info: a GSS mech OID, quality of protection, and service value
+ *
+ * Verifies that an appropriate kernel module is available or already loaded.
+ * Returns an equivalent pseudoflavor, or RPC_AUTH_MAXFLAVOR if "flavor" is
+ * not supported locally.
+ */
+rpc_authflavor_t
+rpcauth_get_pseudoflavor(rpc_authflavor_t flavor, struct rpcsec_gss_info *info)
+{
+	const struct rpc_authops *ops;
+	rpc_authflavor_t pseudoflavor;
+
+	if ((ops = auth_flavors[flavor]) == NULL)
+		request_module("rpc-auth-%u", flavor);
+	spin_lock(&rpc_authflavor_lock);
+	ops = auth_flavors[flavor];
+	if (ops == NULL || !try_module_get(ops->owner)) {
+		spin_unlock(&rpc_authflavor_lock);
+		return RPC_AUTH_MAXFLAVOR;
+	}
+	spin_unlock(&rpc_authflavor_lock);
+
+	pseudoflavor = flavor;
+	if (ops->info2flavor != NULL)
+		pseudoflavor = ops->info2flavor(info);
+
+	module_put(ops->owner);
+	return pseudoflavor;
+}
+EXPORT_SYMBOL_GPL(rpcauth_get_pseudoflavor);
+
+/**
  * rpcauth_list_flavors - discover registered flavors and pseudoflavors
  * @array: array to fill in
  * @size: size of "array"
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4db065d..4522297 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1629,6 +1629,7 @@ static const struct rpc_authops authgss_ops = {
 	.pipes_create	= gss_pipes_dentries_create,
 	.pipes_destroy	= gss_pipes_dentries_destroy,
 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
+	.info2flavor	= gss_mech_info2flavor,
 };
 
 static const struct rpc_credops gss_credops = {
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index b174fcd..b09f25b 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -171,8 +171,7 @@ struct gss_api_mech * gss_mech_get_by_name(const char *name)
 }
 EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 
-struct gss_api_mech *
-gss_mech_get_by_OID(struct xdr_netobj *obj)
+static struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
 {
 	struct gss_api_mech	*pos, *gm = NULL;
 
@@ -188,11 +187,8 @@ gss_mech_get_by_OID(struct xdr_netobj *obj)
 	}
 	spin_unlock(&registered_mechs_lock);
 	return gm;
-
 }
 
-EXPORT_SYMBOL_GPL(gss_mech_get_by_OID);
-
 static inline int
 mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
 {
@@ -282,6 +278,28 @@ gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
 }
 EXPORT_SYMBOL_GPL(gss_svc_to_pseudoflavor);
 
+/**
+ * gss_mech_info2flavor - look up a pseudoflavor given a GSS tuple
+ * @info: a GSS mech OID, quality of protection, and service value
+ *
+ * Returns a matching pseudoflavor, or RPC_AUTH_MAXFLAVOR if the tuple is
+ * not supported.
+ */
+rpc_authflavor_t gss_mech_info2flavor(struct rpcsec_gss_info *info)
+{
+	rpc_authflavor_t pseudoflavor;
+	struct gss_api_mech *gm;
+
+	gm = gss_mech_get_by_OID(&info->oid);
+	if (gm == NULL)
+		return RPC_AUTH_MAXFLAVOR;
+
+	pseudoflavor = gss_svc_to_pseudoflavor(gm, info->service);
+
+	gss_mech_put(gm);
+	return pseudoflavor;
+}
+
 u32
 gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 {

