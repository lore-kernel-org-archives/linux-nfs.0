From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] SUNRPC: Kill RPC_DISPLAY_ALL
Date: Thu, 06 Aug 2009 14:55:31 -0400
Message-ID: <20090806185530.3458.87596.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45913
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751019AbZHFSze (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:34 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At some point, I recall that rpc_pipe_fs used RPC_DISPLAY_ALL.
Currently there are no uses of RPC_DISPLAY_ALL outside the transport
modules themselves, so we can safely get rid of it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h     |    1 -
 net/sunrpc/xprtrdma/transport.c |    5 ----
 net/sunrpc/xprtsock.c           |   50 +++++++++++++++++++++++++++------------
 3 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 65fad95..c090df4 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -38,7 +38,6 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_ADDR = 0,
 	RPC_DISPLAY_PORT,
 	RPC_DISPLAY_PROTO,
-	RPC_DISPLAY_ALL,
 	RPC_DISPLAY_HEX_ADDR,
 	RPC_DISPLAY_HEX_PORT,
 	RPC_DISPLAY_NETID,
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5f9b867..9a63f66 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -181,11 +181,6 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	(void)snprintf(buf, sizeof(buf), "addr=%s port=%s proto=rdma",
-			xprt->address_strings[RPC_DISPLAY_ADDR],
-			xprt->address_strings[RPC_DISPLAY_PORT]);
-	xprt->address_strings[RPC_DISPLAY_ALL] = kstrdup(buf, GFP_KERNEL);
-
 	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
 				NIPQUAD(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7bc3c17..eee5ac9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -307,12 +307,6 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
-	(void)snprintf(buf, sizeof(buf), "addr=%s port=%s proto=%s",
-			xprt->address_strings[RPC_DISPLAY_ADDR],
-			xprt->address_strings[RPC_DISPLAY_PORT],
-			xprt->address_strings[RPC_DISPLAY_PROTO]);
-	xprt->address_strings[RPC_DISPLAY_ALL] = kstrdup(buf, GFP_KERNEL);
-
 	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 }
@@ -1721,8 +1715,11 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 		goto out;
 	}
 
-	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+	dprintk("RPC:       worker connecting xprt %p via %s to "
+				"%s (port %s)\n", xprt,
+			xprt->address_strings[RPC_DISPLAY_PROTO],
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT]);
 
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
@@ -1763,8 +1760,11 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 		goto out;
 	}
 
-	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+	dprintk("RPC:       worker connecting xprt %p via %s to "
+				"%s (port %s)\n", xprt,
+			xprt->address_strings[RPC_DISPLAY_PROTO],
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT]);
 
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
@@ -1889,8 +1889,11 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
 			goto out_eagain;
 	}
 
-	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+	dprintk("RPC:       worker connecting xprt %p via %s to "
+				"%s (port %s)\n", xprt,
+			xprt->address_strings[RPC_DISPLAY_PROTO],
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT]);
 
 	status = xs_tcp_finish_connecting(xprt, sock);
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
@@ -2228,8 +2231,15 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	dprintk("RPC:       set up transport to address %s\n",
-			xprt->address_strings[RPC_DISPLAY_ALL]);
+	if (xprt_bound(xprt))
+		dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PORT],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
+	else
+		dprintk("RPC:       set up xprt to %s (autobind) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
@@ -2293,8 +2303,16 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	dprintk("RPC:       set up transport to address %s\n",
-			xprt->address_strings[RPC_DISPLAY_ALL]);
+	if (xprt_bound(xprt))
+		dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PORT],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
+	else
+		dprintk("RPC:       set up xprt to %s (autobind) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
+
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;

