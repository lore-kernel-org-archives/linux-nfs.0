Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47471 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab2AWVgw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 16:36:52 -0500
Message-ID: <1327354611.2628.20.camel@lade.trondhjem.org>
Subject: Re: [PATCH 1/1] SUNRPC: Adding status trace points
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 23 Jan 2012 13:36:51 -0800
In-Reply-To: <1327348480-32549-2-git-send-email-steved@redhat.com>
References: <1327348480-32549-1-git-send-email-steved@redhat.com>
	 <1327348480-32549-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-01-23 at 14:54 -0500, Steve Dickson wrote: 
> This patch adds three trace points to the status routines
> in the sunrpc state machine.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/clnt.c             |    4 +++
>  2 files changed, 49 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 1852f11..bca5ad3 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -8,6 +8,51 @@
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/tracepoint.h>
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

How do you tell which RPC task this refers to in the output? Shouldn't
we rather make the above

	TP_printk("task:%p@%p, status %d", __entry->task, __entry->clnt, __entry->status)

so that it matches the format in the previous tracepoint patch?

Also, why are you adding tracepoints for specific states in
net/sunrpc/clnt.c? Is the intention to allow the user to target specific
bugs that might be harder to spot in the output from
trace_rpc_task_run_action()?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

