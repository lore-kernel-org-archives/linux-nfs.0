From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] SUNRPC: Make the transport-specific setup
	routine allocate rpc_xprt
Date: Tue, 17 Oct 2006 14:44:27 -0400
Message-ID: <20061017184427.25704.38797.stgit@schiele.dsl.sfldmi.ameritech.net>
References: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZtvq-0000KB-8p
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:54 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZtvm-00078b-Mm
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:55 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
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

Change the location where the rpc_xprt structure is allocated so each
transport implementation can allocate a private area from the same
chunk of memory.

Note also that xprt->ops->destroy, rather than xprt_destroy, is now
responsible for freeing rpc_xprt when the transport is destroyed.

Test plan:
Connectathon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    4 +-
 net/sunrpc/xprt.c           |   31 ++++++------------
 net/sunrpc/xprtsock.c       |   73 +++++++++++++++++++++++++++++--------------
 3 files changed, 61 insertions(+), 47 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 0321fb5..d791901 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -265,8 +265,8 @@ void			xprt_disconnect(struct rpc_xprt *
 /*
  * Socket transport setup operations
  */
-int			xs_setup_udp(struct rpc_xprt *xprt, struct rpc_timeout *to);
-int			xs_setup_tcp(struct rpc_xprt *xprt, struct rpc_timeout *to);
+struct rpc_xprt *	xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
+struct rpc_xprt *	xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8085747..8cc2afa 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -891,39 +891,25 @@ void xprt_set_timeout(struct rpc_timeout
  */
 struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t size, struct rpc_timeout *to)
 {
-	int result;
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
 
-	if ((xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL)) == NULL) {
-		dprintk("RPC:      xprt_create_transport: no memory\n");
-		return ERR_PTR(-ENOMEM);
-	}
-	if (size <= sizeof(xprt->addr)) {
-		memcpy(&xprt->addr, ap, size);
-		xprt->addrlen = size;
-	} else {
-		kfree(xprt);
-		dprintk("RPC:      xprt_create_transport: address too large\n");
-		return ERR_PTR(-EBADF);
-	}
-
 	switch (proto) {
 	case IPPROTO_UDP:
-		result = xs_setup_udp(xprt, to);
+		xprt = xs_setup_udp(ap, size, to);
 		break;
 	case IPPROTO_TCP:
-		result = xs_setup_tcp(xprt, to);
+		xprt = xs_setup_tcp(ap, size, to);
 		break;
 	default:
 		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
 				proto);
 		return ERR_PTR(-EIO);
 	}
-	if (result) {
-		kfree(xprt);
-		dprintk("RPC:      xprt_create_transport: failed, %d\n", result);
-		return ERR_PTR(result);
+	if (IS_ERR(xprt)) {
+		dprintk("RPC:      xprt_create_transport: failed, %ld\n",
+				-PTR_ERR(xprt));
+		return xprt;
 	}
 
 	kref_init(&xprt->kref);
@@ -969,8 +955,11 @@ static void xprt_destroy(struct kref *kr
 	dprintk("RPC:      destroying transport %p\n", xprt);
 	xprt->shutdown = 1;
 	del_timer_sync(&xprt->timer);
+
+	/*
+	 * Tear down transport state and free the rpc_xprt
+	 */
 	xprt->ops->destroy(xprt);
-	kfree(xprt);
 }
 
 /**
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 757fc91..a6f778f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -528,6 +528,7 @@ static void xs_destroy(struct rpc_xprt *
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
 	kfree(xprt->slot);
+	kfree(xprt);
 }
 
 static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
@@ -1349,26 +1350,53 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 	.print_stats		= xs_tcp_print_stats,
 };
 
+static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
+{
+	struct rpc_xprt *xprt;
+
+	if (addrlen > sizeof(xprt->addr)) {
+		dprintk("RPC:      xs_setup_xprt: address too large\n");
+		return ERR_PTR(-EBADF);
+	}
+
+	xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL);
+	if (xprt == NULL) {
+		dprintk("RPC:      xs_setup_xprt: couldn't allocate rpc_xprt\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	xprt->max_reqs = slot_table_size;
+	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
+	if (xprt->slot == NULL) {
+		kfree(xprt);
+		dprintk("RPC:      xs_setup_xprt: couldn't allocate slot table\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	memcpy(&xprt->addr, addr, addrlen);
+	xprt->addrlen = addrlen;
+	xprt->port = xs_get_random_port();
+
+	return xprt;
+}
+
 /**
  * xs_setup_udp - Set up transport to use a UDP socket
- * @xprt: transport to set up
+ * @addr: address of remote server
+ * @addrlen: length of address in bytes
  * @to:   timeout parameters
  *
  */
-int xs_setup_udp(struct rpc_xprt *xprt, struct rpc_timeout *to)
+struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
-	size_t slot_table_size;
-	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+	struct rpc_xprt *xprt;
 
-	xprt->max_reqs = xprt_udp_slot_table_entries;
-	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
-	xprt->slot = kzalloc(slot_table_size, GFP_KERNEL);
-	if (xprt->slot == NULL)
-		return -ENOMEM;
+	xprt = xs_setup_xprt(addr, addrlen, xprt_udp_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
 
-	if (ntohs(addr->sin_port) != 0)
+	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
-	xprt->port = xs_get_random_port();
 
 	xprt->prot = IPPROTO_UDP;
 	xprt->tsh_size = 0;
@@ -1392,29 +1420,26 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 	dprintk("RPC:      set up transport to address %s\n",
 			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
 
-	return 0;
+	return xprt;
 }
 
 /**
  * xs_setup_tcp - Set up transport to use a TCP socket
- * @xprt: transport to set up
+ * @addr: address of remote server
+ * @addrlen: length of address in bytes
  * @to: timeout parameters
  *
  */
-int xs_setup_tcp(struct rpc_xprt *xprt, struct rpc_timeout *to)
+struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
-	size_t slot_table_size;
-	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+	struct rpc_xprt *xprt;
 
-	xprt->max_reqs = xprt_tcp_slot_table_entries;
-	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
-	xprt->slot = kzalloc(slot_table_size, GFP_KERNEL);
-	if (xprt->slot == NULL)
-		return -ENOMEM;
+	xprt = xs_setup_xprt(addr, addrlen, xprt_tcp_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
 
-	if (ntohs(addr->sin_port) != 0)
+	if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
 		xprt_set_bound(xprt);
-	xprt->port = xs_get_random_port();
 
 	xprt->prot = IPPROTO_TCP;
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
@@ -1437,5 +1462,5 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 	dprintk("RPC:      set up transport to address %s\n",
 			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
 
-	return 0;
+	return xprt;
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
