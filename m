From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 3 - Make sure nfsd replies from the address the request was sent to.
Date: Tue, 19 Aug 2003 14:35:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19oyD8-0001HE-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19oyDK-00063i-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 21:35:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 19 Aug 2003 14:35:12 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

This is important on multi-homes hosts.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svc.h |    2 ++
 ./net/sunrpc/svcsock.c       |   16 +++++++++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-08-18 09:51:51.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-08-18 09:42:06.000000000 +1000
@@ -131,6 +131,8 @@ struct svc_rqst {
 				rq_secure  : 1;	/* secure port */
 
 
+	__u32			rq_daddr;	/* dest addr of request - reply from here */
+
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
 

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-08-18 09:51:51.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-08-18 09:53:17.000000000 +1000
@@ -353,6 +353,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
+	struct { struct cmsghdr cmh;
+		struct in_pktinfo pki;
+	} cm;
 	int		len = 0;
 	int		result;
 	int		size;
@@ -364,16 +367,22 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	slen = xdr->len;
 
 	if (rqstp->rq_prot == IPPROTO_UDP) {
-		/* set the destination */
+		/* set the source and destination */
 		struct msghdr	msg;
 		msg.msg_name    = &rqstp->rq_addr;
 		msg.msg_namelen = sizeof(rqstp->rq_addr);
 		msg.msg_iov     = NULL;
 		msg.msg_iovlen  = 0;
-		msg.msg_control = NULL;
-		msg.msg_controllen = 0;
 		msg.msg_flags	= MSG_MORE;
 
+		msg.msg_control = &cm;
+		msg.msg_controllen = sizeof(cm);
+		cm.cmh.cmsg_len = sizeof(cm);
+		cm.cmh.cmsg_level = SOL_IP;
+		cm.cmh.cmsg_type = IP_PKTINFO;
+		cm.pki.ipi_ifindex = 0;
+		cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
+
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;
 	}
@@ -594,6 +603,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_family = AF_INET;
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	rqstp->rq_daddr = skb->nh.iph->daddr;
 
 	svsk->sk_sk->sk_stamp = skb->stamp;
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
