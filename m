From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 11/25] SUNRPC: add xprt switch API for printing
	formatted remote peer addresses
Date: Wed, 09 Aug 2006 10:59:16 -0400
Message-ID: <20060809145916.3914.35845.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcW-0000pz-GE
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:21 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003Hx-NM
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:21 -0700
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

Add a new method to the transport switch API to provide a way to convert
the opaque contents of xprt->addr to a human-readable string.

Test plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |   11 +++++++
 net/sunrpc/xprtsock.c       |   72 ++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 75 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 2c4d6c8..299613b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -51,6 +51,14 @@ struct rpc_timeout {
 	unsigned char		to_exponential;
 };
 
+enum rpc_display_format_t {
+	RPC_DISPLAY_ADDR = 0,
+	RPC_DISPLAY_PORT,
+	RPC_DISPLAY_PROTO,
+	RPC_DISPLAY_ALL,
+	RPC_DISPLAY_MAX,
+};
+
 struct rpc_task;
 struct rpc_xprt;
 struct seq_file;
@@ -103,6 +111,7 @@ #define rq_slen			rq_snd_buf.len
 
 struct rpc_xprt_ops {
 	void		(*set_buffer_size)(struct rpc_xprt *xprt, size_t sndsize, size_t rcvsize);
+	char *		(*print_addr)(struct rpc_xprt *xprt, enum rpc_display_format_t format);
 	int		(*reserve_xprt)(struct rpc_task *task);
 	void		(*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*rpcbind)(struct rpc_task *task);
@@ -207,6 +216,8 @@ struct rpc_xprt {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
+
+	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
 #define XPRT_LAST_FRAG		(1 << 0)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 159d591..692be74 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -125,6 +125,41 @@ static inline void xs_pktdump(char *msg,
 }
 #endif
 
+static void xs_format_peer_addresses(struct rpc_xprt *xprt)
+{
+	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+	char *buf;
+
+	buf = kzalloc(20, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 20, "%u.%u.%u.%u",
+				NIPQUAD(addr->sin_addr.s_addr));
+	}
+	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+		
+
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 8, "%u",
+				ntohs(addr->sin_port));
+	}
+	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+
+	if (xprt->prot == IPPROTO_UDP)
+		xprt->address_strings[RPC_DISPLAY_PROTO] = "udp";
+	else
+		xprt->address_strings[RPC_DISPLAY_PROTO] = "tcp";
+
+	buf = kzalloc(48, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 48, "addr=%u.%u.%u.%u port=%u proto=%s",
+			NIPQUAD(addr->sin_addr.s_addr),
+			ntohs(addr->sin_port),
+			xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+	}
+	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+}
+
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
 static inline int xs_send_head(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, unsigned int len)
@@ -965,6 +1000,19 @@ static unsigned short xs_get_random_port
 }
 
 /**
+ * xs_print_peer_address - format an IPv4 address for printing
+ * @xprt: generic transport
+ * @format: flags field indicating which parts of the address to render
+ */
+static char *xs_print_peer_address(struct rpc_xprt *xprt, enum rpc_display_format_t format)
+{
+	if (xprt->address_strings[format] != NULL)
+		return xprt->address_strings[format];
+	else
+		return "unprintable";
+}
+
+/**
  * xs_set_port - reset the port number in the remote endpoint address
  * @xprt: generic transport
  * @port: new port number
@@ -1021,8 +1069,6 @@ static void xs_udp_connect_worker(void *
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
-	dprintk("RPC:      xs_udp_connect_worker for xprt %p\n", xprt);
-
 	/* Start by resetting any existing state */
 	xs_close(xprt);
 
@@ -1036,6 +1082,9 @@ static void xs_udp_connect_worker(void *
 		goto out;
 	}
 
+	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
+			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+
 	if (!xprt->inet) {
 		struct sock *sk = sock->sk;
 
@@ -1104,8 +1153,6 @@ static void xs_tcp_connect_worker(void *
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
-	dprintk("RPC:      xs_tcp_connect_worker for xprt %p\n", xprt);
-
 	if (!xprt->sock) {
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
@@ -1121,6 +1168,9 @@ static void xs_tcp_connect_worker(void *
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
+	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
+			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+
 	if (!xprt->inet) {
 		struct sock *sk = sock->sk;
 
@@ -1262,6 +1312,7 @@ static void xs_tcp_print_stats(struct rp
 
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
+	.print_addr		= xs_print_peer_address,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.rpcbind		= rpc_getport,
@@ -1279,6 +1330,7 @@ static struct rpc_xprt_ops xs_udp_ops = 
 };
 
 static struct rpc_xprt_ops xs_tcp_ops = {
+	.print_addr		= xs_print_peer_address,
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpc_getport,
@@ -1303,8 +1355,6 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 {
 	size_t slot_table_size;
 
-	dprintk("RPC:      setting up udp-ipv4 transport...\n");
-
 	xprt->max_reqs = xprt_udp_slot_table_entries;
 	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
 	xprt->slot = kzalloc(slot_table_size, GFP_KERNEL);
@@ -1334,6 +1384,10 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 	else
 		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
 
+	xs_format_peer_addresses(xprt);
+	dprintk("RPC:      set up transport to address %s\n",
+			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+
 	return 0;
 }
 
@@ -1347,8 +1401,6 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 {
 	size_t slot_table_size;
 
-	dprintk("RPC:      setting up tcp-ipv4 transport...\n");
-
 	xprt->max_reqs = xprt_tcp_slot_table_entries;
 	slot_table_size = xprt->max_reqs * sizeof(xprt->slot[0]);
 	xprt->slot = kzalloc(slot_table_size, GFP_KERNEL);
@@ -1377,5 +1429,9 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 	else
 		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
 
+	xs_format_peer_addresses(xprt);
+	dprintk("RPC:      set up transport to address %s\n",
+			xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
+
 	return 0;
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
