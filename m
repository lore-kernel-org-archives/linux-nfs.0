From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/20] SUNRPC: Rename xs_bind() to prepare for
	IPv6-specific	bind method
Date: Mon, 06 Aug 2007 11:57:28 -0400
Message-ID: <20070806155728.31233.12060.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xc-00012G-0a
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:36 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xe-0002Dz-W6
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:40 -0700
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

Prepare for introduction of IPv6-specific socket bind function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9efdcb5..8e56c38 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1237,7 +1237,7 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 	}
 }
 
-static int xs_bind(struct sock_xprt *transport, struct socket *sock)
+static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 {
 	struct sockaddr_in myaddr = {
 		.sin_family = AF_INET,
@@ -1265,8 +1265,9 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 		else
 			port--;
 	} while (err == -EADDRINUSE && port != transport->port);
-	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %s (%d)\n",
-		NIPQUAD(myaddr.sin_addr), port, err ? "failed" : "ok", err);
+	dprintk("RPC:       %s "NIPQUAD_FMT":%u: %s (%d)\n",
+			__FUNCTION__, NIPQUAD(myaddr.sin_addr),
+			port, err ? "failed" : "ok", err);
 	return err;
 }
 
@@ -1325,7 +1326,7 @@ static void xs_udp_connect_worker(struct work_struct *work)
 	}
 	xs_reclassify_socket(sock);
 
-	if (xs_bind(transport, sock)) {
+	if (xs_bind4(transport, sock)) {
 		sock_release(sock);
 		goto out;
 	}
@@ -1412,7 +1413,7 @@ static void xs_tcp_connect_worker(struct work_struct *work)
 		}
 		xs_reclassify_socket(sock);
 
-		if (xs_bind(transport, sock)) {
+		if (xs_bind4(transport, sock)) {
 			sock_release(sock);
 			goto out;
 		}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
