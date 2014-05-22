Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43427 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbaEVTcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 30/52] nfsd4: minor encode_read cleanup
Date: Thu, 22 May 2014 15:32:05 -0400
Message-Id: <1400787148-25941-31-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4877abb..741aab2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3076,18 +3076,20 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	len = maxcount;
 	v = 0;
-	while (len > 0) {
+	while (len) {
+		int thislen;
+
 		page = *(resp->rqstp->rq_next_page);
 		if (!page) { /* ran out of pages */
 			maxcount -= len;
 			break;
 		}
+		thislen = min_t(long, len, PAGE_SIZE);
 		resp->rqstp->rq_vec[v].iov_base = page_address(page);
-		resp->rqstp->rq_vec[v].iov_len =
-			len < PAGE_SIZE ? len : PAGE_SIZE;
+		resp->rqstp->rq_vec[v].iov_len = thislen;
 		resp->rqstp->rq_next_page++;
 		v++;
-		len -= PAGE_SIZE;
+		len -= thislen;
 	}
 	read->rd_vlen = v;
 
-- 
1.9.0

