Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47143 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbaLQWfQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:16 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] NFSD: nfsd4_encode_read() should encode eof and maxcount
Date: Wed, 17 Dec 2014 17:35:01 -0500
Message-ID: <1418855704-14127-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I intend to reuse nfsd4_encode_readv() for READ_PLUS, so I need an
alternate way to encode these values.  I think it makes sense for
nfsd4_encode_read() to handle this in a single place for both READ
paths.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4xdr.c | 59 ++++++++++++++++++++++---------------------------------
 1 file changed, 23 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0622d4f..1943cdb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3119,21 +3119,19 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 static __be32 nfsd4_encode_splice_read(
 				struct nfsd4_compoundres *resp,
 				struct nfsd4_read *read,
-				struct file *file, unsigned long maxcount)
+				struct file *file, unsigned long *maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
-	u32 eof;
 	int space_left;
 	__be32 nfserr;
-	__be32 *p = xdr->p - 2;
 
 	/* Make sure there will be room for padding if needed */
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
 	nfserr = nfsd_splice_read(read->rd_rqstp, file,
-				  read->rd_offset, &maxcount);
+				  read->rd_offset, maxcount);
 	if (nfserr) {
 		/*
 		 * nfsd_splice_actor may have already messed with the
@@ -3144,27 +3142,21 @@ static __be32 nfsd4_encode_splice_read(
 		return nfserr;
 	}
 
-	eof = (read->rd_offset + maxcount >=
-	       read->rd_fhp->fh_dentry->d_inode->i_size);
-
-	*(p++) = htonl(eof);
-	*(p++) = htonl(maxcount);
-
-	buf->page_len = maxcount;
-	buf->len += maxcount;
-	xdr->page_ptr += (buf->page_base + maxcount + PAGE_SIZE - 1)
+	buf->page_len = *maxcount;
+	buf->len += *maxcount;
+	xdr->page_ptr += (buf->page_base + *maxcount + PAGE_SIZE - 1)
 							/ PAGE_SIZE;
 
 	/* Use rest of head for padding and remaining ops: */
 	buf->tail[0].iov_base = xdr->p;
 	buf->tail[0].iov_len = 0;
 	xdr->iov = buf->tail;
-	if (maxcount&3) {
-		int pad = 4 - (maxcount&3);
+	if (*maxcount&3) {
+		int pad = 4 - (*maxcount&3);
 
 		*(xdr->p++) = 0;
 
-		buf->tail[0].iov_base += maxcount&3;
+		buf->tail[0].iov_base += *maxcount&3;
 		buf->tail[0].iov_len = pad;
 		buf->len += pad;
 	}
@@ -3179,21 +3171,19 @@ static __be32 nfsd4_encode_splice_read(
 
 static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 struct nfsd4_read *read,
-				 struct file *file, unsigned long maxcount)
+				 struct file *file, unsigned long *maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
-	u32 eof;
 	int v;
-	int starting_len = xdr->buf->len - 8;
+	int starting_len = xdr->buf->len;
 	long len;
 	int thislen;
 	__be32 nfserr;
-	__be32 tmp;
 	__be32 *p;
 	u32 zzz = 0;
 	int pad;
 
-	len = maxcount;
+	len = *maxcount;
 	v = 0;
 
 	thislen = min_t(long, len, ((void *)xdr->end - (void *)xdr->p));
@@ -3216,22 +3206,13 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	read->rd_vlen = v;
 
 	nfserr = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
-			read->rd_vlen, &maxcount);
+			read->rd_vlen, maxcount);
 	if (nfserr)
 		return nfserr;
-	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
+	xdr_truncate_encode(xdr, starting_len + ((*maxcount+3)&~3));
 
-	eof = (read->rd_offset + maxcount >=
-	       read->rd_fhp->fh_dentry->d_inode->i_size);
-
-	tmp = htonl(eof);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
-	tmp = htonl(maxcount);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
-
-	pad = (maxcount&3) ? 4 - (maxcount&3) : 0;
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 8 + maxcount,
-								&zzz, pad);
+	pad = (*maxcount&3) ? 4 - (*maxcount&3) : 0;
+	write_bytes_to_xdr_buf(xdr->buf, starting_len + *maxcount, &zzz, pad);
 	return 0;
 
 }
@@ -3247,6 +3228,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct raparms *ra;
 	__be32 *p;
 	__be32 err;
+	u32 eof;
 
 	if (nfserr)
 		return nfserr;
@@ -3274,9 +3256,14 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	}
 
 	if (file->f_op->splice_read && resp->rqstp->rq_splice_ok)
-		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
+		err = nfsd4_encode_splice_read(resp, read, file, &maxcount);
 	else
-		err = nfsd4_encode_readv(resp, read, file, maxcount);
+		err = nfsd4_encode_readv(resp, read, file, &maxcount);
+
+	eof = (read->rd_offset + maxcount >=
+	       read->rd_fhp->fh_dentry->d_inode->i_size);
+	*p++ = cpu_to_be32(eof);
+	*p++ = cpu_to_be32(maxcount);
 
 	if (!read->rd_filp)
 		nfsd_put_tmp_read_open(file, ra);
-- 
2.1.3

