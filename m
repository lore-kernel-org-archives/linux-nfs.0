Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56186 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932364Ab1AKQVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/14] rpc: allow xprt_class->setup to return a preexisting xprt
Date: Tue, 11 Jan 2011 11:21:26 -0500
Message-Id: <1294762894-21371-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This allows us to reuse the xprt associated with a server connection if
one has already been set up.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |    3 +++
 net/sunrpc/xprtsock.c       |   18 +++++++++---------
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 89d10d2..bef0f53 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -321,6 +321,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_CLOSING		(6)
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
+#define XPRT_INITIALIZED	(9)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 749ad15..856274d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1102,6 +1102,9 @@ found:
 				-PTR_ERR(xprt));
 		return xprt;
 	}
+	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state))
+		/* ->setup returned a pre-initialized xprt: */
+		return xprt;
 
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0ef4dd4..ee091c8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2359,6 +2359,15 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct svc_sock *bc_sock;
 	struct rpc_xprt *ret;
 
+	if (args->bc_xprt->xpt_bc_xprt) {
+		/*
+		 * This server connection already has a backchannel
+		 * export; we can't create a new one, as we wouldn't be
+		 * able to match replies based on xid any more.  So,
+		 * reuse the already-existing one:
+		 */
+		 return args->bc_xprt->xpt_bc_xprt;
+	}
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
@@ -2397,15 +2406,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 			xprt->address_strings[RPC_DISPLAY_PROTO]);
 
 	/*
-	 * The backchannel uses the same socket connection as the
-	 * forechannel
-	 */
-	if (args->bc_xprt->xpt_bc_xprt) {
-		/* XXX: actually, want to catch this case... */
-		ret = ERR_PTR(-EINVAL);
-		goto out_err;
-	}
-	/*
 	 * Once we've associated a backchannel xprt with a connection,
 	 * we want to keep it around as long as long as the connection
 	 * lasts, in case we need to start using it for a backchannel
-- 
1.7.1

