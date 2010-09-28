Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7841 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756568Ab0I1PRx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 11:17:53 -0400
Message-ID: <4CA20716.7000306@parallels.com>
Date: Tue, 28 Sep 2010 19:17:42 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] sunrpc: Add net to xprt_create
References: <4CA20651.4070605@parallels.com>
In-Reply-To: <4CA20651.4070605@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index af4b560..c4f9315 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -249,6 +249,7 @@ static inline int bc_prealloc(struct rpc_rqst *req)
 
 struct xprt_create {
 	int			ident;		/* XPRT_TRANSPORT identifier */
+	struct net *		net;
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa55490..f4bbd83 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -284,6 +284,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
 	struct xprt_create xprtargs = {
+		.net = args->net,
 		.ident = args->protocol,
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
-- 
1.5.5.6

