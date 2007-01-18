From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/13] SUNRPC: teach svc_sendto() to deal with IPv6
	addresses
Date: Thu, 18 Jan 2007 18:50:51 -0500
Message-ID: <20070118235051.24266.69797.stgit@localhost.localdomain>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h21-00057P-M9
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:57 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h23-0001B2-6O
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:59 -0800
To: neilb@suse.de
In-Reply-To: <20070118234855.24266.37463.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

CMSG_DATA comes in different sizes, depending on address family.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/svcsock.c |   67 +++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 50 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 39d8078..4989701 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -36,6 +36,7 @@ #include <linux/freezer.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -438,6 +439,45 @@ svc_wake_up(struct svc_serv *serv)
 	}
 }
 
+union svc_pktinfo_u {
+	struct in_pktinfo pkti;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct in6_pktinfo pkti6;
+#endif
+};
+
+static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
+{
+	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	case AF_INET:
+		do {
+			struct in_pktinfo *pki = CMSG_DATA(cmh);
+
+			cmh->cmsg_level = SOL_IP;
+			cmh->cmsg_type = IP_PKTINFO;
+			pki->ipi_ifindex = 0;
+			pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
+			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
+		} while (0);
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		do {
+			struct in6_pktinfo *pki = CMSG_DATA(cmh);
+
+			cmh->cmsg_level = SOL_IPV6;
+			cmh->cmsg_type = IPV6_PKTINFO;
+			pki->ipi6_ifindex = 0;
+			ipv6_addr_copy(&pki->ipi6_addr,
+					&rqstp->rq_daddr.addr6);
+			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
+		} while (0);
+		break;
+#endif
+	}
+	return;
+}
+
 /*
  * Generic sendto routine
  */
@@ -447,9 +487,8 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
-	char 		buffer[CMSG_SPACE(sizeof(struct in_pktinfo))];
+	char 		buffer[CMSG_SPACE(sizeof(union svc_pktinfo_u))];
 	struct cmsghdr *cmh = (struct cmsghdr *)buffer;
-	struct in_pktinfo *pki = (struct in_pktinfo *)CMSG_DATA(cmh);
 	int		len = 0;
 	int		result;
 	int		size;
@@ -462,21 +501,15 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	slen = xdr->len;
 
 	if (rqstp->rq_prot == IPPROTO_UDP) {
-		/* set the source and destination */
-		struct msghdr	msg;
-		msg.msg_name    = &rqstp->rq_addr;
-		msg.msg_namelen = rqstp->rq_addrlen;
-		msg.msg_iov     = NULL;
-		msg.msg_iovlen  = 0;
-		msg.msg_flags	= MSG_MORE;
-
-		msg.msg_control = cmh;
-		msg.msg_controllen = sizeof(buffer);
-		cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
-		cmh->cmsg_level = SOL_IP;
-		cmh->cmsg_type = IP_PKTINFO;
-		pki->ipi_ifindex = 0;
-		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
+		struct msghdr msg = {
+			.msg_name	= &rqstp->rq_addr,
+			.msg_namelen	= rqstp->rq_addrlen,
+			.msg_control	= cmh,
+			.msg_controllen	= sizeof(buffer),
+			.msg_flags	= MSG_MORE,
+		};
+
+		svc_set_cmsg_data(rqstp, cmh);
 
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
