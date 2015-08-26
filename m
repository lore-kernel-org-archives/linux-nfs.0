Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:36068 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755582AbbHZKbI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 06:31:08 -0400
Received: by qgeb6 with SMTP id b6so123233408qge.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 03:31:07 -0700 (PDT)
Date: Wed, 26 Aug 2015 06:31:03 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Pratyush Anand <panand@redhat.com>
Cc: bfields@fieldses.org, rostedt@goodmis.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@primarydata.com>,
        linux-kernel@vger.kernel.org (open list),
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/2] net: sunrpc: fix tracepoint Warning: unknown op
 '->'
Message-ID: <20150826063103.6f036582@tlielax.poochiereds.net>
In-Reply-To: <edc9697b5140015b15c96cc1b505b3c53169e634.1440482404.git.panand@redhat.com>
References: <cover.1440482404.git.panand@redhat.com>
	<edc9697b5140015b15c96cc1b505b3c53169e634.1440482404.git.panand@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 25 Aug 2015 11:34:19 +0530
Pratyush Anand <panand@redhat.com> wrote:

> `perf stat  -e sunrpc:svc_xprt_do_enqueue true` results in
> 
> Warning: unknown op '->'
> Warning: [sunrpc:svc_xprt_do_enqueue] unknown op '->'
> 
> Similar warning for svc_handle_xprt as well.
> 
> Actually TP_printk() should never dereference an address saved in the ring
> buffer that points somewhere in the kernel. There's no guarantee that that
> object still exists (with the exception of static strings).
> 
> Therefore change all the arguments for TP_printk(), so that it references
> values existing in the ring buffer only.
> 
> While doing that, also fix another possible bug when argument xprt could be
> NULL and TP_fast_assign() tries to access it's elements.
> 
> Signed-off-by: Pratyush Anand <panand@redhat.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> ---
>  include/trace/events/sunrpc.h | 21 ++++++++++++++++-----
>  1 file changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index fd1a02cb3c82..937e482d80e9 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -529,18 +529,24 @@ TRACE_EVENT(svc_xprt_do_enqueue,
>  
>  	TP_STRUCT__entry(
>  		__field(struct svc_xprt *, xprt)
> +		__field(struct sockaddr *, addr)
>  		__field(struct svc_rqst *, rqst)
> +		__field(int, pid)
> +		__field(unsigned long, flags)
>  	),
>  
>  	TP_fast_assign(
>  		__entry->xprt = xprt;
> +		__entry->addr =
> +			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;

I don't get it. It's not safe to save a pointer to xprt and dereference
that in a tracepoint (and I understand why that is), but it is safe to
save a pointer to a structure embedded inside of xprt? Shouldn't you be
saving a copy of the entire sockaddr struct instead?

Ahh, ok -- I think I see the confusion. %pIScp does not print the
address of the sockaddr, but instead dereferences the pointer and
prints it as a formatted address string. See pointer() in
lib/vsprintf.c. You do want to save off a copy of the structure instead.

>  		__entry->rqst = rqst;
> +		__entry->pid = rqst? rqst->rq_task->pid : 0;
> +		__entry->flags = xprt ? xprt->xpt_flags : 0;
>  	),
>  
>  	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s",
> __entry->xprt,
> -		(struct sockaddr *)&__entry->xprt->xpt_remote,
> -		__entry->rqst ? __entry->rqst->rq_task->pid : 0,
> -		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> +		__entry->addr, __entry->pid,
> +		show_svc_xprt_flags(__entry->flags))
>  );
>  
>  TRACE_EVENT(svc_xprt_dequeue,
> @@ -589,16 +595,21 @@ TRACE_EVENT(svc_handle_xprt,
>  	TP_STRUCT__entry(
>  		__field(struct svc_xprt *, xprt)
>  		__field(int, len)
> +		__field(struct sockaddr *, addr)
> +		__field(unsigned long, flags)
>  	),
>  
>  	TP_fast_assign(
>  		__entry->xprt = xprt;
> +		__entry->addr =
> +			xprt ? (struct sockaddr
> *)&xprt->xpt_remote : NULL; __entry->len = len;
> +		__entry->flags = xprt ? xprt->xpt_flags : 0;
>  	),
>  
>  	TP_printk("xprt=0x%p addr=%pIScp len=%d flags=%s",
> __entry->xprt,
> -		(struct sockaddr *)&__entry->xprt->xpt_remote,
> __entry->len,
> -		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> +		__entry->addr, __entry->len,
> +		show_svc_xprt_flags(__entry->flags))
>  );
>  #endif /* _TRACE_SUNRPC_H */
>  


-- 
Jeff Layton <jlayton@poochiereds.net>
