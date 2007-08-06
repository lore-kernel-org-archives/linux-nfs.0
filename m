From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/20] SUNRPC: add a function to format IPv6 addresses
Date: Mon, 06 Aug 2007 11:57:12 -0400
Message-ID: <20070806155712.31233.7677.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xI-000114-Sb
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:17 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xM-00028J-QU
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:21 -0700
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

Clone xs_format_ipv4_peer_addresses into an IPv6 version.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 308e172..1de5dee 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -312,6 +312,58 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
 }
 
+static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
+{
+	struct sockaddr_in6 *addr = (struct sockaddr_in6 *) &xprt->addr;
+	char *buf;
+
+	buf = kzalloc(40, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 40, NIP6_FMT,
+				NIP6(addr->sin6_addr));
+	}
+	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 8, "%u",
+				ntohs(addr->sin6_port));
+	}
+	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		if (xprt->prot == IPPROTO_UDP)
+			snprintf(buf, 8, "udp");
+		else
+			snprintf(buf, 8, "tcp");
+	}
+	xprt->address_strings[RPC_DISPLAY_PROTO] = buf;
+
+	buf = kzalloc(64, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 64, "addr="NIP6_FMT" port=%u proto=%s",
+				NIP6(addr->sin6_addr),
+				ntohs(addr->sin6_port),
+				xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+	}
+	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+
+	buf = kzalloc(36, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 36, NIP6_SEQFMT,
+				NIP6(addr->sin6_addr));
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
+
+	buf = kzalloc(8, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 8, "%4hx",
+				ntohs(addr->sin6_port));
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+}
+
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 {
 	int i;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
