From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 5 - Fix problem with buffer length with rpc/tcp
Date: Thu, 31 Oct 2002 11:08:11 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021031000811.29572@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872su-0005wU-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 16:08:28 -0800
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

I forgot to add '1' for the record-length header in RPC/TCP.
 Thanks to  Hirokazu Takahashi <taka@valinux.co.jp>



 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--- ./net/sunrpc/svcsock.c	2002/10/30 22:40:32	1.1
+++ ./net/sunrpc/svcsock.c	2002/10/30 22:40:35	1.2
@@ -882,9 +882,9 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 
-	/* Position reply write pointer immediately args,
+	/* Position reply write pointer immediately after args,
 	 * allowing for record length */
-	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + (len>>2);
+	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + 1 + (len>>2);
 	rqstp->rq_resbuf.buf  = rqstp->rq_resbuf.base + 1;
 	rqstp->rq_resbuf.len  = 1;
 	rqstp->rq_resbuf.buflen= rqstp->rq_argbuf.buflen - (len>>2) - 1;
@@ -892,7 +892,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_skbuff      = 0;
 	rqstp->rq_argbuf.buf += 1;
 	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2);
+	rqstp->rq_argbuf.buflen = (len >> 2) +1;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
