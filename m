Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47882 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbaCWBM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 22/50] nfsd4: use xdr_truncate_encode
Date: Sat, 22 Mar 2014 21:11:53 -0400
Message-Id: <1395537141-10389-23-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Now that lengths are reliable, we can use xdr_truncate instead of
open-coding it everywhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a3dce3c..e5cc354 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2043,7 +2043,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 	struct svc_fh *tempfh = NULL;
 	struct kstatfs statfs;
 	__be32 *p;
-	__be32 *start = xdr->p;
+	int starting_len = xdr->buf->len;
 	__be32 *attrlenp;
 	u32 dummy;
 	u64 dummy64;
@@ -2534,13 +2534,8 @@ out:
 	kfree(acl);
 	if (tempfh)
 		fh_put(tempfh);
-	if (status) {
-		int nbytes = (char *)xdr->p - (char *)start;
-		/* open code what *should* be xdr_truncate(xdr, len); */
-		xdr->iov->iov_len -= nbytes;
-		xdr->buf->len -= nbytes;
-		xdr->p = start;
-	}
+	if (status)
+		xdr_truncate_encode(xdr, starting_len);
 	return status;
 out_nfserr:
 	status = nfserrno(err);
@@ -3005,6 +3000,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct page *page;
 	unsigned long maxcount; 
 	struct xdr_stream *xdr = &resp->xdr;
+	int starting_len = xdr->buf->len;
 	long len;
 	__be32 *p;
 
@@ -3041,8 +3037,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 			&maxcount);
 
 	if (nfserr) {
-		xdr->p -= 2;
-		xdr->iov->iov_len -= 8;
+		xdr->buf->page_len = 0;
+		xdr_truncate_encode(xdr, starting_len);
 		return nfserr;
 	}
 	eof = (read->rd_offset + maxcount >=
@@ -3077,6 +3073,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	int maxcount;
 	struct xdr_stream *xdr = &resp->xdr;
 	char *page;
+	int length_offset = xdr->buf->len;
 	__be32 *p;
 
 	if (nfserr)
@@ -3101,8 +3098,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	if (nfserr == nfserr_isdir)
 		nfserr = nfserr_inval;
 	if (nfserr) {
-		xdr->p--;
-		xdr->iov->iov_len -= 4;
+		xdr_truncate_encode(xdr, length_offset);
 		return nfserr;
 	}
 
@@ -3133,7 +3129,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	int maxcount;
 	loff_t offset;
 	struct xdr_stream *xdr = &resp->xdr;
-	__be32 *page, *savep, *tailbase;
+	int starting_len = xdr->buf->len;
+	__be32 *page, *tailbase;
 	__be32 *p;
 
 	if (nfserr)
@@ -3144,7 +3141,6 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		return nfserr_resource;
 
 	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
-	savep = p;
 
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
@@ -3206,9 +3202,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	return 0;
 err_no_verf:
-	xdr->p = savep;
-	xdr->iov->iov_len = ((char *)resp->xdr.p)
-				- (char *)resp->xdr.buf->head[0].iov_base;
+	xdr_truncate_encode(xdr, starting_len);
 	return nfserr;
 }
 
-- 
1.8.5.3

