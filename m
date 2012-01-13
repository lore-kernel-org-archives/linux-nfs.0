Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18187 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757696Ab2AMKDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 05:03:01 -0500
Subject: [PATCH v2 1/4] SUNRPC: use proper network namespace in rpcbind
 RPCBPROC_GETADDR procedure
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 14:02:40 +0400
Message-ID: <20120113100240.12259.99660.stgit@localhost6.localdomain6>
In-Reply-To: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
References: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass request socket network namespace to rpc_uaddr2sockaddr() instead of
hardcoded "init_net",  when decoding address in RPCBPROC_GETADDR procedure.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 7c6fac0..4ce3a8e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -934,7 +934,8 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	dprintk("RPC: %5u RPCB_%s reply: %s\n", task->tk_pid,
 			task->tk_msg.rpc_proc->p_name, (char *)p);
 
-	if (rpc_uaddr2sockaddr(&init_net, (char *)p, len, sap, sizeof(address)) == 0)
+	if (rpc_uaddr2sockaddr(req->rq_xprt->xprt_net, (char *)p, len,
+				sap, sizeof(address)) == 0)
 		goto out_fail;
 	rpcb->r_port = rpc_get_port(sap);
 

