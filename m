Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:51879 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759258AbbBIDH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:57 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so13707399igd.3
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] SUNRPC: Cleanup to remove remaining uses of XPRT_CONNECTION_ABORT
Date: Sun,  8 Feb 2015 22:07:41 -0500
Message-Id: <1423451262-84493-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-10-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-5-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-6-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-7-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-8-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-9-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h | 1 -
 net/sunrpc/xprtsock.c       | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 86af854338b5..ae39d478a272 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -360,7 +360,6 @@ void			xprt_unlock_connect(struct rpc_xprt *, void *);
 #define XPRT_BOUND		(4)
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
-#define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ca45f1c1c36d..2e2ee764500f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -785,7 +785,6 @@ static void xs_error_report(struct sock *sk)
 static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
 {
 	smp_mb__before_atomic();
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
@@ -1876,7 +1875,6 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	struct socket *sock;
 	int status = -EIO;
 
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	status = __sock_create(xprt->xprt_net, AF_LOCAL,
 					SOCK_STREAM, 0, &sock, 1);
 	if (status < 0) {
@@ -2121,7 +2119,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	int status = -EIO;
 
 	if (!sock) {
-		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
 				xs_addr(xprt)->sa_family, SOCK_STREAM,
 				IPPROTO_TCP, true);
-- 
2.1.0

