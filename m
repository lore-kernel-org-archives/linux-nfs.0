From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener sockets
Date: Wed, 13 Aug 2008 18:39:54 -0400
Message-ID: <20080813223953.13068.97829.stgit@manray.1015granger.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30800 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbYHMWlq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:41:46 -0400
In-Reply-To: <20080813223653.13068.9467.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My plan is to use an AF_INET listener on systems that support only IPv4,
and an AF_INET6 listener on systems that can support IPv6. Incoming
IPv4 packets will be posted to an AF_INET6 listener with a mapped IPv4
address.

Max Matveev <makc@sgi.com> says:
  Creating a single listener can be dangerous - if net.ipv6.bindv6only
  is enabled then it's possible to create another listener in v4
  namespace on the same port and steal the traffic from the "unifed"
  listener. You need to disable V6ONLY explicitly via a sockopt to stop
  that.

Set appropriate socket option on RPC server listener sockets to prevent
this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3e65719..f91377c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1114,6 +1114,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
+	int		val;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
@@ -1146,6 +1147,18 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	else
 		svc_tcp_init(svsk, serv);
 
+	/*
+	 * We start one listener per sv_serv.  We want AF_INET
+	 * requests to be automatically shunted to our AF_INET6
+	 * listener using a mapped IPv4 address.  Make sure
+	 * no-one starts an equivalent IPv4 listener, which
+	 * would steal our incoming connections.
+	 */
+	val = 0;
+	if (serv->sv_family == AF_INET6)
+		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
+					(char *)&val, sizeof(val));
+
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);
 

