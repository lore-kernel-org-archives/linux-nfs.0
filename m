From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 15 of 15 -  NFSv4 server fixes
Date: Mon, 06 Jan 2003 11:05:05 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlN-0002YF-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlh-0002XR-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:25 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:06 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet
Assorted fixes particularly related to handling the new style
xdr_buf buffers for NFSv4 server


  ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    2 +
 ./fs/nfsd/nfs4xdr.c         |   53 +++++++++++++++++++++++++++++++-------------
 ./include/linux/nfsd/xdr4.h |    1 
 3 files changed, 41 insertions(+), 15 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-01-06 10:56:22.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2003-01-06 10:56:51.000000000 +1100
@@ -568,6 +568,8 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
+	resp->tagp = resp->p + 1; /* skip over status */
+	/* reserve space for: status, taglen, tag, and opcnt */
 	resp->p += 3 + XDR_QUADLEN(args->taglen);
 	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
 	resp->taglen = args->taglen;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-01-06 10:56:22.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2003-01-06 10:56:51.000000000 +1100
@@ -1728,8 +1728,17 @@ nfsd4_encode_read(struct nfsd4_compoundr
 	WRITE32(maxcount);
 	ADJUST_ARGS();
 	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
-	resp->p = resp->xbuf->tail[0].iov_base;
+
 	resp->xbuf->page_len = maxcount;
+
+	/* set up page for remaining responses */
+	svc_take_page(resp->rqstp);
+	resp->xbuf->tail[0].iov_base = 
+		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->tail[0].iov_len = 0;
+	resp->p = resp->xbuf->tail[0].iov_base;
+	resp->end = resp->p + PAGE_SIZE/4;
+
 	if (maxcount&3) {
 		*(resp->p)++ = 0;
 		resp->xbuf->tail[0].iov_base += maxcount&3;
@@ -1753,11 +1762,6 @@ nfsd4_encode_readlink(struct nfsd4_compo
 	svc_take_page(resp->rqstp);
 	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
 
-	svc_take_page(resp->rqstp);
-	resp->xbuf->tail[0].iov_base = 
-		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
-	resp->xbuf->tail[0].iov_len = 0;
-
 	maxcount = PAGE_SIZE;
 	RESERVE_SPACE(4);
 
@@ -1774,7 +1778,14 @@ nfsd4_encode_readlink(struct nfsd4_compo
 	WRITE32(maxcount);
 	ADJUST_ARGS();
 	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+
+	svc_take_page(resp->rqstp);
+	resp->xbuf->tail[0].iov_base = 
+		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->tail[0].iov_len = 0;
 	resp->p = resp->xbuf->tail[0].iov_base;
+	resp->end = resp->p + PAGE_SIZE/4;
+
 	resp->xbuf->page_len = maxcount;
 	if (maxcount&3) {
 		*(resp->p)++ = 0;
@@ -1803,6 +1814,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	WRITE32(0);
 	WRITE32(0);
 	ADJUST_ARGS();
+	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
 
 	maxcount = PAGE_SIZE;
 	if (maxcount > readdir->rd_maxcount)
@@ -1832,16 +1844,26 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	    readdir->common.err == nfserr_readdir_nospc &&
 	    readdir->buffer == page) 
 		nfserr = nfserr_readdir_nospc;
-	if (!nfserr) {
-		if (readdir->offset)
-			xdr_encode_hyper(readdir->offset, offset);
+	if (nfserr)
+		return nfserr;
 
-		p = readdir->buffer;
-		*p++ = 0;	/* no more entries */
-		*p++ = htonl(readdir->common.err == nfserr_eof);
-		resp->xbuf->page_len = ((char*)p) - (char*)page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
-	}
-	return nfserr;
+	if (readdir->offset)
+		xdr_encode_hyper(readdir->offset, offset);
+
+	p = readdir->buffer;
+	*p++ = 0;	/* no more entries */
+	*p++ = htonl(readdir->common.err == nfserr_eof);
+	resp->xbuf->page_len = ((char*)p) - (char*)page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+
+	/* allocate a page for the tail */
+	svc_take_page(resp->rqstp);
+	resp->xbuf->tail[0].iov_base = 
+		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->tail[0].iov_len = 0;
+	resp->p = resp->xbuf->tail[0].iov_base;
+	resp->end = resp->p + PAGE_SIZE/4;
+
+	return 0;
 }
 
 static void
@@ -2066,6 +2088,7 @@ nfs4svc_encode_compoundres(struct svc_rq
 	 * All that remains is to write the tag and operation count...
 	 */
 	struct iovec *iov;
+	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
 	memcpy(p, resp->tag, resp->taglen);
 	p += XDR_QUADLEN(resp->taglen);

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-01-06 10:56:22.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2003-01-06 10:56:51.000000000 +1100
@@ -320,6 +320,7 @@ struct nfsd4_compoundres {
 	u32				taglen;
 	char *				tag;
 	u32				opcnt;
+	u32 *				tagp; /* where to encode tag and  opcount */
 };
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
