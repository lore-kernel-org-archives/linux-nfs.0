Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522AbcCUOm1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 10:42:27 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: use short read rather than i_size to set eof
Date: Mon, 21 Mar 2016 10:42:25 -0400
Message-Id: <82e4c7a9756b21a4645421d04735ccf491b4296a.1458571329.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the result of a local read to determine when to set the eof flag.  This
allows us to return the location of the end of the file atomically at the
time of the read.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfsd/nfs3proc.c |   10 ++++------
 fs/nfsd/nfs4xdr.c  |    9 +++++----
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 7b755b7..6be6092 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -147,6 +147,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 {
 	__be32	nfserr;
 	u32	max_blocksize = svc_max_payload(rqstp);
+	unsigned long cnt = min(argp->count, max_blocksize);
 
 	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",
 				SVCFH_fmt(&argp->fh),
@@ -157,7 +158,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
 	 * + 1 (xdr opaque byte count) = 26
 	 */
-	resp->count = min(argp->count, max_blocksize);
+	resp->count = cnt;
 	svc_reserve_auth(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3)<<2) + resp->count +4);
 
 	fh_copy(&resp->fh, &argp->fh);
@@ -165,11 +166,8 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 				  argp->offset,
 			   	  rqstp->rq_vec, argp->vlen,
 				  &resp->count);
-	if (nfserr == 0) {
-		struct inode	*inode = d_inode(resp->fh.fh_dentry);
-
-		resp->eof = (argp->offset + resp->count) >= inode->i_size;
-	}
+	if (nfserr == 0)
+		resp->eof = cnt > resp->count;
 
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d6ef095..2e14839 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3362,6 +3362,7 @@ static __be32 nfsd4_encode_splice_read(
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
 	u32 eof;
+	long len;
 	int space_left;
 	__be32 nfserr;
 	__be32 *p = xdr->p - 2;
@@ -3370,6 +3371,7 @@ static __be32 nfsd4_encode_splice_read(
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
+	len = maxcount;
 	nfserr = nfsd_splice_read(read->rd_rqstp, file,
 				  read->rd_offset, &maxcount);
 	if (nfserr) {
@@ -3382,8 +3384,7 @@ static __be32 nfsd4_encode_splice_read(
 		return nfserr;
 	}
 
-	eof = (read->rd_offset + maxcount >=
-	       d_inode(read->rd_fhp->fh_dentry)->i_size);
+	eof = len > maxcount;
 
 	*(p++) = htonl(eof);
 	*(p++) = htonl(maxcount);
@@ -3453,14 +3454,14 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	}
 	read->rd_vlen = v;
 
+	len = maxcount;
 	nfserr = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
 			read->rd_vlen, &maxcount);
 	if (nfserr)
 		return nfserr;
 	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
 
-	eof = (read->rd_offset + maxcount >=
-	       d_inode(read->rd_fhp->fh_dentry)->i_size);
+	eof = len > maxcount;
 
 	tmp = htonl(eof);
 	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
-- 
1.7.1

