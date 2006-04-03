From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 16] knfsd: nfsd4: fix corruption on readdir encoding with 64k pages
Date: Mon, 3 Apr 2006 15:18:51 +1000
Message-ID: <1060403051851.1833@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUX-0005UB-9Z
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:41 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHUV-0004T7-J8
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:41 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Fix corruption on readdir encoding with 64k pages.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2006-04-03 15:12:11.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2006-04-03 15:12:13.000000000 +1000
@@ -2157,7 +2157,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 {
 	int maxcount;
 	loff_t offset;
-	u32 *page, *savep;
+	u32 *page, *savep, *tailbase;
 	ENCODE_HEAD;
 
 	if (nfserr)
@@ -2173,6 +2173,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	WRITE32(0);
 	ADJUST_ARGS();
 	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+	tailbase = p;
 
 	maxcount = PAGE_SIZE;
 	if (maxcount > readdir->rd_maxcount)
@@ -2217,14 +2218,12 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	*p++ = htonl(readdir->common.err == nfserr_eof);
 	resp->xbuf->page_len = ((char*)p) - (char*)page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
 
-	/* allocate a page for the tail */
-	svc_take_page(resp->rqstp);
-	resp->xbuf->tail[0].iov_base = 
-		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
-	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
+	/* Use rest of head for padding and remaining ops: */
+	resp->rqstp->rq_restailpage = 0;
+	resp->xbuf->tail[0].iov_base = tailbase;
 	resp->xbuf->tail[0].iov_len = 0;
 	resp->p = resp->xbuf->tail[0].iov_base;
-	resp->end = resp->p + PAGE_SIZE/4;
+	resp->end = resp->p + (PAGE_SIZE - resp->xbuf->head[0].iov_len)/4;
 
 	return 0;
 err_no_verf:


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
