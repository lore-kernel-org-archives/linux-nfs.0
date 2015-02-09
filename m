Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:42314 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933602AbbBIRTA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:19:00 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so17805878iga.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:18:59 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/14] SUNRPC: Cleanup to remove remaining uses of XPRT_CONNECTION_ABORT
Date: Mon,  9 Feb 2015 12:18:39 -0500
Message-Id: <1423502324-25981-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-9-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-5-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-7-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-8-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-9-git-send-email-trond.myklebust@primarydata.com>
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
index c65f74019288..2f8db3499a17 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -804,7 +804,6 @@ static void xs_error_report(struct sock *sk)
 static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
 {
 	smp_mb__before_atomic();
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
@@ -1904,7 +1903,6 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	struct socket *sock;
 	int status = -EIO;
 
-	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	status = __sock_create(xprt->xprt_net, AF_LOCAL,
 					SOCK_STREAM, 0, &sock, 1);
 	if (status < 0) {
@@ -2149,7 +2147,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	int status = -EIO;
 
 	if (!sock) {
-		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
 				xs_addr(xprt)->sa_family, SOCK_STREAM,
 				IPPROTO_TCP, true);
-- 
2.1.0

