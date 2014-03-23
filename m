Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbaCWBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 20/50] nfsd4: keep xdr buf length updated
Date: Sat, 22 Mar 2014 21:11:51 -0400
Message-Id: <1395537141-10389-21-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  2 ++
 fs/nfsd/nfs4xdr.c  | 12 ++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e5cc711..8360def 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1222,6 +1222,8 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 	xdr->iov = head;
 	xdr->p   = head->iov_base + head->iov_len;
 	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
+	/* Tail and page_len should be zero at this point: */
+	buf->len = buf->head[0].iov_len;
 }
 
 /*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fae7d02..a3dce3c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3051,9 +3051,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(eof);
 	WRITE32(maxcount);
 	ADJUST_ARGS();
-	resp->xdr.buf->head[0].iov_len = (char*)p
-				- (char*)resp->xdr.buf->head[0].iov_base;
+	WARN_ON_ONCE(resp->xdr.buf->head[0].iov_len != (char*)p
+				- (char*)resp->xdr.buf->head[0].iov_base);
 	resp->xdr.buf->page_len = maxcount;
+	xdr->buf->len += maxcount;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3064,6 +3065,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
+		xdr->buf->len -= (maxcount&3);
 		ADJUST_ARGS();
 	}
 	return 0;
@@ -3109,6 +3111,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
+	xdr->buf->len += maxcount;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3191,6 +3194,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	*p++ = htonl(readdir->common.err == nfserr_eof);
 	resp->xdr.buf->page_len = ((char*)p) -
 		(char*)page_address(*(resp->rqstp->rq_next_page-1));
+	xdr->buf->len += xdr->buf->page_len;
 
 	xdr->iov = xdr->buf->tail;
 
@@ -3818,6 +3822,10 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
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
1.8.5.3

