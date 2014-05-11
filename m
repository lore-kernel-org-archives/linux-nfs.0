Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38659 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757859AbaEKUxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 43/43] nfsd4: kill write32, write64
Date: Sun, 11 May 2014 16:52:48 -0400
Message-Id: <1399841568-19716-44-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

And switch a couple other functions from the encode(&p,...) convention
to the p = encode(p,...) convention mostly used elsewhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   51 +++++++++++++++++++++------------------------------
 1 file changed, 21 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f875bda..2956e66 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1699,39 +1699,30 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
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
@@ -2189,7 +2180,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		write_change(&p, &stat, dentry->d_inode);
+		p = encode_change(p, &stat, dentry->d_inode);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2815,7 +2806,7 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 32);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &create->cr_cinfo);
+		p = encode_cinfo(p, &create->cr_cinfo);
 		*p++ = cpu_to_be32(2);
 		*p++ = cpu_to_be32(create->cr_bmval[0]);
 		*p++ = cpu_to_be32(create->cr_bmval[1]);
@@ -2938,7 +2929,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &link->li_cinfo);
+		p = encode_cinfo(p, &link->li_cinfo);
 	}
 	return nfserr;
 }
@@ -2959,7 +2950,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	p = xdr_reserve_space(xdr, 40);
 	if (!p)
 		return nfserr_resource;
-	write_cinfo(&p, &open->op_cinfo);
+	p = encode_cinfo(p, &open->op_cinfo);
 	*p++ = cpu_to_be32(open->op_rflags);
 	*p++ = cpu_to_be32(2);
 	*p++ = cpu_to_be32(open->op_bmval[0]);
@@ -3378,7 +3369,7 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		write_cinfo(&p, &remove->rm_cinfo);
+		p = encode_cinfo(p, &remove->rm_cinfo);
 	}
 	return nfserr;
 }
@@ -3393,8 +3384,8 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
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
1.7.9.5

