Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757196AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/43] nfsd4: keep xdr buf length updated
Date: Sun, 11 May 2014 16:52:17 -0400
Message-Id: <1399841568-19716-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 ++
 fs/nfsd/nfs4xdr.c  |   12 ++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7c45172..ad0bc5f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1211,6 +1211,8 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 	xdr->iov = head;
 	xdr->p   = head->iov_base + head->iov_len;
 	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
+	/* Tail and page_len should be zero at this point: */
+	buf->len = buf->head[0].iov_len;
 }
 
 /*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 38a78a5..2f16a80 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3038,9 +3038,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	WRITE32(eof);
 	WRITE32(maxcount);
-	resp->xdr.buf->head[0].iov_len = (char*)p
-				- (char*)resp->xdr.buf->head[0].iov_base;
+	WARN_ON_ONCE(resp->xdr.buf->head[0].iov_len != (char *)p
+				- (char *)resp->xdr.buf->head[0].iov_base);
 	resp->xdr.buf->page_len = maxcount;
+	xdr->buf->len += maxcount;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3051,6 +3052,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
+		xdr->buf->len -= (maxcount&3);
 	}
 	return 0;
 }
@@ -3094,6 +3096,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
+	xdr->buf->len += maxcount;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3174,6 +3177,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	*p++ = htonl(readdir->common.err == nfserr_eof);
 	resp->xdr.buf->page_len = ((char*)p) -
 		(char*)page_address(*(resp->rqstp->rq_next_page-1));
+	xdr->buf->len += xdr->buf->page_len;
 
 	xdr->iov = xdr->buf->tail;
 
@@ -3777,6 +3781,10 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	 * All that remains is to write the tag and operation count...
 	 */
 	struct nfsd4_compound_state *cs = &resp->cstate;
+	struct xdr_buf *buf = resp->xdr.buf;
+
+	WARN_ON_ONCE(buf->len != buf->head[0].iov_len + buf->page_len +
+				 buf->tail[0].iov_len);
 
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
-- 
1.7.9.5

