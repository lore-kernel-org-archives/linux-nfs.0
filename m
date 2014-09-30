Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbaI3NoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 09:44:00 -0400
Date: Tue, 30 Sep 2014 09:43:59 -0400
To: linux-nfs@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
        "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH] nfsd4: fix corruption of NFSv4 read data
Message-ID: <20140930134359.GA5472@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The calculation of page_ptr here is wrong in the case the read doesn't
start at an offset that is a multiple of a page.

The result is that nfs4svc_encode_compoundres sets rq_next_page to a
value one too small, and then the loop in svc_free_res_pages may
incorrectly fail to clear a page pointer in rq_respages[].

Pages left in the rq_respages[] are considered free for the next rpc
request to use, so xdr data may be written to that page, which may hold
data still waiting to be transmitted to the client or data in the page
cache.

The observed result was silent data corruption seen on an NFSv4 client.

We tag this as "fixing" 05638dc73af2 because that commit exposed this
bug, though the incorrect calculation predates it.

Particular thanks to Andrea Arcangeli and David Gilbert for analysis and
testing.

Fixes: 05638dc73af2 "nfsd4: simplify server xdr->next_page use"
Cc: stable@vger.kernel.org
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

I'm planning to pass this along to Linus, probably later today.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e94457c..b01f6e1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3104,7 +3104,8 @@ static __be32 nfsd4_encode_splice_read(
 
 	buf->page_len = maxcount;
 	buf->len += maxcount;
-	xdr->page_ptr += (maxcount + PAGE_SIZE - 1) / PAGE_SIZE;
+	xdr->page_ptr += (buf->page_base + maxcount + PAGE_SIZE - 1)
+							/ PAGE_SIZE;
 
 	/* Use rest of head for padding and remaining ops: */
 	buf->tail[0].iov_base = xdr->p;
-- 
1.9.1

