From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/20] SUNRPC: Free address buffers in a loop
Date: Mon, 06 Aug 2007 11:56:57 -0400
Message-ID: <20070806155657.31233.70469.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4x1-0000uj-8i
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:56:59 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4x5-0005vU-3X
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:03 -0700
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

Use more generic logic to free buffers holding formatted addresses.  This
makes it less likely a bug will be introduced when adding additional buffer
types in xs_format_peer_address().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 81a90e0..1f71531 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -279,10 +279,14 @@ static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 	}
 	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
 
-	if (xprt->prot == IPPROTO_UDP)
-		xprt->address_strings[RPC_DISPLAY_PROTO] = "udp";
-	else
-		xprt->address_strings[RPC_DISPLAY_PROTO] = "tcp";
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		if (xprt->prot == IPPROTO_UDP)
+			snprintf(buf, 8, "udp");
+		else
+			snprintf(buf, 8, "tcp");
+	}
+	xprt->address_strings[RPC_DISPLAY_PROTO] = buf;
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf) {
@@ -296,9 +300,10 @@ static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 {
-	kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
+	int i;
+
+	for (i = 0; i < RPC_DISPLAY_MAX; i++)
+		kfree(xprt->address_strings[i]);
 }
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
