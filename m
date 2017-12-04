Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:46780 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751941AbdLDTN5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:13:57 -0500
Subject: [PATCH v1 4/4] SUNRPC: Remove rpc_protocol()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 Dec 2017 14:13:55 -0500
Message-ID: <20171204191354.18629.23260.stgit@manet.1015granger.net>
In-Reply-To: <20171204190904.18629.70341.stgit@manet.1015granger.net>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since nfs4_create_referral_server was the only call site of
rpc_protocol, rpc_protocol can now be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h |    1 -
 net/sunrpc/clnt.c           |   16 ----------------
 2 files changed, 17 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 71c237e..ed761f7 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -179,7 +179,6 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 int		rpc_restart_call_prepare(struct rpc_task *);
 int		rpc_restart_call(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
-int		rpc_protocol(struct rpc_clnt *);
 struct net *	rpc_net_ns(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
 size_t		rpc_max_bc_payload(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e2a4184..6e432ec 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1376,22 +1376,6 @@ int rpc_localaddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t buflen)
 EXPORT_SYMBOL_GPL(rpc_setbufsize);
 
 /**
- * rpc_protocol - Get transport protocol number for an RPC client
- * @clnt: RPC client to query
- *
- */
-int rpc_protocol(struct rpc_clnt *clnt)
-{
-	int protocol;
-
-	rcu_read_lock();
-	protocol = rcu_dereference(clnt->cl_xprt)->prot;
-	rcu_read_unlock();
-	return protocol;
-}
-EXPORT_SYMBOL_GPL(rpc_protocol);
-
-/**
  * rpc_net_ns - Get the network namespace for this RPC client
  * @clnt: RPC client to query
  *

