Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33579 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbbFDV07 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:26:59 -0400
Received: by igbpi8 with SMTP id pi8so1761904igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:26:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] SUNRPC: Remove unused argument 'tk_ops' in rpc_run_bc_task
Date: Thu,  4 Jun 2015 17:26:51 -0400
Message-Id: <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h | 3 +--
 net/sunrpc/clnt.c            | 5 ++---
 net/sunrpc/svc.c             | 3 +--
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 5f1e6bd4c316..2aa68976a482 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -205,8 +205,7 @@ struct rpc_wait_queue {
  */
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
-struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
-				const struct rpc_call_ops *ops);
+struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_put_task_async(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa70f663eb92..46c13bca8555 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1033,13 +1033,12 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
  * @req: RPC request
  * @tk_ops: RPC call ops
  */
-struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
-				const struct rpc_call_ops *tk_ops)
+struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 {
 	struct rpc_task *task;
 	struct xdr_buf *xbufp = &req->rq_snd_buf;
 	struct rpc_task_setup task_setup_data = {
-		.callback_ops = tk_ops,
+		.callback_ops = &rpc_default_ops,
 	};
 
 	dprintk("RPC: rpc_run_bc_task req= %p\n", req);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e144902d382e..51c8cad5e765 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1350,7 +1350,6 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 {
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
-	static const struct rpc_call_ops reply_ops = { };
 	struct rpc_task *task;
 	int error;
 
@@ -1391,7 +1390,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 
 	/* Finally, send the reply synchronously */
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
-	task = rpc_run_bc_task(req, &reply_ops);
+	task = rpc_run_bc_task(req);
 	if (IS_ERR(task)) {
 		error = PTR_ERR(task);
 		goto out;
-- 
2.4.2

