Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43495 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbaEVTcq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 44/52] nfsd4: read encoding cleanup
Date: Thu, 22 May 2014 15:32:19 -0400
Message-Id: <1400787148-25941-45-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Trivial cleanup, no change in functionality.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index bf853fd..b8be187 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3075,6 +3075,7 @@ static __be32 nfsd4_encode_splice_read(
 				struct file *file, unsigned long maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
+	struct xdr_buf *buf = xdr->buf;
 	u32 eof;
 	int starting_len = xdr->buf->len - 8;
 	int space_left;
@@ -3097,7 +3098,7 @@ static __be32 nfsd4_encode_splice_read(
 		 * page length; reset it so as not to confuse
 		 * xdr_truncate_encode:
 		 */
-		xdr->buf->page_len = 0;
+		buf->page_len = 0;
 		return nfserr;
 	}
 
@@ -3105,29 +3106,29 @@ static __be32 nfsd4_encode_splice_read(
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
 
 	tmp = htonl(eof);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
+	write_bytes_to_xdr_buf(buf, starting_len    , &tmp, 4);
 	tmp = htonl(maxcount);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
+	write_bytes_to_xdr_buf(buf, starting_len + 4, &tmp, 4);
 
-	resp->xdr.buf->page_len = maxcount;
-	xdr->buf->len += maxcount;
+	buf->page_len = maxcount;
+	buf->len += maxcount;
 	xdr->page_ptr += (maxcount + PAGE_SIZE - 1) / PAGE_SIZE;
-	xdr->iov = xdr->buf->tail;
+	xdr->iov = buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
-	resp->xdr.buf->tail[0].iov_base = xdr->p;
-	resp->xdr.buf->tail[0].iov_len = 0;
+	buf->tail[0].iov_base = xdr->p;
+	buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		p = xdr_reserve_space(xdr, 4);
 		WRITE32(0);
-		resp->xdr.buf->tail[0].iov_base += maxcount&3;
-		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		xdr->buf->len -= (maxcount&3);
+		buf->tail[0].iov_base += maxcount&3;
+		buf->tail[0].iov_len = 4 - (maxcount&3);
+		buf->len -= (maxcount&3);
 	}
 
 	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
-				xdr->buf->buflen - xdr->buf->len);
-	xdr->buf->buflen = xdr->buf->len + space_left;
+				buf->buflen - buf->len);
+	buf->buflen = buf->len + space_left;
 	xdr->end = (__be32 *)((void *)xdr->end + space_left);
 
 	return 0;
-- 
1.9.0

