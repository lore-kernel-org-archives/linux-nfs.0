Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41900 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbFEAZF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 20:25:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 4/6] SUNRPC: Remove unused argument 'tk_ops' in rpc_run_bc_task
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
Date: Thu, 4 Jun 2015 20:27:37 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B5F515A7-9F67-43AF-8D37-584A2E4F0672@oracle.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 4, 2015, at 5:26 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

Yeah, I was wondering about that. Seems reasonable.

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> include/linux/sunrpc/sched.h | 3 +--
> net/sunrpc/clnt.c            | 5 ++---
> net/sunrpc/svc.c             | 3 +--
> 3 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 5f1e6bd4c316..2aa68976a482 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -205,8 +205,7 @@ struct rpc_wait_queue {
>  */
> struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
> struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
> -struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
> -				const struct rpc_call_ops *ops);
> +struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req);
> void		rpc_put_task(struct rpc_task *);
> void		rpc_put_task_async(struct rpc_task *);
> void		rpc_exit_task(struct rpc_task *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index fa70f663eb92..46c13bca8555 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1033,13 +1033,12 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
>  * @req: RPC request
>  * @tk_ops: RPC call ops
>  */
> -struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
> -				const struct rpc_call_ops *tk_ops)
> +struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
> {
> 	struct rpc_task *task;
> 	struct xdr_buf *xbufp = &req->rq_snd_buf;
> 	struct rpc_task_setup task_setup_data = {
> -		.callback_ops = tk_ops,
> +		.callback_ops = &rpc_default_ops,
> 	};
> 
> 	dprintk("RPC: rpc_run_bc_task req= %p\n", req);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index e144902d382e..51c8cad5e765 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1350,7 +1350,6 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> {
> 	struct kvec	*argv = &rqstp->rq_arg.head[0];
> 	struct kvec	*resv = &rqstp->rq_res.head[0];
> -	static const struct rpc_call_ops reply_ops = { };
> 	struct rpc_task *task;
> 	int error;
> 
> @@ -1391,7 +1390,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> 
> 	/* Finally, send the reply synchronously */
> 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
> -	task = rpc_run_bc_task(req, &reply_ops);
> +	task = rpc_run_bc_task(req);
> 	if (IS_ERR(task)) {
> 		error = PTR_ERR(task);
> 		goto out;
> -- 
> 2.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



