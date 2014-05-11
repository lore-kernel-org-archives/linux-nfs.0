Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757196AbaEKUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 17/43] nfsd4: reserve space before inlining 0-copy pages
Date: Sun, 11 May 2014 16:52:22 -0400
Message-Id: <1399841568-19716-18-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we've included page-cache pages in the encoding it's difficult to
remove them and restart encoding.  (xdr_truncate_encode doesn't handle
that case.)  So, make sure we'll have adequate space to finish the
operation first.

For now COMPOUND_SLACK_SPACE checks should prevent this case happening,
but we want to remove those checks.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d0e59b9..846d241 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3056,6 +3056,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (!p)
 		return nfserr_resource;
 
+	/* Make sure there will be room for padding if needed: */
+	if (xdr->end - xdr->p < 1)
+		return nfserr_resource;
+
 	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
@@ -3107,8 +3111,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		p = xdr_reserve_space(xdr, 4);
-		if (!p)
-			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
@@ -3141,6 +3143,9 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	if (!p)
 		return nfserr_resource;
 
+	if (xdr->end - xdr->p < 1)
+		return nfserr_resource;
+
 	/*
 	 * XXX: By default, the ->readlink() VFS op will truncate symlinks
 	 * if they would overflow the buffer.  Is this kosher in NFSv4?  If
@@ -3167,8 +3172,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		p = xdr_reserve_space(xdr, 4);
-		if  (!p)
-			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-- 
1.7.9.5

