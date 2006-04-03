From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 16] knfsd: nfsd4: fix corruption of returned data when using 64k pages
Date: Mon, 3 Apr 2006 15:18:46 +1000
Message-ID: <1060403051846.1821@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751477AbWDCFXk@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


In v4 we grab an extra page just for the padding of returned data.  The
formula that the rpc server uses to allocate pages for the response doesn't
take into account this extra page.

Instead of adjusting those formulae, we adopt the same solution as v2 and
v3, and put the "tail" data in the same page as the "head" data.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   42 +++++++++++++++++-------------------------
 1 file changed, 17 insertions(+), 25 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2006-04-03 15:12:06.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2006-04-03 15:12:11.000000000 +1000
@@ -2084,27 +2084,20 @@ nfsd4_encode_read(struct nfsd4_compoundr
 	WRITE32(eof);
 	WRITE32(maxcount);
 	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
-
+	resp->xbuf->head[0].iov_len = (char*)p
+					- (char*)resp->xbuf->head[0].iov_base;
 	resp->xbuf->page_len = maxcount;
 
-	/* read zero bytes -> don't set up tail */
-	if(!maxcount)
-		return 0;        
-
-	/* set up page for remaining responses */
-	svc_take_page(resp->rqstp);
-	resp->xbuf->tail[0].iov_base = 
-		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
-	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
+	/* Use rest of head for padding and remaining ops: */
+	resp->rqstp->rq_restailpage = 0;
+	resp->xbuf->tail[0].iov_base = p;
 	resp->xbuf->tail[0].iov_len = 0;
-	resp->p = resp->xbuf->tail[0].iov_base;
-	resp->end = resp->p + PAGE_SIZE/4;
-
 	if (maxcount&3) {
-		*(resp->p)++ = 0;
+		RESERVE_SPACE(4);
+		WRITE32(0);
 		resp->xbuf->tail[0].iov_base += maxcount&3;
 		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -2141,21 +2134,20 @@ nfsd4_encode_readlink(struct nfsd4_compo
 
 	WRITE32(maxcount);
 	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+	resp->xbuf->head[0].iov_len = (char*)p
+				- (char*)resp->xbuf->head[0].iov_base;
+	resp->xbuf->page_len = maxcount;
 
-	svc_take_page(resp->rqstp);
-	resp->xbuf->tail[0].iov_base = 
-		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
-	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
+	/* Use rest of head for padding and remaining ops: */
+	resp->rqstp->rq_restailpage = 0;
+	resp->xbuf->tail[0].iov_base = p;
 	resp->xbuf->tail[0].iov_len = 0;
-	resp->p = resp->xbuf->tail[0].iov_base;
-	resp->end = resp->p + PAGE_SIZE/4;
-
-	resp->xbuf->page_len = maxcount;
 	if (maxcount&3) {
-		*(resp->p)++ = 0;
+		RESERVE_SPACE(4);
+		WRITE32(0);
 		resp->xbuf->tail[0].iov_base += maxcount&3;
 		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+		ADJUST_ARGS();
 	}
 	return 0;
 }
