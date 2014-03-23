Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47871 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141AbaCWBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 18/50] nfsd4: use xdr_stream throughout compound encoding
Date: Sat, 22 Mar 2014 21:11:49 -0400
Message-Id: <1395537141-10389-19-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  2 +-
 fs/nfsd/nfs4xdr.c  | 23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9e7cb05..e5cc711 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1242,7 +1242,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	svcxdr_init_encode(rqstp, resp);
 	resp->tagp = resp->xdr.p;
 	/* reserve space for: taglen, tag, and opcnt */
-	resp->xdr.p += 2 + XDR_QUADLEN(args->taglen);
+	xdr_reserve_space(&resp->xdr, 8 + args->taglen);
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6025713..d665c60 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1748,10 +1748,10 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
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
@@ -3040,8 +3040,11 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
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
 
@@ -3094,9 +3097,12 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
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
@@ -3196,8 +3202,9 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
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
1.8.5.3

