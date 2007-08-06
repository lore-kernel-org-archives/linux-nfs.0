From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/20] SUNRPC: Rename xs_format_peer_addresses
Date: Mon, 06 Aug 2007 11:57:07 -0400
Message-ID: <20070806155707.31233.15635.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xH-00010y-K6
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:15 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xK-00025b-Lp
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:19 -0700
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

Prepare to add an IPv6 version of xs_format_peer_addresses by renaming it
to xs_format_ipv4_peer_addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index eb55ff1..308e172 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -260,7 +260,7 @@ struct sock_xprt {
 #define TCP_RCV_COPY_XID	(1UL << 2)
 #define TCP_RCV_COPY_DATA	(1UL << 3)
 
-static void xs_format_peer_addresses(struct rpc_xprt *xprt)
+static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
 	char *buf;
@@ -1610,7 +1610,7 @@ struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
 	else
 		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
 
-	xs_format_peer_addresses(xprt);
+	xs_format_ipv4_peer_addresses(xprt);
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1652,7 +1652,7 @@ struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
 	else
 		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
 
-	xs_format_peer_addresses(xprt);
+	xs_format_ipv4_peer_addresses(xprt);
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
