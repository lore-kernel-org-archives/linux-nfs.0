Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34813 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbHZKc6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 06:32:58 -0400
Received: by qkfh127 with SMTP id h127so116796488qkf.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 03:32:58 -0700 (PDT)
Date: Wed, 26 Aug 2015 06:32:55 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Pratyush Anand <panand@redhat.com>
Cc: bfields@fieldses.org, rostedt@goodmis.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@primarydata.com>,
        linux-kernel@vger.kernel.org (open list),
        Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/2] net: sunrpc: fix trace print of &xprt->xpt_remote
Message-ID: <20150826063255.3cdd5475@tlielax.poochiereds.net>
In-Reply-To: <3e2f763f7701d7ff6915b52a3c80fd1f550ae951.1440482404.git.panand@redhat.com>
References: <cover.1440482404.git.panand@redhat.com>
	<3e2f763f7701d7ff6915b52a3c80fd1f550ae951.1440482404.git.panand@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 25 Aug 2015 11:34:20 +0530
Pratyush Anand <panand@redhat.com> wrote:

> TP_printk() for svc_xprt_dequeue intends to print address of
> xprt->xpt_remote, however it prints address of another structure where
> xprt->xpt_remote has been copied.
> 
> This patch fixes the above behaviour.
> 
> Signed-off-by: Pratyush Anand <panand@redhat.com>
> ---
>  include/trace/events/sunrpc.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 937e482d80e9..37b6af1a911a 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -556,19 +556,19 @@ TRACE_EVENT(svc_xprt_dequeue,
>  
>  	TP_STRUCT__entry(
>  		__field(struct svc_xprt *, xprt)
> -		__field_struct(struct sockaddr_storage, ss)
> +		__field(struct sockaddr *, addr)
>  		__field(unsigned long, flags)
>  	),
>  
>  	TP_fast_assign(
> -		__entry->xprt = xprt,
> -		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
> +		__entry->xprt = xprt;
> +		__entry->addr =
> +			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;

NAK, this is wrong. %pIScp will dereference that address so you don't
want to pass a NULL pointer to it. We do want to save a copy of the
sockaddr.

>  		__entry->flags = xprt ? xprt->xpt_flags : 0;
>  	),
>  
>  	TP_printk("xprt=0x%p addr=%pIScp flags=%s", __entry->xprt,
> -		(struct sockaddr *)&__entry->ss,
> -		show_svc_xprt_flags(__entry->flags))
> +		__entry->addr, show_svc_xprt_flags(__entry->flags))
>  );
>  
>  TRACE_EVENT(svc_wake_up,


-- 
Jeff Layton <jlayton@poochiereds.net>
