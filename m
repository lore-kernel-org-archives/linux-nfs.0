From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/17] SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listener
	sockets
Date: Tue, 03 Mar 2009 17:32:55 -0500
Message-ID: <20090303223254.2933.70364.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:63402 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbZCCWd0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:33:26 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are about to convert to using separate RPC listener sockets for
AF_INET and AF_INET6.  This echoes the way IPv6 is handled in user
space by TI-RPC, and eliminates the need to worry about mapped IPv4
AF_INET6 addresses when doing address comparisons.

Start by setting the IPV6ONLY flag on RPC listener sockets.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d00bc33..ac6cd65 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1144,13 +1144,11 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		svc_tcp_init(svsk, serv);
 
 	/*
-	 * We start one listener per sv_serv.  We want AF_INET
-	 * requests to be automatically shunted to our PF_INET6
-	 * listener using a mapped IPv4 address.  Make sure
-	 * no-one starts an equivalent IPv4 listener, which
-	 * would steal our incoming connections.
+	 * If this is a PF_INET6 listener, we want to avoid
+	 * getting requests from IPv4 remotes.  Those should
+	 * be shunted to a PF_INET listener via rpcbind.
 	 */
-	val = 0;
+	val = 1;
 	if (inet->sk_family == PF_INET6)
 		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
 					(char *)&val, sizeof(val));

