From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] sunrpc: Adding trace points to status routines.
Date: Fri, 24 Apr 2009 16:08:41 -0400
Message-ID: <49F21C49.8030101@redhat.com>
References: <49F1E348.2060309@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41047 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567AbZDXUIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2009 16:08:47 -0400
In-Reply-To: <49F1E348.2060309-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> Hey Trond,
>
> Here is a very simple patch that adds three trace points 
> to the sunrpc state machine. The trace points are strategically
> placed so they will only be called during error conditions. The 
> purpose of these trace point is to show processes that are spinning
> or get hung up in the NFS code and its associated subsystems.
>
> Case in point. Recently I had a customer that was seeing 
> rpciod spinning (using %100 of the cpu) for a relative
> short amount time (actually I think I mentioned this bug
> to you). 
>
> Using systemtap scripts that only showed errors in the 
> rpc status routines, I was able to determine the process was
> spinning in the bind code. Basically doing an IPv6 bind
> with no takers (although we are still working on it).
>
> So it occurred to me, that it would have been very handy to
> have a light weight mechanism that only showed errors the sunrpc 
> code was processing. So I ported those systemtap scripts into 
> trace points.
>
> Note, we did try to use the existing dprintk() but it took much 
> much longer for the problem to occur, if at all. Plus when the 
> problem did happen, the volume of data to sieve through 
> as a bit daunting.
>
> An example of the the output is:
>
> <...>-2684  [001]  1437.010389: call_status: 100003[4]:0 status=-107
>                                routine name: prog[version]:Proc tk_status
>
> which shows who is failing (i.e. the program number and version) and 
> what they are trying to do (the procedure number).
>
> Now there are some common errors like ETIMOUT and EAGAIN, but we can 
> filter those  out using the 'filer' file that the trace points 
> system supplies.
>
> Please consider... I really think light weight information will be
> very handy... 
>
>   

I agree.  This information could be very handy at times.

The problem with this whole approach that it is impossible
to figure out what trace_bind_status() does using cscope or
tags or any tools like that.  One will have to figure out
that it is a trace event and then figure out how and where
it is defined.  Bleah.

    Thanx...

       ps


> steved.
>  
> Author: Steve Dickson <steved@redhat.com>
> Date:   Fri Apr 24 11:12:31 2009 -0400
>
>     Adds three trace points to the status routines in the
>     sunrpc state machine. The trace points will only execute
>     in error conditions.
>     
>     The goal of these trace points it to make it easier to
>     debug process that spin or get hung up in the NFS and
>     related subsystems.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> new file mode 100644
> index 0000000..f502eb4
> --- /dev/null
> +++ b/include/trace/events/sunrpc.h
> @@ -0,0 +1,86 @@
> +#if !defined(_TRACE_SUNRPC_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_SUNRPC_H
> +
> +#include <linux/tracepoint.h>
> +
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM sunrpc
> +
> +TRACE_EVENT(call_status,
> +
> +	TP_PROTO(struct rpc_task *task),
> +
> +	TP_ARGS(task),
> +
> +	TP_STRUCT__entry(
> +		__field(u32, cl_prog)
> +		__field(u32, cl_vers)
> +		__field(u32, p_proc)
> +		__field(int, tk_status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->cl_vers = task->tk_client->cl_vers;
> +		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->tk_status = task->tk_status;
> +	),
> +
> +	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
> +		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
> +);
> +
> +TRACE_EVENT(bind_status,
> +
> +	TP_PROTO(struct rpc_task *task),
> +
> +	TP_ARGS(task),
> +
> +	TP_STRUCT__entry(
> +		__field(u32, cl_prog)
> +		__field(u32, cl_vers)
> +		__field(u32, p_proc)
> +		__field(int, tk_status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->cl_vers = task->tk_client->cl_vers;
> +		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->tk_status = task->tk_status;
> +	),
> +
> +	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
> +		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
> +);
> +TRACE_EVENT(connect_status,
> +
> +	TP_PROTO(struct rpc_task *task, int status),
> +
> +	TP_ARGS(task, status),
> +
> +	TP_STRUCT__entry(
> +		__field(u32, cl_prog)
> +		__field(u32, cl_vers)
> +		__field(u32, p_proc)
> +		__field(int, tk_status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->cl_vers = task->tk_client->cl_vers;
> +		__entry->p_proc = task->tk_client->cl_procinfo->p_proc;
> +		__entry->cl_prog = task->tk_client->cl_prog;
> +		__entry->tk_status = status;
> +	),
> +
> +	TP_printk("%d[%d]:%d status=%d", __entry->cl_prog, 
> +		__entry->cl_vers,__entry->p_proc, __entry->tk_status)
> +
> +);
> +#endif /* __TRACE_SUNRPC_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 5abab09..b86ee2a 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -37,6 +37,9 @@
>  #include <linux/sunrpc/rpc_pipe_fs.h>
>  #include <linux/sunrpc/metrics.h>
>  
> +#include <linux/ftrace.h>
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/sunrpc.h>
>  
>  #ifdef RPC_DEBUG
>  # define RPCDBG_FACILITY	RPCDBG_CALL
> @@ -957,6 +960,7 @@ call_bind_status(struct rpc_task *task)
>  		return;
>  	}
>  
> +	trace_bind_status(task);
>  	switch (task->tk_status) {
>  	case -ENOMEM:
>  		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
> @@ -1038,6 +1042,7 @@ call_connect_status(struct rpc_task *task)
>  		return;
>  	}
>  
> +	trace_connect_status(task, status);
>  	switch (status) {
>  		/* if soft mounted, test if we've timed out */
>  	case -ETIMEDOUT:
> @@ -1141,6 +1146,7 @@ call_status(struct rpc_task *task)
>  		return;
>  	}
>  
> +	trace_call_status(task);
>  	task->tk_status = 0;
>  	switch(status) {
>  	case -EHOSTDOWN:
>
>                                         
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

