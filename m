From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 5 - Make sure final xdr_buf.len is correct on server reply
Date: Thu, 07 Nov 2002 11:56:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E189ayP-0008Jw-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189ayW-0001cJ-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 16:56:49 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 7 Nov 2002 11:56:41 +1100
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

rq_res->len was not always updated properly.
It is only needed in the sendto routine, so we calculate
it just before that is called, and don't bother
updating it anywhere else.




 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c          |    7 -------
 ./fs/nfsd/nfsxdr.c           |    7 -------
 ./include/linux/sunrpc/svc.h |    1 -
 ./net/sunrpc/svcsock.c       |    7 +++++++
 4 files changed, 7 insertions(+), 15 deletions(-)

--- ./include/linux/sunrpc/svc.h	2002/11/06 23:12:16	1.3
+++ ./include/linux/sunrpc/svc.h	2002/11/06 23:12:23	1.4
@@ -167,7 +167,6 @@ xdr_ressize_check(struct svc_rqst *rqstp
 	char *cp = (char*)p;
 
 	vec->iov_len = cp - (char*)vec->iov_base;
-	rqstp->rq_res.len = vec->iov_len;
 
 	return vec->iov_len <= PAGE_SIZE;
 }
--- ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:16	1.3
+++ ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:23	1.4
@@ -397,10 +397,6 @@ nfssvc_encode_readres(struct svc_rqst *r
 		*p = 0;
 		rqstp->rq_res.tail[0].iov_len = 4 - (resp->count&3);
 	}
-	rqstp->rq_res.len = 
-		rqstp->rq_res.head[0].iov_len+
-		rqstp->rq_res.page_len+
-		rqstp->rq_res.tail[0].iov_len;
 	return 1;
 }
 
@@ -413,9 +409,6 @@ nfssvc_encode_readdirres(struct svc_rqst
 	*p++ = 0;			/* no more entries */
 	*p++ = htonl((resp->common.err == nfserr_eof));
 	rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
-	rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len;
 
 	return 1;
 }
--- ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:16	1.3
+++ ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:23	1.4
@@ -616,10 +616,6 @@ nfs3svc_encode_readres(struct svc_rqst *
 			*p = 0;
 			rqstp->rq_res.tail[0].iov_len = 4 - (resp->count & 3);
 		}
-		rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len+
-			rqstp->rq_res.tail[0].iov_len;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);
@@ -689,9 +685,6 @@ nfs3svc_encode_readdirres(struct svc_rqs
 		*p++ = 0;		/* no more entries */
 		*p++ = htonl(resp->common.err == nfserr_eof);
 		rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
-		rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);
--- ./net/sunrpc/svcsock.c	2002/11/06 23:12:08	1.2
+++ ./net/sunrpc/svcsock.c	2002/11/06 23:12:24	1.3
@@ -1195,6 +1195,7 @@ svc_send(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk;
 	int		len;
+	struct xdr_buf	*xb;
 
 	if ((svsk = rqstp->rq_sock) == NULL) {
 		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
@@ -1205,6 +1206,12 @@ svc_send(struct svc_rqst *rqstp)
 	/* release the receive skb before sending the reply */
 	svc_release_skb(rqstp);
 
+	/* calculate over-all length */
+	xb = & rqstp->rq_res;
+	xb->len = xb->head[0].iov_len +
+		xb->page_len +
+		xb->tail[0].iov_len;
+
 	len = svsk->sk_sendto(rqstp);
 	svc_sock_release(rqstp);
 


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
