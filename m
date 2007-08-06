From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/20] SUNRPC: Add hex-formatted address support
	to	rpc_peeraddr2str()
Date: Mon, 06 Aug 2007 11:57:02 -0400
Message-ID: <20070806155702.31233.3234.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xB-00010L-7s
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:09 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xF-000222-9X
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:13 -0700
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

Add support for the NFS client's need to export volume information
with IP addresses formatted in hex instead of decimal.

This isn't used yet, but subsequent patches (not in this series) will
change the NFS client to use this functionality.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    2 ++
 net/sunrpc/xprtsock.c       |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index d11cedd..4596c26 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -53,6 +53,8 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_PORT,
 	RPC_DISPLAY_PROTO,
 	RPC_DISPLAY_ALL,
+	RPC_DISPLAY_HEX_ADDR,
+	RPC_DISPLAY_HEX_PORT,
 	RPC_DISPLAY_MAX,
 };
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1f71531..eb55ff1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -296,6 +296,20 @@ static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 			xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
 	}
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+
+	buf = kzalloc(10, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 10, "%02x%02x%02x%02x",
+				NIPQUAD(addr->sin_addr.s_addr));
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
+
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 8, "%4hx",
+				ntohs(addr->sin_port));
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
