From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: rq_arg
Date: Fri, 15 Nov 2002 13:08:52 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021115.130852.26540379.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CaLB-0007J6-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 22:52:33 -0800
Received: from sv1.valinux.co.jp ([202.221.173.100]:1214)
	by panoramix.vasoftware.com with esmtp (Exim 4.05-VA-mm1 #1 (Debian))
	id 18CXvl-0002SC-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 20:18:09 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Hello Neil,

I found a bug in svc_udp_recvfrom() and fixed it.
rq_arg.head[0].iov_len and rq_arg.page_len will be set to
wrong value when length of date is smaller than PAGE_SIZE.

Thank you,
Hirokazu Takahashi.


--- net/sunrpc/svcsock.c.BUG	Thu Nov 14 22:09:36 2030
+++ net/sunrpc/svcsock.c	Fri Nov 15 11:24:34 2030
@@ -572,10 +572,15 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 	}
 
-
 	rqstp->rq_arg.len = len;
-	rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
-	rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
+	if (len <= rqstp->rq_arg.head[0].iov_len) {
+		rqstp->rq_arg.head[0].iov_len = len;
+		rqstp->rq_arg.page_len = 0;
+	} else {
+		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
+		rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
+	}
+
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
