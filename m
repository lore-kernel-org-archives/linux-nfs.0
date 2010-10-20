Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:58285 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab0JTQDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 12:03:12 -0400
Received: by gwb19 with SMTP id 19so87756gwb.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Oct 2010 09:03:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] SUNRPC: Use conventional switch statement when
	reclassifying sockets
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Oct 2010 11:52:51 -0400
Message-ID: <20101020155251.6446.28913.stgit@ellison.1015granger.net>
In-Reply-To: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
References: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Defensive coding: If "family" is ever something that is neither
AF_INET nor AF_INET6, xs_reclassify_socket6() is not the appropriate
default action.  Choose to do nothing in that case.

Introduced by commit 6bc9638a.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7915565..b58eef7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1558,7 +1558,7 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
 
-	if (myaddr.ss_family == PF_INET)
+	if (myaddr.ss_family == AF_INET)
 		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
 				&((struct sockaddr_in *)&myaddr)->sin_addr,
 				port, err ? "failed" : "ok", err);
@@ -1594,10 +1594,14 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
-	if (family == PF_INET)
+	switch (family) {
+	case AF_INET:
 		xs_reclassify_socket4(sock);
-	else
+		break;
+	case AF_INET6:
 		xs_reclassify_socket6(sock);
+		break;
+	}
 }
 #else
 static inline void xs_reclassify_socket4(struct socket *sock)

