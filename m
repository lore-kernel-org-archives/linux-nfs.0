Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:37049 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933022AbaLBNbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 08:31:18 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so9079758qcq.25
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 05:31:16 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 2 Dec 2014 08:31:12 -0500
To: bfields@fieldses.org
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] sunrpc: add some tracepoints around enqueue and
 dequeue of svc_xprt
Message-ID: <20141202083112.5f706ddb@tlielax.poochiereds.net>
In-Reply-To: <1416597571-4265-5-git-send-email-jlayton@primarydata.com>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<1416597571-4265-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Nov 2014 14:19:31 -0500
Jeff Layton <jlayton@primarydata.com> wrote:

> These were useful when I was tracking down a race condition between
> svc_xprt_do_enqueue and svc_get_next_xprt.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  include/trace/events/sunrpc.h | 94 +++++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/svc_xprt.c         | 23 +++++++----
>  2 files changed, 110 insertions(+), 7 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index ee4438a63a48..b9c1dc6c825a 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -8,6 +8,7 @@
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/xprtsock.h>
> +#include <linux/sunrpc/svc_xprt.h>
>  #include <net/tcp_states.h>
>  #include <linux/net.h>
>  #include <linux/tracepoint.h>
> @@ -480,6 +481,99 @@ DEFINE_EVENT(svc_rqst_status, svc_send,
>  	TP_PROTO(struct svc_rqst *rqst, int status),
>  	TP_ARGS(rqst, status));
>  
> +#define show_svc_xprt_flags(flags)					\
> +	__print_flags(flags, "|",					\
> +		{ (1UL << XPT_BUSY),		"XPT_BUSY"},		\
> +		{ (1UL << XPT_CONN),		"XPT_CONN"},		\
> +		{ (1UL << XPT_CLOSE),		"XPT_CLOSE"},		\
> +		{ (1UL << XPT_DATA),		"XPT_DATA"},		\
> +		{ (1UL << XPT_TEMP),		"XPT_TEMP"},		\
> +		{ (1UL << XPT_DEAD),		"XPT_DEAD"},		\
> +		{ (1UL << XPT_CHNGBUF),		"XPT_CHNGBUF"},		\
> +		{ (1UL << XPT_DEFERRED),	"XPT_DEFERRED"},	\
> +		{ (1UL << XPT_OLD),		"XPT_OLD"},		\
> +		{ (1UL << XPT_LISTENER),	"XPT_LISTENER"},	\
> +		{ (1UL << XPT_CACHE_AUTH),	"XPT_CACHE_AUTH"},	\
> +		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"})
> +
> +TRACE_EVENT(svc_xprt_do_enqueue,
> +	TP_PROTO(struct svc_xprt *xprt, struct svc_rqst *rqst),
> +
> +	TP_ARGS(xprt, rqst),
> +
> +	TP_STRUCT__entry(
> +		__field(struct svc_xprt *, xprt)
> +		__field(struct svc_rqst *, rqst)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->xprt = xprt;
> +		__entry->rqst = rqst;
> +	),
> +
> +	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s", __entry->xprt,
> +		(struct sockaddr *)&__entry->xprt->xpt_remote,
> +		__entry->rqst ? __entry->rqst->rq_task->pid : 0,
> +		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> +);
> +
> +TRACE_EVENT(svc_xprt_dequeue,
> +	TP_PROTO(struct svc_xprt *xprt),
> +
> +	TP_ARGS(xprt),
> +
> +	TP_STRUCT__entry(
> +		__field(struct svc_xprt *, xprt)
> +		__field_struct(struct sockaddr_storage, ss)
> +		__field(unsigned long, flags)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->xprt = xprt,
> +		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
> +		__entry->flags = xprt ? xprt->xpt_flags : 0;
> +	),
> +
> +	TP_printk("xprt=0x%p addr=%pIScp flags=%s", __entry->xprt,
> +		(struct sockaddr *)&__entry->ss,
> +		show_svc_xprt_flags(__entry->flags))
> +);
> +
> +TRACE_EVENT(svc_wake_up,
> +	TP_PROTO(int pid),
> +
> +	TP_ARGS(pid),
> +
> +	TP_STRUCT__entry(
> +		__field(int, pid)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = pid;
> +	),
> +
> +	TP_printk("pid=%d", __entry->pid)
> +);
> +
> +TRACE_EVENT(svc_handle_xprt,
> +	TP_PROTO(struct svc_xprt *xprt, int len),
> +
> +	TP_ARGS(xprt, len),
> +
> +	TP_STRUCT__entry(
> +		__field(struct svc_xprt *, xprt)
> +		__field(int, len)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->xprt = xprt;
> +		__entry->len = len;
> +	),
> +
> +	TP_printk("xprt=0x%p addr=%pIScp len=%d flags=%s", __entry->xprt,
> +		(struct sockaddr *)&__entry->xprt->xpt_remote, __entry->len,
> +		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> +);
>  #endif /* _TRACE_SUNRPC_H */
>  
>  #include <trace/define_trace.h>
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index ed90d955f733..0ae1d78d934d 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -322,12 +322,12 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>  static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  {
>  	struct svc_pool *pool;
> -	struct svc_rqst	*rqstp;
> +	struct svc_rqst	*rqstp = NULL;
>  	int cpu;
>  	bool queued = false;
>  
>  	if (!svc_xprt_has_something_to_do(xprt))
> -		return;
> +		goto out;
>  
>  	/* Mark transport as busy. It will remain in this state until
>  	 * the provider calls svc_xprt_received. We update XPT_BUSY
> @@ -337,7 +337,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
>  		/* Don't enqueue transport while already enqueued */
>  		dprintk("svc: transport %p busy, not enqueued\n", xprt);
> -		return;
> +		goto out;
>  	}
>  
>  	cpu = get_cpu();
> @@ -377,7 +377,7 @@ redo_search:
>  		atomic_long_inc(&pool->sp_stats.threads_woken);
>  		wake_up_process(rqstp->rq_task);
>  		put_cpu();
> -		return;
> +		goto out;
>  	}
>  	rcu_read_unlock();
>  
> @@ -387,6 +387,7 @@ redo_search:
>  	 * up to it directly but we can wake the thread up in the hopes that it
>  	 * will pick it up once it searches for a xprt to service.
>  	 */
> +	dprintk("svc: transport %p put into queue\n", xprt);

Not sure how I ended up adding this dprintk here. That can certainly be
removed since it's a duplicate of the one inside the following
conditional block and we don't really want that to fire but once.

Bruce, do you want me to resend this patch with that removed?

>  	if (!queued) {
>  		queued = true;
>  		dprintk("svc: transport %p put into queue\n", xprt);
> @@ -396,7 +397,10 @@ redo_search:
>  		spin_unlock_bh(&pool->sp_lock);
>  		goto redo_search;
>  	}
> +	rqstp = NULL;
>  	put_cpu();
> +out:
> +	trace_svc_xprt_do_enqueue(xprt, rqstp);
>  }
>  
>  /*
> @@ -420,7 +424,7 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
>  	struct svc_xprt	*xprt = NULL;
>  
>  	if (list_empty(&pool->sp_sockets))
> -		return NULL;
> +		goto out;
>  
>  	spin_lock_bh(&pool->sp_lock);
>  	if (likely(!list_empty(&pool->sp_sockets))) {
> @@ -433,7 +437,8 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
>  			xprt, atomic_read(&xprt->xpt_ref.refcount));
>  	}
>  	spin_unlock_bh(&pool->sp_lock);
> -
> +out:
> +	trace_svc_xprt_dequeue(xprt);
>  	return xprt;
>  }
>  
> @@ -515,6 +520,7 @@ void svc_wake_up(struct svc_serv *serv)
>  		rcu_read_unlock();
>  		dprintk("svc: daemon %p woken up.\n", rqstp);
>  		wake_up_process(rqstp->rq_task);
> +		trace_svc_wake_up(rqstp->rq_task->pid);
>  		return;
>  	}
>  	rcu_read_unlock();
> @@ -522,6 +528,7 @@ void svc_wake_up(struct svc_serv *serv)
>  	/* No free entries available */
>  	set_bit(SP_TASK_PENDING, &pool->sp_flags);
>  	smp_wmb();
> +	trace_svc_wake_up(0);
>  }
>  EXPORT_SYMBOL_GPL(svc_wake_up);
>  
> @@ -740,7 +747,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  		dprintk("svc_recv: found XPT_CLOSE\n");
>  		svc_delete_xprt(xprt);
>  		/* Leave XPT_BUSY set on the dead xprt: */
> -		return 0;
> +		goto out;
>  	}
>  	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
>  		struct svc_xprt *newxpt;
> @@ -771,6 +778,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  	}
>  	/* clear XPT_BUSY: */
>  	svc_xprt_received(xprt);
> +out:
> +	trace_svc_handle_xprt(xprt, len);
>  	return len;
>  }
>  


-- 
Jeff Layton <jlayton@primarydata.com>
