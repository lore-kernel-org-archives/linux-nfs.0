From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] SUNRPC: Make address format buffers more generic
Date: Wed, 25 Oct 2006 12:47:17 -0400
Message-ID: <20061025164717.6410.91272.stgit@localhost.localdomain>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcrQw-0006Vm-1R
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:41:14 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcrQw-0003pG-Rp
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:41:15 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061025164602.6410.27449.stgit@localhost.localdomain>
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

For now we will assume that all transports will use the address format
buffers in the rpc_xprt struct to store their addresses.  Change
rpc_peer2str() to be a generic routine to handle this, and get rid of the
print_address() op in the rpc_xprt_ops vector.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    1 -
 net/sunrpc/clnt.c           |    6 +++++-
 net/sunrpc/xprtsock.c       |   23 ++++-------------------
 3 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 17f3227..f780e72 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -106,7 +106,6 @@ #define rq_slen			rq_snd_buf.len
 
 struct rpc_xprt_ops {
 	void		(*set_buffer_size)(struct rpc_xprt *xprt, size_t sndsize, size_t rcvsize);
-	char *		(*print_addr)(struct rpc_xprt *xprt, enum rpc_display_format_t format);
 	int		(*reserve_xprt)(struct rpc_task *task);
 	void		(*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*rpcbind)(struct rpc_task *task);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 78696f2..1a07fe9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -582,7 +582,11 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr);
 char *rpc_peeraddr2str(struct rpc_clnt *clnt, enum rpc_display_format_t format)
 {
 	struct rpc_xprt *xprt = clnt->cl_xprt;
-	return xprt->ops->print_addr(xprt, format);
+
+	if (xprt->address_strings[format] != NULL)
+		return xprt->address_strings[format];
+	else
+		return "unprintable";
 }
 EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 05e051a..781c58b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1068,19 +1068,6 @@ static unsigned short xs_get_random_port
 }
 
 /**
- * xs_print_peer_address - format an IPv4 address for printing
- * @xprt: generic transport
- * @format: flags field indicating which parts of the address to render
- */
-static char *xs_print_peer_address(struct rpc_xprt *xprt, enum rpc_display_format_t format)
-{
-	if (xprt->address_strings[format] != NULL)
-		return xprt->address_strings[format];
-	else
-		return "unprintable";
-}
-
-/**
  * xs_set_port - reset the port number in the remote endpoint address
  * @xprt: generic transport
  * @port: new port number
@@ -1153,7 +1140,7 @@ static void xs_udp_connect_worker(void *
 	}
 
 	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
-			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	if (!sx->inet) {
 		struct sock *sk = sock->sk;
@@ -1240,7 +1227,7 @@ static void xs_tcp_connect_worker(void *
 		xs_tcp_reuse_connection(xprt);
 
 	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
-			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	if (!sx->inet) {
 		struct sock *sk = sock->sk;
@@ -1387,7 +1374,6 @@ static void xs_tcp_print_stats(struct rp
 
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
-	.print_addr		= xs_print_peer_address,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.rpcbind		= rpc_getport,
@@ -1405,7 +1391,6 @@ static struct rpc_xprt_ops xs_udp_ops = 
 };
 
 static struct rpc_xprt_ops xs_tcp_ops = {
-	.print_addr		= xs_print_peer_address,
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpc_getport,
@@ -1492,7 +1477,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
 
 	xs_format_peer_addresses(xprt);
 	dprintk("RPC:      set up transport to address %s\n",
-			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+			xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	return xprt;
 }
@@ -1536,7 +1521,7 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 
 	xs_format_peer_addresses(xprt);
 	dprintk("RPC:      set up transport to address %s\n",
-			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+			xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	return xprt;
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
