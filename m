Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f169.google.com ([209.85.210.169]:65025 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab3A1Ubm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:31:42 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so4964876iaf.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:31:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 2/5] SUNRPC: Define rpcsec_gss_info structure
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 28 Jan 2013 15:31:40 -0500
Message-ID: <20130128203139.2523.43728.stgit@seurat.1015granger.net>
In-Reply-To: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
References: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcsec_gss_info is a collection of information used by the NFSv4
SECINFO procedure.  For simplicity and efficiency, I'd like to
return this structure from the NFSv4 XDR layer, and pass it
straight into the RPC client.

Define an RPC client structure that can be shared between NFS and
RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c          |   12 ++++++------
 fs/nfs/nfs4xdr.c                |   20 +++++++++++---------
 include/linux/nfs_xdr.h         |   21 +++++----------------
 include/linux/sunrpc/auth_gss.h |    6 ------
 include/linux/sunrpc/gss_api.h  |   18 ++++++++++++++++++
 5 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 1e09eb7..f97b0a8 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -137,23 +137,23 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
 	struct xdr_netobj oid;
-	int i;
+	unsigned int i;
 	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
 
 	for (i = 0; i < flavors->num_flavors; i++) {
-		struct nfs4_secinfo_flavor *flavor;
-		flavor = &flavors->flavors[i];
+		struct nfs4_secinfo4 *flavor = &flavors->flavors[i];
 
 		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
 			pseudoflavor = flavor->flavor;
 			break;
 		} else if (flavor->flavor == RPC_AUTH_GSS) {
-			oid.len  = flavor->gss.sec_oid4.len;
-			oid.data = flavor->gss.sec_oid4.data;
+			oid.len  = flavor->flavor_info.oid.len;
+			oid.data = flavor->flavor_info.oid.data;
 			mech = gss_mech_get_by_OID(&oid);
 			if (!mech)
 				continue;
-			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
+			pseudoflavor = gss_svc_to_pseudoflavor(mech,
+						flavor->flavor_info.service);
 			gss_mech_put(mech);
 			break;
 		}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26b1439..c445b8c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5209,27 +5209,29 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
-static int decode_secinfo_gss(struct xdr_stream *xdr, struct nfs4_secinfo_flavor *flavor)
+static int decode_secinfo_gss(struct xdr_stream *xdr, struct nfs4_secinfo4 *flavor)
 {
+	u32 oid_len;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	flavor->gss.sec_oid4.len = be32_to_cpup(p);
-	if (flavor->gss.sec_oid4.len > GSS_OID_MAX_LEN)
+	oid_len = be32_to_cpup(p);
+	if (oid_len > GSS_OID_MAX_LEN)
 		goto out_err;
 
-	p = xdr_inline_decode(xdr, flavor->gss.sec_oid4.len);
+	p = xdr_inline_decode(xdr, oid_len);
 	if (unlikely(!p))
 		goto out_overflow;
-	memcpy(flavor->gss.sec_oid4.data, p, flavor->gss.sec_oid4.len);
+	memcpy(flavor->flavor_info.oid.data, p, oid_len);
+	flavor->flavor_info.oid.len = oid_len;
 
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
-	flavor->gss.qop4 = be32_to_cpup(p++);
-	flavor->gss.service = be32_to_cpup(p);
+	flavor->flavor_info.qop = be32_to_cpup(p++);
+	flavor->flavor_info.service = be32_to_cpup(p);
 
 	return 0;
 
@@ -5242,10 +5244,10 @@ out_err:
 
 static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 {
-	struct nfs4_secinfo_flavor *sec_flavor;
+	struct nfs4_secinfo4 *sec_flavor;
+	unsigned int i, num_flavors;
 	int status;
 	__be32 *p;
-	int i, num_flavors;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 467167402..92a6e7c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1046,25 +1046,14 @@ struct nfs4_fs_locations_res {
 	struct nfs4_fs_locations       *fs_locations;
 };
 
-struct nfs4_secinfo_oid {
-	unsigned int len;
-	char data[GSS_OID_MAX_LEN];
-};
-
-struct nfs4_secinfo_gss {
-	struct nfs4_secinfo_oid sec_oid4;
-	unsigned int qop4;
-	unsigned int service;
-};
-
-struct nfs4_secinfo_flavor {
-	unsigned int 		flavor;
-	struct nfs4_secinfo_gss	gss;
+struct nfs4_secinfo4 {
+	u32			flavor;
+	struct rpcsec_gss_info	flavor_info;
 };
 
 struct nfs4_secinfo_flavors {
-	unsigned int num_flavors;
-	struct nfs4_secinfo_flavor flavors[0];
+	unsigned int		num_flavors;
+	struct nfs4_secinfo4	flavors[0];
 };
 
 struct nfs4_secinfo_arg {
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index f1cfd4c..39de1f30 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -28,12 +28,6 @@ enum rpc_gss_proc {
 	RPC_GSS_PROC_DESTROY = 3
 };
 
-enum rpc_gss_svc {
-	RPC_GSS_SVC_NONE = 1,
-	RPC_GSS_SVC_INTEGRITY = 2,
-	RPC_GSS_SVC_PRIVACY = 3
-};
-
 /* on-the-wire gss cred: */
 struct rpc_gss_wire_cred {
 	u32			gc_v;		/* version */
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index a19e254..6381b5b 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -27,8 +27,26 @@ struct gss_ctx {
 #define GSS_C_NO_CONTEXT	((struct gss_ctx *) 0)
 #define GSS_C_NULL_OID		((struct xdr_netobj) 0)
 
+/* RPCSEC_GSS services, from RFC 2203, section 5 */
+enum rpc_gss_svc {
+	/* The enumerated value for 0 is reserved */
+	RPC_GSS_SVC_NONE = 1,
+	RPC_GSS_SVC_INTEGRITY = 2,
+	RPC_GSS_SVC_PRIVACY = 3
+};
+
 /*XXX  arbitrary length - is this set somewhere? */
 #define GSS_OID_MAX_LEN 32
+struct rpcsec_gss_oid {
+	unsigned int	len;
+	u8		data[GSS_OID_MAX_LEN];
+};
+
+struct rpcsec_gss_info {
+	struct rpcsec_gss_oid	oid;
+	u32			qop;
+	u32			service;
+};
 
 /* gss-api prototypes; note that these are somewhat simplified versions of
  * the prototypes specified in RFC 2744. */

