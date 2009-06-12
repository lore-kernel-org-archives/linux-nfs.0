From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 11/14] SQUASHME: Moves embedded #ifdefs into #ifdef function blocks
Date: Thu, 11 Jun 2009 22:54:17 -0700
Message-ID: <1244786060-2200-12-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55147 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbZFLF6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:11 -0400
In-Reply-To: <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: New xs_tcp_read_data()]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/xprtsock.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fe57ebd..c6f24c0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1207,6 +1207,23 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	return 0;
 }
+
+static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
+					struct xdr_skb_reader *desc)
+{
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+
+	return (transport->tcp_flags & TCP_RPC_REPLY) ?
+		xs_tcp_read_reply(xprt, desc) :
+		xs_tcp_read_callback(xprt, desc);
+}
+#else
+static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
+					struct xdr_skb_reader *desc)
+{
+	return xs_tcp_read_reply(xprt, desc);
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -1218,17 +1235,8 @@ static void xs_tcp_read_data(struct rpc_xprt *xprt,
 {
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
-	int status;
-
-#if defined(CONFIG_NFS_V4_1)
-	status = (transport->tcp_flags & TCP_RPC_REPLY) ?
-		xs_tcp_read_reply(xprt, desc) :
-		xs_tcp_read_callback(xprt, desc);
-#else
-	status = xs_tcp_read_reply(xprt, desc);
-#endif /* CONFIG_NFS_V4_1 */
 
-	if (status == 0)
+	if (_xs_tcp_read_data(xprt, desc) == 0)
 		xs_tcp_check_fraghdr(transport);
 	else {
 		/*
-- 
1.5.4.3

