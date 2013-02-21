Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36081 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753836Ab3BUQVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:21:44 -0500
Date: Thu, 21 Feb 2013 11:21:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: synchronous AF_LOCAL connect
Message-ID: <20130221162139.GB9743@fieldses.org>
References: <20130218225424.GD3391@fieldses.org>
 <20130220154751.GH14606@fieldses.org>
 <2F275139-9861-4414-8C9F-BD74544C9AD7@oracle.com>
 <20130220160350.GJ14606@fieldses.org>
 <EA9EE56A-73BB-4866-AA86-1EE4150AFE87@oracle.com>
 <20130220163424.GK14606@fieldses.org>
 <FB21B277-FA7D-490C-B389-58A91C46B490@oracle.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235D7E49@SACEXCMBX04-PRD.hq.netapp.com>
 <1361381561.12328.441.camel@willson.li.ssimo.org>
 <20130220230337.GC3575@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130220230337.GC3575@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2013 at 06:03:37PM -0500, J. Bruce Fields wrote:
> OK, I've added that check and fixed some other bugs (thanks to Chuck for
> some help in IRC).
> 
> I think that gets rpcbind working in containers fine.
> 
> gss-proxy has one more problem: it needs to do upcalls from nfsd threads
> which won't have the right filesystem namespace.
> 
> I get a write from gss-proxy when it starts and can do an initial
> connect then using its context.  But if we disconnect after that I'm
> stuck.
> 
> Does it cause any problems if I just set the idle_timeout to 0 for
> AF_LOCAL?

That gives me the following three patches.  They work for me.

Would it make more sense to make the idle timeout configurable?  I
couldn't see why disconnecting idle AF_LOCAL rpcbind connections would
be particularly important anyway.

--b.

commit 6656841afa0602f7aae3e42648eb44bfe79f7389
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Feb 20 17:52:19 2013 -0500

    SUNRPC: make AF_LOCAL connect synchronous
    
    It doesn't appear that anyone actually needs to connect asynchronously.
    
    Also, using a workqueue for the connect means we lose the namespace
    information from the original process.  This is a problem since there's
    no way to explicitly pass in a filesystem namespace for resolution of an
    AF_LOCAL address.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bbc0915..b1df874 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1866,13 +1866,9 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
  * @xprt: RPC transport to connect
  * @transport: socket transport to connect
  * @create_sock: function to create a socket of the correct type
- *
- * Invoked by a work queue tasklet.
  */
-static void xs_local_setup_socket(struct work_struct *work)
+static void xs_local_setup_socket(struct sock_xprt *transport)
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
 	int status = -EIO;
@@ -1919,6 +1915,31 @@ out:
 	current->flags &= ~PF_FSTRANS;
 }
 
+static void xs_local_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	unsigned long timeout;
+
+	 if (RPC_IS_ASYNC(task))
+	 	rpc_exit(task, -ENOTCONN);
+
+	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
+		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
+				"seconds\n",
+				xprt, xprt->reestablish_timeout / HZ);
+		timeout = xprt->reestablish_timeout;
+		xprt->reestablish_timeout <<= 1;
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+		rpc_delay(task, timeout);
+	} else
+		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
+	xs_local_setup_socket(transport);
+}
+
 #ifdef CONFIG_SUNRPC_SWAP
 static void xs_set_memalloc(struct rpc_xprt *xprt)
 {
@@ -2454,7 +2475,7 @@ static struct rpc_xprt_ops xs_local_ops = {
 	.alloc_slot		= xprt_alloc_slot,
 	.rpcbind		= xs_local_rpcbind,
 	.set_port		= xs_local_set_port,
-	.connect		= xs_connect,
+	.connect		= xs_local_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_local_send_request,
@@ -2627,8 +2648,6 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 			goto out_err;
 		}
 		xprt_set_bound(xprt);
-		INIT_DELAYED_WORK(&transport->connect_worker,
-					xs_local_setup_socket);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
 		break;
 	default:

commit 3d622fe729b9b4382785c3ef2ef61e484df1b3ec
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Feb 21 10:14:22 2013 -0500

    SUNRPC: attempt AF_LOCAL connect on setup
    
    In the gss-proxy case, setup time is when I know I'll have the right
    namespace for the connect.
    
    In other cases, it might be useful to get any connection errors
    earlier--though actually in practice it doesn't make any difference for
    rpcbind.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b1df874..f2cf652 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1867,7 +1867,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
  * @transport: socket transport to connect
  * @create_sock: function to create a socket of the correct type
  */
-static void xs_local_setup_socket(struct sock_xprt *transport)
+static int xs_local_setup_socket(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
@@ -1913,6 +1913,7 @@ out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
 	current->flags &= ~PF_FSTRANS;
+	return status;
 }
 
 static void xs_local_connect(struct rpc_task *task)
@@ -2649,6 +2650,9 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 		}
 		xprt_set_bound(xprt);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
+		ret = ERR_PTR(xs_local_setup_socket(transport));
+		if (ret)
+			goto out_err;
 		break;
 	default:
 		ret = ERR_PTR(-EAFNOSUPPORT);

commit 1a67db92015506ca07e6fc7a24583917adcbb43d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Feb 20 18:08:52 2013 -0500

    SUNRPC: no idle timeout for AF_LOCAL sockets
    
    In the gss-proxy case I don't want to have to reconnect at random--I
    want to connect only on gss-proxy startup when I can steal gss-proxy's
    context to do the connect in the right namespace.
    
    And surely an AF_LOCAL socket isn't a ton of state to keep around--how
    about we just turn off the idle timeout for AF_LOCAL sockets.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f2cf652..a32227e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2635,7 +2635,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-	xprt->idle_timeout = XS_IDLE_DISC_TO;
+	xprt->idle_timeout = 0;
 
 	xprt->ops = &xs_local_ops;
 	xprt->timeout = &xs_local_default_timeout;
