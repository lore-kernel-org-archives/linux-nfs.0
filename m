Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47302 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843Ab1ITKOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 06:14:51 -0400
Subject: [PATCH v4 7/8] SUNRPC: remove rpcbind clients creation during service
	registering
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 20 Sep 2011 14:14:27 +0400
Message-ID: <20110920101427.9861.24667.stgit@localhost6.localdomain6>
In-Reply-To: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We don't need this code since rpcbind clients are creating during RPC service
creation.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 64e15d1..9327305 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -428,11 +428,6 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	int error;
-
-	error = rpcb_create_local();
-	if (error)
-		return error;
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
@@ -568,11 +563,7 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	int error;
 
-	error = rpcb_create_local();
-	if (error)
-		return error;
 	if (rpcb_local_clnt4 == NULL)
 		return -EPROTONOSUPPORT;
 

