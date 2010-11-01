Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38762 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763Ab0KAT61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 15:58:27 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Initialize source address if passed-in srcaddr is
	AF_UNSPEC
To: nbowler@elliptictech.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Nov 2010 15:58:21 -0400
Message-ID: <20101101195631.9279.16018.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Recently xs_bind() was changed so it can't tolerate an AF_UNSPEC
bind address; it needs a fully initialized ANYADDR.  We recently fixed
this case in xprtsock.c, but some upper layer protocols seem to assume
that it's OK to pass in an AF_UNSPEC address for the source address.
Catch that case too.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Untested.

 net/sunrpc/xprtsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfcab5a..fd6484b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2181,7 +2181,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	new = container_of(xprt, struct sock_xprt, xprt);
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
-	if (args->srcaddr)
+	if (args->srcaddr && args->srcaddr->sa_family != AF_UNSPEC)
 		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
 	else {
 		int err;

