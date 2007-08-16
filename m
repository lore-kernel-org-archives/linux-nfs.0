From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Add support for formatted universal
	addresses
Date: Thu, 16 Aug 2007 16:03:26 -0400
Message-ID: <20070816200326.3831.43473.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILlZj-0005pM-GU
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:04:11 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILlZn-0003n7-KE
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:04:15 -0700
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

"Universal addresses" are a string representation of an IP address and
port.  They are described fully in RFC 3530, section 2.2.  Add support
for generating them in the RPC client's socket transport module.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 4596c26..902a9c0 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -55,6 +55,7 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_ALL,
 	RPC_DISPLAY_HEX_ADDR,
 	RPC_DISPLAY_HEX_PORT,
+	RPC_DISPLAY_UNIVERSAL_ADDR,
 	RPC_DISPLAY_MAX,
 };
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 45b2af1..4fa0cd9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -328,6 +328,15 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt)
 				ntohs(addr->sin_port));
 	}
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+
+	buf = kzalloc(30, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 30, NIPQUAD_FMT".%u.%u",
+				NIPQUAD(addr->sin_addr.s_addr),
+				ntohs(addr->sin_port) >> 8,
+				ntohs(addr->sin_port) & 0xff);
+	}
+	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 }
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
@@ -380,6 +389,15 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
 				ntohs(addr->sin6_port));
 	}
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
+
+	buf = kzalloc(50, GFP_KERNEL);
+	if (buf) {
+		snprintf(buf, 50, NIP6_FMT".%u.%u",
+				NIP6(addr->sin6_addr),
+				ntohs(addr->sin6_port) >> 8,
+				ntohs(addr->sin6_port) & 0xff);
+	}
+	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
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
