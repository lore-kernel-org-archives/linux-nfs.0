Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33703 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab3A1Ubu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:31:50 -0500
Received: by mail-ie0-f175.google.com with SMTP id c12so858970ieb.34
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:31:50 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 3/5] SUNRPC: Introduce rpcauth_lookup_gss_pseudoflavor()
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 28 Jan 2013 15:31:48 -0500
Message-ID: <20130128203148.2523.54613.stgit@seurat.1015granger.net>
In-Reply-To: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
References: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling gss_foo() in the NFS client without first ensuring the GSS
kernel module is pinned is not safe.  Introduce an rpcauth API that
pins the GSS module properly before performing the pseudoflavor
lookup.

The refactored code addresses a bug:  If nfs_find_best_sec() matches
on an OID, but the "service" part of the tuple is not supported by
our RPC client, nfs_find_best_sec() currently returns
RPC_AUTH_MAXFLAVOR, but should return RPC_AUTH_UNIX.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c                |   44 ++++++++++++++++++++-------------
 include/linux/sunrpc/auth.h           |    4 +++
 include/linux/sunrpc/gss_api.h        |    5 ++--
 net/sunrpc/auth.c                     |   31 +++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   28 +++++++++++++++++----
 6 files changed, 88 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index f97b0a8..7ab7ab7 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -133,33 +133,43 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 	return ret;
 }
 
+/**
+ * nfs_find_best_sec - Find a security mechanism supported locally
+ * @flavors: List of security tuples returned by SECINFO procedure
+ *
+ * The "flavors" array is searched in the order returned from the server,
+ * per RFC 3530.  Return the pseudoflavor of the first security mechanism
+ * in the array we support.  RPC_AUTH_UNIX is returned if no matching
+ * flavor is found in the array.
+ */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
-	struct gss_api_mech *mech;
-	struct xdr_netobj oid;
 	unsigned int i;
-	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
 
 	for (i = 0; i < flavors->num_flavors; i++) {
 		struct nfs4_secinfo4 *flavor = &flavors->flavors[i];
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
+		rpc_authflavor_t pseudoflavor;
+
+		switch (flavor->flavor) {
+		case RPC_AUTH_NULL:
+		case RPC_AUTH_UNIX:
+			dprintk("%s: Using supported flavor %d\n",
+				__func__, flavor->flavor);
+			return flavor->flavor;
+		case RPC_AUTH_GSS:
+			pseudoflavor = rpcauth_lookup_gss_pseudoflavor(
+							&flavor->flavor_info);
+			if (pseudoflavor != RPC_AUTH_MAXFLAVOR) {
+				dprintk("%s: Using supported GSS flavor %d\n",
+					__func__, pseudoflavor);
+				return pseudoflavor;
+			}
 			break;
 		}
 	}
 
-	return pseudoflavor;
+	dprintk("%s: No supported flavor found, using AUTH_UNIX\n", __func__);
+	return RPC_AUTH_UNIX;
 }
 
 static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index f25ba92..b1a49a5 100644
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
+	rpc_authflavor_t	(*lookup_pseudoflavor)(struct rpcsec_gss_info *);
 };
 
 struct rpc_credops {
@@ -136,6 +139,7 @@ int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
+rpc_authflavor_t	rpcauth_lookup_gss_pseudoflavor(struct rpcsec_gss_info *);
 int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 6381b5b..a7bbe96 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -135,9 +135,8 @@ struct gss_api_ops {
 int gss_mech_register(struct gss_api_mech *);
 void gss_mech_unregister(struct gss_api_mech *);
 
-/* returns a mechanism descriptor given an OID, and increments the mechanism's
- * reference count. */
-struct gss_api_mech * gss_mech_get_by_OID(struct xdr_netobj *);
+/* Given a GSS security tuple, look up a pseudoflavor */
+rpc_authflavor_t gss_mech_lookup_pseudoflavor(struct rpcsec_gss_info *);
 
 /* Returns a reference to a mechanism, given a name like "krb5" etc. */
 struct gss_api_mech *gss_mech_get_by_name(const char *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..5e160c9 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -124,6 +124,37 @@ rpcauth_unregister(const struct rpc_authops *ops)
 EXPORT_SYMBOL_GPL(rpcauth_unregister);
 
 /**
+ * rpcauth_lookup_gss_pseudoflavor - find pseudoflavor matching a GSS tuple
+ * @info: a GSS mech OID, quality of protection, and service value
+ *
+ * Returns a matching pseudoflavor, or RPC_AUTH_MAXFLAVOR if the tuple is
+ * not supported locally.
+ */
+rpc_authflavor_t
+rpcauth_lookup_gss_pseudoflavor(struct rpcsec_gss_info *info)
+{
+	const struct rpc_authops *ops;
+	rpc_authflavor_t pseudoflavor;
+
+	if ((ops = auth_flavors[RPC_AUTH_GSS]) == NULL)
+		request_module("rpc-auth-%u", RPC_AUTH_GSS);
+	spin_lock(&rpc_authflavor_lock);
+	ops = auth_flavors[RPC_AUTH_GSS];
+	if (ops == NULL || !try_module_get(ops->owner)) {
+		spin_unlock(&rpc_authflavor_lock);
+		dprintk("RPC:       %s: failed to pin GSS module\n", __func__);
+		return RPC_AUTH_MAXFLAVOR;
+	}
+	spin_unlock(&rpc_authflavor_lock);
+
+	pseudoflavor = ops->lookup_pseudoflavor(info);
+
+	module_put(ops->owner);
+	return pseudoflavor;
+}
+EXPORT_SYMBOL_GPL(rpcauth_lookup_gss_pseudoflavor);
+
+/**
  * rpcauth_list_flavors - discover registered flavors and pseudoflavors
  * @array: array to fill in
  * @size: size of "array"
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6e5c824..f2e8f45 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1629,6 +1629,7 @@ static const struct rpc_authops authgss_ops = {
 	.pipes_create	= gss_pipes_dentries_create,
 	.pipes_destroy	= gss_pipes_dentries_destroy,
 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
+	.lookup_pseudoflavor = gss_mech_lookup_pseudoflavor,
 };
 
 static const struct rpc_credops gss_credops = {
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index b174fcd..883b5b8 100644
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
+ * gss_mech_lookup_pseudoflavor - look up a pseudoflavor given a GSS tuple
+ * @info: a GSS mech OID, quality of protection, and service value
+ *
+ * Returns a matching pseudoflavor, or RPC_AUTH_MAXFLAVOR if the tuple is
+ * not supported.
+ */
+rpc_authflavor_t gss_mech_lookup_pseudoflavor(struct rpcsec_gss_info *info)
+{
+	rpc_authflavor_t pseudoflavor;
+	struct gss_api_mech *mech;
+
+	mech = gss_mech_get_by_OID(&info->oid);
+	if (mech == NULL)
+		return RPC_AUTH_MAXFLAVOR;
+
+	pseudoflavor = gss_svc_to_pseudoflavor(mech, info->service);
+
+	gss_mech_put(mech);
+	return pseudoflavor;
+}
+
 u32
 gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 {

