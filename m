Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f171.google.com ([209.85.210.171]:60010 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab3A3Xmw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 18:42:52 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so3185087iaz.16
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 15:42:52 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 6/9] SUNRPC: Consider qop when looking up pseudoflavors
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 30 Jan 2013 18:42:50 -0500
Message-ID: <20130130234250.47786.74224.stgit@seurat.1015granger.net>
In-Reply-To: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 SECINFO operation returns a list of security flavors that
the server supports for a particular share.  An NFSv4 client is
supposed to pick a pseudoflavor it supports that corresponds to one
of the flavors returned by the server.

GSS flavors in this list have a GSS tuple that identify a specific
GSS pseudoflavor.

Currently our client ignores the GSS tuple's "qop" value.  A
matching pseudoflavor is chosen based only on the OID and service
value.

So far this omission has not had much effect on Linux.  The NFSv4
protocol currently supports only one qop value: zero, or
GSS_C_QOP_DEFAULT.

However, if an NFSv4 server happens to return something other than
zero in the qop field, our client won't notice.  This could cause
the client to behave in incorrect ways that could have security
implications.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/gss_api.h        |    4 +++-
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    3 +++
 net/sunrpc/auth_gss/gss_mech_switch.c |   19 +++++++++++++------
 net/sunrpc/auth_gss/svcauth_gss.c     |    4 +++-
 4 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index aba7687..e8299b2 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -25,6 +25,7 @@ struct gss_ctx {
 
 #define GSS_C_NO_BUFFER		((struct xdr_netobj) 0)
 #define GSS_C_NO_CONTEXT	((struct gss_ctx *) 0)
+#define GSS_C_QOP_DEFAULT	(0)
 
 /*XXX  arbitrary length - is this set somewhere? */
 #define GSS_OID_MAX_LEN 32
@@ -68,12 +69,13 @@ u32 gss_unwrap(
 u32 gss_delete_sec_context(
 		struct gss_ctx		**ctx_id);
 
-u32 gss_svc_to_pseudoflavor(struct gss_api_mech *, u32 service);
+rpc_authflavor_t gss_svc_to_pseudoflavor(struct gss_api_mech *, u32 qop, u32 service);
 u32 gss_pseudoflavor_to_service(struct gss_api_mech *, u32 pseudoflavor);
 char *gss_service_to_auth_domain_name(struct gss_api_mech *, u32 service);
 
 struct pf_desc {
 	u32	pseudoflavor;
+	u32	qop;
 	u32	service;
 	char	*name;
 	char	*auth_domain_name;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index b822ec5..33255ff 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -729,16 +729,19 @@ static const struct gss_api_ops gss_kerberos_ops = {
 static struct pf_desc gss_kerberos_pfs[] = {
 	[0] = {
 		.pseudoflavor = RPC_AUTH_GSS_KRB5,
+		.qop = GSS_C_QOP_DEFAULT,
 		.service = RPC_GSS_SVC_NONE,
 		.name = "krb5",
 	},
 	[1] = {
 		.pseudoflavor = RPC_AUTH_GSS_KRB5I,
+		.qop = GSS_C_QOP_DEFAULT,
 		.service = RPC_GSS_SVC_INTEGRITY,
 		.name = "krb5i",
 	},
 	[2] = {
 		.pseudoflavor = RPC_AUTH_GSS_KRB5P,
+		.qop = GSS_C_QOP_DEFAULT,
 		.service = RPC_GSS_SVC_PRIVACY,
 		.name = "krb5p",
 	},
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 8d03d32..c8da89e 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -271,19 +271,26 @@ int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr, int size)
 	return i;
 }
 
-u32
-gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
+/**
+ * gss_svc_to_pseudoflavor - map a GSS service number to a pseudoflavor
+ * @gm: GSS mechanism handle
+ * @qop: GSS quality-of-protection value
+ * @service: GSS service value
+ *
+ * Returns a matching security flavor, or RPC_AUTH_MAXFLAVOR if none is found.
+ */
+rpc_authflavor_t gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 qop, u32 service)
 {
 	int i;
 
 	for (i = 0; i < gm->gm_pf_num; i++) {
-		if (gm->gm_pfs[i].service == service) {
+		if (gm->gm_pfs[i].qop == qop &&
+		    gm->gm_pfs[i].service == service) {
 			return gm->gm_pfs[i].pseudoflavor;
 		}
 	}
-	return RPC_AUTH_MAXFLAVOR; /* illegal value */
+	return RPC_AUTH_MAXFLAVOR;
 }
-EXPORT_SYMBOL_GPL(gss_svc_to_pseudoflavor);
 
 /**
  * gss_mech_info2flavor - look up a pseudoflavor given a GSS tuple
@@ -301,7 +308,7 @@ rpc_authflavor_t gss_mech_info2flavor(struct rpcsec_gss_info *info)
 	if (gm == NULL)
 		return RPC_AUTH_MAXFLAVOR;
 
-	pseudoflavor = gss_svc_to_pseudoflavor(gm, info->service);
+	pseudoflavor = gss_svc_to_pseudoflavor(gm, info->qop, info->service);
 
 	gss_mech_put(gm);
 	return pseudoflavor;
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73e9573..2c0481d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1208,7 +1208,9 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 		svcdata->rsci = rsci;
 		cache_get(&rsci->h);
 		rqstp->rq_cred.cr_flavor = gss_svc_to_pseudoflavor(
-					rsci->mechctx->mech_type, gc->gc_svc);
+					rsci->mechctx->mech_type,
+					GSS_C_QOP_DEFAULT,
+					gc->gc_svc);
 		ret = SVC_OK;
 		goto out;
 	}

