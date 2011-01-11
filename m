Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932363Ab1AKQVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/14] rpc: move sk_bc_xprt to svc_xprt
Date: Tue, 11 Jan 2011 11:21:24 -0500
Message-Id: <1294762894-21371-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This seems obviously transport-level information even if it's currently
used only by the server socket code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    1 -
 net/sunrpc/svcsock.c            |   10 ++++++----
 net/sunrpc/xprtsock.c           |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c8f81da..7ad9751 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -79,6 +79,7 @@ struct svc_xprt {
 	struct list_head	xpt_users;	/* callbacks on free */
 
 	struct net		*xpt_net;
+	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 1b353a7..04dba23 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,7 +28,6 @@ struct svc_sock {
 	/* private TCP part */
 	u32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
-	struct rpc_xprt		*sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 52bd113..3bb400f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -987,15 +987,17 @@ static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
 		vec[0] = rqstp->rq_arg.head[0];
 	} else {
 		/* REPLY */
-		if (svsk->sk_bc_xprt)
-			req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
+		struct rpc_xprt *bc_xprt = svsk->sk_xprt.xpt_bc_xprt;
+
+		if (bc_xprt)
+			req = xprt_lookup_rqst(bc_xprt, xid);
 
 		if (!req) {
 			printk(KERN_NOTICE
 				"%s: Got unrecognized reply: "
-				"calldir 0x%x sk_bc_xprt %p xid %08x\n",
+				"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
 				__func__, ntohl(calldir),
-				svsk->sk_bc_xprt, xid);
+				bc_xprt, xid);
 			vec[0] = rqstp->rq_arg.head[0];
 			goto out;
 		}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfcab5a..18dc42e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2379,9 +2379,9 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	 * The backchannel uses the same socket connection as the
 	 * forechannel
 	 */
+	args->bc_xprt->xpt_bc_xprt = xprt;
 	xprt->bc_xprt = args->bc_xprt;
 	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
-	bc_sock->sk_bc_xprt = xprt;
 	transport->sock = bc_sock->sk_sock;
 	transport->inet = bc_sock->sk_sk;
 
-- 
1.7.1

