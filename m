Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34085 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab2LQQKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 11:10:49 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TkdHE-0007d1-OB
	for linux-nfs@vger.kernel.org; Mon, 17 Dec 2012 11:10:48 -0500
Date: Mon, 17 Dec 2012 11:10:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd4: fix oops on unusual readlike compound
Message-ID: <20121217161048.GG23546@fieldses.org>
References: <20121217160959.GF23546@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121217160959.GF23546@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If the argument and reply together exceed the maximum payload size, then
a reply with a read-like operation can overlow the rq_pages array.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3bf8a9d..e104725 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2925,11 +2925,16 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	len = maxcount;
 	v = 0;
 	while (len > 0) {
-		pn = resp->rqstp->rq_resused++;
+		pn = resp->rqstp->rq_resused;
+		if (!resp->rqstp->rq_respages[pn]) { /* ran out of pages */
+			maxcount -= len;
+			break;
+		}
 		resp->rqstp->rq_vec[v].iov_base =
 			page_address(resp->rqstp->rq_respages[pn]);
 		resp->rqstp->rq_vec[v].iov_len =
 			len < PAGE_SIZE ? len : PAGE_SIZE;
+		resp->rqstp->rq_resused++;
 		v++;
 		len -= PAGE_SIZE;
 	}
@@ -2975,6 +2980,8 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 		return nfserr;
 	if (resp->xbuf->page_len)
 		return nfserr_resource;
+	if (!*resp->rqstp->rq_next_page)
+		return nfserr_resource;
 
 	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused++]);
 
@@ -3024,6 +3031,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		return nfserr;
 	if (resp->xbuf->page_len)
 		return nfserr_resource;
+	if (!*resp->rqstp->rq_next_page)
+		return nfserr_resource;
 
 	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
 	savep = p;
-- 
1.7.9.5

