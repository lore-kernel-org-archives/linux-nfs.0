Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbaEVTcr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 46/52] nfsd4: allow exotic read compounds
Date: Thu, 22 May 2014 15:32:21 -0400
Message-Id: <1400787148-25941-47-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I'm not sure why a client would want to stuff multiple reads in a
single compound rpc, but it's legal for them to do it, and we should
really support it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/nfs/nfs41-server.txt |  2 -
 fs/nfsd/nfs4xdr.c                              | 55 +++++++++++---------------
 2 files changed, 23 insertions(+), 34 deletions(-)

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
index fec9e13..f3eb7fa 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3139,28 +3139,34 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	struct xdr_stream *xdr = &resp->xdr;
 	u32 eof;
 	int v;
-	struct page *page;
 	int starting_len = xdr->buf->len - 8;
-	int space_left;
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
@@ -3170,6 +3176,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 			read->rd_vlen, &maxcount);
 	if (nfserr)
 		return nfserr;
+	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
 
 	eof = (read->rd_offset + maxcount >=
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
@@ -3179,27 +3186,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	tmp = htonl(maxcount);
 	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
 
-	resp->xdr.buf->page_len = maxcount;
-	xdr->buf->len += maxcount;
-	xdr->page_ptr += v;
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
-
-	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
-				xdr->buf->buflen - xdr->buf->len);
-	xdr->buf->buflen = xdr->buf->len + space_left;
-	xdr->end = (__be32 *)((void *)xdr->end + space_left);
-
+	pad = (maxcount&3) ? 4 - (maxcount&3) : 0;
+	write_bytes_to_xdr_buf(xdr->buf, starting_len + 8 + maxcount,
+								&zzz, pad);
 	return 0;
 
 }
@@ -3233,6 +3222,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	xdr_commit_encode(xdr);
 
 	maxcount = svc_max_payload(resp->rqstp);
+	if (maxcount > xdr->buf->buflen - xdr->buf->len)
+		maxcount = xdr->buf->buflen - xdr->buf->len;
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
 
-- 
1.9.0

