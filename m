From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 16 of 34 - fixes an xdr error by removing the verifier from error return.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006J2-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xc-HH
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqf-0005hu-Oy
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:53 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
To: Andrew Morton <akpm@osdl.org>
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:33.000000000 +1100
@@ -2091,7 +2091,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 {
 	int maxcount;
 	loff_t offset;
-	u32 *page;
+	u32 *page, *savep;
 	ENCODE_HEAD;
 
 	if (nfserr)
@@ -2100,6 +2100,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 		return nfserr_resource;
 
 	RESERVE_SPACE(8);  /* verifier */
+	savep = p;
 
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
@@ -2117,8 +2118,10 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	 * pointer and eof field.
 	 */
 	maxcount = (maxcount >> 2) - 4;
-	if (maxcount < 0)
-		return nfserr_toosmall;
+	if (maxcount < 0) {
+		nfserr =  nfserr_toosmall;
+		goto err_no_verf;
+	}
 
 	svc_take_page(resp->rqstp);
 	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
@@ -2136,7 +2139,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	    readdir->buffer == page) 
 		nfserr = nfserr_toosmall;
 	if (nfserr)
-		return nfserr;
+		goto err_no_verf;
 
 	if (readdir->offset)
 		xdr_encode_hyper(readdir->offset, offset);
@@ -2156,6 +2159,10 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	resp->end = resp->p + PAGE_SIZE/4;
 
 	return 0;
+err_no_verf:
+	p = savep;
+	ADJUST_ARGS();
+	return nfserr;
 }
 
 static void


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
