Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f169.google.com ([209.85.210.169]:33651 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281Ab3A3Ted (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 14:34:33 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so2848542iaf.14
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 11:34:33 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Pin GSS module while handling flavor lookups
To: linux-nfs@vger.kernel.org
Date: Wed, 30 Jan 2013 14:34:30 -0500
Message-ID: <20130130193120.1289.33936.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an API similar to rpcauth_lookup_pseudoflavor().  The NFS server
should not call GSS API functions directly without first pinning
the GSS module.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Bruce-

Are you interested in taking something like this (untested) patch
for 3.9?  (This has pre-requisites I posted earlier this week).

Not sure what to do about svcauth_gss_flavor(), which has the same
issue.


 fs/nfsd/nfs4xdr.c                     |   18 ++++++++---------
 include/linux/sunrpc/auth.h           |    2 ++
 include/linux/sunrpc/gss_api.h        |    3 +++
 net/sunrpc/auth.c                     |   35 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   31 +++++++++++++++++++++++++++++
 6 files changed, 80 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0dc1158..f986209 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3129,8 +3129,7 @@ static __be32
 nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 			 __be32 nfserr,struct svc_export *exp)
 {
-	int i = 0;
-	u32 nflavs;
+	u32 i, nflavs;
 	struct exp_flavor_info *flavs;
 	struct exp_flavor_info def_flavs[2];
 	__be32 *p;
@@ -3162,23 +3161,22 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 	ADJUST_ARGS();
 	for (i = 0; i < nflavs; i++) {
 		u32 flav = flavs[i].pseudoflavor;
-		struct gss_api_mech *gm = gss_mech_get_by_pseudoflavor(flav);
+		struct rpcsec_gss_info info;
 
-		if (gm) {
+		if (rpcauth_lookup_gss_info(flav, &info) == 0) {
 			RESERVE_SPACE(4);
 			WRITE32(RPC_AUTH_GSS);
 			ADJUST_ARGS();
-			RESERVE_SPACE(4 + gm->gm_oid.len);
-			WRITE32(gm->gm_oid.len);
-			WRITEMEM(gm->gm_oid.data, gm->gm_oid.len);
+			RESERVE_SPACE(4 + info.oid.len);
+			WRITE32(info.oid.len);
+			WRITEMEM(info.oid.data, info.oid.len);
 			ADJUST_ARGS();
 			RESERVE_SPACE(4);
-			WRITE32(0); /* qop */
+			WRITE32(info.qop);
 			ADJUST_ARGS();
 			RESERVE_SPACE(4);
-			WRITE32(gss_pseudoflavor_to_service(gm, flav));
+			WRITE32(info.service);
 			ADJUST_ARGS();
-			gss_mech_put(gm);
 		} else {
 			RESERVE_SPACE(4);
 			WRITE32(flav);
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b1a49a5..312684c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -105,6 +105,7 @@ struct rpc_authops {
 	void			(*pipes_destroy)(struct rpc_auth *);
 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
 	rpc_authflavor_t	(*lookup_pseudoflavor)(struct rpcsec_gss_info *);
+	int			(*lookup_gss_info)(rpc_authflavor_t, struct rpcsec_gss_info *);
 };
 
 struct rpc_credops {
@@ -140,6 +141,7 @@ int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
 rpc_authflavor_t	rpcauth_lookup_gss_pseudoflavor(struct rpcsec_gss_info *);
+int			rpcauth_lookup_gss_info(rpc_authflavor_t, struct rpcsec_gss_info *);
 int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 6f40fd1..1293a7b 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -133,6 +133,9 @@ void gss_mech_unregister(struct gss_api_mech *);
 /* Given a GSS security tuple, look up a pseudoflavor */
 rpc_authflavor_t gss_mech_lookup_pseudoflavor(struct rpcsec_gss_info *);
 
+/* Given a pseudoflavor, look up a GSS security tuple */
+int gss_mech_lookup_info(rpc_authflavor_t, struct rpcsec_gss_info *);
+
 /* Returns a reference to a mechanism, given a name like "krb5" etc. */
 struct gss_api_mech *gss_mech_get_by_name(const char *);
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 32e305b..0cfffbc 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -157,6 +157,41 @@ rpcauth_lookup_gss_pseudoflavor(struct rpcsec_gss_info *info)
 EXPORT_SYMBOL_GPL(rpcauth_lookup_gss_pseudoflavor);
 
 /**
+ * rpcauth_lookup_gss_info - find GSS tuple matching a pseudoflavor
+ * @pseudoflavor: GSS pseudoflavor to match
+ * @info: rpcsec_gss_info structure to fill in
+ *
+ * Returns zero and fills in "info" if pseudoflavor matches a
+ * supported mechanism.
+ */
+int
+rpcauth_lookup_gss_info(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
+{
+	const struct rpc_authops *ops;
+	int result;
+
+	if ((ops = auth_flavors[pseudoflavor]) == NULL)
+		request_module("rpc-auth-%u", RPC_AUTH_GSS);
+	spin_lock(&rpc_authflavor_lock);
+	ops = auth_flavors[pseudoflavor];
+	if (ops == NULL || !try_module_get(ops->owner)) {
+		spin_unlock(&rpc_authflavor_lock);
+		dprintk("RPC:       %s: failed to pin module\n", __func__);
+		return -ENOMEM;
+	}
+	spin_unlock(&rpc_authflavor_lock);
+
+	if (ops->lookup_gss_info == NULL)
+		result = -ENOMEM;
+	else
+		result = ops->lookup_gss_info(pseudoflavor, info);
+
+	module_put(ops->owner);
+	return result;
+}
+EXPORT_SYMBOL_GPL(rpcauth_lookup_gss_info);
+
+/**
  * rpcauth_list_flavors - discover registered flavors and pseudoflavors
  * @array: array to fill in
  * @size: size of "array"
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f2e8f45..f1e92f4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1630,6 +1630,7 @@ static const struct rpc_authops authgss_ops = {
 	.pipes_destroy	= gss_pipes_dentries_destroy,
 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
 	.lookup_pseudoflavor = gss_mech_lookup_pseudoflavor,
+	.lookup_gss_info = gss_mech_lookup_info,
 };
 
 static const struct rpc_credops gss_credops = {
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 3ba0450..7331b0b 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -314,6 +314,37 @@ rpc_authflavor_t gss_mech_lookup_pseudoflavor(struct rpcsec_gss_info *info)
 	return pseudoflavor;
 }
 
+/**
+ * gss_mech_lookup_info - look up a GSS tuple for a given pseudoflavor
+ * @pseudoflavor: GSS pseudoflavor to match
+ * @info: rpcsec_gss_info structure to fill in
+ *
+ * Returns zero and fills in "info" if pseudoflavor matches a
+ * supported mechanism.
+ */
+int gss_mech_lookup_info(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
+{
+	struct gss_api_mech *gm;
+	int i;
+
+	gm = gss_mech_get_by_pseudoflavor(pseudoflavor);
+	if (gm == NULL)
+		return -ENOMEM;
+
+	for (i = 0; i < gm->gm_pf_num; i++)
+		if (gm->gm_pfs[i].pseudoflavor == pseudoflavor) {
+			memcpy(info->oid.data, gm->gm_oid.data, gm->gm_oid.len);
+			info->oid.len = gm->gm_oid.len;
+			info->qop = gm->gm_pfs[i].qop;
+			info->service = gm->gm_pfs[i].service;
+			gss_mech_put(gm);
+			return 0;
+		}
+
+	gss_mech_put(gm);
+	return -ENOMEM;
+}
+
 u32
 gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 {

