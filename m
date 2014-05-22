Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43439 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaEVTcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 32/52] nfsd4: fix buflen calculation after read encoding
Date: Thu, 22 May 2014 15:32:07 -0400
Message-Id: <1400787148-25941-33-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We don't necessarily want to assume that the buflen is the same
as the number of bytes available in the pages.  We may have some reason
to set it to something less (for example, later patches will use a
smaller buflen to enforce session limits).

So, calculate the buflen relative to the previous buflen instead of
recalculating it from scratch.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 91d0b9a..ad594f2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3053,6 +3053,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	unsigned long maxcount; 
 	struct xdr_stream *xdr = &resp->xdr;
 	int starting_len = xdr->buf->len;
+	int space_left;
 	long len;
 	__be32 *p;
 
@@ -3117,7 +3118,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	resp->xdr.buf->page_len = maxcount;
 	xdr->buf->len += maxcount;
 	xdr->page_ptr += v;
-	xdr->buf->buflen = maxcount + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3130,6 +3130,12 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
 		xdr->buf->len -= (maxcount&3);
 	}
+
+	space_left = min_t(int, (void *)xdr->end - (void *)xdr->p,
+				xdr->buf->buflen - xdr->buf->len);
+	xdr->buf->buflen = xdr->buf->len + space_left;
+	xdr->end = (__be32 *)((void *)xdr->end + space_left);
+
 	return 0;
 }
 
-- 
1.9.0

