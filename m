Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18754 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab2LDLKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 06:10:13 -0500
Subject: [PATCH] SUNRPC: connect to UNIX sockets synchronously
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 14:10:27 +0300
Message-ID: <20121204111006.23758.22102.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Local tranports uses UNIX sockets and connecting of these sockets is done in
context of file system namespace (i.e. task file system root).
Currenly, all sockets connect operations are performed by rpciod work queue,
which actually means, that any service will be registered in the same
rpcbind instance regardless to process file system root.
This is not suitable for containers, which usually have it's own nested root.
There are 2 approaches, how the problem can be solved.

First one is to store proper root in transport and switch to it in rpciod
workqueue function for connect operations. But this looks ugly and such
approach was rejected by community.

The second one is to connect to unix sockets synchronously, which is
implemented by this patch.

But there should be noted, that such implementation introduces limitation
(Trond's quote):
"That approach can fall afoul of the selinux restrictions on the process
context. Processes that are allowed to write data, may not be allowed to
create sockets or call connect(). That is the main reason for doing it
in the rpciod context, which is a clean kernel process context."

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/xprtsock.c |   46 ++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index aaaadfb..362a5a6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1882,12 +1882,10 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
  * @transport: socket transport to connect
  * @create_sock: function to create a socket of the correct type
  *
- * Invoked by a work queue tasklet.
+ * Used to synchronously connect to UNIX sockets.
  */
-static void xs_local_setup_socket(struct work_struct *work)
+static void xs_local_setup_socket(struct sock_xprt *transport)
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
 	int status = -EIO;
@@ -2463,19 +2461,53 @@ static void bc_destroy(struct rpc_xprt *xprt)
 {
 }
 
+/**
+ * xs_local_connect - connect a socket to a remote endpoint
+ * @task: address of RPC task that manages state of connect request
+ *
+ * Used for UNIX transports only.
+ */
+static void xs_local_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (transport->sock != NULL) {
+		printk(KERN_WARNING "Local xprt %p is connected already\n", xprt);
+		return;
+	}
+	dprintk("RPC:       xs_local_connect for xprt %p\n", xprt);
+	xs_local_setup_socket(transport);
+}
+
+/**
+ * xs_local_destroy - prepare to shutdown a local transport
+ * @xprt: doomed transport
+ *
+ */
+static void xs_local_destroy(struct rpc_xprt *xprt)
+{
+	dprintk("RPC:       xs_local_destroy xprt %p\n", xprt);
+
+	xs_close(xprt);
+	xs_free_peer_addresses(xprt);
+	xprt_free(xprt);
+	module_put(THIS_MODULE);
+}
+
 static struct rpc_xprt_ops xs_local_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
 	.rpcbind		= xs_local_rpcbind,
 	.set_port		= xs_local_set_port,
-	.connect		= xs_connect,
+	.connect		= xs_local_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_local_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_close,
-	.destroy		= xs_destroy,
+	.destroy		= xs_local_destroy,
 	.print_stats		= xs_local_print_stats,
 };
 
@@ -2642,8 +2674,6 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 			goto out_err;
 		}
 		xprt_set_bound(xprt);
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_local_setup_socket);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
 		break;
 	default:

