From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG][PATCH] NFS over TCP doesn't work on linux-2.5.43
Date: Fri, 18 Oct 2002 12:03:26 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021018.120326.21935018.taka@valinux.co.jp>
References: <20021017.220458.59648341.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182NX6-0006b7-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 20:10:40 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20021017.220458.59648341.taka@valinux.co.jp>
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

I found another problem that argbuf and resbuf may be overlapped.
We should throw away previous one and apply a new patch.

> I've solved the problem that NFS over TCP doesn't work on linux-2.5.43.
> Could you apply it?

And I realize these new manner of handling argbuf and resbuf will
conflict with my zerocopy patches.
I'll port them again linux2.5.34 soon.


--- linux/net/sunrpc/svcsock.c.ORG	Thu Oct 17 14:10:43 2030
+++ linux/net/sunrpc/svcsock.c	Fri Oct 18 11:20:27 2030
@@ -882,17 +882,18 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 
+	rqstp->rq_skbuff         = 0;
+	rqstp->rq_argbuf.buf    += 1;
+	rqstp->rq_argbuf.len     = (len >> 2) + 1;
+	rqstp->rq_argbuf.buflen  = (len >> 2) + 1;
+
 	/* Position reply write pointer immediately args,
 	 * allowing for record length */
-	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + (len>>2);
-	rqstp->rq_resbuf.buf  = rqstp->rq_resbuf.base + 1;
-	rqstp->rq_resbuf.len  = 1;
-	rqstp->rq_resbuf.buflen= rqstp->rq_argbuf.buflen - (len>>2) - 1;
+	rqstp->rq_resbuf.base   += rqstp->rq_argbuf.buflen;
+	rqstp->rq_resbuf.buf     = rqstp->rq_resbuf.base + 1;
+	rqstp->rq_resbuf.len     = 1;
+	rqstp->rq_resbuf.buflen -= rqstp->rq_argbuf.buflen;
 
-	rqstp->rq_skbuff      = 0;
-	rqstp->rq_argbuf.buf += 1;
-	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2);
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
