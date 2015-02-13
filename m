Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41442 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbBMSI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 13:08:28 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so12189546igb.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 10:08:27 -0800 (PST)
Subject: [PATCH] SUNRPC: Always manipulate rpc_rqst::rq_bc_pa_list under
 xprt->bc_pa_lock
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 13 Feb 2015 13:08:25 -0500
Message-ID: <20150213180513.10705.1546.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Other code that accesses rq_bc_pa_list holds xprt->bc_pa_lock.
xprt_complete_bc_request() should do the same.

Fixes: 2ea24497a1b3 ("SUNRPC: RPC callbacks may be split . . .")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
How about this (compile-tested only)?

 net/sunrpc/backchannel_rqst.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 651f49a..9dd0ea8d 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -309,12 +309,15 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct svc_serv *bc_serv = xprt->bc_serv;
 
+	spin_lock(&xprt->bc_pa_lock);
+	list_del(&req->rq_bc_pa_list);
+	spin_unlock(&xprt->bc_pa_lock);
+
 	req->rq_private_buf.len = copied;
 	set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
 
 	dprintk("RPC:       add callback request to list\n");
 	spin_lock(&bc_serv->sv_cb_lock);
-	list_del(&req->rq_bc_pa_list);
 	list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
 	wake_up(&bc_serv->sv_cb_waitq);
 	spin_unlock(&bc_serv->sv_cb_lock);

