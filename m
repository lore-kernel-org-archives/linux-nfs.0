From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Keep nfsd from exiting when seeing recv() errors
Date: Wed, 16 Nov 2005 11:24:22 +0100
Message-ID: <20051116102421.GA17988@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcKSs-0001m1-So
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 02:24:30 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcKSp-00014t-EB
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 02:24:30 -0800
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

Hi,

I submitted this one previously - svc_tcp_recvfrom currently returns
any errors to the caller, including ECONNRESET and the like.

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

The following patch fixes this problem

Olaf
------------------------------------------------------------------
Subject: Keep nfsd from exiting when seeing recv() errors

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


-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
