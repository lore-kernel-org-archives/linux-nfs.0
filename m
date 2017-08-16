Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29851 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdHPQnM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 12:43:12 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 5/6] SUNRPC: Add a function to allow waiting for RPC transmission
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170816161929.11271-6-trond.myklebust@primarydata.com>
Date: Wed, 16 Aug 2017 12:43:07 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A0D358C7-C590-45CE-B4BF-F93BB08469B4@oracle.com>
References: <20170816161929.11271-1-trond.myklebust@primarydata.com> <20170816161929.11271-2-trond.myklebust@primarydata.com> <20170816161929.11271-3-trond.myklebust@primarydata.com> <20170816161929.11271-4-trond.myklebust@primarydata.com> <20170816161929.11271-5-trond.myklebust@primarydata.com> <20170816161929.11271-6-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 16, 2017, at 12:19 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Sometimes, we only want to know that the RPC message is in the process
> of being transmitted. Add a function to allow that.

The last time I tried these last two, they resulted in a significant
performance regression. Is there anything I can do to help track
that down?


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> include/linux/sunrpc/sched.h |  3 +++
> net/sunrpc/sched.c           | 22 ++++++++++++++++++++++
> net/sunrpc/xprt.c            |  6 ++++++
> 3 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index c1768f9d993b..148cd6c5d2eb 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -141,6 +141,8 @@ struct rpc_task_setup {
> #define RPC_TASK_ACTIVE		2
> #define RPC_TASK_MSG_RECV	3
> #define RPC_TASK_MSG_RECV_WAIT	4
> +#define RPC_TASK_MSG_XMIT	5
> +#define RPC_TASK_MSG_XMIT_WAIT	6
> 
> #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
> #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
> @@ -246,6 +248,7 @@ void		rpc_free(struct rpc_task *);
> int		rpciod_up(void);
> void		rpciod_down(void);
> int		__rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *);
> +int		rpc_wait_for_msg_send(struct rpc_task *task);
> #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> struct net;
> void		rpc_show_tasks(struct net *);
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 0cc83839c13c..30509a4d7e00 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -320,6 +320,19 @@ int __rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *act
> EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
> 
> /*
> + * Allow callers to wait for completion of an RPC call
> + */
> +int rpc_wait_for_msg_send(struct rpc_task *task)
> +{
> +	if (!test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate))
> +		return 0;
> +	set_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate);
> +	return wait_on_bit_action(&task->tk_runstate, RPC_TASK_MSG_XMIT,
> +			rpc_wait_bit_killable, TASK_KILLABLE);
> +}
> +EXPORT_SYMBOL_GPL(rpc_wait_for_msg_send);
> +
> +/*
>  * Make an RPC task runnable.
>  *
>  * Note: If the task is ASYNC, and is being made runnable after sitting on an
> @@ -700,6 +713,7 @@ rpc_reset_task_statistics(struct rpc_task *task)
> {
> 	task->tk_timeouts = 0;
> 	task->tk_flags &= ~(RPC_CALL_MAJORSEEN|RPC_TASK_KILLED|RPC_TASK_SENT);
> +	set_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
> 
> 	rpc_init_task_statistics(task);
> }
> @@ -928,6 +942,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
> 	memset(task, 0, sizeof(*task));
> 	atomic_set(&task->tk_count, 1);
> 	task->tk_flags  = task_setup_data->flags;
> +	task->tk_runstate = BIT(RPC_TASK_MSG_XMIT);
> 	task->tk_ops = task_setup_data->callback_ops;
> 	task->tk_calldata = task_setup_data->callback_data;
> 	INIT_LIST_HEAD(&task->tk_task);
> @@ -1012,6 +1027,13 @@ static void rpc_async_release(struct work_struct *work)
> 
> static void rpc_release_resources_task(struct rpc_task *task)
> {
> +	if (test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate)) {
> +		clear_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
> +		smp_mb__after_atomic();
> +		if (test_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate))
> +			wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_XMIT);
> +	}
> +
> 	xprt_release(task);
> 	if (task->tk_msg.rpc_cred) {
> 		put_rpccred(task->tk_msg.rpc_cred);
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index a558e8c620c0..62c379865f7c 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -978,6 +978,12 @@ bool xprt_prepare_transmit(struct rpc_task *task)
> 		goto out_unlock;
> 	}
> 	ret = true;
> +	if (test_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate)) {
> +		clear_bit(RPC_TASK_MSG_XMIT, &task->tk_runstate);
> +		smp_mb__after_atomic();
> +		if (test_bit(RPC_TASK_MSG_XMIT_WAIT, &task->tk_runstate))
> +			wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_XMIT);
> +	}
> out_unlock:
> 	spin_unlock_bh(&xprt->transport_lock);
> 	return ret;
> -- 
> 2.13.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



