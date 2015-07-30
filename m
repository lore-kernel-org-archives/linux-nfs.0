Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34844 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbG3Nzv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:55:51 -0400
Received: by pdrg1 with SMTP id g1so25083087pdr.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:55:51 -0700 (PDT)
Message-ID: <55BA2CD2.1040303@gmail.com>
Date: Thu, 30 Jul 2015 21:55:30 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 5/5] NFSD: Return word2 bitmask if setting security label
 in OPEN/CREATE
References: <55BA2B46.90204@gmail.com>
In-Reply-To: <55BA2B46.90204@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Security label can be set in OPEN/CRATE request, nfsd should set
the bitmask in word2 if setting success.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 95 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 56 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 21e1263..0ff1abe 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2224,6 +2224,39 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 	return err;
 }
 
+static __be32
+nfsd4_encode_bitmap(struct xdr_stream *xdr, u32 bmval0, u32 bmval1, u32 bmval2)
+{
+	__be32 *p;
+
+	if (bmval2) {
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
+			goto out_resource;
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(bmval0);
+		*p++ = cpu_to_be32(bmval1);
+		*p++ = cpu_to_be32(bmval2);
+	} else if (bmval1) {
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
+			goto out_resource;
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(bmval0);
+		*p++ = cpu_to_be32(bmval1);
+	} else {
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
+			goto out_resource;
+		*p++ = cpu_to_be32(1);
+		*p++ = cpu_to_be32(bmval0);
+	}
+
+	return 0;
+out_resource:
+	return nfserr_resource;
+}
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -2321,28 +2354,9 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 	}
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 
-	if (bmval2) {
-		p = xdr_reserve_space(xdr, 16);
-		if (!p)
-			goto out_resource;
-		*p++ = cpu_to_be32(3);
-		*p++ = cpu_to_be32(bmval0);
-		*p++ = cpu_to_be32(bmval1);
-		*p++ = cpu_to_be32(bmval2);
-	} else if (bmval1) {
-		p = xdr_reserve_space(xdr, 12);
-		if (!p)
-			goto out_resource;
-		*p++ = cpu_to_be32(2);
-		*p++ = cpu_to_be32(bmval0);
-		*p++ = cpu_to_be32(bmval1);
-	} else {
-		p = xdr_reserve_space(xdr, 8);
-		if (!p)
-			goto out_resource;
-		*p++ = cpu_to_be32(1);
-		*p++ = cpu_to_be32(bmval0);
-	}
+	status = nfsd4_encode_bitmap(xdr, bmval0, bmval1, bmval2);
+	if (status)
+		goto out;
 
 	attrlen_offset = xdr->buf->len;
 	p = xdr_reserve_space(xdr, 4);
@@ -2735,13 +2749,11 @@ out_acl:
 	}
 #endif /* CONFIG_NFSD_PNFS */
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
-		p = xdr_reserve_space(xdr, 16);
-		if (!p)
-			goto out_resource;
-		*p++ = cpu_to_be32(3);
-		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
-		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
-		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
+		status = nfsd4_encode_bitmap(xdr, NFSD_SUPPATTR_EXCLCREAT_WORD0,
+						  NFSD_SUPPATTR_EXCLCREAT_WORD1,
+						  NFSD_SUPPATTR_EXCLCREAT_WORD2);
+		if (status)
+			goto out;
 	}
 
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
@@ -3068,13 +3080,12 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	__be32 *p;
 
 	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 32);
+		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		p = encode_cinfo(p, &create->cr_cinfo);
-		*p++ = cpu_to_be32(2);
-		*p++ = cpu_to_be32(create->cr_bmval[0]);
-		*p++ = cpu_to_be32(create->cr_bmval[1]);
+		encode_cinfo(p, &create->cr_cinfo);
+		nfserr = nfsd4_encode_bitmap(xdr, create->cr_bmval[0],
+				create->cr_bmval[1], create->cr_bmval[2]);
 	}
 	return nfserr;
 }
@@ -3214,16 +3225,22 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	nfserr = nfsd4_encode_stateid(xdr, &open->op_stateid);
 	if (nfserr)
 		goto out;
-	p = xdr_reserve_space(xdr, 40);
+	p = xdr_reserve_space(xdr, 24);
 	if (!p)
 		return nfserr_resource;
 	p = encode_cinfo(p, &open->op_cinfo);
 	*p++ = cpu_to_be32(open->op_rflags);
-	*p++ = cpu_to_be32(2);
-	*p++ = cpu_to_be32(open->op_bmval[0]);
-	*p++ = cpu_to_be32(open->op_bmval[1]);
-	*p++ = cpu_to_be32(open->op_delegate_type);
 
+	nfserr = nfsd4_encode_bitmap(xdr, open->op_bmval[0], open->op_bmval[1],
+					open->op_bmval[2]);
+	if (nfserr)
+		goto out;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
+
+	*p++ = cpu_to_be32(open->op_delegate_type);
 	switch (open->op_delegate_type) {
 	case NFS4_OPEN_DELEGATE_NONE:
 		break;
-- 
2.4.3

