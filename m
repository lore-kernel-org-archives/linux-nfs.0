From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/7] SUNRPC: Fix TCP rebinding logic
Date: Tue, 06 Nov 2007 19:39:45 -0500
Message-ID: <20071107003945.13713.61995.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpYva-0002Lv-Bg
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:37:54 -0800
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpYvf-00052P-OQ
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:00 -0800
In-Reply-To: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently the TCP rebinding logic assumes that if we're not using a
reserved port, then we don't need to reconnect on the same port if a
disconnection event occurs. This breaks most RPC duplicate reply cache
implementations.

Also take into account the fact that xprt_min_resvport and
xprt_max_resvport may change while we're reconnecting, since the user may
change them at any time via the sysctls. Ensure that we check the port
boundaries every time we loop in xs_bind4/xs_bind6. Also ensure that if the
boundaries change, we only scan the ports a maximum of 2 times.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   59 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 322e4e2..5a83a40 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1272,34 +1272,53 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 	}
 }
 
+static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
+{
+	unsigned short port = transport->port;
+
+	if (port == 0 && transport->xprt.resvport)
+		port = xs_get_random_port();
+	return port;
+}
+
+static unsigned short xs_next_srcport(struct sock_xprt *transport, struct socket *sock, unsigned short port)
+{
+	if (transport->port != 0)
+		transport->port = 0;
+	if (!transport->xprt.resvport)
+		return 0;
+	if (port <= xprt_min_resvport || port > xprt_max_resvport)
+		return xprt_max_resvport;
+	return --port;
+}
+
 static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
 	};
 	struct sockaddr_in *sa;
-	int err;
-	unsigned short port = transport->port;
+	int err, nloop = 0;
+	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short last;
 
-	if (!transport->xprt.resvport)
-		port = 0;
 	sa = (struct sockaddr_in *)&transport->addr;
 	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
-		if (!transport->xprt.resvport)
+		if (port == 0)
 			break;
 		if (err == 0) {
 			transport->port = port;
 			break;
 		}
-		if (port <= xprt_min_resvport)
-			port = xprt_max_resvport;
-		else
-			port--;
-	} while (err == -EADDRINUSE && port != transport->port);
+		last = port;
+		port = xs_next_srcport(transport, sock, port);
+		if (port > last)
+			nloop++;
+	} while (err == -EADDRINUSE && nloop != 2);
 	dprintk("RPC:       %s "NIPQUAD_FMT":%u: %s (%d)\n",
 			__FUNCTION__, NIPQUAD(myaddr.sin_addr),
 			port, err ? "failed" : "ok", err);
@@ -1312,28 +1331,27 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		.sin6_family = AF_INET6,
 	};
 	struct sockaddr_in6 *sa;
-	int err;
-	unsigned short port = transport->port;
+	int err, nloop = 0;
+	unsigned short port = xs_get_srcport(transport, sock);
+	unsigned short last;
 
-	if (!transport->xprt.resvport)
-		port = 0;
 	sa = (struct sockaddr_in6 *)&transport->addr;
 	myaddr.sin6_addr = sa->sin6_addr;
 	do {
 		myaddr.sin6_port = htons(port);
 		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
-		if (!transport->xprt.resvport)
+		if (port == 0)
 			break;
 		if (err == 0) {
 			transport->port = port;
 			break;
 		}
-		if (port <= xprt_min_resvport)
-			port = xprt_max_resvport;
-		else
-			port--;
-	} while (err == -EADDRINUSE && port != transport->port);
+		last = port;
+		port = xs_next_srcport(transport, sock, port);
+		if (port > last)
+			nloop++;
+	} while (err == -EADDRINUSE && nloop != 2);
 	dprintk("RPC:       xs_bind6 "NIP6_FMT":%u: %s (%d)\n",
 		NIP6(myaddr.sin6_addr), port, err ? "failed" : "ok", err);
 	return err;
@@ -1815,7 +1833,6 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
 		memcpy(&new->addr, args->srcaddr, args->addrlen);
-	new->port = xs_get_random_port();
 
 	return xprt;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
