From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/30] SUNRPC: Fix a memory leak in rpcb_getport_async
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.64490.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207AbYJGWcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:51 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0b025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:48 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 172935b..0a22f00 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -580,7 +580,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		status = -ENOMEM;
 		dprintk("RPC: %5u %s: no memory available\n",
 			task->tk_pid, __func__);
-		goto bailout_nofree;
+		goto bailout_release_client;
 	}
 	map->r_prog = clnt->cl_prog;
 	map->r_vers = clnt->cl_vers;
@@ -605,6 +605,8 @@ void rpcb_getport_async(struct rpc_task *task)
 	rpc_put_task(child);
 	return;
 
+bailout_release_client:
+	rpc_release_client(rpcb_clnt);
 bailout_nofree:
 	rpcb_wake_rpcbind_waiters(xprt, status);
 	task->tk_status = status;

