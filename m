Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42520 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356AbbFROrL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 10:47:11 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] nfsd: wrap too long lines in nfsd4_encode_read
Date: Thu, 18 Jun 2015 16:45:02 +0200
Message-Id: <1434638702-353-6-git-send-email-hch@lst.de>
In-Reply-To: <1434638702-353-1-git-send-email-hch@lst.de>
References: <1434638702-353-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4xdr.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9388a5f..8ca800c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3431,7 +3431,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		nfserr = nfserr_resource;
 		goto out;
 	}
-	if (resp->xdr.buf->page_len && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags)) {
+	if (resp->xdr.buf->page_len &&
+	    test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags)) {
 		WARN_ON_ONCE(1);
 		nfserr = nfserr_resource;
 		goto out;
@@ -3439,13 +3440,15 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	xdr_commit_encode(xdr);
 
 	maxcount = svc_max_payload(resp->rqstp);
-	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
+	maxcount = min_t(unsigned long, maxcount,
+			 (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
 
 	if (read->rd_tmp_file)
 		ra = nfsd_init_raparms(file);
 
-	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
+	if (file->f_op->splice_read &&
+	    test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, file, maxcount);
-- 
1.9.1

