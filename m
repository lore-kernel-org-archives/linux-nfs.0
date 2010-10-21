Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50544 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab0JUT0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 15:26:44 -0400
Subject: [PATCH] xs_bind retry binding forever
To: Trond.Myklebust@netapp.com
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 21 Oct 2010 13:33:37 -0500
Message-ID: <20101021183337.12776.18768.stgit@lady3jane.americas.sgi.com>
In-Reply-To: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com>
References: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Retry bind for reserved source ports forever.  Add an error message when we
have a hard time binding one.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 net/sunrpc/xprtsock.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b6309db..79a001b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1560,9 +1560,16 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		}
 		last = port;
 		port = xs_next_srcport(transport, sock, port);
-		if (port > last)
+		if (port > last) {
+			if (nloop > 2 && net_ratelimit()) {
+				printk("RPC: %s %pI4: Cannot bind reserved "
+				       "source port.  Consider decreasing "
+				       "min_resvport.\n",
+				       __func__, &myaddr.sin_addr);
+			}
 			nloop++;
-	} while (err == -EADDRINUSE && nloop != 2);
+		}
+	} while (err == -EADDRINUSE);
 	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
 			__func__, &myaddr.sin_addr,
 			port, err ? "failed" : "ok", err);
@@ -1593,9 +1600,16 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		}
 		last = port;
 		port = xs_next_srcport(transport, sock, port);
-		if (port > last)
+		if (port > last) {
+			if (nloop > 2 && net_ratelimit()) {
+				printk("RPC: %s %pI6: Cannot bind reserved "
+				       "source port.  Consider decreasing "
+				       "min_resvport.\n",
+					__func__, &myaddr.sin6_addr);
+			}
 			nloop++;
-	} while (err == -EADDRINUSE && nloop != 2);
+		}
+	} while (err == -EADDRINUSE);
 	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
 		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
 	return err;

