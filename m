Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58936 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771Ab1GOR4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 13:56:46 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH (RESEND) 01/12] sunrpc:  Don't attempt to bind to AF_UNSPEC address.
Date: Fri, 15 Jul 2011 10:55:57 -0700
Message-Id: <1310752568-21280-2-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This lets calling code simply pass AF_UNSPEC addresses
instead of adding lots of checks to conditionally pass
NULL addresses.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 72abb73... 37299c0... M	net/sunrpc/xprtsock.c
 net/sunrpc/xprtsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 72abb73..37299c0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2509,9 +2509,9 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
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

