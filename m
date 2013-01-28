Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:51846 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929Ab3A1UcH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:32:07 -0500
Received: by mail-ia0-f177.google.com with SMTP id h8so4853594iaa.22
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:32:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 5/5] SUNRPC: Consider qop when looking up pseudoflavors
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 28 Jan 2013 15:32:05 -0500
Message-ID: <20130128203205.2523.85925.stgit@seurat.1015granger.net>
In-Reply-To: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
References: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A list of GSS tuples are returned in response to a SECINFO request.
The client is supposed to pick a pseudoflavor it supports that
corresponds to one of the tuples returned by the server.

Currently we ignore a GSS tuple's "qop" value.  A pseudoflavor is
chosen based on the OID and service.  NFSv4 appears to support
only one qop value: zero.  So this omission has not had much effect.

However, if a server returns something other than zero in that
field, we won't catch it, and may behave in incorrect or unexpected
ways.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/gss_api.h        |    2 ++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    3 +++
 net/sunrpc/auth_gss/gss_mech_switch.c |   22 +++++++++++++++++++++-
 3 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index a7bbe96..7daacea 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -26,6 +26,7 @@ struct gss_ctx {
 #define GSS_C_NO_BUFFER		((struct xdr_netobj) 0)
 #define GSS_C_NO_CONTEXT	((struct gss_ctx *) 0)
 #define GSS_C_NULL_OID		((struct xdr_netobj) 0)
+#define GSS_C_QOP_DEFAULT	(0)
 
 /* RPCSEC_GSS services, from RFC 2203, section 5 */
 enum rpc_gss_svc {
@@ -82,6 +83,7 @@ char *gss_service_to_auth_domain_name(struct gss_api_mech *, u32 service);
 
 struct pf_desc {
 	u32	pseudoflavor;
+	u32	qop;
 	u32	service;
 	char	*name;
 	char	*auth_domain_name;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 8b1005d..9d99f3a 100644
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
index 64dbf07a..731e298 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -285,6 +285,25 @@ gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
 }
 EXPORT_SYMBOL_GPL(gss_svc_to_pseudoflavor);
 
+/*
+ * Same as gss_svc_to_pseudoflavor, but includes a search on the qop
+ * as well.
+ */
+static rpc_authflavor_t gss_qop_svc_to_pseudoflavor(struct gss_api_mech *gm,
+	u32 qop, u32 service)
+{
+	int i;
+
+	for (i = 0; i < gm->gm_pf_num; i++) {
+		if (gm->gm_pfs[i].qop == qop &&
+		    gm->gm_pfs[i].service == service) {
+			return gm->gm_pfs[i].pseudoflavor;
+		}
+	}
+
+	return RPC_AUTH_MAXFLAVOR;
+}
+
 /**
  * gss_mech_lookup_pseudoflavor - look up a pseudoflavor given a GSS tuple
  * @info: a GSS mech OID, quality of protection, and service value
@@ -301,7 +320,8 @@ rpc_authflavor_t gss_mech_lookup_pseudoflavor(struct rpcsec_gss_info *info)
 	if (mech == NULL)
 		return RPC_AUTH_MAXFLAVOR;
 
-	pseudoflavor = gss_svc_to_pseudoflavor(mech, info->service);
+	pseudoflavor = gss_qop_svc_to_pseudoflavor(mech,
+					info->qop, info->service);
 
 	gss_mech_put(mech);
 	return pseudoflavor;

