Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab2AXPlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 10:41:55 -0500
Message-ID: <4F1ED12D.3090001@RedHat.com>
Date: Tue, 24 Jan 2012 10:41:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH v2] SUNRPC: Add trace events to the sunrpc subsystem
References: <1327090364-6549-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1327090364-6549-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond

On 01/20/2012 03:12 PM, Trond Myklebust wrote:
> Add declarations to allow tracing of RPC call creation, running, sleeping,
> and destruction.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  include/linux/sunrpc/sched.h  |    2 +-
>  include/trace/events/sunrpc.h |  124 +++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/sched.c            |   12 ++++
>  3 files changed, 137 insertions(+), 1 deletions(-)
>  create mode 100644 include/trace/events/sunrpc.h
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index bd337f9..f7b2df5 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -271,7 +271,7 @@ static inline int rpc_task_has_priority(struct rpc_task *task, unsigned char pri
>  }
>  
>  #ifdef RPC_DEBUG
> -static inline const char * rpc_qname(struct rpc_wait_queue *q)
> +static inline const char * rpc_qname(const struct rpc_wait_queue *q)
>  {
>  	return ((q && q->name) ? q->name : "unknown");
>  }
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> new file mode 100644
> index 0000000..51cc949
> --- /dev/null
> +++ b/include/trace/events/sunrpc.h
> @@ -0,0 +1,124 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM sunrpc
> +
> +#if !defined(_TRACE_SUNRPC_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_SUNRPC_H
> +
> +#include <linux/sunrpc/sched.h>
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/tracepoint.h>
> +
> +DECLARE_EVENT_CLASS(rpc_task_running,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
> +
> +	TP_ARGS(clnt, task, action),
> +
> +	TP_STRUCT__entry(
> +		__field(const struct rpc_clnt *, clnt)
> +		__field(const struct rpc_task *, task)
> +		__field(const void *, action)
> +		__field(unsigned long, runstate)
> +		__field(int, status)
> +		__field(unsigned short, flags)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->clnt = clnt;
> +		__entry->task = task;
> +		__entry->action = action;
> +		__entry->runstate = task->tk_runstate;
> +		__entry->status = task->tk_status;
> +		__entry->flags = task->tk_flags;
> +		),
> +
> +	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d action=%pf",
> +		__entry->task,
> +		__entry->clnt,
> +		__entry->flags,
> +		__entry->runstate,
> +		__entry->status,
> +		__entry->action
> +		)
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_begin,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_run_action,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_complete,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DECLARE_EVENT_CLASS(rpc_task_queued,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),
> +
> +	TP_ARGS(clnt, task, q),
> +
> +	TP_STRUCT__entry(
> +		__field(const struct rpc_clnt *, clnt)
> +		__field(const struct rpc_task *, task)
> +		__field(const struct rpc_wait_queue *, queue)
> +		__field(unsigned long, timeout)
> +		__field(unsigned long, runstate)
> +		__field(int, status)
> +		__field(unsigned short, flags)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->clnt = clnt;
> +		__entry->task = task;
> +		__entry->queue = q;
> +		__entry->timeout = task->tk_timeout;
> +		__entry->runstate = task->tk_runstate;
> +		__entry->status = task->tk_status;
> +		__entry->flags = task->tk_flags;
> +		),
> +
> +	TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
> +		__entry->task,
> +		__entry->clnt,
> +		__entry->flags,
> +		__entry->runstate,
> +		__entry->status,
> +		__entry->timeout,
> +		rpc_qname(__entry->queue)
> +		)
> +);
It turns out using rpc_qname() is not quite right... 
Neil Horman, from our internal review,  points out:

"IIRC we do the TP_fast_assign and TP_printk separately
because we don't serialize the printk on the code path that generates it.  I.e.
the data that __entry->queue points to may be freed by the time the printk
dereferences it.  I think what you need is to declare in the __entry:
__string(	qname, rpc_qname(q))

in TP_fast_assign replace the queue assignment with  something like
__entry->qname = __assign_str(rpc_qname(q));

And then in the printk:
__get_str(qname);"

Which basically translate into the following (untested):
DECLARE_EVENT_CLASS(rpc_task_queued,

    TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const struct rpc_wait_queue *q),

    TP_ARGS(clnt, task, q),

    TP_STRUCT__entry(
        __field(const struct rpc_clnt *, clnt)
        __field(const struct rpc_task *, task)
        __string(qname, rpc_qname(q))
        __field(unsigned long, timeout)
        __field(unsigned long, runstate)
        __field(int, status)
        __field(unsigned short, flags)
        ),

    TP_fast_assign(
        __entry->clnt = clnt;
        __entry->task = task;
        __entry->qname = __assign_str(rpc_qname(q));
        __entry->timeout = task->tk_timeout;
        __entry->runstate = task->tk_runstate;
        __entry->status = task->tk_status;
        __entry->flags = task->tk_flags;
        ),

    TP_printk("task:%p@%p flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
        __entry->task,
        __entry->clnt,
        __entry->flags,
        __entry->runstate,
        __entry->status,
        __entry->timeout,
        __get_str(__entry->qname)
        )
);

There are a number of examples of this in include/trace/events.

steved.
