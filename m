Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:27470 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab2AWUDB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:03:01 -0500
Subject: Re: [PATCH 1/1] SUNRPC: Adding status trace points
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1327348480-32549-2-git-send-email-steved@redhat.com>
Date: Mon, 23 Jan 2012 15:02:56 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <383508F5-8A0B-4EBE-B81B-6A75887CD156@oracle.com>
References: <1327348480-32549-1-git-send-email-steved@redhat.com> <1327348480-32549-2-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 23, 2012, at 2:54 PM, Steve Dickson wrote:

> This patch adds three trace points to the status routines
> in the sunrpc state machine.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
> net/sunrpc/clnt.c             |    4 +++
> 2 files changed, 49 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 1852f11..bca5ad3 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -8,6 +8,51 @@
> #include <linux/sunrpc/clnt.h>
> #include <linux/tracepoint.h>
> 
> +DECLARE_EVENT_CLASS(rpc_task_status,
> +
> +	TP_PROTO(struct rpc_task *task),
> +
> +	TP_ARGS(task),
> +
> +	TP_STRUCT__entry(
> +		__field(int, status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->status = task->tk_status;
> +	),
> +
> +	TP_printk("status %d", __entry->status)
> +);
> +
> +DEFINE_EVENT(rpc_task_status, rpc_call_status,
> +	TP_PROTO(struct rpc_task *task), 
> +
> +	TP_ARGS(task)
> +);
> +
> +DEFINE_EVENT(rpc_task_status, rpc_bind_status,
> +	TP_PROTO(struct rpc_task *task), 
> +
> +	TP_ARGS(task)
> +);
> +
> +TRACE_EVENT(rpc_connect_status,
> +	TP_PROTO(int status),
> +
> +	TP_ARGS(status),
> +
> +	TP_STRUCT__entry(
> +		__field(int, status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->status = status;
> +	),
> +
> +	TP_printk("status=%d", __entry->status)
> +);
> +
> DECLARE_EVENT_CLASS(rpc_task_running,
> 
> 	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task *task, const void *action),
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index f0268ea..bbe7385 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -55,6 +55,7 @@ static DEFINE_SPINLOCK(rpc_client_lock);
> 
> static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
> 
> +#include <trace/events/sunrpc.h>

I'd prefer that this #include be kept with the others at the head of the file, unless there is a strong reason this one needs to be inconsistent.

I'm glad a clean way was found to add trace points to the RPC client.

> static void	call_start(struct rpc_task *task);
> static void	call_reserve(struct rpc_task *task);
> @@ -1163,6 +1164,7 @@ call_bind_status(struct rpc_task *task)
> 		return;
> 	}
> 
> +	trace_rpc_bind_status(task);
> 	switch (task->tk_status) {
> 	case -ENOMEM:
> 		dprintk("RPC: %5u rpcbind out of memory\n", task->tk_pid);
> @@ -1262,6 +1264,7 @@ call_connect_status(struct rpc_task *task)
> 		return;
> 	}
> 
> +	trace_rpc_connect_status(status);

Is this trace point as useful as, say, a trace point in xprt_connect_status(), or in the transport's connect worker?  The way transport connection works today is that all of the actual work is handled while sending an RPC, and is basically hidden from the FSM.

I'd like to capture connection events, I'm just wondering if a trace point here is the best way to do it.

> 	switch (status) {
> 		/* if soft mounted, test if we've timed out */
> 	case -ETIMEDOUT:
> @@ -1450,6 +1453,7 @@ call_status(struct rpc_task *task)
> 		return;
> 	}
> 
> +	trace_rpc_call_status(task);
> 	task->tk_status = 0;
> 	switch(status) {
> 	case -EHOSTDOWN:
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




