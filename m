From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/20] SUNRPC: Rename IPv4 connect workers
Date: Mon, 06 Aug 2007 11:57:43 -0400
Message-ID: <20070806155743.31233.26108.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xs-00012w-7f
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:52 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xw-0002Ml-8o
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:56 -0700
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

Prepare for introduction of IPv6 versions of same.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3bd80e1..34ab136 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1363,12 +1363,12 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 }
 
 /**
- * xs_udp_connect_worker - set up a UDP socket
+ * xs_udp_connect_worker4 - set up a UDP socket
  * @work: RPC transport to connect
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_udp_connect_worker(struct work_struct *work)
+static void xs_udp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
@@ -1468,12 +1468,12 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 }
 
 /**
- * xs_tcp_connect_worker - connect a TCP socket to a remote endpoint
+ * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
  * @work: RPC transport to connect
  *
  * Invoked by a work queue tasklet.
  */
-static void xs_tcp_connect_worker(struct work_struct *work)
+static void xs_tcp_connect_worker4(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, connect_worker.work);
@@ -1705,7 +1705,7 @@ struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
-	INIT_DELAYED_WORK(&transport->connect_worker, xs_udp_connect_worker);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_udp_connect_worker4);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_UDP_CONN_TO;
 	xprt->reestablish_timeout = XS_UDP_REEST_TO;
@@ -1747,7 +1747,7 @@ struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->connect_timeout = XS_TCP_CONN_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
