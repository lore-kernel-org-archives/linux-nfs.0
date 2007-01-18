From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/13] SUNRPC: Make rq_daddr field address-version
	independent
Date: Thu, 18 Jan 2007 18:50:47 -0500
Message-ID: <20070118235047.24266.66730.stgit@localhost.localdomain>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h1z-000571-5A
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:55 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h20-0000LC-OQ
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:57 -0800
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

The rq_daddr field must support larger addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 include/linux/sunrpc/svc.h |   14 ++++++++++----
 net/sunrpc/svcsock.c       |    4 ++--
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index bdd1f0a..7ba9dda 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -11,6 +11,7 @@ #ifndef SUNRPC_SVC_H
 #define SUNRPC_SVC_H
 
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/auth.h>
@@ -188,7 +189,13 @@ static inline void svc_putu32(struct kve
 	iov->iov_len += sizeof(__be32);
 }
 
-	
+union svc_addr_u {
+    struct in_addr	addr;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+    struct in6_addr	addr6;
+#endif
+};
+
 /*
  * The context of a single thread, including the request currently being
  * processed.
@@ -224,8 +231,7 @@ struct svc_rqst {
 	unsigned short
 				rq_secure  : 1;	/* secure port */
 
-
-	__be32			rq_daddr;	/* dest addr of request - reply from here */
+	union svc_addr_u	rq_daddr;	/* dest addr of request - reply from here */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
@@ -305,7 +311,7 @@ struct svc_deferred_req {
 	struct svc_sock		*svsk;
 	struct sockaddr_storage	addr;	/* where reply must go */
 	size_t			addrlen;
-	__be32			daddr;	/* where reply must come from */
+	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	int			argslen;
 	__be32			args[0];
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 140ff37..39d8078 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -476,7 +476,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		cmh->cmsg_level = SOL_IP;
 		cmh->cmsg_type = IP_PKTINFO;
 		pki->ipi_ifindex = 0;
-		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr;
+		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
 
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;
@@ -750,7 +750,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addrlen = sizeof(struct sockaddr_in);
 
 	/* Remember which interface received this request */
-	rqstp->rq_daddr = skb->nh.iph->daddr;
+	rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
