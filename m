Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaEVTcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/52] nfsd4: use xdr_stream throughout compound encoding
Date: Thu, 22 May 2014 15:31:49 -0400
Message-Id: <1400787148-25941-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note this makes ADJUST_ARGS useless; we'll remove it in the following
patch.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  2 +-
 fs/nfsd/nfs4xdr.c  | 23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1433854..969a7b3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1286,7 +1286,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	svcxdr_init_encode(rqstp, resp);
 	resp->tagp = resp->xdr.p;
 	/* reserve space for: taglen, tag, and opcnt */
-	resp->xdr.p += 2 + XDR_QUADLEN(args->taglen);
+	xdr_reserve_space(&resp->xdr, 8 + args->taglen);
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0ab7aae..bc8c9e0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1747,10 +1747,10 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 }
 
 #define RESERVE_SPACE(nbytes)	do {				\
-	p = resp->xdr.p;						\
-	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->xdr.end);		\
+	p = xdr_reserve_space(&resp->xdr, nbytes);		\
+	BUG_ON(!p);						\
 } while (0)
-#define ADJUST_ARGS()		resp->xdr.p = p
+#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\
 
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
@@ -3056,8 +3056,11 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
 			&maxcount);
 
-	if (nfserr)
+	if (nfserr) {
+		xdr->p -= 2;
+		xdr->iov->iov_len -= 8;
 		return nfserr;
+	}
 	eof = (read->rd_offset + maxcount >=
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
 
@@ -3110,9 +3113,12 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	 */
 	nfserr = nfsd_readlink(readlink->rl_rqstp, readlink->rl_fhp, page, &maxcount);
 	if (nfserr == nfserr_isdir)
-		return nfserr_inval;
-	if (nfserr)
+		nfserr = nfserr_inval;
+	if (nfserr) {
+		xdr->p--;
+		xdr->iov->iov_len -= 4;
 		return nfserr;
+	}
 
 	WRITE32(maxcount);
 	ADJUST_ARGS();
@@ -3213,8 +3219,9 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	return 0;
 err_no_verf:
-	p = savep;
-	ADJUST_ARGS();
+	xdr->p = savep;
+	xdr->iov->iov_len = ((char *)resp->xdr.p)
+				- (char *)resp->xdr.buf->head[0].iov_base;
 	return nfserr;
 }
 
-- 
1.9.0

