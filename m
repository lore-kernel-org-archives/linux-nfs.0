From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 02/19] rpc: gss: Add oid values to the gss_api mechanism
	structures
Date: Thu, 21 Feb 2008 13:43:57 -0500
Message-ID: <20080221184357.19195.79305.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:12389 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbYBUSn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:43:57 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 294204609
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:43:57 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Usha Ketineni <uketinen@us.ibm.com>

On NFSV4 server side, these are required as part of the security
triple(oid,qop,service) information being sent in the response of the
SECINFO operation.

Signed-off-by: Usha Ketineni <uketinen@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 fs/nfsd/nfs4xdr.c                    |    6 +++---
 include/linux/sunrpc/gss_api.h       |    2 +-
 include/linux/sunrpc/gss_krb5.h      |    2 ++
 net/sunrpc/auth_gss/gss_krb5_mech.c  |    4 +++-
 net/sunrpc/auth_gss/gss_spkm3_mech.c |    4 +++-
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b0592e7..d6b43eb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2519,9 +2519,9 @@ nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 			RESERVE_SPACE(4);
 			WRITE32(RPC_AUTH_GSS);
 			ADJUST_ARGS();
-			RESERVE_SPACE(4 + gm->gm_oid.len);
-			WRITE32(gm->gm_oid.len);
-			WRITEMEM(gm->gm_oid.data, gm->gm_oid.len);
+			RESERVE_SPACE(4 + gm->gm_oid->len);
+			WRITE32(gm->gm_oid->len);
+			WRITEMEM(gm->gm_oid->data, gm->gm_oid->len);
 			ADJUST_ARGS();
 			RESERVE_SPACE(4);
 			WRITE32(0); /* qop */
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 459c5fc..ed0b80c 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -76,7 +76,7 @@ struct pf_desc {
 struct gss_api_mech {
 	struct list_head	gm_list;
 	struct module		*gm_owner;
-	struct xdr_netobj	gm_oid;
+	struct xdr_netobj	*gm_oid;
 	char			*gm_name;
 	const struct gss_api_ops *gm_ops;
 	/* pseudoflavors supported by this mechanism: */
diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 5a4b1e0..8c38aba 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -70,6 +70,8 @@ enum seal_alg {
 	SEAL_ALG_DES3KD = 0x0002
 };
 
+extern struct xdr_netobj krb5_oid;
+
 #define KRB5_CKSUM_LENGTH 8
 
 #define CKSUMTYPE_CRC32			0x0001
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 60c3dba..3c070d0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -232,10 +232,12 @@ static struct pf_desc gss_kerberos_pfs[] = {
 	},
 };
 
+struct xdr_netobj krb5_oid = {9, "\x2a\x86\x48\x86\xf7\x12\x01\x02\x02"};
+
 static struct gss_api_mech gss_kerberos_mech = {
 	.gm_name	= "krb5",
 	.gm_owner	= THIS_MODULE,
-	.gm_oid		= {9, (void *)"\x2a\x86\x48\x86\xf7\x12\x01\x02\x02"},
+	.gm_oid		= &krb5_oid,
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index 5deb4b6..210b23b 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -214,10 +214,12 @@ static struct pf_desc gss_spkm3_pfs[] = {
 	{RPC_AUTH_GSS_SPKMI, RPC_GSS_SVC_INTEGRITY, "spkm3i"},
 };
 
+struct xdr_netobj spkm3_oid = {7, "\053\006\001\005\005\001\003"};
+
 static struct gss_api_mech gss_spkm3_mech = {
 	.gm_name	= "spkm3",
 	.gm_owner	= THIS_MODULE,
-	.gm_oid		= {7, "\053\006\001\005\005\001\003"},
+	.gm_oid		= &spkm3_oid,
 	.gm_ops		= &gss_spkm3_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_spkm3_pfs),
 	.gm_pfs		= gss_spkm3_pfs,

