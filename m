From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 14/25] SUNRPC: Use "sockaddr_storage" for storing RPC
	client's remote peer address
Date: Wed, 09 Aug 2006 10:59:24 -0400
Message-ID: <20060809145923.3914.2604.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000os-M1
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003Gk-5q
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

IPv6 addresses are big (128 bytes).  Now that no RPC client consumers treat
the addr field in rpc_xprt structs as an opaque, and access it only via the
API calls, we can safely widen the field in the rpc_xprt struct to
accomodate larger addresses.

Test plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    3 ++-
 net/sunrpc/clnt.c           |    2 +-
 net/sunrpc/xprt.c           |    3 ++-
 net/sunrpc/xprtsock.c       |   15 ++++++++++-----
 4 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 299613b..2cbd689 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -134,7 +134,8 @@ struct rpc_xprt {
 	struct sock *		inet;		/* INET layer */
 
 	struct rpc_timeout	timeout;	/* timeout parms */
-	struct sockaddr_in	addr;		/* server address */
+	struct sockaddr_storage	addr;		/* server address */
+	size_t			addrlen;	/* size of server address */
 	int			prot;		/* IP protocol */
 
 	unsigned long		cong;		/* current congestion */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8f21e47..742cb1e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -553,7 +553,7 @@ size_t rpc_peeraddr(struct rpc_clnt *cln
 	if (bytes > bufsize)
 		bytes = bufsize;
 	memcpy(buf, &clnt->cl_xprt->addr, bytes);
-	return sizeof(xprt->addr);
+	return xprt->addrlen;
 }
 EXPORT_SYMBOL(rpc_peeraddr);
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e35444e..dcc0bd7 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -900,7 +900,8 @@ static struct rpc_xprt *xprt_setup(int p
 	if ((xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL)) == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	xprt->addr = *ap;
+	memcpy(&xprt->addr, ap, sizeof(*ap));
+	xprt->addrlen = sizeof(*ap);
 
 	switch (proto) {
 	case IPPROTO_UDP:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 692be74..ababfe9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -335,7 +335,7 @@ static int xs_udp_send_request(struct rp
 
 	req->rq_xtime = jiffies;
 	status = xs_sendpages(xprt->sock, (struct sockaddr *) &xprt->addr,
-				sizeof(xprt->addr), xdr, req->rq_bytes_sent);
+				xprt->addrlen, xdr, req->rq_bytes_sent);
 
 	dprintk("RPC:      xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
@@ -1020,8 +1020,11 @@ static char *xs_print_peer_address(struc
  */
 static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 {
+	struct sockaddr_in *sap = (struct sockaddr_in *) &xprt->addr;
+
 	dprintk("RPC:      setting port for xprt %p to %u\n", xprt, port);
-	xprt->addr.sin_port = htons(port);
+
+	sap->sin_port = htons(port);
 	if (port != 0)
 		xprt_set_bound(xprt);
 }
@@ -1204,7 +1207,7 @@ static void xs_tcp_connect_worker(void *
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
 	status = sock->ops->connect(sock, (struct sockaddr *) &xprt->addr,
-			sizeof(xprt->addr), O_NONBLOCK);
+			xprt->addrlen, O_NONBLOCK);
 	dprintk("RPC: %p  connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
 	if (status < 0) {
@@ -1354,6 +1357,7 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 int xs_setup_udp(struct rpc_xprt *xprt, struct rpc_timeout *to)
 {
 	size_t slot_table_size;
+	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
 
 	xprt->max_reqs = xprt_udp_slot_table_entries;
 	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
@@ -1361,7 +1365,7 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 	if (xprt->slot == NULL)
 		return -ENOMEM;
 
-	if (ntohs(xprt->addr.sin_port) != 0)
+	if (ntohs(addr->sin_port != 0))
 		xprt_set_bound(xprt);
 	xprt->port = xs_get_random_port();
 
@@ -1400,6 +1404,7 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 int xs_setup_tcp(struct rpc_xprt *xprt, struct rpc_timeout *to)
 {
 	size_t slot_table_size;
+	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
 
 	xprt->max_reqs = xprt_tcp_slot_table_entries;
 	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
@@ -1407,7 +1412,7 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 	if (xprt->slot == NULL)
 		return -ENOMEM;
 
-	if (ntohs(xprt->addr.sin_port) != 0)
+	if (ntohs(addr->sin_port) != 0)
 		xprt_set_bound(xprt);
 	xprt->port = xs_get_random_port();
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
