From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 6 - Make sure nfsd replies from the address the request was sent to.
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004Vg-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027c-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002HZ-Rq
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:56 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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


This is important on multi-homes hosts.


diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-09-04 11:32:11.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-09-04 11:46:27.000000000 +1000
@@ -112,6 +112,8 @@ struct svc_rqst {
 				rq_secure  : 1,	/* secure port */
 				rq_auth    : 1;	/* check client */
 
+	__u32			rq_daddr;	/* dest addr of request - reply from here */
+
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
 

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-04 11:45:48.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-04 11:46:27.000000000 +1000
@@ -317,6 +317,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	struct msghdr	msg;
+	struct { struct cmsghdr cmh;
+		struct in_pktinfo pki;
+	} cm;
 	int		i, buflen, len;
 
 	for (i = buflen = 0; i < nr; i++)
@@ -326,8 +329,18 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	msg.msg_namelen = sizeof(rqstp->rq_addr);
 	msg.msg_iov     = iov;
 	msg.msg_iovlen  = nr;
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
+	if (rqstp->rq_prot == IPPROTO_UDP) {
+		msg.msg_control = &cm;
+		msg.msg_controllen = sizeof(cm);
+		cm.cmh.cmsg_len = sizeof(cm);
+		cm.cmh.cmsg_level = SOL_IP;
+		cm.cmh.cmsg_type = IP_PKTINFO;
+		cm.pki.ipi_ifindex = 0;
+		cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
+	} else {
+		msg.msg_control = NULL;
+		msg.msg_controllen = 0;
+	}
 
 	/* This was MSG_DONTWAIT, but I now want it to wait.
 	 * The only thing that it would wait for is memory and
@@ -531,6 +544,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_family = AF_INET;
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	rqstp->rq_daddr = skb->nh.iph->daddr;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
