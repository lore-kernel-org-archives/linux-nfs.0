From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 17 - Don't over-write rpc request with response.
Date: Fri, 11 Oct 2002 15:27:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKt-0003bS-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLK-0003gY-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:10 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:54 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

We are going to want rpc request to be immutable so that
we can take a copy and put it aside to be processed later.
Currently the tcp code writes the response into the same
buffer as the request, thus corrupting the request.
With this patch, the response goes after the request.  There should
always be enough room as large reqeusts (Write) has small
responses, and large responses (read) are for small requests.

buflen is changed for requests to record the length of the
request.  It already gets reset for each new request.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

--- ./net/sunrpc/svcsock.c	2002/10/11 00:41:07	1.2
+++ ./net/sunrpc/svcsock.c	2002/10/11 01:51:33	1.3
@@ -526,6 +526,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_argbuf.base = data;
 	rqstp->rq_argbuf.buf  = data;
 	rqstp->rq_argbuf.len  = (len >> 2);
+	rqstp->rq_argbuf.buflen = (len >> 2);
 	/* rqstp->rq_resbuf      = rqstp->rq_defbuf; */
 	rqstp->rq_prot        = IPPROTO_UDP;
 
@@ -867,14 +868,17 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 
-	/* Position reply write pointer immediately after
-	 * record length */
-	rqstp->rq_resbuf.buf += 1;
+	/* Position reply write pointer immediately args,
+	 * allowing for record length */
+	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + (len>>2);
+	rqstp->rq_resbuf.buf  = rqstp->rq_resbuf.base + 1;
 	rqstp->rq_resbuf.len  = 1;
+	rqstp->rq_resbuf.buflen= rqstp->rq_argbuf.buflen - (len>>2) - 1;
 
 	rqstp->rq_skbuff      = 0;
 	rqstp->rq_argbuf.buf += 1;
 	rqstp->rq_argbuf.len  = (len >> 2);
+	rqstp->rq_argbuf.buflen = (len >> 2);
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
