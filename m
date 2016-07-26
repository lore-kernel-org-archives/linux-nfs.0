Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36302 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109AbcGZNvp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2016 09:51:45 -0400
Received: by mail-it0-f65.google.com with SMTP id j124so659646ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2016 06:51:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: accept() may return sockets that are still in SYN_RECV
Date: Tue, 26 Jul 2016 09:51:19 -0400
Message-Id: <1469541080-4184-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're seeing traces of the following form:

 [10952.396347] svc: transport ffff88042ba4a 000 dequeued, inuse=2
 [10952.396351] svc: tcp_accept ffff88042ba4 a000 sock ffff88042a6e4c80
 [10952.396362] nfsd: connect from 10.2.6.1, port=187
 [10952.396364] svc: svc_setup_socket ffff8800b99bcf00
 [10952.396368] setting up TCP socket for reading
 [10952.396370] svc: svc_setup_socket created ffff8803eb10a000 (inet ffff88042b75b800)
 [10952.396373] svc: transport ffff8803eb10a000 put into queue
 [10952.396375] svc: transport ffff88042ba4a000 put into queue
 [10952.396377] svc: server ffff8800bb0ec000 waiting for data (to = 3600000)
 [10952.396380] svc: transport ffff8803eb10a000 dequeued, inuse=2
 [10952.396381] svc_recv: found XPT_CLOSE
 [10952.396397] svc: svc_delete_xprt(ffff8803eb10a000)
 [10952.396398] svc: svc_tcp_sock_detach(ffff8803eb10a000)
 [10952.396399] svc: svc_sock_detach(ffff8803eb10a000)
 [10952.396412] svc: svc_sock_free(ffff8803eb10a000)

i.e. an immediate close of the socket after initialisation.

The culprit appears to be the test at the end of svc_tcp_init, which
checks if the newly created socket is in the TCP_ESTABLISHED state,
and immediately closes it if not. The evidence appears to suggest that
the socket might still be in the SYN_RECV state at this time.

The fix is to check for both states, and then to add a check in
svc_tcp_state_change() to ensure we don't close the socket when
it transitions into TCP_ESTABLISHED.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index df61a4ec21a4..38b132ff6dce 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -767,8 +767,10 @@ static void svc_tcp_state_change(struct sock *sk)
 		printk("svc: socket %p: no user data\n", sk);
 	else {
 		svsk->sk_ostate(sk);
-		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-		svc_xprt_enqueue(&svsk->sk_xprt);
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+			svc_xprt_enqueue(&svsk->sk_xprt);
+		}
 	}
 }
 
@@ -1294,8 +1296,13 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		if (sk->sk_state != TCP_ESTABLISHED)
+		switch (sk->sk_state) {
+		case TCP_SYN_RECV:
+		case TCP_ESTABLISHED:
+			break;
+		default:
 			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+		}
 	}
 }
 
-- 
2.7.4

