From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Linux NFS & Heartbeat Failover (RH9.0)
Date: Sun, 17 Aug 2003 21:05:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16191.24979.340685.673333@gargle.gargle.HOWL>
References: <1061046205.3f3e47bd69679@mail.aidasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19oLMe-000144-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Aug 2003 04:06:24 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <tim@aidasystems.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Sun, 17 Aug 2003 21:06:12 +1000
To: Tim Hasson <tim@aidasystems.com>
In-Reply-To: message from Tim Hasson on Saturday August 16
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

On Saturday August 16, tim@aidasystems.com wrote:
> 
> Running tcpdump on the primary node like so:
> tcpdump -np -s 1600 udp port 2049
> gives some interesting info, especially when I retry mounting by the virtual 
> ip from the nfs client. It looks like the server accepts the connection on the 
> virtual ip (i.e. eth0:0) but nfsd on port 2049 replies using the primary 
> interface ip (i.e. eth0). The client doesn't like the reply from different 
> host I guess therefore timing out.

Could you try the following patch and let me know if it helps?
Thanks.

NeilBrown


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svc.h |    2 ++
 ./net/sunrpc/svcsock.c       |   18 ++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-08-17 20:25:23.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-08-17 20:26:34.000000000 +1000
@@ -112,6 +112,8 @@ struct svc_rqst {
 				rq_secure  : 1,	/* secure port */
 				rq_auth    : 1;	/* check client */
 
+	__u32			rq_daddr;	/* dest addr of request - reply from here */
+
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
 

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-08-13 10:04:08.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-08-17 21:01:56.000000000 +1000
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
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
