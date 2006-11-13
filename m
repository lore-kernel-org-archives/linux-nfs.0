From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/13] SUNRPC: teach svc_sendto() to deal with IPv6
	addresses
Date: Mon, 13 Nov 2006 07:58:28 -0500
Message-ID: <20061113125828.4435.87540.stgit@localhost.localdomain>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjdfZ-0004EO-KJ
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:24:21 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gjdfa-0005qn-G8
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:24:22 -0800
To: neilb@suse.de
In-Reply-To: <20061113125640.4435.11957.stgit@localhost.localdomain>
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

 net/sunrpc/svcsock.c |   69 ++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index cced146..e8a9379 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -35,6 +35,7 @@ #include <linux/file.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -408,6 +409,47 @@ svc_wake_up(struct svc_serv *serv)
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
+			struct in_pktinfo *pki =
+					(struct in_pktinfo *) CMSG_DATA(cmh);
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
+			struct in6_pktinfo *pki =
+					(struct in6_pktinfo *) CMSG_DATA(cmh);
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
@@ -417,9 +459,8 @@ svc_sendto(struct svc_rqst *rqstp, struc
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
@@ -432,21 +473,15 @@ svc_sendto(struct svc_rqst *rqstp, struc
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
