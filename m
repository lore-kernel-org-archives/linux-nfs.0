Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56232 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab0JTPxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 11:53:04 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so2427262iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Oct 2010 08:53:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] SUNRPC: Properly initialize sock_xprt.srcaddr in all cases
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Oct 2010 11:53:01 -0400
Message-ID: <20101020155301.6446.43378.stgit@ellison.1015granger.net>
In-Reply-To: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
References: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The source address field in the transport's sock_xprt is initialized
ONLY IF the RPC application passed a pointer to a source address
during the call to rpc_create().  However, xs_bind() subsequently uses
the value of this field without regard to whether the source address
was initialized during transport creation or not.

So far we've been lucky: the uninitialized value of this field is
zeroes.  xs_bind(), until recently, used only the sin[6]_addr field in
this sockaddr, and all zeroes is a valid value for this: it means
ANYADDR.  This is a happy coincidence.

However, xs_bind() now wants to use the sa_family field as well, and
expects it to be initialized to something other than zero.

Therefore, the source address sockaddr field should be fully
initialized at transport create time in _every_ case, not just when
the RPC application wants to use a specific bind address.

Bruce added a workaround for this missing initialization by adjusting
commit 6bc9638a, but the "right" way to do this is to ensure that the
source address sockaddr is always correctly initialized from the
get-go.

This patch doesn't introduce a behavior change.  It's simply a
clean-up of Bruce's fix, to prevent future problems of this kind.  It
may look like overkill, but

  a) it clearly documents the default initial value of this field,

  b) it doesn't assume that the sockaddr_storage memory is first
     initialized to any particular value, and

  c) it will fail verbosely if some unknown address family is passed
     in

Originally introduced by commit d3bc9a1d.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b58eef7..27fc4b4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1629,7 +1629,6 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
 				protocol, -err);
 		goto out;
 	}
-	transport->srcaddr.ss_family = family;
 	xs_reclassify_socket(family, sock);
 
 	if (xs_bind(transport, sock)) {
@@ -2136,6 +2135,31 @@ static struct rpc_xprt_ops bc_tcp_ops = {
 	.print_stats		= xs_tcp_print_stats,
 };
 
+static int xs_init_anyaddr(const int family, struct sockaddr *sap)
+{
+	static const struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+	};
+	static const struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+	};
+
+	switch (family) {
+	case AF_INET:
+		memcpy(sap, &sin, sizeof(sin));
+		break;
+	case AF_INET6:
+		memcpy(sap, &sin6, sizeof(sin6));
+		break;
+	default:
+		dprintk("RPC:       %s: Bad address family\n", __func__);
+		return -EAFNOSUPPORT;
+	}
+	return 0;
+}
+
 static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
 {
@@ -2159,6 +2183,13 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	xprt->addrlen = args->addrlen;
 	if (args->srcaddr)
 		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
+	else {
+		int err;
+		err = xs_init_anyaddr(args->dstaddr->sa_family,
+					(struct sockaddr *)&new->srcaddr);
+		if (err != 0)
+			return ERR_PTR(err);
+	}
 
 	return xprt;
 }

