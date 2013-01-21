Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39845 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab3AUUq2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:28 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 01/13] sunrpc: Don't attempt to bind to AF_UNSPEC address.
Date: Mon, 21 Jan 2013 12:45:47 -0800
Message-Id: <1358801159-18829-2-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This lets calling code simply pass AF_UNSPEC addresses
instead of adding lots of checks to conditionally pass
NULL addresses.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 net/sunrpc/xprtsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 75853ca..32a016e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2561,9 +2561,9 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 	new = container_of(xprt, struct sock_xprt, xprt);
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;
-	if (args->srcaddr)
+	if (args->srcaddr && (args->srcaddr->sa_family != AF_UNSPEC)) {
 		memcpy(&new->srcaddr, args->srcaddr, args->addrlen);
-	else {
+	} else {
 		int err;
 		err = xs_init_anyaddr(args->dstaddr->sa_family,
 					(struct sockaddr *)&new->srcaddr);
-- 
1.7.3.4

