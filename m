Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f169.google.com ([209.85.210.169]:36822 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947086Ab3BHV2I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2013 16:28:08 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so4822169iaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 08 Feb 2013 13:28:05 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 2/3] NFSD: SECINFO doesn't handle unsupported pseudoflavors
 correctly
To: linux-nfs@vger.kernel.org
Date: Fri, 08 Feb 2013 16:28:03 -0500
Message-ID: <20130208212803.2234.60073.stgit@seurat.1015granger.net>
In-Reply-To: <20130208212007.2234.35721.stgit@seurat.1015granger.net>
References: <20130208212007.2234.35721.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfsd4_do_encode_secinfo() can't find GSS info that matches an
export security flavor, it assumes the flavor is not a GSS
pseudoflavor, and simply puts it on the wire.

However, if this XDR encoding logic is given a legitimate GSS
pseudoflavor but the RPC layer says it does not support that
pseudoflavor for some reason, then the server leaks GSS pseudoflavor
numbers onto the wire.

I confirmed this happens by blacklisting rpcsec_gss_krb5, then
attempted a client transition from the pseudo-fs to a Kerberos-only
share.  The client received a flavor list containing the Kerberos
pseudoflavor numbers, rather than GSS tuples.

The encoder logic can check that each pseudoflavor in flavs[] is
less than MAXFLAVOR before writing it into the buffer, to prevent
this.  But after "nflavs" is written into the XDR buffer, the
encoder can't skip writing flavor information into the buffer when
it discovers the RPC layer doesn't support that flavor.

So count the number of valid flavors as they are written into the
XDR buffer, then write that count into the XDR buffer when all
recognized flavors have been encoded.
---

 fs/nfsd/nfs4xdr.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0c1ae2c..4e9f0b5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3129,10 +3129,11 @@ static __be32
 nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 			 __be32 nfserr, struct svc_export *exp)
 {
-	u32 i, nflavs;
+	u32 i, nflavs, supported;
 	struct exp_flavor_info *flavs;
 	struct exp_flavor_info def_flavs[2];
-	__be32 *p;
+	__be32 *p, *flavorsp;
+	static bool report = true;
 
 	if (nfserr)
 		goto out;
@@ -3156,13 +3157,17 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 		}
 	}
 
+	supported = 0;
 	RESERVE_SPACE(4);
-	WRITE32(nflavs);
+	flavorsp = p++;		/* to be backfilled later */
 	ADJUST_ARGS();
+
 	for (i = 0; i < nflavs; i++) {
+		rpc_authflavor_t pf = flavs[i].pseudoflavor;
 		struct rpcsec_gss_info info;
 
-		if (rpcauth_get_gssinfo(flavs[i].pseudoflavor, &info) == 0) {
+		if (rpcauth_get_gssinfo(pf, &info) == 0) {
+			supported++;
 			RESERVE_SPACE(4 + 4 + info.oid.len + 4 + 4);
 			WRITE32(RPC_AUTH_GSS);
 			WRITE32(info.oid.len);
@@ -3170,13 +3175,22 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 			WRITE32(info.qop);
 			WRITE32(info.service);
 			ADJUST_ARGS();
-		} else {
+		} else if (pf < RPC_AUTH_MAXFLAVOR) {
+			supported++;
 			RESERVE_SPACE(4);
-			WRITE32(flavs[i].pseudoflavor);
+			WRITE32(pf);
 			ADJUST_ARGS();
+		} else {
+			if (report)
+				pr_warn("NFS: SECINFO: security flavor %u "
+					"is not supported\n", pf);
 		}
 	}
 
+	if (nflavs != supported)
+		report = false;
+	*flavorsp = htonl(supported);
+
 out:
 	if (exp)
 		exp_put(exp);

