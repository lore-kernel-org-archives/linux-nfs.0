Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47930 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbaCWBMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 46/50] nfsd4: allow exotic read compounds
Date: Sat, 22 Mar 2014 21:12:17 -0400
Message-Id: <1395537141-10389-47-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

---
 Documentation/filesystems/nfs/nfs41-server.txt |   2 -
 fs/nfsd/nfs4xdr.c                              | 100 +++++++++++++------------
 2 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
index b930ad0..c49cd7e 100644
--- a/Documentation/filesystems/nfs/nfs41-server.txt
+++ b/Documentation/filesystems/nfs/nfs41-server.txt
@@ -176,7 +176,5 @@ Nonstandard compound limitations:
   ca_maxrequestsize request and a ca_maxresponsesize reply, so we may
   fail to live up to the promise we made in CREATE_SESSION fore channel
   negotiation.
-* No more than one read-like operation allowed per compound; encoding
-  replies that cross page boundaries (except for read data) not handled.
 
 See also http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues.
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e052351..d92dd1b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3074,11 +3074,11 @@ static __be32 nfsd4_encode_splice_read(
 				struct file *file, unsigned long maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
+	struct xdr_buf *buf = xdr->buf;
 	u32 eof;
-	int starting_len = xdr->buf->len - 8;
+	int space_left;
 	__be32 nfserr;
-	__be32 tmp;
-	__be32 *p;
+	__be32 *p = xdr->p - 2;
 
 	/*
 	 * Don't inline pages unless we know there's room for eof,
@@ -3090,34 +3090,38 @@ static __be32 nfsd4_encode_splice_read(
 	nfserr = nfsd_splice_read(read->rd_rqstp, file,
 				  read->rd_offset, &maxcount);
 	if (nfserr) {
-		xdr->buf->page_len = 0;
+		buf->page_len = 0;
 		return nfserr;
 	}
 
 	eof = (read->rd_offset + maxcount >=
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
 
-	tmp = htonl(eof);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
-	tmp = htonl(maxcount);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
+	*(p++) = htonl(eof);
+	*(p++) = htonl(maxcount);
 
-	resp->xdr.buf->page_len = maxcount;
-	xdr->buf->len += maxcount;
-	xdr->page_ptr += (maxcount + PAGE_SIZE - 1) / PAGE_SIZE;
-	xdr->buf->buflen = maxcount + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
-	xdr->iov = xdr->buf->tail;
+	buf->page_len = maxcount;
+	buf->len += maxcount;
 
 	/* Use rest of head for padding and remaining ops: */
-	resp->xdr.buf->tail[0].iov_base = xdr->p;
-	resp->xdr.buf->tail[0].iov_len = 0;
+	buf->tail[0].iov_base = xdr->p;
+	buf->tail[0].iov_len = 0;
+	xdr->iov = xdr->buf->tail;
 	if (maxcount&3) {
-		p = xdr_reserve_space(xdr, 4);
-		WRITE32(0);
-		resp->xdr.buf->tail[0].iov_base += maxcount&3;
-		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		xdr->buf->len -= (maxcount&3);
+		int pad = 4 - (maxcount&3);
+
+		*(xdr->p++) = 0;
+
+		buf->tail[0].iov_base += maxcount&3;
+		buf->tail[0].iov_len = pad;
+		buf->len += pad;
 	}
+
+	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
+				buf->buflen - buf->len);
+	buf->buflen = buf->len + space_left;
+	xdr->end = (__be32 *)((void *)xdr->end + space_left);
+
 	return 0;
 }
 
@@ -3128,27 +3132,34 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	struct xdr_stream *xdr = &resp->xdr;
 	u32 eof;
 	int v;
-	struct page *page;
 	int starting_len = xdr->buf->len - 8;
 	long len;
+	int thislen;
 	__be32 nfserr;
 	__be32 tmp;
 	__be32 *p;
+	u32 zzz = 0;
+	int pad;
 
 	len = maxcount;
 	v = 0;
-	while (len) {
-		int thislen;
 
-		page = *(resp->rqstp->rq_next_page);
-		if (!page) { /* ran out of pages */
-			maxcount -= len;
-			break;
-		}
+	thislen = (void *)xdr->end - (void *)xdr->p;
+	if (len < thislen)
+		thislen = len;
+	p = xdr_reserve_space(xdr, (thislen+3)&~3);
+	WARN_ON_ONCE(!p);
+	resp->rqstp->rq_vec[v].iov_base = p;
+	resp->rqstp->rq_vec[v].iov_len = thislen;
+	v++;
+	len -= thislen;
+
+	while (len) {
 		thislen = min_t(long, len, PAGE_SIZE);
-		resp->rqstp->rq_vec[v].iov_base = page_address(page);
+		p = xdr_reserve_space(xdr, (thislen+3)&~3);
+		WARN_ON_ONCE(!p);
+		resp->rqstp->rq_vec[v].iov_base = p;
 		resp->rqstp->rq_vec[v].iov_len = thislen;
-		resp->rqstp->rq_next_page++;
 		v++;
 		len -= thislen;
 	}
@@ -3158,6 +3169,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 			read->rd_vlen, &maxcount);
 	if (nfserr)
 		return nfserr;
+	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
 
 	eof = (read->rd_offset + maxcount >=
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
@@ -3167,22 +3179,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	tmp = htonl(maxcount);
 	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
 
-	resp->xdr.buf->page_len = maxcount;
-	xdr->buf->len += maxcount;
-	xdr->page_ptr += v;
-	xdr->buf->buflen = maxcount + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
-	xdr->iov = xdr->buf->tail;
-
-	/* Use rest of head for padding and remaining ops: */
-	resp->xdr.buf->tail[0].iov_base = xdr->p;
-	resp->xdr.buf->tail[0].iov_len = 0;
-	if (maxcount&3) {
-		p = xdr_reserve_space(xdr, 4);
-		WRITE32(0);
-		resp->xdr.buf->tail[0].iov_base += maxcount&3;
-		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		xdr->buf->len -= (maxcount&3);
-	}
+	pad = (maxcount&3) ? 4 - (maxcount&3) : 0;
+	write_bytes_to_xdr_buf(xdr->buf, starting_len + 8 + maxcount,
+								&zzz, pad);
 	return 0;
 
 }
@@ -3204,16 +3203,19 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p) {
-		WARN_ON_ONCE(1);
+		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
 		return nfserr_resource;
 	}
 
-	if (resp->xdr.buf->page_len)
+	if (resp->rqstp->rq_splice_ok && resp->xdr.buf->page_len) {
+		WARN_ON_ONCE(1);
 		return nfserr_resource;
-
+	}
 	xdr_commit_encode(xdr);
 
 	maxcount = svc_max_payload(resp->rqstp);
+	if (maxcount > xdr->buf->buflen - xdr->buf->len)
+		maxcount = xdr->buf->buflen - xdr->buf->len;
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
 
-- 
1.8.5.3

