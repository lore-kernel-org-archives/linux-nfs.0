From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind
 registrations.
Date: Mon, 06 Jul 2009 18:12:13 +0530
Message-ID: <4A51F125.5080709@suse.de>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com> <18992.35996.986951.556723@notabene.brown> <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com> <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37302 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbZGFMmj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 08:42:39 -0400
In-Reply-To: <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Jun 11, 2009, at 11:44 AM, Chuck Lever wrote:
>> On Jun 11, 2009, at 12:48 AM, Neil Brown wrote:

>>
>>> How hard would it be to add (optional) connected UDP support?  Would
>>> we just make the code more like the TCP version, or are there any
>>> gotchas that you know of that we would need to be careful of?
>>
>> The code in net/sunrpc/xprtsock.c is a bunch of transport methods,
>> many of which are shared between the UDP and TCP transport
>> capabilities.  You could probably do this easily by creating a new
>> xprt_class structure and a new ops vector, then reuse as many UDP
>> methods as possible.  The TCP connect method could be usable as is,
>> but it would be simple to copy-n-paste a new one if some variation is
>> required.  Then, define a new XPRT_ value, and use that in
>> rpcb_create_local().

I attempted a patch based on your suggestions, while the socket seems
to be getting the -ECONNREFUSED error, but it isn't propagating all the
way up (yet to debug, why)




 include/linux/sunrpc/xprtsock.h |    6 ++
 net/sunrpc/rpcb_clnt.c          |    2 +-
 net/sunrpc/xprt.c               |    5 +
 net/sunrpc/xprtsock.c           |  186 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 198 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index c2a46c4..3f05a45 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -22,6 +22,12 @@ void		cleanup_socket_xprt(void);
  */
 #define XPRT_TRANSPORT_UDP	IPPROTO_UDP
 #define XPRT_TRANSPORT_TCP	IPPROTO_TCP
+/*
+ * Connected UDP doesn't seem to be a well-defined protocol, picking a number
+ * other than 17 and 6 should be OK.
+ * FIXME: If the above assumption is wrong.
+ */
+#define XPRT_TRANSPORT_CUDP	18
 
 /*
  * RPC slot table sizes for UDP, TCP transports
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index beee6da..73f8048 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -135,7 +135,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 					  size_t addrlen, u32 version)
 {
 	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
+		.protocol	= XPRT_TRANSPORT_CUDP,
 		.address	= addr,
 		.addrsize	= addrlen,
 		.servername	= "localhost",
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f412a85..7e605f1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -898,6 +898,11 @@ void xprt_transmit(struct rpc_task *task)
 	req->rq_connect_cookie = xprt->connect_cookie;
 	req->rq_xtime = jiffies;
 	status = xprt->ops->send_request(task);
+	if (status == -ECONNREFUSED) {
+		dprintk("RPC: send_request returned (%d) in xprt_transmit\n",
+				status);
+		rpc_exit(task, status);
+	}
 	if (status != 0) {
 		task->tk_status = status;
 		return;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..6cc24c3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -193,6 +193,8 @@ static ctl_table sunrpc_table[] = {
  */
 #define XS_IDLE_DISC_TO		(5U * 60 * HZ)
 
+#define IPPROTO_CUDP	XPRT_TRANSPORT_CUDP
+
 #ifdef RPC_DEBUG
 # undef  RPC_DEBUG_DATA
 # define RPCDBG_FACILITY	RPCDBG_TRANS
@@ -1832,6 +1834,100 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
+/**
+ * xs_cudp_connect_worker4 - set up a connected UDP socket
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_cudp_connect_worker4(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock = transport->sock;
+	int err, status = -EIO;
+
+	if (xprt->shutdown)
+		goto out;
+
+	/* Start by resetting any existing state */
+	xs_reset_transport(transport);
+
+	err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
+		goto out;
+	}
+	xs_reclassify_socket4(sock);
+
+	if (xs_bind4(transport, sock)) {
+		sock_release(sock);
+		goto out;
+	}
+
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+
+	xs_udp_finish_connecting(xprt, sock);
+	err = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
+	if (err < 0) {
+		dprintk("RPC:	connect on UDP socket.. failed (%d).\n", -err);
+		goto out;
+	}
+	status = 0;
+out:
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+}
+
+/**
+ * xs_cudp_connect_worker6 - set up a Connected UDP socket
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_cudp_connect_worker6(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock = transport->sock;
+	int err, status = -EIO;
+
+	if (xprt->shutdown)
+		goto out;
+
+	/* Start by resetting any existing state */
+	xs_reset_transport(transport);
+
+	err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
+		goto out;
+	}
+	xs_reclassify_socket6(sock);
+
+	if (xs_bind6(transport, sock) < 0) {
+		sock_release(sock);
+		goto out;
+	}
+
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+
+	xs_udp_finish_connecting(xprt, sock);
+	err = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
+	if (err < 0) {
+		dprintk("RPC:	connect on UDP socket... failed (%d).\n", -err);
+		goto out;
+	}
+	status = 0;
+out:
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+}
+
 /*
  * We need to preserve the port number so the reply cache on the server can
  * find our cached RPC replies when we get around to reconnecting.
@@ -2192,6 +2288,24 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.print_stats		= xs_tcp_print_stats,
 };
 
+static struct rpc_xprt_ops xs_cudp_ops = {
+	.set_buffer_size	= xs_udp_set_buffer_size,
+	.reserve_xprt		= xprt_reserve_xprt_cong,
+	.release_xprt		= xprt_release_xprt_cong,
+	.rpcbind		= rpcb_getport_async,
+	.set_port		= xs_set_port,
+	.connect		= xs_tcp_connect,
+	.buf_alloc		= rpc_malloc,
+	.buf_free		= rpc_free,
+	.send_request		= xs_udp_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_rtt,
+	.timer			= xs_udp_timer,
+	.release_request	= xprt_release_rqst_cong,
+	.close			= xs_close,
+	.destroy		= xs_destroy,
+	.print_stats		= xs_udp_print_stats,
+};
+
 static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
 {
@@ -2298,6 +2412,68 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	return ERR_PTR(-EINVAL);
 }
 
+/**
+ * xs_setup_cudp - Set up transport to use a connected UDP socket
+ * @args: rpc transport creation arguments
+ *
+ */
+static struct rpc_xprt *xs_setup_cudp(struct xprt_create *args)
+{
+	struct sockaddr *addr = args->dstaddr;
+	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
+
+	xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
+	xprt->prot = IPPROTO_CUDP;
+	xprt->tsh_size = 0;
+	/* XXX: header size can vary due to auth type, IPv6, etc. */
+	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
+
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->connect_timeout = XS_UDP_CONN_TO;
+	xprt->reestablish_timeout = XS_UDP_REEST_TO;
+	xprt->idle_timeout = XS_IDLE_DISC_TO;
+
+	xprt->ops = &xs_cudp_ops;
+	xprt->timeout = &xs_udp_default_timeout;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_cudp_connect_worker4);
+		xs_format_ipv4_peer_addresses(xprt, "cudp", RPCBIND_NETID_UDP);
+		break;
+	case AF_INET6:
+		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
+			xprt_set_bound(xprt);
+
+		INIT_DELAYED_WORK(&transport->connect_worker,
+					xs_cudp_connect_worker6);
+		xs_format_ipv6_peer_addresses(xprt, "cudp", RPCBIND_NETID_UDP);
+		break;
+	default:
+		kfree(xprt);
+		return ERR_PTR(-EAFNOSUPPORT);
+	}
+
+	dprintk("RPC:       set up transport to address %s\n",
+			xprt->address_strings[RPC_DISPLAY_ALL]);
+
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+
+	kfree(xprt->slot);
+	kfree(xprt);
+	return ERR_PTR(-EINVAL);
+}
+
 static const struct rpc_timeout xs_tcp_default_timeout = {
 	.to_initval = 60 * HZ,
 	.to_maxval = 60 * HZ,
@@ -2379,6 +2555,14 @@ static struct xprt_class	xs_tcp_transport = {
 	.setup		= xs_setup_tcp,
 };
 
+static struct xprt_class	xs_cudp_transport = {
+	.list		= LIST_HEAD_INIT(xs_cudp_transport.list),
+	.name		= "cudp",
+	.owner		= THIS_MODULE,
+	.ident		= IPPROTO_CUDP,
+	.setup		= xs_setup_cudp,
+};
+
 /**
  * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
@@ -2392,6 +2576,7 @@ int init_socket_xprt(void)
 
 	xprt_register_transport(&xs_udp_transport);
 	xprt_register_transport(&xs_tcp_transport);
+	xprt_register_transport(&xs_cudp_transport);
 
 	return 0;
 }
@@ -2411,4 +2596,5 @@ void cleanup_socket_xprt(void)
 
 	xprt_unregister_transport(&xs_udp_transport);
 	xprt_unregister_transport(&xs_tcp_transport);
+	xprt_unregister_transport(&xs_cudp_transport);
 }

> I've thought about this some more...
> 
> It seems to me that you might be better off using the existing UDP
> transport code, but adding a new RPC_CLNT_CREATE_ flag to enable
> connected UDP semantics.  The two transports are otherwise exactly the
> same.
> 

It doesn't seem that there is a clean way of doing this. The function
xs_setup_udp() sets up the corresponding connect_worker function which
actually sets up the UDP socket. There doesn't seem to be a way to check
whether this flag (or a new rpc_clnt->cl_ flag) is set or not in either of
the functions.

OTOH, why not use AF_LOCAL sockets since it's for local communication only?


Thanks,


-- 
Suresh Jayaraman
