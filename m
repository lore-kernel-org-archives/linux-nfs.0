Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51900 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab3BZEGm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2013 23:06:42 -0500
Date: Mon, 25 Feb 2013 23:06:40 -0500
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: [PATCH] SUNRPC: make AF_LOCAL connect synchronous
Message-ID: <20130226040639.GA30088@fieldses.org>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
 <1361464705-12340-2-git-send-email-bfields@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA5F3@SACEXCMBX04-PRD.hq.netapp.com>
 <20130221194804.GC3531@pad.fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA946@SACEXCMBX04-PRD.hq.netapp.com>
 <20130221203603.GE3531@pad.fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DAA19@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DAA19@SACEXCMBX04-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It doesn't appear that anyone actually needs to connect asynchronously.

Also, using a workqueue for the connect means we lose the namespace
information from the original process.  This is a problem since there's
no way to explicitly pass in a filesystem namespace for resolution of an
AF_LOCAL address.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

On Thu, Feb 21, 2013 at 08:42:14PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-02-21 at 15:36 -0500, J. Bruce Fields wrote:
> > On Thu, Feb 21, 2013 at 08:02:30PM +0000, Myklebust, Trond wrote:
> > > A 5 minute msleep() is probably a bit excessive. Making it interruptible
> > > might help, but ...
> > > That does however raise the issue of why we need exponential back off
> > > here? An AF_LOCAL connect call is pretty efficient.
> > 
> > And the only excuse for the connect not succeeding is, what, rpcbind
> > just crashed or something?  In which case I think our only
> > responsibility is just not to spin furiously.  How about just something
> > like
> > 
> > 	ret = xs_local_setup_socket(transport);
> > 	if (ret && !RPC_IS_SOFTCONN(task))
> > 		msleep_interruptible(1000);
> > 	return;
> 
> This general approach works for me...
> 
> > ?
> > 
> > Or we could keep the same exponential timeout logic and just adjust the
> > min/max.
> > 
> > I have no strong opinions here....
> 
> I'm fine with just using a fixed timeout, as long as it is not too
> short. 15 seconds, perhaps?

OK, just plugging in 15s--does this look OK?  If so, could you take it
for 3.9?

The rest of the gss-proxy work will have to wait for 3.10, I think, but
this seems simple enough and also fills in one last gap in the nfsd
containerization work.--b.

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bbc0915..4dc8eb2 100644
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
+static int xs_local_setup_socket(struct sock_xprt *transport)
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
 	int status = -EIO;
@@ -1917,6 +1913,31 @@ out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
 	current->flags &= ~PF_FSTRANS;
+	return status;
+}
+
+static void xs_local_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	int ret;
+
+	 if (RPC_IS_ASYNC(task)) {
+		/*
+		 * We want the AF_LOCAL connect to be resolved in the
+		 * filesystem namespace of the process making the rpc
+		 * call.  Thus we connect synchronously.
+		 *
+		 * If we want to support asynchronous AF_LOCAL calls,
+		 * we'll need to figure out how to pass a namespace to
+		 * connect.
+		 */
+		rpc_exit(task, -ENOTCONN);
+		return;
+	}
+	ret = xs_local_setup_socket(transport);
+	if (ret && !RPC_IS_SOFTCONN(task))
+		msleep_interruptible(15000);
 }
 
 #ifdef CONFIG_SUNRPC_SWAP
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
-- 
1.7.11.7

