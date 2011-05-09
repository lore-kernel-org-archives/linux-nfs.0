Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52263 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab1EITWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:22:49 -0400
Received: by gxk21 with SMTP id 21so1936764gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:22:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] SUNRPC: Support for RPC over AF_LOCAL transports
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:22:44 -0400
Message-ID: <20110509192244.16449.75609.stgit@matisse.1015granger.net>
In-Reply-To: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
References: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

TI-RPC introduces the capability of performing RPC over AF_LOCAL
sockets.  It uses this mainly for registering and unregistering
local RPC services securely with the local rpcbind, but we could
also conceivably use it as a generic upcall mechanism.

This patch provides a client-side only implementation for the moment.
We might also consider a server-side implementation to provide
AF_LOCAL access to NLM (for statd downcalls, and such like).

Autobinding is not supported on kernel AF_LOCAL transports at this
time.  Kernel ULPs must specify the pathname of the remote endpoint
when an AF_LOCAL transport is created.  rpcbind supports registering
services available via AF_LOCAL, so the kernel could handle it with
some adjustment to ->rpcbind and ->set_port.  But we don't need this
feature for doing upcalls via well-known named sockets.

This has not been tested with ULPs that move a substantial amount of
data.  Thus, I can't attest to how robust the write_space and
congestion management logic is.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/msg_prot.h |    1 
 include/linux/sunrpc/xprt.h     |    3 
 net/sunrpc/clnt.c               |    8 +
 net/sunrpc/xprtsock.c           |  395 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 403 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 77e6248..c68a147 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -145,6 +145,7 @@ typedef __be32	rpc_fraghdr;
 #define RPCBIND_NETID_TCP	"tcp"
 #define RPCBIND_NETID_UDP6	"udp6"
 #define RPCBIND_NETID_TCP6	"tcp6"
+#define RPCBIND_NETID_LOCAL	"local"
 
 /*
  * Note that RFC 1833 does not put any size restrictions on the
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a0f998c..81cce3b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -141,7 +141,8 @@ enum xprt_transports {
 	XPRT_TRANSPORT_UDP	= IPPROTO_UDP,
 	XPRT_TRANSPORT_TCP	= IPPROTO_TCP,
 	XPRT_TRANSPORT_BC_TCP	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
-	XPRT_TRANSPORT_RDMA	= 256
+	XPRT_TRANSPORT_RDMA	= 256,
+	XPRT_TRANSPORT_LOCAL	= 257,
 };
 
 struct rpc_xprt {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b91f8f9..c0b03df 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -32,7 +32,9 @@
 #include <linux/slab.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
+#include <linux/in.h>
 #include <linux/in6.h>
+#include <linux/un.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -298,6 +300,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * up a string representation of the passed-in address.
 	 */
 	if (args->servername == NULL) {
+		struct sockaddr_un *sun =
+				(struct sockaddr_un *)args->address;
 		struct sockaddr_in *sin =
 				(struct sockaddr_in *)args->address;
 		struct sockaddr_in6 *sin6 =
@@ -305,6 +309,10 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 
 		servername[0] = '\0';
 		switch (args->address->sa_family) {
+		case AF_LOCAL:
+			snprintf(servername, sizeof(servername), "%s",
+				 sun->sun_path);
+			break;
 		case AF_INET:
 			snprintf(servername, sizeof(servername), "%pI4",
 				 &sin->sin_addr.s_addr);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6d54d39..a546eec 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/capability.h>
@@ -28,6 +29,7 @@
 #include <linux/in.h>
 #include <linux/net.h>
 #include <linux/mm.h>
+#include <linux/un.h>
 #include <linux/udp.h>
 #include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
@@ -45,6 +47,9 @@
 #include <net/tcp.h>
 
 #include "sunrpc.h"
+
+static void xs_close(struct rpc_xprt *xprt);
+
 /*
  * xprtsock tunables
  */
@@ -261,6 +266,11 @@ static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
 	return (struct sockaddr *) &xprt->addr;
 }
 
+static inline struct sockaddr_un *xs_addr_un(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr_un *) &xprt->addr;
+}
+
 static inline struct sockaddr_in *xs_addr_in(struct rpc_xprt *xprt)
 {
 	return (struct sockaddr_in *) &xprt->addr;
@@ -276,23 +286,34 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 	struct sockaddr *sap = xs_addr(xprt);
 	struct sockaddr_in6 *sin6;
 	struct sockaddr_in *sin;
+	struct sockaddr_un *sun;
 	char buf[128];
 
-	(void)rpc_ntop(sap, buf, sizeof(buf));
-	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
-
 	switch (sap->sa_family) {
+	case AF_LOCAL:
+		sun = xs_addr_un(xprt);
+		strlcpy(buf, sun->sun_path, sizeof(buf));
+		xprt->address_strings[RPC_DISPLAY_ADDR] =
+						kstrdup(buf, GFP_KERNEL);
+		break;
 	case AF_INET:
+		(void)rpc_ntop(sap, buf, sizeof(buf));
+		xprt->address_strings[RPC_DISPLAY_ADDR] =
+						kstrdup(buf, GFP_KERNEL);
 		sin = xs_addr_in(xprt);
 		snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 		break;
 	case AF_INET6:
+		(void)rpc_ntop(sap, buf, sizeof(buf));
+		xprt->address_strings[RPC_DISPLAY_ADDR] =
+						kstrdup(buf, GFP_KERNEL);
 		sin6 = xs_addr_in6(xprt);
 		snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
 		break;
 	default:
 		BUG();
 	}
+
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 }
 
@@ -506,6 +527,60 @@ static inline void xs_encode_stream_record_marker(struct xdr_buf *buf)
 }
 
 /**
+ * xs_local_send_request - write an RPC request to an AF_LOCAL socket
+ * @task: RPC task that manages the state of an RPC request
+ *
+ * Return values:
+ *        0:	The request has been sent
+ *   EAGAIN:	The socket was blocked, please call again later to
+ *		complete the request
+ * ENOTCONN:	Caller needs to invoke connect logic then call again
+ *    other:	Some other error occured, the request was not sent
+ */
+static int xs_local_send_request(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	struct xdr_buf *xdr = &req->rq_snd_buf;
+	int status;
+
+	xs_encode_stream_record_marker(&req->rq_snd_buf);
+
+	xs_pktdump("packet data:",
+			req->rq_svec->iov_base, req->rq_svec->iov_len);
+
+	status = xs_sendpages(transport->sock, NULL, 0,
+						xdr, req->rq_bytes_sent);
+	dprintk("RPC:       %s(%u) = %d\n",
+			__func__, xdr->len - req->rq_bytes_sent, status);
+	if (likely(status >= 0)) {
+		req->rq_bytes_sent += status;
+		req->rq_xmit_bytes_sent += status;
+		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
+			req->rq_bytes_sent = 0;
+			return 0;
+		}
+		status = -EAGAIN;
+	}
+
+	switch (status) {
+	case -EAGAIN:
+		status = xs_nospace(task);
+		break;
+	default:
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
+			-status);
+	case -EPIPE:
+		xs_close(xprt);
+		status = -ENOTCONN;
+	}
+
+	return status;
+}
+
+/**
  * xs_udp_send_request - write an RPC request to a UDP socket
  * @task: address of RPC task that manages the state of an RPC request
  *
@@ -788,6 +863,88 @@ static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
 	return (struct rpc_xprt *) sk->sk_user_data;
 }
 
+static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
+{
+	struct xdr_skb_reader desc = {
+		.skb		= skb,
+		.offset		= sizeof(rpc_fraghdr),
+		.count		= skb->len - sizeof(rpc_fraghdr),
+	};
+
+	if (xdr_partial_copy_from_skb(xdr, 0, &desc, xdr_skb_read_bits) < 0)
+		return -1;
+	if (desc.count)
+		return -1;
+	return 0;
+}
+
+/**
+ * xs_local_data_ready - "data ready" callback for AF_LOCAL sockets
+ * @sk: socket with data to read
+ * @len: how much data to read
+ *
+ * Currently this assumes we can read the whole reply in a single gulp.
+ */
+static void xs_local_data_ready(struct sock *sk, int len)
+{
+	struct rpc_task *task;
+	struct rpc_xprt *xprt;
+	struct rpc_rqst *rovr;
+	struct sk_buff *skb;
+	int err, repsize, copied;
+	u32 _xid;
+	__be32 *xp;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	dprintk("RPC:       %s...\n", __func__);
+	xprt = xprt_from_sock(sk);
+	if (xprt == NULL)
+		goto out;
+
+	skb = skb_recv_datagram(sk, 0, 1, &err);
+	if (skb == NULL)
+		goto out;
+
+	if (xprt->shutdown)
+		goto dropit;
+
+	repsize = skb->len - sizeof(rpc_fraghdr);
+	if (repsize < 4) {
+		dprintk("RPC:       impossible RPC reply size %d\n", repsize);
+		goto dropit;
+	}
+
+	/* Copy the XID from the skb... */
+	xp = skb_header_pointer(skb, sizeof(rpc_fraghdr), sizeof(_xid), &_xid);
+	if (xp == NULL)
+		goto dropit;
+
+	/* Look up and lock the request corresponding to the given XID */
+	spin_lock(&xprt->transport_lock);
+	rovr = xprt_lookup_rqst(xprt, *xp);
+	if (!rovr)
+		goto out_unlock;
+	task = rovr->rq_task;
+
+	copied = rovr->rq_private_buf.buflen;
+	if (copied > repsize)
+		copied = repsize;
+
+	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
+		dprintk("RPC:       sk_buff copy failed\n");
+		goto out_unlock;
+	}
+
+	xprt_complete_rqst(task, copied);
+
+ out_unlock:
+	spin_unlock(&xprt->transport_lock);
+ dropit:
+	skb_free_datagram(sk, skb);
+ out:
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
 /**
  * xs_udp_data_ready - "data ready" callback for UDP sockets
  * @sk: socket with data to read
@@ -1574,11 +1731,31 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 	return err;
 }
 
+/*
+ * We don't support autobind on AF_LOCAL sockets
+ */
+static void xs_local_rpcbind(struct rpc_task *task)
+{
+	xprt_set_bound(task->tk_xprt);
+}
+
+static void xs_local_set_port(struct rpc_xprt *xprt, unsigned short port)
+{
+}
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key xs_key[2];
 static struct lock_class_key xs_slock_key[2];
 
+static inline void xs_reclassify_socketu(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	BUG_ON(sock_owned_by_user(sk));
+	sock_lock_init_class_and_name(sk, "slock-AF_LOCAL-RPC",
+		&xs_slock_key[1], "sk_lock-AF_LOCAL-RPC", &xs_key[1]);
+}
+
 static inline void xs_reclassify_socket4(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -1600,6 +1777,9 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
 	switch (family) {
+	case AF_LOCAL:
+		xs_reclassify_socketu(sock);
+		break;
 	case AF_INET:
 		xs_reclassify_socket4(sock);
 		break;
@@ -1609,6 +1789,10 @@ static inline void xs_reclassify_socket(int family, struct socket *sock)
 	}
 }
 #else
+static inline void xs_reclassify_socketu(struct socket *sock)
+{
+}
+
 static inline void xs_reclassify_socket4(struct socket *sock)
 {
 }
@@ -1647,6 +1831,94 @@ out:
 	return ERR_PTR(err);
 }
 
+static int xs_local_finish_connecting(struct rpc_xprt *xprt,
+				      struct socket *sock)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
+									xprt);
+
+	if (!transport->inet) {
+		struct sock *sk = sock->sk;
+
+		write_lock_bh(&sk->sk_callback_lock);
+
+		xs_save_old_callbacks(transport, sk);
+
+		sk->sk_user_data = xprt;
+		sk->sk_data_ready = xs_local_data_ready;
+		sk->sk_write_space = xs_udp_write_space;
+		sk->sk_error_report = xs_error_report;
+		sk->sk_allocation = GFP_ATOMIC;
+
+		xprt_clear_connected(xprt);
+
+		/* Reset to new socket */
+		transport->sock = sock;
+		transport->inet = sk;
+
+		write_unlock_bh(&sk->sk_callback_lock);
+	}
+
+	/* Tell the socket layer to start connecting... */
+	xprt->stat.connect_count++;
+	xprt->stat.connect_start = jiffies;
+	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, 0);
+}
+
+/**
+ * xs_local_setup_socket - create AF_LOCAL socket, connect to a local endpoint
+ * @xprt: RPC transport to connect
+ * @transport: socket transport to connect
+ * @create_sock: function to create a socket of the correct type
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_local_setup_socket(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock;
+	int status = -EIO;
+
+	if (xprt->shutdown)
+		goto out;
+
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	status = __sock_create(xprt->xprt_net, AF_LOCAL,
+					SOCK_STREAM, 0, &sock, 1);
+	if (status < 0) {
+		dprintk("RPC:       can't create AF_LOCAL "
+			"transport socket (%d).\n", -status);
+		goto out;
+	}
+	xs_reclassify_socketu(sock);
+
+	dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+
+	status = xs_local_finish_connecting(xprt, sock);
+	switch (status) {
+	case 0:
+		dprintk("RPC:       xprt %p connected to %s\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		xprt_set_connected(xprt);
+		break;
+	case -ENOENT:
+		dprintk("RPC:       xprt %p: socket %s does not exist\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		break;
+	default:
+		printk(KERN_ERR "%s: unhandled error (%d) connecting to %s\n",
+				__func__, -status,
+				xprt->address_strings[RPC_DISPLAY_ADDR]);
+	}
+
+out:
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+}
+
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1920,6 +2192,32 @@ static void xs_connect(struct rpc_task *task)
 }
 
 /**
+ * xs_local_print_stats - display AF_LOCAL socket-specifc stats
+ * @xprt: rpc_xprt struct containing statistics
+ * @seq: output file
+ *
+ */
+static void xs_local_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+{
+	long idle_time = 0;
+
+	if (xprt_connected(xprt))
+		idle_time = (long)(jiffies - xprt->last_used) / HZ;
+
+	seq_printf(seq, "\txprt:\tlocal %lu %lu %lu %ld %lu %lu %lu "
+			"%llu %llu\n",
+			xprt->stat.bind_count,
+			xprt->stat.connect_count,
+			xprt->stat.connect_time,
+			idle_time,
+			xprt->stat.sends,
+			xprt->stat.recvs,
+			xprt->stat.bad_xids,
+			xprt->stat.req_u,
+			xprt->stat.bklog_u);
+}
+
+/**
  * xs_udp_print_stats - display UDP socket-specifc stats
  * @xprt: rpc_xprt struct containing statistics
  * @seq: output file
@@ -2089,6 +2387,21 @@ static void bc_destroy(struct rpc_xprt *xprt)
 {
 }
 
+static struct rpc_xprt_ops xs_local_ops = {
+	.reserve_xprt		= xprt_reserve_xprt,
+	.release_xprt		= xs_tcp_release_xprt,
+	.rpcbind		= xs_local_rpcbind,
+	.set_port		= xs_local_set_port,
+	.connect		= xs_connect,
+	.buf_alloc		= rpc_malloc,
+	.buf_free		= rpc_free,
+	.send_request		= xs_local_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.close			= xs_close,
+	.destroy		= xs_destroy,
+	.print_stats		= xs_local_print_stats,
+};
+
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
@@ -2150,6 +2463,8 @@ static int xs_init_anyaddr(const int family, struct sockaddr *sap)
 	};
 
 	switch (family) {
+	case AF_LOCAL:
+		break;
 	case AF_INET:
 		memcpy(sap, &sin, sizeof(sin));
 		break;
@@ -2197,6 +2512,70 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	return xprt;
 }
 
+static const struct rpc_timeout xs_local_default_timeout = {
+	.to_initval = 10 * HZ,
+	.to_maxval = 10 * HZ,
+	.to_retries = 2,
+};
+
+/**
+ * xs_setup_local - Set up transport to use an AF_LOCAL socket
+ * @args: rpc transport creation arguments
+ *
+ * AF_LOCAL is a "tpi_cots_ord" transport, just like TCP
+ */
+static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
+{
+	struct sockaddr_un *sun = (struct sockaddr_un *)args->dstaddr;
+	struct sock_xprt *transport;
+	struct rpc_xprt *xprt;
+	struct rpc_xprt *ret;
+
+	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
+	xprt->prot = 0;
+	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
+	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
+
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->idle_timeout = XS_IDLE_DISC_TO;
+
+	xprt->ops = &xs_local_ops;
+	xprt->timeout = &xs_local_default_timeout;
+
+	switch (sun->sun_family) {
+	case AF_LOCAL:
+		if (sun->sun_path[0] != '/') {
+			dprintk("RPC:       bad AF_LOCAL address: %s\n",
+					sun->sun_path);
+			ret = ERR_PTR(-EINVAL);
+			goto out_err;
+		}
+		xprt_set_bound(xprt);
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_local_setup_socket);
+		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
+		break;
+	default:
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
+	}
+
+	dprintk("RPC:       set up xprt to %s via AF_LOCAL\n",
+			xprt->address_strings[RPC_DISPLAY_ADDR]);
+
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+	ret = ERR_PTR(-EINVAL);
+out_err:
+	xprt_free(xprt);
+	return ret;
+}
+
 static const struct rpc_timeout xs_udp_default_timeout = {
 	.to_initval = 5 * HZ,
 	.to_maxval = 30 * HZ,
@@ -2438,6 +2817,14 @@ out_err:
 	return ret;
 }
 
+static struct xprt_class	xs_local_transport = {
+	.list		= LIST_HEAD_INIT(xs_local_transport.list),
+	.name		= "named UNIX socket",
+	.owner		= THIS_MODULE,
+	.ident		= XPRT_TRANSPORT_LOCAL,
+	.setup		= xs_setup_local,
+};
+
 static struct xprt_class	xs_udp_transport = {
 	.list		= LIST_HEAD_INIT(xs_udp_transport.list),
 	.name		= "udp",
@@ -2473,6 +2860,7 @@ int init_socket_xprt(void)
 		sunrpc_table_header = register_sysctl_table(sunrpc_table);
 #endif
 
+	xprt_register_transport(&xs_local_transport);
 	xprt_register_transport(&xs_udp_transport);
 	xprt_register_transport(&xs_tcp_transport);
 	xprt_register_transport(&xs_bc_tcp_transport);
@@ -2493,6 +2881,7 @@ void cleanup_socket_xprt(void)
 	}
 #endif
 
+	xprt_unregister_transport(&xs_local_transport);
 	xprt_unregister_transport(&xs_udp_transport);
 	xprt_unregister_transport(&xs_tcp_transport);
 	xprt_unregister_transport(&xs_bc_tcp_transport);

