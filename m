Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58930 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623Ab1GOR4d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 13:56:33 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH (RESEND) 10/12] nfs: Bind to srcaddr in rpcb_create.
Date: Fri, 15 Jul 2011 10:56:06 -0700
Message-Id: <1310752568-21280-11-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This more properly clones the existing client connection
settings, allowing rpc calls to take advantage of routing
rules based on source IP addresses.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e45d2fb... 13dae70... M	net/sunrpc/rpcb_clnt.c
:100644 100644 90c292e... 22841e1... M	net/sunrpc/sunrpc.h
:100644 100644 37299c0... 72408c2... M	net/sunrpc/xprtsock.c
 net/sunrpc/rpcb_clnt.c |   28 ++++++++++++++++++++++++++--
 net/sunrpc/sunrpc.h    |   45 +++++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c  |   43 -------------------------------------------
 3 files changed, 71 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index e45d2fb..13dae70 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xprtsock.h>
+#include "sunrpc.h"
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_BIND
@@ -292,11 +293,13 @@ out:
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version)
+				    size_t salen, int proto, u32 version,
+				    struct sockaddr *srcaddr)
 {
 	struct rpc_create_args args = {
 		.net		= &init_net,
 		.protocol	= proto,
+		.saddress	= srcaddr,
 		.address	= srvaddr,
 		.addrsize	= salen,
 		.servername	= hostname,
@@ -601,11 +604,32 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_task	*child;
 	struct sockaddr_storage addr;
 	struct sockaddr *sap = (struct sockaddr *)&addr;
+	struct sockaddr_storage srcaddr;
+	struct sockaddr *srcaddra = NULL;
 	size_t salen;
 	int status;
+	struct sock_xprt *sxprt;
 
 	clnt = rpcb_find_transport_owner(task->tk_client);
 	xprt = clnt->cl_xprt;
+	sxprt = container_of(xprt, struct sock_xprt, xprt);
+
+	/* We just want to bind to the IP, not the port */
+	memset(&srcaddr, 0, sizeof(srcaddr));
+	srcaddr.ss_family = sxprt->srcaddr.ss_family;
+	if (sxprt->srcaddr.ss_family == AF_INET) {
+		struct sockaddr_in *si = (struct sockaddr_in *)(&srcaddr);
+		struct sockaddr_in *si2;
+		si2 = (struct sockaddr_in *)(&sxprt->srcaddr);
+		si->sin_addr.s_addr = si2->sin_addr.s_addr;
+		srcaddra = (struct sockaddr *)(&srcaddr);
+	} else if (sxprt->srcaddr.ss_family == AF_INET6) {
+		struct sockaddr_in6 *si = (struct sockaddr_in6 *)(&srcaddr);
+		struct sockaddr_in6 *si2;
+		si2 = (struct sockaddr_in6 *)(&sxprt->srcaddr);
+		memcpy(&si->sin6_addr, &si2->sin6_addr, sizeof(si2->sin6_addr));
+		srcaddra = (struct sockaddr *)(&srcaddr);
+	}
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
@@ -660,7 +684,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		task->tk_pid, __func__, bind_version);
 
 	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
-				bind_version);
+				bind_version, srcaddra);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index 90c292e..22841e1 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -37,6 +37,51 @@ struct rpc_buffer {
 	char	data[];
 };
 
+struct sock_xprt {
+	struct rpc_xprt		xprt;
+
+	/*
+	 * Network layer
+	 */
+	struct socket		*sock;
+	struct sock		*inet;
+
+	/*
+	 * State of TCP reply receive
+	 */
+	__be32			tcp_fraghdr,
+				tcp_xid,
+				tcp_calldir;
+
+	u32			tcp_offset,
+				tcp_reclen;
+
+	unsigned long		tcp_copied,
+				tcp_flags;
+
+	/*
+	 * Connection of transports
+	 */
+	struct delayed_work	connect_worker;
+	struct sockaddr_storage	srcaddr;
+	unsigned short		srcport;
+
+	/*
+	 * UDP socket buffer size parameters
+	 */
+	size_t			rcvsize,
+				sndsize;
+
+	/*
+	 * Saved socket callback addresses
+	 */
+	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_state_change)(struct sock *);
+	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
+};
+
+
 static inline int rpc_reply_expected(struct rpc_task *task)
 {
 	return (task->tk_msg.rpc_proc != NULL) &&
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37299c0..72408c2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -202,49 +202,6 @@ static inline void xs_pktdump(char *msg, u32 *packet, unsigned int count)
 }
 #endif
 
-struct sock_xprt {
-	struct rpc_xprt		xprt;
-
-	/*
-	 * Network layer
-	 */
-	struct socket *		sock;
-	struct sock *		inet;
-
-	/*
-	 * State of TCP reply receive
-	 */
-	__be32			tcp_fraghdr,
-				tcp_xid,
-				tcp_calldir;
-
-	u32			tcp_offset,
-				tcp_reclen;
-
-	unsigned long		tcp_copied,
-				tcp_flags;
-
-	/*
-	 * Connection of transports
-	 */
-	struct delayed_work	connect_worker;
-	struct sockaddr_storage	srcaddr;
-	unsigned short		srcport;
-
-	/*
-	 * UDP socket buffer size parameters
-	 */
-	size_t			rcvsize,
-				sndsize;
-
-	/*
-	 * Saved socket callback addresses
-	 */
-	void			(*old_data_ready)(struct sock *, int);
-	void			(*old_state_change)(struct sock *);
-	void			(*old_write_space)(struct sock *);
-	void			(*old_error_report)(struct sock *);
-};
 
 /*
  * TCP receive state flags
-- 
1.7.3.4

