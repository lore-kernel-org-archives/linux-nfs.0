Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34212 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdHPXAQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 19:00:16 -0400
Received: by mail-io0-f195.google.com with SMTP id m88so3127718iod.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 16:00:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/5] SUNRPC: Don't hold the transport lock when receiving backchannel data
Date: Wed, 16 Aug 2017 19:00:05 -0400
Message-Id: <20170816230008.20006-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170816230008.20006-2-trond.myklebust@primarydata.com>
References: <20170816230008.20006-1-trond.myklebust@primarydata.com>
 <20170816230008.20006-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The backchannel request has no associated task, so it is going nowhere
until we call xprt_complete_bc_request().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 4 ++--
 net/sunrpc/xprtsock.c         | 5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index ac701c28f44f..c2c68a15b59d 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -171,10 +171,10 @@ int xprt_setup_bc(struct rpc_xprt *xprt, unsigned int min_reqs)
 	/*
 	 * Add the temporary list to the backchannel preallocation list
 	 */
-	spin_lock_bh(&xprt->bc_pa_lock);
+	spin_lock(&xprt->bc_pa_lock);
 	list_splice(&tmp_list, &xprt->bc_pa_list);
 	xprt_inc_alloc_count(xprt, min_reqs);
-	spin_unlock_bh(&xprt->bc_pa_lock);
+	spin_unlock(&xprt->bc_pa_lock);
 
 	dprintk("RPC:       setup backchannel transport done\n");
 	return 0;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 04dbc7027712..a2312f14beb4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1389,11 +1389,9 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 
-	/* Look up and lock the request corresponding to the given XID */
-	spin_lock_bh(&xprt->transport_lock);
+	/* Look up the request corresponding to the given XID */
 	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
 	if (req == NULL) {
-		spin_unlock_bh(&xprt->transport_lock);
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
 		return -1;
@@ -1404,7 +1402,6 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_bc_request(req, transport->tcp_copied);
-	spin_unlock_bh(&xprt->transport_lock);
 
 	return 0;
 }
-- 
2.13.5

