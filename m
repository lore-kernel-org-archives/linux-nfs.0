Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbaEVTch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 22/52] nfsd4: reserve space before inlining 0-copy pages
Date: Thu, 22 May 2014 15:31:57 -0400
Message-Id: <1400787148-25941-23-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
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
 fs/nfsd/nfs4xdr.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9c532eb..9fb1b1a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3071,6 +3071,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (!p)
 		return nfserr_resource;
 
+	/* Make sure there will be room for padding if needed: */
+	if (xdr->end - xdr->p < 1)
+		return nfserr_resource;
+
 	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
@@ -3122,8 +3126,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		p = xdr_reserve_space(xdr, 4);
-		if (!p)
-			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
@@ -3156,6 +3158,9 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	if (!p)
 		return nfserr_resource;
 
+	if (xdr->end - xdr->p < 1)
+		return nfserr_resource;
+
 	/*
 	 * XXX: By default, the ->readlink() VFS op will truncate symlinks
 	 * if they would overflow the buffer.  Is this kosher in NFSv4?  If
@@ -3182,8 +3187,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		p = xdr_reserve_space(xdr, 4);
-		if  (!p)
-			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-- 
1.9.0

