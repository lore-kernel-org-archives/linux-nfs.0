Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36851 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbaHCRDR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:17 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so7873117qgd.19
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] SUNRPC: svc_tcp_write_space: don't clear SOCK_NOSPACE prematurely
Date: Sun,  3 Aug 2014 13:03:04 -0400
Message-Id: <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If requests are queued in the socket inbuffer waiting for an
svc_tcp_has_wspace() requirement to be satisfied, then we do not want
to clear the SOCK_NOSPACE flag until we've satisfied that requirement.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b507cd327d9b..7322ea1164fd 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -446,11 +446,31 @@ static void svc_write_space(struct sock *sk)
 	}
 }
 
+static int svc_tcp_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
+	int required;
+
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
+		return 1;
+	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
+	if (sk_stream_wspace(svsk->sk_sk) >= required ||
+	    (sk_stream_min_wspace(svsk->sk_sk) == 0 &&
+	     atomic_read(&xprt->xpt_reserved) == 0))
+		return 1;
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 0;
+}
+
 static void svc_tcp_write_space(struct sock *sk)
 {
+	struct svc_sock *svsk = (struct svc_sock *)(sk->sk_user_data);
 	struct socket *sock = sk->sk_socket;
 
-	if (sk_stream_is_writeable(sk) && sock)
+	if (!sk_stream_is_writeable(sk) || !sock)
+		return;
+	if (!svsk || svc_tcp_has_wspace(&svsk->sk_xprt))
 		clear_bit(SOCK_NOSPACE, &sock->flags);
 	svc_write_space(sk);
 }
@@ -1197,23 +1217,6 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 	svc_putnl(resv, 0);
 }
 
-static int svc_tcp_has_wspace(struct svc_xprt *xprt)
-{
-	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
-	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
-	int required;
-
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
-		return 1;
-	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
-	if (sk_stream_wspace(svsk->sk_sk) >= required ||
-	    (sk_stream_min_wspace(svsk->sk_sk) == 0 &&
-	     atomic_read(&xprt->xpt_reserved) == 0))
-		return 1;
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	return 0;
-}
-
 static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
 				       struct net *net,
 				       struct sockaddr *sa, int salen,
-- 
1.9.3

