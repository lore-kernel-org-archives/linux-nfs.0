From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG][PATCH] NFS over TCP doesn't work on linux-2.5.43
Date: Tue, 22 Oct 2002 09:40:17 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15796.36961.219609.963119@notabene.cse.unsw.edu.au>
References: <20021017.220458.59648341.taka@valinux.co.jp>
	<20021018.120326.21935018.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183mA9-0002Lc-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 16:40:46 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 22 Oct 2002 09:40:29 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday October 18
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

On Friday October 18, taka@valinux.co.jp wrote:
> Hello,
> 
> I found another problem that argbuf and resbuf may be overlapped.
> We should throw away previous one and apply a new patch.
> 
> > I've solved the problem that NFS over TCP doesn't work on linux-2.5.43.
> > Could you apply it?
> 

Thanks for noticing this. 
I think the following it patch is simpler and achieves the same
result.  Could you please check that it addresses the issues you
discovered?

NeilBrown

--- ./net/sunrpc/svcsock.c	2002/10/21 23:26:40	1.1
+++ ./net/sunrpc/svcsock.c	2002/10/21 23:33:06
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
This sf.net emial is sponsored by: Influence the future 
of  Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576298;k?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
