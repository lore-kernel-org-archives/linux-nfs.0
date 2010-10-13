Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:36081 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab0JMVok (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 17:44:40 -0400
Received: from lady3jane.americas.sgi.com (lady3jane.americas.sgi.com [128.162.244.187])
	by relay1.corp.sgi.com (Postfix) with ESMTP id A1ADF8F8040
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 14:44:39 -0700 (PDT)
Received: from lady3jane.americas.sgi.com (localhost [127.0.0.1])
	by lady3jane.americas.sgi.com (Postfix) with ESMTP id 11CD42416E13
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:52:05 -0500 (CDT)
Subject: [PATCH] Add an error message for xs_bind
To: linux-nfs@vger.kernel.org
From: Ben Myers <bpm@sgi.com>
Date: Wed, 13 Oct 2010 15:52:05 -0500
Message-ID: <20101013205205.17640.48657.stgit@lady3jane.americas.sgi.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

xs_bind4 doesn't log an error when it can't get a reserved source port due to
them all being in use.  This situation can be hard to debug when it is
intermittent or you don't know what to look for in the debug output.  Add an
error message describing how to resolve this problem when it happens.
---
 net/sunrpc/xprtsock.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fe9306b..ea5f38e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1563,6 +1563,12 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
+	if (err == -EADDRINUSE && nloop == 2 && transport->xprt.resvport) {
+		printk("RPC: %s %pI4: cannot bind reserved source port, "
+				"too many ports already in use.  "
+				"consider increasing xprt_max_resvport.\n",
+				__func__, &myaddr.sin_addr);
+	}
 	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
 			__func__, &myaddr.sin_addr,
 			port, err ? "failed" : "ok", err);
@@ -1596,6 +1602,12 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
+	if (err == -EADDRINUSE && nloop == 2 && transport->xprt.resvport) {
+		printk("RPC: %s %pI6: cannot bind reserved source port, "
+				"too many ports already in use.  "
+				"consider increasing xprt_max_resvport.\n",
+				__func__, &myaddr.sin6_addr);
+	}
 	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
 		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
 	return err;

