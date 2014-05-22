Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43501 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbaEVTcr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 45/52] nfsd4: more read encoding cleanup
Date: Thu, 22 May 2014 15:32:20 -0400
Message-Id: <1400787148-25941-46-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

More cleanup, no change in functionality.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b8be187..fec9e13 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3077,11 +3077,9 @@ static __be32 nfsd4_encode_splice_read(
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
 	u32 eof;
-	int starting_len = xdr->buf->len - 8;
 	int space_left;
 	__be32 nfserr;
-	__be32 tmp;
-	__be32 *p;
+	__be32 *p = xdr->p - 2;
 
 	/*
 	 * Don't inline pages unless we know there's room for eof,
@@ -3105,25 +3103,25 @@ static __be32 nfsd4_encode_splice_read(
 	eof = (read->rd_offset + maxcount >=
 	       read->rd_fhp->fh_dentry->d_inode->i_size);
 
-	tmp = htonl(eof);
-	write_bytes_to_xdr_buf(buf, starting_len    , &tmp, 4);
-	tmp = htonl(maxcount);
-	write_bytes_to_xdr_buf(buf, starting_len + 4, &tmp, 4);
+	*(p++) = htonl(eof);
+	*(p++) = htonl(maxcount);
 
 	buf->page_len = maxcount;
 	buf->len += maxcount;
 	xdr->page_ptr += (maxcount + PAGE_SIZE - 1) / PAGE_SIZE;
-	xdr->iov = buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
 	buf->tail[0].iov_base = xdr->p;
 	buf->tail[0].iov_len = 0;
+	xdr->iov = buf->tail;
 	if (maxcount&3) {
-		p = xdr_reserve_space(xdr, 4);
-		WRITE32(0);
+		int pad = 4 - (maxcount&3);
+
+		*(xdr->p++) = 0;
+
 		buf->tail[0].iov_base += maxcount&3;
-		buf->tail[0].iov_len = 4 - (maxcount&3);
-		buf->len -= (maxcount&3);
+		buf->tail[0].iov_len = pad;
+		buf->len += pad;
 	}
 
 	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
-- 
1.9.0

