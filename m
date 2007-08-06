From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/20] SUNRPC: Add IPv6 address support
	to	net/sunrpc/xprtsock.c
Date: Mon, 06 Aug 2007 11:57:53 -0400
Message-ID: <20070806155753.31233.82962.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4y2-00014H-I6
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:02 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4y4-0002Q8-FD
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:06 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Finalize support for setting up RPC client transports to remote RPC
services addressed via IPv6.

Based on work done by Gilles Quillard at Bull Open Source.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |   57 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 391b88d..fb55c1c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -13,6 +13,9 @@
  *  (C) 1999 Trond Myklebust <trond.myklebust@fys.uio.no>
  *
  * IP socket transport implementation, (C) 2005 Chuck Lever <cel@netapp.com>
+ *
+ * IPv6 support contributed by Gilles Quillard, Bull Open Source, 2005.
+ *   <gilles.quillard@bull.net>
  */
 
 #include <linux/types.h>
@@ -1790,6 +1793,7 @@ static struct rpc_xprt *xs_setup_xprt(struct rpc_xprtsock_create *args, unsigned
  */
 struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 {
+	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 
@@ -1798,15 +1802,11 @@ struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 		return xprt;
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
-	if (ntohs(((struct sockaddr_in *)args->dstaddr)->sin_port) != 0)
-		xprt_set_bound(xprt);
-
 	xprt->prot = IPPROTO_UDP;
 	xprt->tsh_size = 0;
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
-	INIT_DELAYED_WORK(&transport->connect_worker, xs_udp_connect_worker4);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
 	xprt->reestablish_timeout = XS_UDP_REEST_TO;
@@ -1819,7 +1819,28 @@ struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 	else
 		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
 
-	xs_format_ipv4_peer_addresses(xprt);
+	switch (addr->sa_family) {
+	case AF_INET:
+		if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_udp_connect_worker4);
+		xs_format_ipv4_peer_addresses(xprt);
+		break;
+	case AF_INET6:
+		if (ntohs(((struct sockaddr_in6 *)addr)->sin6_port) != 0)
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_udp_connect_worker6);
+		xs_format_ipv6_peer_addresses(xprt);
+		break;
+	default:
+		kfree(xprt);
+		return NULL;
+	}
+
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1833,6 +1854,7 @@ struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
  */
 struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 {
+	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 
@@ -1841,14 +1863,10 @@ struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 		return xprt;
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
-	if (ntohs(((struct sockaddr_in *)args->dstaddr)->sin_port) != 0)
-		xprt_set_bound(xprt);
-
 	xprt->prot = IPPROTO_TCP;
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_TCP_CONN_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
@@ -1861,7 +1879,26 @@ struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 	else
 		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
 
-	xs_format_ipv4_peer_addresses(xprt);
+	switch (addr->sa_family) {
+	case AF_INET:
+		if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
+		xs_format_ipv4_peer_addresses(xprt);
+		break;
+	case AF_INET6:
+		if (ntohs(((struct sockaddr_in6 *)addr)->sin6_port) != 0)
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
+		xs_format_ipv6_peer_addresses(xprt);
+		break;
+	default:
+		kfree(xprt);
+		return NULL;
+	}
+
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
