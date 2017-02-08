Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35930 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdBHQYq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:24:46 -0500
Received: by mail-io0-f196.google.com with SMTP id q20so16303657ioi.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:24:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SUNRPC: Remove unused function rpc_get_timeout()
Date: Wed,  8 Feb 2017 11:17:52 -0500
Message-Id: <20170208161755.3614-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170208161755.3614-1-trond.myklebust@primarydata.com>
References: <20170208161755.3614-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h |  1 -
 net/sunrpc/clnt.c           | 15 ---------------
 2 files changed, 16 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 333ad11b3dd9..33f216edb434 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -182,7 +182,6 @@ int		rpc_protocol(struct rpc_clnt *);
 struct net *	rpc_net_ns(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
 size_t		rpc_max_bc_payload(struct rpc_clnt *);
-unsigned long	rpc_get_timeout(struct rpc_clnt *clnt);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1dc9f3bac099..2838a1fab460 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1453,21 +1453,6 @@ size_t rpc_max_bc_payload(struct rpc_clnt *clnt)
 EXPORT_SYMBOL_GPL(rpc_max_bc_payload);
 
 /**
- * rpc_get_timeout - Get timeout for transport in units of HZ
- * @clnt: RPC client to query
- */
-unsigned long rpc_get_timeout(struct rpc_clnt *clnt)
-{
-	unsigned long ret;
-
-	rcu_read_lock();
-	ret = rcu_dereference(clnt->cl_xprt)->timeout->to_initval;
-	rcu_read_unlock();
-	return ret;
-}
-EXPORT_SYMBOL_GPL(rpc_get_timeout);
-
-/**
  * rpc_force_rebind - force transport to check that remote port is unchanged
  * @clnt: client to rebind
  *
-- 
2.9.3

