Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752385AbcJGKGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:06:45 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2 06/10] SUNRPC: add AF_VSOCK support to xprtsock.c
Date: Fri,  7 Oct 2016 11:01:50 +0100
Message-Id: <1475834514-4058-7-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/xprt.h |   1 +
 net/sunrpc/xprtsock.c       | 385 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 381 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a16070d..12048a4 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -165,6 +165,7 @@ enum xprt_transports {
 	XPRT_TRANSPORT_RDMA	= 256,
 	XPRT_TRANSPORT_BC_RDMA	= XPRT_TRANSPORT_RDMA | XPRT_TRANSPORT_BC,
 	XPRT_TRANSPORT_LOCAL	= 257,
+	XPRT_TRANSPORT_VSOCK	= 258,
 };
 
 struct rpc_xprt {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfdce75..c61a0ed 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -46,6 +46,7 @@
 #include <net/checksum.h>
 #include <net/udp.h>
 #include <net/tcp.h>
+#include <net/af_vsock.h>
 
 #include <trace/events/sunrpc.h>
 
@@ -269,6 +270,13 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 		sin6 = xs_addr_in6(xprt);
 		snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
 		break;
+	case AF_VSOCK:
+		(void)rpc_ntop(sap, buf, sizeof(buf));
+		xprt->address_strings[RPC_DISPLAY_ADDR] =
+						kstrdup(buf, GFP_KERNEL);
+		snprintf(buf, sizeof(buf), "%08x",
+			 ((struct sockaddr_vm *)sap)->svm_cid);
+		break;
 	default:
 		BUG();
 	}
@@ -1865,21 +1873,30 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
 
-	if (myaddr.ss_family == AF_INET)
+	switch (myaddr.ss_family) {
+	case AF_INET:
 		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
 				&((struct sockaddr_in *)&myaddr)->sin_addr,
 				port, err ? "failed" : "ok", err);
-	else
+		break;
+	case AF_INET6:
 		dprintk("RPC:       %s %pI6:%u: %s (%d)\n", __func__,
 				&((struct sockaddr_in6 *)&myaddr)->sin6_addr,
 				port, err ? "failed" : "ok", err);
+		break;
+	case AF_VSOCK:
+		dprintk("RPC:       %s %u:%u: %s (%d)\n", __func__,
+				((struct sockaddr_vm *)&myaddr)->svm_cid,
+				port, err ? "failed" : "ok", err);
+		break;
+	}
 	return err;
 }
 
 /*
- * We don't support autobind on AF_LOCAL sockets
+ * We don't support autobind on AF_LOCAL and AF_VSOCK sockets
  */
-static void xs_local_rpcbind(struct rpc_task *task)
+static void xs_dummy_rpcbind(struct rpc_task *task)
 {
 	xprt_set_bound(task->tk_xprt);
 }
@@ -1916,6 +1933,14 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
 }
 
+static inline void xs_reclassify_socket_vsock(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	sock_lock_init_class_and_name(sk, "slock-AF_VSOCK-RPC",
+		&xs_slock_key[1], "sk_lock-AF_VSOCK-RPC", &xs_key[1]);
+}
+
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
 	if (WARN_ON_ONCE(!sock_allow_reclassification(sock->sk)))
@@ -1931,6 +1956,9 @@ static inline void xs_reclassify_socket(int family, struct socket *sock)
 	case AF_INET6:
 		xs_reclassify_socket6(sock);
 		break;
+	case AF_VSOCK:
+		xs_reclassify_socket_vsock(sock);
+		break;
 	}
 }
 #else
@@ -2676,7 +2704,7 @@ static struct rpc_xprt_ops xs_local_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
-	.rpcbind		= xs_local_rpcbind,
+	.rpcbind		= xs_dummy_rpcbind,
 	.set_port		= xs_local_set_port,
 	.connect		= xs_local_connect,
 	.buf_alloc		= rpc_malloc,
@@ -2768,6 +2796,10 @@ static int xs_init_anyaddr(const int family, struct sockaddr *sap)
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
+	static const struct sockaddr_vm svm = {
+		.svm_family		= AF_VSOCK,
+		.svm_cid		= VMADDR_CID_ANY,
+	};
 
 	switch (family) {
 	case AF_LOCAL:
@@ -2778,6 +2810,9 @@ static int xs_init_anyaddr(const int family, struct sockaddr *sap)
 	case AF_INET6:
 		memcpy(sap, &sin6, sizeof(sin6));
 		break;
+	case AF_VSOCK:
+		memcpy(sap, &svm, sizeof(svm));
+		break;
 	default:
 		dprintk("RPC:       %s: Bad address family\n", __func__);
 		return -EAFNOSUPPORT;
@@ -3133,6 +3168,330 @@ out_err:
 	return ret;
 }
 
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+/**
+ * xs_vsock_state_change - callback to handle vsock socket state changes
+ * @sk: socket whose state has changed
+ *
+ */
+static void xs_vsock_state_change(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	dprintk("RPC:       %s client %p...\n", __func__, xprt);
+	dprintk("RPC:       state %x conn %d dead %d zapped %d sk_shutdown %d\n",
+			sk->sk_state, xprt_connected(xprt),
+			sock_flag(sk, SOCK_DEAD),
+			sock_flag(sk, SOCK_ZAPPED),
+			sk->sk_shutdown);
+
+	trace_rpc_socket_state_change(xprt, sk->sk_socket);
+
+	switch (sk->sk_state) {
+	case SS_CONNECTING:
+		/* Do nothing */
+		break;
+
+	case SS_CONNECTED:
+		spin_lock(&xprt->transport_lock);
+		if (!xprt_test_and_set_connected(xprt)) {
+			xs_stream_reset_state(xprt, vsock_read_sock);
+			xprt->connect_cookie++;
+
+			xprt_wake_pending_tasks(xprt, -EAGAIN);
+		}
+		spin_unlock(&xprt->transport_lock);
+		break;
+
+	case SS_DISCONNECTING:
+		/* TODO do we need to distinguish between various shutdown (client-side/server-side)? */
+		/* The client initiated a shutdown of the socket */
+		xprt->connect_cookie++;
+		xprt->reestablish_timeout = 0;
+		set_bit(XPRT_CLOSING, &xprt->state);
+		smp_mb__before_atomic();
+		clear_bit(XPRT_CONNECTED, &xprt->state);
+		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+		smp_mb__after_atomic();
+		break;
+
+	case SS_UNCONNECTED:
+		xs_sock_mark_closed(xprt);
+		break;
+	}
+
+ out:
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
+/**
+ * xs_vsock_error_report - callback to handle vsock socket state errors
+ * @sk: socket
+ *
+ * Note: we don't call sock_error() since there may be a rpc_task
+ * using the socket, and so we don't want to clear sk->sk_err.
+ */
+static void xs_vsock_error_report(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+	int err;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+
+	err = -sk->sk_err;
+	if (err == 0)
+		goto out;
+	/* Is this a reset event? */
+	if (sk->sk_state == SS_UNCONNECTED)
+		xs_sock_mark_closed(xprt);
+	dprintk("RPC:       %s client %p, error=%d...\n",
+			__func__, xprt, -err);
+	trace_rpc_socket_error(xprt, sk->sk_socket, err);
+	xprt_wake_pending_tasks(xprt, err);
+ out:
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
+/**
+ * xs_vsock_finish_connecting - initialize and connect socket
+ */
+static int xs_vsock_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	int ret = -ENOTCONN;
+
+	if (!transport->inet) {
+		struct sock *sk = sock->sk;
+
+		write_lock_bh(&sk->sk_callback_lock);
+
+		xs_save_old_callbacks(transport, sk);
+
+		sk->sk_user_data = xprt;
+		sk->sk_data_ready = xs_data_ready;
+		sk->sk_state_change = xs_vsock_state_change;
+		sk->sk_write_space = xs_tcp_write_space;
+		sk->sk_error_report = xs_vsock_error_report;
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
+	if (!xprt_bound(xprt))
+		goto out;
+
+	xs_set_memalloc(xprt);
+
+	/* Tell the socket layer to start connecting... */
+	xprt->stat.connect_count++;
+	xprt->stat.connect_start = jiffies;
+	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
+	switch (ret) {
+	case 0:
+		xs_set_srcport(transport, sock);
+	case -EINPROGRESS:
+		/* SYN_SENT! */
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	}
+out:
+	return ret;
+}
+
+/**
+ * xs_vsock_setup_socket - create a vsock socket and connect to a remote endpoint
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_vsock_setup_socket(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct socket *sock = transport->sock;
+	struct rpc_xprt *xprt = &transport->xprt;
+	int status = -EIO;
+
+	if (!sock) {
+		sock = xs_create_sock(xprt, transport,
+				xs_addr(xprt)->sa_family, SOCK_STREAM,
+				0, true);
+		if (IS_ERR(sock)) {
+			status = PTR_ERR(sock);
+			goto out;
+		}
+	}
+
+	dprintk("RPC:       worker connecting xprt %p via %s to "
+				"%s (port %s)\n", xprt,
+			xprt->address_strings[RPC_DISPLAY_PROTO],
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT]);
+
+	status = xs_vsock_finish_connecting(xprt, sock);
+	trace_rpc_socket_connect(xprt, sock, status);
+	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
+			xprt, -status, xprt_connected(xprt),
+			sock->sk->sk_state);
+	switch (status) {
+	default:
+		printk("%s: connect returned unhandled error %d\n",
+			__func__, status);
+	case -EADDRNOTAVAIL:
+		/* We're probably in TIME_WAIT. Get rid of existing socket,
+		 * and retry
+		 */
+		xs_tcp_force_close(xprt);
+		break;
+	case 0:
+	case -EINPROGRESS:
+	case -EALREADY:
+		xprt_unlock_connect(xprt, transport);
+		xprt_clear_connecting(xprt);
+		return;
+	case -EINVAL:
+		/* Happens, for instance, if the user specified a link
+		 * local IPv6 address without a scope-id.
+		 */
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ENETUNREACH:
+	case -EADDRINUSE:
+	case -ENOBUFS:
+		/* retry with existing socket, after a delay */
+		xs_tcp_force_close(xprt);
+		goto out;
+	}
+	status = -EAGAIN;
+out:
+	xprt_unlock_connect(xprt, transport);
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+}
+
+/**
+ * xs_vsock_print_stats - display vsock socket-specifc stats
+ * @xprt: rpc_xprt struct containing statistics
+ * @seq: output file
+ *
+ */
+static void xs_vsock_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	long idle_time = 0;
+
+	if (xprt_connected(xprt))
+		idle_time = (long)(jiffies - xprt->last_used) / HZ;
+
+	seq_printf(seq, "\txprt:\tvsock %u %lu %lu %lu %ld %lu %lu %lu "
+			"%llu %llu %lu %llu %llu\n",
+			transport->srcport,
+			xprt->stat.bind_count,
+			xprt->stat.connect_count,
+			xprt->stat.connect_time,
+			idle_time,
+			xprt->stat.sends,
+			xprt->stat.recvs,
+			xprt->stat.bad_xids,
+			xprt->stat.req_u,
+			xprt->stat.bklog_u,
+			xprt->stat.max_slots,
+			xprt->stat.sending_u,
+			xprt->stat.pending_u);
+}
+
+static struct rpc_xprt_ops xs_vsock_ops = {
+	.reserve_xprt		= xprt_reserve_xprt,
+	.release_xprt		= xs_tcp_release_xprt,
+	.alloc_slot		= xprt_lock_and_alloc_slot,
+	.rpcbind		= xs_dummy_rpcbind,
+	.set_port		= xs_set_port,
+	.connect		= xs_connect,
+	.buf_alloc		= rpc_malloc,
+	.buf_free		= rpc_free,
+	.send_request		= xs_tcp_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.close			= xs_tcp_shutdown,
+	.destroy		= xs_destroy,
+	.print_stats		= xs_vsock_print_stats,
+};
+
+static const struct rpc_timeout xs_vsock_default_timeout = {
+	.to_initval = 60 * HZ,
+	.to_maxval = 60 * HZ,
+	.to_retries = 2,
+};
+
+/**
+ * xs_setup_vsock - Set up transport to use a vsock socket
+ * @args: rpc transport creation arguments
+ *
+ */
+static struct rpc_xprt *xs_setup_vsock(struct xprt_create *args)
+{
+	struct sockaddr_vm *addr = (struct sockaddr_vm *)args->dstaddr;
+	struct sock_xprt *transport;
+	struct rpc_xprt *xprt;
+	struct rpc_xprt *ret;
+
+	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries,
+			     xprt_max_tcp_slot_table_entries);
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
+	xprt->ops = &xs_vsock_ops;
+	xprt->timeout = &xs_vsock_default_timeout;
+
+	INIT_WORK(&transport->recv_worker, xs_stream_data_receive_workfn);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_vsock_setup_socket);
+
+	switch (addr->svm_family) {
+	case AF_VSOCK:
+		if (addr->svm_port == 0) {
+			dprintk("RPC:       autobind not supported with AF_VSOCK\n");
+			ret = ERR_PTR(-EINVAL);
+			goto out_err;
+		}
+		xprt_set_bound(xprt);
+		xs_format_peer_addresses(xprt, "vsock", "vsock" /* TODO register official netid? */);
+		break;
+	default:
+		ret = ERR_PTR(-EAFNOSUPPORT);
+		goto out_err;
+	}
+
+	dprintk("RPC:       set up xprt to %s (port %s) via AF_VSOCK\n",
+		xprt->address_strings[RPC_DISPLAY_ADDR],
+		xprt->address_strings[RPC_DISPLAY_PORT]);
+
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+	ret = ERR_PTR(-EINVAL);
+out_err:
+	xs_xprt_free(xprt);
+	return ret;
+}
+#endif
+
 static struct xprt_class	xs_local_transport = {
 	.list		= LIST_HEAD_INIT(xs_local_transport.list),
 	.name		= "named UNIX socket",
@@ -3165,6 +3524,16 @@ static struct xprt_class	xs_bc_tcp_transport = {
 	.setup		= xs_setup_bc_tcp,
 };
 
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+static struct xprt_class	xs_vsock_transport = {
+	.list		= LIST_HEAD_INIT(xs_vsock_transport.list),
+	.name		= "vsock",
+	.owner		= THIS_MODULE,
+	.ident		= XPRT_TRANSPORT_VSOCK,
+	.setup		= xs_setup_vsock,
+};
+#endif
+
 /**
  * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
@@ -3180,6 +3549,9 @@ int init_socket_xprt(void)
 	xprt_register_transport(&xs_udp_transport);
 	xprt_register_transport(&xs_tcp_transport);
 	xprt_register_transport(&xs_bc_tcp_transport);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	xprt_register_transport(&xs_vsock_transport);
+#endif
 
 	return 0;
 }
@@ -3201,6 +3573,9 @@ void cleanup_socket_xprt(void)
 	xprt_unregister_transport(&xs_udp_transport);
 	xprt_unregister_transport(&xs_tcp_transport);
 	xprt_unregister_transport(&xs_bc_tcp_transport);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	xprt_unregister_transport(&xs_vsock_transport);
+#endif
 }
 
 static int param_set_uint_minmax(const char *val,
-- 
2.7.4

