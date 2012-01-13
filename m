Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41052 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756334Ab2AMIw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 03:52:56 -0500
Subject: [PATCH v5 4/6] SUNRPC: create rpcbind client in passed network
 namespace context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 12:52:35 +0400
Message-ID: <20120113085234.31750.46126.stgit@localhost6.localdomain6>
In-Reply-To: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
References: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rpcbind clients are per network namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 371d229..0d76c0f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -344,11 +344,12 @@ out:
 	return result;
 }
 
-static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version)
+static struct rpc_clnt *rpcb_create(struct net *net, char *hostname,
+				    struct sockaddr *srvaddr, size_t salen,
+				    int proto, u32 version)
 {
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= net,
 		.protocol	= proto,
 		.address	= srvaddr,
 		.addrsize	= salen,
@@ -708,8 +709,8 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __func__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
-				bind_version);
+	rpcb_clnt = rpcb_create(xprt->xprt_net, clnt->cl_server, sap, salen,
+				xprt->prot, bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",

