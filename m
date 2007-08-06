From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/20] SUNRPC: create connect workers for IPv6
Date: Mon, 06 Aug 2007 11:57:48 -0400
Message-ID: <20070806155748.31233.23253.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xv-000138-7L
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:55 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xz-0002Np-7U
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:59 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clone separate connect worker functions for connecting AF_INET6 sockets.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 34ab136..391b88d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1403,6 +1403,47 @@ out:
 	xprt_clear_connecting(xprt);
 }
 
+/**
+ * xs_udp_connect_worker6 - set up a UDP socket
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_udp_connect_worker6(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock = transport->sock;
+	int err, status = -EIO;
+
+	if (xprt->shutdown || !xprt_bound(xprt))
+		goto out;
+
+	/* Start by resetting any existing state */
+	xs_close(xprt);
+
+	if ((err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
+		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
+		goto out;
+	}
+	xs_reclassify_socket(sock);
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
+	status = 0;
+out:
+	xprt_wake_pending_tasks(xprt, status);
+	xprt_clear_connecting(xprt);
+}
+
 /*
  * We need to preserve the port number so the reply cache on the server can
  * find our cached RPC replies when we get around to reconnecting.
@@ -1529,6 +1570,66 @@ out_clear:
 }
 
 /**
+ * xs_tcp_connect_worker6 - connect a TCP socket to a remote endpoint
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_connect_worker6(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock = transport->sock;
+	int err, status = -EIO;
+
+	if (xprt->shutdown || !xprt_bound(xprt))
+		goto out;
+
+	if (!sock) {
+		/* start from scratch */
+		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
+			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
+			goto out;
+		}
+		xs_reclassify_socket(sock);
+
+		if (xs_bind6(transport, sock) < 0) {
+			sock_release(sock);
+			goto out;
+		}
+	} else
+		/* "close" the socket, preserving the local port */
+		xs_tcp_reuse_connection(xprt);
+
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+
+	status = xs_tcp_finish_connecting(xprt, sock);
+	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
+			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
+	if (status < 0) {
+		switch (status) {
+			case -EINPROGRESS:
+			case -EALREADY:
+				goto out_clear;
+			case -ECONNREFUSED:
+			case -ECONNRESET:
+				/* retry with existing socket, after a delay */
+				break;
+			default:
+				/* get rid of existing socket, and retry */
+				xs_close(xprt);
+				break;
+		}
+	}
+out:
+	xprt_wake_pending_tasks(xprt, status);
+out_clear:
+	xprt_clear_connecting(xprt);
+}
+
+/**
  * xs_connect - connect a socket to a remote endpoint
  * @task: address of RPC task that manages state of connect request
  *


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
