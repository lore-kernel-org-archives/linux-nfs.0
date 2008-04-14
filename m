From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/24] SUNRPC: RPC server still uses 2.4 method for disabling
	TCP Nagle
Date: Mon, 14 Apr 2008 12:27:01 -0400
Message-ID: <20080414162701.12741.10868.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:48607 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119AbYDNQ11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:27 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the 2.6 method for disabling TCP Nagle in the kernel's RPC server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c475977..6d4162b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -38,6 +38,7 @@
 #include <net/checksum.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/tcp.h>
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -1045,7 +1046,6 @@ void svc_cleanup_xprt_sock(void)
 static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
 	struct sock	*sk = svsk->sk_sk;
-	struct tcp_sock *tp = tcp_sk(sk);
 
 	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
@@ -1063,7 +1063,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
 
-		tp->nonagle = 1;        /* disable Nagle's algorithm */
+		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
 		/* initialise setting must have enough space to
 		 * receive and respond to one request.

