From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Fix the return value of rpc_run_bc_task()
Date: Fri, 19 Mar 2010 16:16:37 -0400
Message-ID: <1269029797.10771.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30837 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab0CSURd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Mar 2010 16:17:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently rpc_run_bc_task() will return NULL if the task allocation failed.
However the only caller is bc_send, which assumes that the return value
will be an ERR_PTR.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 154034b..19c9983 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -659,6 +659,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
 	task = rpc_new_task(&task_setup_data);
 	if (!task) {
 		xprt_free_bc_request(req);
+		task = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 	task->tk_rqstp = req;

