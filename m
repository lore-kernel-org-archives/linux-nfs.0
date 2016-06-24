Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbcFXS2j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jun 2016 14:28:39 -0400
Date: Fri, 24 Jun 2016 14:28:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] SUNRPC: Fix tracepoint storage issues with
 svc_recv and svc_rqst_status
Message-ID: <20160624182837.GH3287@fieldses.org>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 24, 2016 at 10:55:43AM -0400, Trond Myklebust wrote:
> There is no guarantee that either the request or the svc_xprt exist
> by the time we get round to printing the trace message.

Thanks.  I'll also add:

  Cc: stable@vger.kernel.org
  Fixes: 83a712e0afef "sunrpc: add some tracepoints around ..."

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  include/trace/events/sunrpc.h | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 003dca933803..e82493d07a86 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -455,20 +455,22 @@ TRACE_EVENT(svc_recv,
>  	TP_ARGS(rqst, status),
>  
>  	TP_STRUCT__entry(
> -		__field(struct sockaddr *, addr)
>  		__field(__be32, xid)
>  		__field(int, status)
>  		__field(unsigned long, flags)
> +		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
>  	),
>  
>  	TP_fast_assign(
> -		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
>  		__entry->xid = status > 0 ? rqst->rq_xid : 0;
>  		__entry->status = status;
>  		__entry->flags = rqst->rq_flags;
> +		memcpy(__get_dynamic_array(addr),
> +			&rqst->rq_addr, rqst->rq_addrlen);
>  	),
>  
> -	TP_printk("addr=%pIScp xid=0x%x status=%d flags=%s", __entry->addr,
> +	TP_printk("addr=%pIScp xid=0x%x status=%d flags=%s",
> +			(struct sockaddr *)__get_dynamic_array(addr),
>  			be32_to_cpu(__entry->xid), __entry->status,
>  			show_rqstp_flags(__entry->flags))
>  );
> @@ -480,22 +482,23 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
>  	TP_ARGS(rqst, status),
>  
>  	TP_STRUCT__entry(
> -		__field(struct sockaddr *, addr)
>  		__field(__be32, xid)
> -		__field(int, dropme)
>  		__field(int, status)
>  		__field(unsigned long, flags)
> +		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
>  	),
>  
>  	TP_fast_assign(
> -		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
>  		__entry->xid = rqst->rq_xid;
>  		__entry->status = status;
>  		__entry->flags = rqst->rq_flags;
> +		memcpy(__get_dynamic_array(addr),
> +			&rqst->rq_addr, rqst->rq_addrlen);
>  	),
>  
>  	TP_printk("addr=%pIScp rq_xid=0x%x status=%d flags=%s",
> -		__entry->addr, be32_to_cpu(__entry->xid),
> +		(struct sockaddr *)__get_dynamic_array(addr),
> +		be32_to_cpu(__entry->xid),
>  		__entry->status, show_rqstp_flags(__entry->flags))
>  );
>  
> -- 
> 2.7.4
