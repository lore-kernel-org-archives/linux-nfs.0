Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:58346 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933600Ab3D3WtQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 18:49:16 -0400
Received: by mail-ie0-f169.google.com with SMTP id ar20so1358806iec.28
        for <linux-nfs@vger.kernel.org>; Tue, 30 Apr 2013 15:49:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFSD: SECINFO doesn't handle unsupported pseudoflavors
 correctly
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 30 Apr 2013 18:48:54 -0400
Message-ID: <20130430224854.21406.20228.stgit@seurat.1015granger.net>
In-Reply-To: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
References: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
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
XDR buffer, then write that count into a placeholder in the XDR
buffer when all recognized flavors have been encoded.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4xdr.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ce327e3..758a1f3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3140,10 +3140,11 @@ static __be32
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
@@ -3167,13 +3168,17 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
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
@@ -3181,13 +3186,22 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
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

