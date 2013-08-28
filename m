Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4197 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab3H1Tk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 15:40:26 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v2 02/16] SUNRPC: Remove unused struct rpc_clnt field cl_protname
Date: Wed, 28 Aug 2013 15:40:07 -0400
Message-ID: <1377718821-28159-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h | 1 -
 net/sunrpc/clnt.c           | 1 -
 2 files changed, 2 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index bfe11be..481f9c0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -41,7 +41,6 @@ struct rpc_clnt {
 				cl_vers,	/* RPC version number */
 				cl_maxproc;	/* max procedure number */
 
-	const char *		cl_protname;	/* protocol name */
 	struct rpc_auth *	cl_auth;	/* authenticator */
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e862f8c..a327cc7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -348,7 +348,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
-	clnt->cl_protname = program->name;
 	clnt->cl_prog     = args->prognumber ? : program->number;
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
-- 
1.8.3.1

