Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f176.google.com ([209.85.210.176]:36080 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab3CPTyg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:54:36 -0400
Received: by mail-ia0-f176.google.com with SMTP id i18so4162833iac.21
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:54:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 03/15] SUNRPC: Define rpcsec_gss_info structure
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:54:34 -0400
Message-ID: <20130316195434.27329.71934.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 SECINFO procedure returns a list of security flavors.  Any
GSS flavor also has a GSS tuple containing an OID, a quality-of-
protection value, and a service value, which specifies a particular
GSS pseudoflavor.

For simplicity and efficiency, I'd like to return each GSS tuple
from the NFSv4 SECINFO XDR decoder and pass it straight into the RPC
client.

Define a data structure that is visible to both the NFS client and
the RPC client.  Take structure and field names from the relevant
standards to avoid confusion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c              |   12 ++++++------
 fs/nfs/nfs4xdr.c                    |   21 ++++++++++++---------
 include/linux/nfs_xdr.h             |   21 +++++----------------
 include/linux/sunrpc/gss_api.h      |   14 ++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_mech.c |    2 +-
 5 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 0dd7660..88231c9 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -138,23 +138,23 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
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
index e3edda5..95b396f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5209,27 +5209,30 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
-static int decode_secinfo_gss(struct xdr_stream *xdr, struct nfs4_secinfo_flavor *flavor)
+static int decode_secinfo_gss(struct xdr_stream *xdr,
+			      struct nfs4_secinfo4 *flavor)
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
 
@@ -5242,10 +5245,10 @@ out_err:
 
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
index 94b0406..a021eb0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1047,25 +1047,14 @@ struct nfs4_fs_locations_res {
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
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index a19e254..98950e5 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -25,10 +25,20 @@ struct gss_ctx {
 
 #define GSS_C_NO_BUFFER		((struct xdr_netobj) 0)
 #define GSS_C_NO_CONTEXT	((struct gss_ctx *) 0)
-#define GSS_C_NULL_OID		((struct xdr_netobj) 0)
 
 /*XXX  arbitrary length - is this set somewhere? */
 #define GSS_OID_MAX_LEN 32
+struct rpcsec_gss_oid {
+	unsigned int	len;
+	u8		data[GSS_OID_MAX_LEN];
+};
+
+/* From RFC 3530 */
+struct rpcsec_gss_info {
+	struct rpcsec_gss_oid	oid;
+	u32			qop;
+	u32			service;
+};
 
 /* gss-api prototypes; note that these are somewhat simplified versions of
  * the prototypes specified in RFC 2744. */
@@ -76,7 +86,7 @@ struct pf_desc {
 struct gss_api_mech {
 	struct list_head	gm_list;
 	struct module		*gm_owner;
-	struct xdr_netobj	gm_oid;
+	struct rpcsec_gss_oid	gm_oid;
 	char			*gm_name;
 	const struct gss_api_ops *gm_ops;
 	/* pseudoflavors supported by this mechanism: */
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index d3611f1..61d36ce 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -754,7 +754,7 @@ MODULE_ALIAS("rpc-auth-gss-390005");
 static struct gss_api_mech gss_kerberos_mech = {
 	.gm_name	= "krb5",
 	.gm_owner	= THIS_MODULE,
-	.gm_oid		= {9, (void *)"\x2a\x86\x48\x86\xf7\x12\x01\x02\x02"},
+	.gm_oid		= { 9, "\x2a\x86\x48\x86\xf7\x12\x01\x02\x02" },
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,

