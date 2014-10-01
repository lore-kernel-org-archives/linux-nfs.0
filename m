Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbaJAREk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2014 13:04:40 -0400
Date: Wed, 1 Oct 2014 13:04:40 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 3.17
Message-ID: <20141001170440.GB28623@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following change from:

  git://linux-nfs.org/~bfields/linux.git for-3.17

This fixes a data corruption bug introduced by the v3.16 xdr encoding
rewrite.  I haven't managed to reproduce it myself yet, but it's
apparently not hard to hit given the right workload.

--b.

commit 15b23ef5d348
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Sep 24 16:32:34 2014 -0400

    nfsd4: fix corruption of NFSv4 read data
    
    The calculation of page_ptr here is wrong in the case the read doesn't
    start at an offset that is a multiple of a page.
    
    The result is that nfs4svc_encode_compoundres sets rq_next_page to a
    value one too small, and then the loop in svc_free_res_pages may
    incorrectly fail to clear a page pointer in rq_respages[].
    
    Pages left in rq_respages[] are available for the next rpc request to
    use, so xdr data may be written to that page, which may hold data still
    waiting to be transmitted to the client or data in the page cache.
    
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

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e94457c33ad6..b01f6e100ee8 100644
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
