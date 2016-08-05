Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:23582 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763378AbcHEVxX convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2016 17:53:23 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Adamson William Andros <andros@netapp.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 7 5/8] SUNRPC add remove xprt flag to
 rpc_task_release_client
Date: Fri, 5 Aug 2016 21:53:16 +0000
Message-ID: <FE18E43C-4E1A-4DF2-B923-33CE4B866EE6@primarydata.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
 <1469645000-19791-6-git-send-email-andros@netapp.com>
In-Reply-To: <1469645000-19791-6-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 27, 2016, at 14:43, andros@netapp.com wrote:
> 
> From: Andy Adamson <andros@netapp.com>
> 
> Want to specify which rpc_xprt to use in rpc_run_task.
> 
> Don't pass in an rpc_xprt in rpc_init_task just to have it not used as it
> is removed in rpc_task_release_client.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> include/linux/sunrpc/clnt.h | 2 +-
> net/sunrpc/clnt.c           | 7 +++----
> net/sunrpc/sched.c          | 2 +-
> 3 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index b6810c9..99410bb 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -148,7 +148,7 @@ int		rpc_switch_client_transport(struct rpc_clnt *,
> 
> void		rpc_shutdown_client(struct rpc_clnt *);
> void		rpc_release_client(struct rpc_clnt *);
> -void		rpc_task_release_client(struct rpc_task *);
> +void		rpc_task_release_client(struct rpc_task *, int);
> 
> int		rpcb_create_local(struct net *);
> void		rpcb_put_local(struct net *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index cb49898..459f9b1 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -961,7 +961,7 @@ out:
> }
> EXPORT_SYMBOL_GPL(rpc_bind_new_program);
> 
> -void rpc_task_release_client(struct rpc_task *task)
> +void rpc_task_release_client(struct rpc_task *task, int rm_xprt)
> {
> 	struct rpc_clnt *clnt = task->tk_client;
> 	struct rpc_xprt *xprt = task->tk_xprt;
> @@ -976,9 +976,8 @@ void rpc_task_release_client(struct rpc_task *task)
> 		rpc_release_client(clnt);
> 	}
> 
> -	if (xprt != NULL) {
> +	if (rm_xprt && xprt) {
> 		task->tk_xprt = NULL;
> -
> 		xprt_put(xprt);
> 	}
> }
> @@ -988,7 +987,7 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
> {
> 
> 	if (clnt != NULL) {
> -		rpc_task_release_client(task);
> +		rpc_task_release_client(task, 0);

Can we rather just kill this call to rpc_task_release_client)? I’m not aware of any remaining code paths that make it necessary. Am I missing something?

> 		if (task->tk_xprt == NULL)
> 			task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
> 		task->tk_client = clnt;
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 9ae5885..575b254 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -1017,7 +1017,7 @@ static void rpc_release_resources_task(struct rpc_task *task)
> 		put_rpccred(task->tk_msg.rpc_cred);
> 		task->tk_msg.rpc_cred = NULL;
> 	}
> -	rpc_task_release_client(task);
> +	rpc_task_release_client(task, 1);
> }
> 
> static void rpc_final_put_task(struct rpc_task *task,
> -- 
> 1.8.3.1
> 

