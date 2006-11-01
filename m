From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/12] SUNRPC: Make rq_daddr field address-version
	independent
Date: Wed, 01 Nov 2006 13:08:41 -0500
Message-ID: <20061101180841.14581.35194.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfKWD-0006Ge-KA
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:53 -0800
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfKWC-0002md-Sw
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:54 -0800
To: neilb@suse.de
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
index fb9768a..ae51e53 100644
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
@@ -292,7 +298,7 @@ struct svc_deferred_req {
 	struct sockaddr_storage	addr;
 	int			addrlen;
 	struct svc_sock		*svsk;	/* where reply must go */
-	__be32			daddr;	/* where reply must come from */
+	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	int			argslen;
 	__be32			args[0];
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f506780..b0fb46f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -446,7 +446,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		cmh->cmsg_level = SOL_IP;
 		cmh->cmsg_type = IP_PKTINFO;
 		pki->ipi_ifindex = 0;
-		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr;
+		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
 
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;
@@ -718,7 +718,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	sin->sin_family = AF_INET;
 	sin->sin_port = skb->h.uh->source;
 	sin->sin_addr.s_addr = skb->nh.iph->saddr;
-	rqstp->rq_daddr = skb->nh.iph->daddr;
+	rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
