From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 5 - Keep track of which page is the 'tail' of an NFSd reply
Date: Tue, 11 Feb 2003 15:37:24 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18iSAe-0008HQ-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iSB0-0005vQ-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 20:37:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 11 Feb 2003 15:37:33 +1100
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

NFS replies can have a 'tail' after a 'data' component 
(for read, readlink, readdir).
For nfsv2 and v3 this tail is in the same page as the head.
For nfsv4, this tail is in a separate page.
We need to keep track of which page so that it right one
gets sent.  This patch does that.

(against 2.5.60)
 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c          |    2 ++
 ./fs/nfsd/nfs4xdr.c          |    3 +++
 ./fs/nfsd/nfsxdr.c           |    2 ++
 ./include/linux/sunrpc/svc.h |    1 +
 ./net/sunrpc/svcsock.c       |    2 +-
 5 files changed, 9 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-02-11 14:25:27.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2003-02-11 14:25:34.000000000 +1100
@@ -667,6 +667,7 @@ nfs3svc_encode_readlinkres(struct svc_rq
 		rqstp->rq_res.page_len = resp->len;
 		if (resp->len & 3) {
 			/* need to pad the tail */
+			rqstp->rq_restailpage = 0;
 			rqstp->rq_res.tail[0].iov_base = p;
 			*p = 0;
 			rqstp->rq_res.tail[0].iov_len = 4 - (resp->len&3);
@@ -691,6 +692,7 @@ nfs3svc_encode_readres(struct svc_rqst *
 		rqstp->rq_res.page_len = resp->count;
 		if (resp->count & 3) {
 			/* need to pad the tail */
+			rqstp->rq_restailpage = 0;
 			rqstp->rq_res.tail[0].iov_base = p;
 			*p = 0;
 			rqstp->rq_res.tail[0].iov_len = 4 - (resp->count & 3);

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-02-11 14:25:34.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2003-02-11 14:25:34.000000000 +1100
@@ -1735,6 +1735,7 @@ nfsd4_encode_read(struct nfsd4_compoundr
 	svc_take_page(resp->rqstp);
 	resp->xbuf->tail[0].iov_base = 
 		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
 	resp->xbuf->tail[0].iov_len = 0;
 	resp->p = resp->xbuf->tail[0].iov_base;
 	resp->end = resp->p + PAGE_SIZE/4;
@@ -1782,6 +1783,7 @@ nfsd4_encode_readlink(struct nfsd4_compo
 	svc_take_page(resp->rqstp);
 	resp->xbuf->tail[0].iov_base = 
 		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
 	resp->xbuf->tail[0].iov_len = 0;
 	resp->p = resp->xbuf->tail[0].iov_base;
 	resp->end = resp->p + PAGE_SIZE/4;
@@ -1859,6 +1861,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	svc_take_page(resp->rqstp);
 	resp->xbuf->tail[0].iov_base = 
 		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->rqstp->rq_restailpage = resp->rqstp->rq_resused-1;
 	resp->xbuf->tail[0].iov_len = 0;
 	resp->p = resp->xbuf->tail[0].iov_base;
 	resp->end = resp->p + PAGE_SIZE/4;

diff ./fs/nfsd/nfsxdr.c~current~ ./fs/nfsd/nfsxdr.c
--- ./fs/nfsd/nfsxdr.c~current~	2003-02-11 14:25:34.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2003-02-11 14:25:34.000000000 +1100
@@ -396,6 +396,7 @@ nfssvc_encode_readlinkres(struct svc_rqs
 	rqstp->rq_res.page_len = resp->len;
 	if (resp->len & 3) {
 		/* need to pad the tail */
+		rqstp->rq_restailpage = 0;
 		rqstp->rq_res.tail[0].iov_base = p;
 		*p = 0;
 		rqstp->rq_res.tail[0].iov_len = 4 - (resp->len&3);
@@ -415,6 +416,7 @@ nfssvc_encode_readres(struct svc_rqst *r
 	rqstp->rq_res.page_len = resp->count;
 	if (resp->count & 3) {
 		/* need to pad the tail */
+		rqstp->rq_restailpage = 0;
 		rqstp->rq_res.tail[0].iov_base = p;
 		*p = 0;
 		rqstp->rq_res.tail[0].iov_len = 4 - (resp->count&3);

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-02-11 14:25:34.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2003-02-11 14:25:34.000000000 +1100
@@ -114,6 +114,7 @@ struct svc_rqst {
 	struct xdr_buf		rq_res;
 	struct page *		rq_argpages[RPCSVC_MAXPAGES];
 	struct page *		rq_respages[RPCSVC_MAXPAGES];
+	int			rq_restailpage;
 	short			rq_argused;	/* pages used for argument */
 	short			rq_arghi;	/* pages available in argument page list */
 	short			rq_resused;	/* pages used for result */

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-02-11 14:25:34.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2003-02-11 14:25:34.000000000 +1100
@@ -388,7 +388,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
 		/* The tail *will* be in respages[0]; */
-		result = sock->ops->sendpage(sock, rqstp->rq_respages[0], 
+		result = sock->ops->sendpage(sock, rqstp->rq_respages[rqstp->rq_restailpage], 
 					     ((unsigned long)xdr->tail[0].iov_base)& (PAGE_SIZE-1),
 					     xdr->tail[0].iov_len, 0);
 


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
