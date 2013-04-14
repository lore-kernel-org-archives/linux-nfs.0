Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50341 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219Ab3DNRAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Apr 2013 13:00:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] SUNRPC: Allow rpc_create() to request that TCP slots be unlimited
Date: Sun, 14 Apr 2013 13:00:37 -0400
Message-Id: <1365958838-39047-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365958838-39047-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365958838-39047-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is mainly for use by NFSv4.1, where the session negotiation
ultimately wants to decide how many RPC slots we can fill.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 include/linux/sunrpc/xprt.h | 3 +++
 net/sunrpc/clnt.c           | 2 ++
 net/sunrpc/xprtsock.c       | 6 +++++-
 4 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 2cf4ffa..e7d492c 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -124,6 +124,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
 #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
 #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
+#define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 12815f6..ff53924 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -255,6 +255,8 @@ static inline int bc_prealloc(struct rpc_rqst *req)
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
+#define XPRT_CREATE_INFINITE_SLOTS	(1U)
+
 struct xprt_create {
 	int			ident;		/* XPRT_TRANSPORT identifier */
 	struct net *		net;
@@ -263,6 +265,7 @@ struct xprt_create {
 	size_t			addrlen;
 	const char		*servername;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	unsigned int		flags;
 };
 
 struct xprt_class {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a80ee9b..651245a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -414,6 +414,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	};
 	char servername[48];
 
+	if (args->flags & RPC_CLNT_CREATE_INFINITE_SLOTS)
+		xprtargs.flags |= XPRT_CREATE_INFINITE_SLOTS;
 	/*
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3081620..726e702 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2762,9 +2762,13 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	struct rpc_xprt *xprt;
 	struct sock_xprt *transport;
 	struct rpc_xprt *ret;
+	unsigned int max_slot_table_size = xprt_max_tcp_slot_table_entries;
+
+	if (args->flags & XPRT_CREATE_INFINITE_SLOTS)
+		max_slot_table_size = RPC_MAX_SLOT_TABLE_LIMIT;
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries,
-			xprt_max_tcp_slot_table_entries);
+			max_slot_table_size);
 	if (IS_ERR(xprt))
 		return xprt;
 	transport = container_of(xprt, struct sock_xprt, xprt);
-- 
1.8.1.4

