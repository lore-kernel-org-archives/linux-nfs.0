From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/20] SUNRPC: Add a helper for extracting the address
	using	the correct type
Date: Mon, 06 Aug 2007 11:57:58 -0400
Message-ID: <20070806155758.31233.92152.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4y7-00018w-Lo
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:07 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4yB-0006PP-LF
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:58:11 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fb55c1c..24a8348 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -263,9 +263,24 @@ struct sock_xprt {
 #define TCP_RCV_COPY_XID	(1UL << 2)
 #define TCP_RCV_COPY_DATA	(1UL << 3)
 
+static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr *) &xprt->addr;
+}
+
+static inline struct sockaddr_in *xs_addr_in(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr_in *) &xprt->addr;
+}
+
+static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr_in6 *) &xprt->addr;
+}
+
 static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 {
-	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+	struct sockaddr_in *addr = xs_addr_in(xprt);
 	char *buf;
 
 	buf = kzalloc(20, GFP_KERNEL);
@@ -317,7 +332,7 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
 {
-	struct sockaddr_in6 *addr = (struct sockaddr_in6 *) &xprt->addr;
+	struct sockaddr_in6 *addr = xs_addr_in6(xprt);
 	char *buf;
 
 	buf = kzalloc(40, GFP_KERNEL);
@@ -547,7 +562,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 
 	req->rq_xtime = jiffies;
 	status = xs_sendpages(transport->sock,
-			      (struct sockaddr *) &xprt->addr,
+			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
 			      req->rq_bytes_sent);
 
@@ -1224,7 +1239,7 @@ static unsigned short xs_get_random_port(void)
  */
 static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 {
-	struct sockaddr *addr = (struct sockaddr *) &xprt->addr;
+	struct sockaddr *addr = xs_addr(xprt);
 
 	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
 
@@ -1507,8 +1522,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
-	return kernel_connect(sock, (struct sockaddr *) &xprt->addr,
-			xprt->addrlen, O_NONBLOCK);
+	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
 }
 
 /**


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
