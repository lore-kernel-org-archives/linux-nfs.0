From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Fill in rqstp->rq_daddr in svc_tcp_recvfrom
Date: Tue, 12 Jul 2005 11:04:56 +0200
Message-ID: <20050712090455.GA9243@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsGhy-0006Ig-KC
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 02:05:42 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsGhy-0006lq-8f
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 02:05:42 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 71948E0BB
	for <nfs@lists.sourceforge.net>; Tue, 12 Jul 2005 11:04:56 +0200 (CEST)
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

Here's a patch we added to SLES in response to a customer bug report:

# Subject: Fill in rqstp->rq_daddr in svc_tcp_recvfrom
#
# This patch fills the daddr member of the rpc struct svc_rqst structure for  
# TCP-based sockets in the recvfrom proceedure.  Currently, the field is 
# not set thus leaving it with left over garbage from a previous allocation. 
#
# This makes the behavior consistent between UDP- and TCP-based RPC. 
#
# This patch enables HA software to failover TCP-based RPC services
# such as TCP-based NFS. 
#
# Signed-off-by: okir@suse.de

Index: linux-2.6.12.orig/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.12.orig/net/sunrpc/svcsock.c	2005-07-08 11:45:25.000000000 +0200
+++ linux-2.6.12/net/sunrpc/svcsock.c	2005-07-12 10:57:05.000000000 +0200
@@ -455,8 +455,9 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	struct socket	*sock;
 	int		len, alen;
 
-	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	sock = rqstp->rq_sock->sk_sock;
+	rqstp->rq_daddr = inet_sk((const struct sock *)sock)->rcv_saddr;
+	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 
 	msg.msg_name    = &rqstp->rq_addr;
 	msg.msg_namelen = sizeof(rqstp->rq_addr);
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
