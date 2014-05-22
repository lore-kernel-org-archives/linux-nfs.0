Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43532 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849AbaEVTcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 51/52] nfsd4: kill write32, write64
Date: Thu, 22 May 2014 15:32:26 -0400
Message-Id: <1400787148-25941-52-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

And switch a couple other functions from the encode(&p,...) convention
to the p = encode(p,...) convention mostly used elsewhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 51 +++++++++++++++++++++------------------------------
 1 file changed, 21 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2a5bd29..6813870 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1683,39 +1683,30 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_TAIL;
 }
 
-static void write32(__be32 **p, u32 n)
-{
-	*(*p)++ = htonl(n);
-}
-
-static void write64(__be32 **p, u64 n)
-{
-	write32(p, (n >> 32));
-	write32(p, (u32)n);
-}
-
-static void write_change(__be32 **p, struct kstat *stat, struct inode *inode)
+static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *inode)
 {
 	if (IS_I_VERSION(inode)) {
-		write64(p, inode->i_version);
+		p = xdr_encode_hyper(p, inode->i_version);
 	} else {
-		write32(p, stat->ctime.tv_sec);
-		write32(p, stat->ctime.tv_nsec);
+		*p++ = cpu_to_be32(stat->ctime.tv_sec);
+		*p++ = cpu_to_be32(stat->ctime.tv_nsec);
 	}
+	return p;
 }
 
-static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
+static __be32 *encode_cinfo(__be32 *p, struct nfsd4_change_info *c)
 {
-	write32(p, c->atomic);
+	*p++ = cpu_to_be32(c->atomic);
 	if (c->change_supported) {
-		write64(p, c->before_change);
-		write64(p, c->after_change);
+		p = xdr_encode_hyper(p, c->before_change);
+		p = xdr_encode_hyper(p, c->after_change);
 	} else {
-		write32(p, c->before_ctime_sec);
-		write32(p, c->before_ctime_nsec);
-		write32(p, c->after_ctime_sec);
-		write32(p, c->after_ctime_nsec);
+		*p++ = cpu_to_be32(c->before_ctime_sec);
+		*p++ = cpu_to_be32(c->before_ctime_nsec);
+		*p++ = cpu_to_be32(c->after_ctime_sec);
+		*p++ = cpu_to_be32(c->after_ctime_nsec);
 	}
+	return p;
 }
 
 /* Encode as an array of strings the string given with components
@@ -2186,7 +2177,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		write_change(&p, &stat, dentry->d_inode);
+		p = encode_change(p, &stat, dentry->d_inode);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2817,7 +2808,7 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 32);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &create->cr_cinfo);
+		p = encode_cinfo(p, &create->cr_cinfo);
 		*p++ = cpu_to_be32(2);
 		*p++ = cpu_to_be32(create->cr_bmval[0]);
 		*p++ = cpu_to_be32(create->cr_bmval[1]);
@@ -2940,7 +2931,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &link->li_cinfo);
+		p = encode_cinfo(p, &link->li_cinfo);
 	}
 	return nfserr;
 }
@@ -2961,7 +2952,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	p = xdr_reserve_space(xdr, 40);
 	if (!p)
 		return nfserr_resource;
-	write_cinfo(&p, &open->op_cinfo);
+	p = encode_cinfo(p, &open->op_cinfo);
 	*p++ = cpu_to_be32(open->op_rflags);
 	*p++ = cpu_to_be32(2);
 	*p++ = cpu_to_be32(open->op_bmval[0]);
@@ -3383,7 +3374,7 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &remove->rm_cinfo);
+		p = encode_cinfo(p, &remove->rm_cinfo);
 	}
 	return nfserr;
 }
@@ -3398,8 +3389,8 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 40);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &rename->rn_sinfo);
-		write_cinfo(&p, &rename->rn_tinfo);
+		p = encode_cinfo(p, &rename->rn_sinfo);
+		p = encode_cinfo(p, &rename->rn_tinfo);
 	}
 	return nfserr;
 }
-- 
1.9.0

