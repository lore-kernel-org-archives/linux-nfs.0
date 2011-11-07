Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49085 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab1KGO5U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 09:57:20 -0500
Subject: Re: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error happens.
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111107150654.1c045aad@notabene.brown>
Date: Mon, 7 Nov 2011 09:56:58 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Message-Id: <74D9D408-72B2-4CD3-BFFE-9774537B174E@oracle.com>
References: <20111107150654.1c045aad@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 6, 2011, at 11:06 PM, NeilBrown wrote:

> 
> hi all,
> It being over a year since I last raised this I thought it might be time to
> try again.
> 
> The problem is that an NFSv4 mount request (the default) to an unrouteable
> server results in a 3 minute timeout instead of an instant failure.
> 
> This is easy to test by simply removing your default route then trying to
> mount something outside your local network.

Awesome, thanks for the simple reproducer!

> This patch causes any SOFTCONN task to be woken up as soon as a connection
> error occurs so that it can fail promptly.  The failure reasons gets passed
> back and as it is not ETIMEDOUT it causes immediate failure.
> 
> Is this a reasonable approach?

I don't have a philosophical objection to this.  However, Trond knows the architecture of TCP reconnection the best; I can't comment on the choice of returning the actual errno instead of ETIMEDOUT.

> Thanks,
> NeilBrown
> 
> 
> 
> 
> From a1aea8fc3977ffa9951c3d7f27dbb1905e5f560f Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.de>
> Date: Mon, 7 Nov 2011 15:00:17 +1100
> Subject: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error
> happens.
> 
> A 'SOFTCONN' task should fail if there is an error or a major timeout
> during connection.
> 
> However errors are currently converted into a timeout (60seconds for
> TCP) which is treated as a minor timeout and 3 of these are required
> before failure.
> 
> The result of this is that if you try to mount an NFSv4 filesystem
> (which doesn't require rpcbind and the failure modes that provides)
> from a server which you do not have a route to (an so get
> NETUNREACHABLE), you have an unnecessary 3 minutes timeout.
> 
> So when ENETUNREACH is reported for a connection - or other errors
> which are fatal, wake up any SOFTCONN tasks with that error - rather
> than letting them wait 60 seconds and then generate ETIMEDOUT.
> 
> This causes the above mentioned mount attempt to fail instantly.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> include/linux/sunrpc/sched.h |    1 +
> net/sunrpc/sched.c           |   29 +++++++++++++++++++++++++++++
> net/sunrpc/xprtsock.c        |    6 +++++-
> 3 files changed, 35 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index e775689..b85451b 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -236,6 +236,7 @@ void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
> void		rpc_wake_up(struct rpc_wait_queue *);
> struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
> void		rpc_wake_up_status(struct rpc_wait_queue *, int);
> +void		rpc_wake_up_softconn_status(struct rpc_wait_queue *, int);
> int		rpc_queue_empty(struct rpc_wait_queue *);
> void		rpc_delay(struct rpc_task *, unsigned long);
> void *		rpc_malloc(struct rpc_task *, size_t);
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index d12ffa5..d92000a 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -543,6 +543,35 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
> }
> EXPORT_SYMBOL_GPL(rpc_wake_up_status);
> 
> +/**
> + * rpc_wake_up_softconn_status - wake up all SOFTCONN rpc_tasks and set their
> + * status value.
> + * @queue: rpc_wait_queue on which the tasks are sleeping
> + * @status: status value to set
> + *
> + * Grabs queue->lock
> + */
> +void rpc_wake_up_softconn_status(struct rpc_wait_queue *queue, int status)
> +{
> +	struct rpc_task *task, *next;
> +	struct list_head *head;
> +
> +	spin_lock_bh(&queue->lock);
> +	head = &queue->tasks[queue->maxpriority];
> +	for (;;) {
> +		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
> +			if (RPC_IS_SOFTCONN(task)) {
> +				task->tk_status = status;
> +				rpc_wake_up_task_queue_locked(queue, task);
> +			}
> +		if (head == &queue->tasks[0])
> +			break;
> +		head--;
> +	}
> +	spin_unlock_bh(&queue->lock);
> +}
> +EXPORT_SYMBOL_GPL(rpc_wake_up_softconn_status);
> +
> static void __rpc_queue_timer_fn(unsigned long ptr)
> {
> 	struct rpc_wait_queue *queue = (struct rpc_wait_queue *)ptr;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index d7f97ef..02c683b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2158,7 +2158,11 @@ static void xs_tcp_setup_socket(struct work_struct *work)
> 	case -ECONNREFUSED:
> 	case -ECONNRESET:
> 	case -ENETUNREACH:
> -		/* retry with existing socket, after a delay */
> +		/* Retry with existing socket after a delay, except
> +		 * for SOFTCONN tasks which fail. */
> +		xprt_clear_connecting(xprt);
> +		rpc_wake_up_softconn_status(&xprt->pending, status);
> +		return;
> 	case 0:
> 	case -EINPROGRESS:
> 	case -EALREADY:
> -- 
> 1.7.7
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




