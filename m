From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG][PATCH] NFS over TCP doesn't work on linux-2.5.43
Date: Thu, 17 Oct 2002 22:04:58 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021017.220458.59648341.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182ARe-0003UA-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 06:12:11 -0700
To: neilb@cse.unsw.edu.au
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

Hello,

I've solved the problem that NFS over TCP doesn't work on linux-2.5.43.
Could you apply it?

--- linux-2.5.43/net/sunrpc/svcsock.c.ORG	Thu Oct 17 14:10:43 2030
+++ linux-2.5.43/net/sunrpc/svcsock.c	Thu Oct 17 21:46:56 2030
@@ -891,8 +891,8 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_skbuff      = 0;
 	rqstp->rq_argbuf.buf += 1;
-	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2);
+	rqstp->rq_argbuf.len  = (len >> 2) + 1;
+	rqstp->rq_argbuf.buflen = (len >> 2) + 1;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
