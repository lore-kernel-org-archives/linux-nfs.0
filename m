From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Keep nfsd from exiting when seeing recv() errors
Date: Mon, 11 Jul 2005 11:45:32 +0200
Message-ID: <20050711094531.GE27163@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WYTEVAkct0FjGQmd"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drur8-0000p6-4V
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:45:42 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drur4-0000Dy-Rp
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:45:42 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 3672DF07E
	for <nfs@lists.sourceforge.net>; Mon, 11 Jul 2005 11:45:32 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--WYTEVAkct0FjGQmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I think I submitted this one previously - svc_tcp_recvfrom currently
returns any errors to the caller, including ECONNRESET and the like.

This is something svc_recv isn't able to deal with:

	len = svsk->sk_recvfrom(rqstp);
	[...]
	if (len == 0 || len == -EAGAIN) {
		[...]
		return -EAGAIN;
	}

	[...]
	return len;

The nfsd main loop will exit when it sees an error code other than
EAGAIN.

The attached patch fixes this problem.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--WYTEVAkct0FjGQmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-svc-recv-errors

Subject: Keep nfsd from exiting when seeing recv() errors
From: Olaf Kirch <okir@suse.de>

svc_recv is not equipped to deal with error codes other than EAGAIN,
and will propagate anything else (such as ECONNRESET) up to nfsd,
causing it to exit.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: 2.4.21/net/sunrpc/svcsock.c
===================================================================
--- 2.4.21.orig/net/sunrpc/svcsock.c	2003-06-13 16:51:39.000000000 +0200
+++ 2.4.21/net/sunrpc/svcsock.c	2004-09-20 13:11:53.000000000 +0200
@@ -894,7 +894,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 					svsk->sk_server->sv_name, -len);
-		svc_sock_received(svsk);
+		goto err_delete;
 	}
 
 	return len;


--WYTEVAkct0FjGQmd--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
