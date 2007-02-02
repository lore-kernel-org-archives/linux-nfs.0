From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 14] knfsd: SUNRPC: Make rq_daddr field
	address-version independent
Date: Fri, 2 Feb 2007 15:40:24 +1100
Message-ID: <1070202044024.19089@suse.de>
References: <20070202153531.18622.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCqHG-00080p-7n
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:43:59 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCqEF-0007aX-V1
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:40:52 -0800
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


From: Chuck Lever <chuck.lever@oracle.com>
The rq_daddr field must support larger addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |   15 +++++++++++----
 ./net/sunrpc/svcsock.c       |    4 ++--
 2 files changed, 13 insertions(+), 6 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2007-02-02 15:22:32.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2007-02-02 15:22:32.000000000 +1100
@@ -11,6 +11,7 @@
 #define SUNRPC_SVC_H
 
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/auth.h>
@@ -191,7 +192,13 @@ static inline void svc_putu32(struct kve
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
@@ -227,8 +234,8 @@ struct svc_rqst {
 	unsigned short
 				rq_secure  : 1;	/* secure port */
 
-
-	__be32			rq_daddr;	/* dest addr of request - reply from here */
+	union svc_addr_u	rq_daddr;	/* dest addr of request
+						 *  - reply from here */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
@@ -308,7 +315,7 @@ struct svc_deferred_req {
 	struct svc_sock		*svsk;
 	struct sockaddr_storage	addr;	/* where reply must go */
 	size_t			addrlen;
-	__be32			daddr;	/* where reply must come from */
+	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	int			argslen;
 	__be32			args[0];

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-02-02 15:22:32.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-02-02 15:22:32.000000000 +1100
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
