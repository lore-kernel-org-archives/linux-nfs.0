From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] only udp calls sock_sendmsg() to set destination.
Date: Fri, 15 Nov 2002 13:27:06 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021115.132706.26959611.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CaCV-0003nU-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 22:43:35 -0800
Received: from sv1.valinux.co.jp ([202.221.173.100]:1224)
	by panoramix.vasoftware.com with esmtp (Exim 4.05-VA-mm1 #1 (Debian))
	id 18CYDN-0003rh-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 20:36:21 -0800
To: <neilb@cse.unsw.edu.au>
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

I realized the first sock_sendmsg in svc_sendto() is meaningless
in case of TCP as the connection is already established.
I fixed it so that sock_sendmsg is called only if it's UDP.

Thank you,
Hirokazu Takahashi.


--- net/sunrpc/svcsock.c.ORG4	Sun Nov  3 08:37:04 2030
+++ net/sunrpc/svcsock.c	Sun Nov  3 08:38:34 2030
@@ -351,11 +351,13 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	down(&svsk->sk_sem);
 
 	/* set the destination */
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	len = sock_sendmsg(sock, &msg, 0);
-	set_fs(oldfs);
-	if (len < 0)
-		goto out;
+	if (rqstp->rq_prot == IPPROTO_UDP) {
+		oldfs = get_fs(); set_fs(KERNEL_DS);
+		len = sock_sendmsg(sock, &msg, 0);
+		set_fs(oldfs);
+		if (len < 0)
+			goto out;
+	}
 
 	/* send head */
 	if (slen == xdr->head[0].iov_len)


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
