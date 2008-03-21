From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Clean up: rename sock_xprt's addr field
Date: Fri, 21 Mar 2008 18:07:43 -0400
Message-ID: <20080321220617.15442.42229.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:29946 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYCUWIA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:08:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The usual convention is to use the name "addr" for fields that store
destination addresses in the RPC client.  The sock_xprt's addr field is
a socket's source address, not a destination address.

Clean up: rename this field in order to make it less confusing.

Note that the client-side RDMA transport doesn't copy out the source
address field passed in from xprt_create_transport(); it doesn't need to do
this yet, but perhaps it should if rpcbind and NLM over RDMA are ever
implemented.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
A singleton clean-up patch for 2.6.26.  Cc: linux-nfs for those of you
following along at home.
---

 net/sunrpc/xprtsock.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8bd3b0f..560fff1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -240,7 +240,7 @@ struct sock_xprt {
 	 * Connection of transports
 	 */
 	struct delayed_work	connect_worker;
-	struct sockaddr_storage	addr;
+	struct sockaddr_storage	source_address;
 	unsigned short		port;
 
 	/*
@@ -1344,7 +1344,7 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in *)&transport->addr;
+	sa = (struct sockaddr_in *)&transport->source_address;
 	myaddr.sin_addr = sa->sin_addr;
 	do {
 		myaddr.sin_port = htons(port);
@@ -1377,7 +1377,7 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport, sock);
 	unsigned short last;
 
-	sa = (struct sockaddr_in6 *)&transport->addr;
+	sa = (struct sockaddr_in6 *)&transport->source_address;
 	myaddr.sin6_addr = sa->sin6_addr;
 	do {
 		myaddr.sin6_port = htons(port);
@@ -1885,7 +1885,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
-		memcpy(&new->addr, args->srcaddr, args->addrlen);
+		memcpy(&new->source_address, args->srcaddr, args->addrlen);
 
 	return xprt;
 }

