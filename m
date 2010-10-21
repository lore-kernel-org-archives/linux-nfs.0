Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756020Ab0JUUiC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 16:38:02 -0400
Date: Thu, 21 Oct 2010 16:38:01 -0400
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: "xprt" reference count drops to 0
Message-ID: <20101021203801.GA12038@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
 <4CAAE046.5060209@bull.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CAAE046.5060209@bull.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 05, 2010 at 10:22:30AM +0200, Menyhart Zoltan wrote:
> Due to some race conditions, the reference count can become 0
> while "xprt" is still on a "pool":

Apologies, your email got buried in my inbox....

> 
> WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()
>  [] kref_get+0x23/0x2d
>  [] svc_xprt_get+0x12/0x14 [sunrpc]
>  [] svc_recv+0x2db/0x78a [sunrpc]

Which kernel exactly did you see this on?  Is it reproduceable?

> I think we should increase the reference counter before adding "xprt"
> onto any list.

I don't see the xprt added to any list after the svc_xprt_get() you've
added below.

Help, I'm confused!

--b.

> 
> Obviously, we keep increasing the reference count before passing "xprt"
> to another thread via "rqstp->rq_xprt".
> 
> Thanks,
> 
> Zoltan Menyhart

> "svc_xprt_get()" should be invoked before adding "xprt" onto "pool" by
> "svc_xprt_enqueue()".
> Otherwise "xprt->xpt_ref" can drop to 0 due to race conditions.
> 
> Signed-off-by: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
> 
> --- old/net/sunrpc/svc_xprt.c	2010-10-05 09:47:51.000000000 +0200
> +++ new/net/sunrpc/svc_xprt.c	2010-10-05 09:47:20.000000000 +0200
> @@ -369,6 +369,7 @@
>  	}
>  
>   process:
> +	svc_xprt_get(xprt);
>  	if (!list_empty(&pool->sp_threads)) {
>  		rqstp = list_entry(pool->sp_threads.next,
>  				   struct svc_rqst,
> @@ -381,7 +382,6 @@
>  				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
>  				rqstp, rqstp->rq_xprt);
>  		rqstp->rq_xprt = xprt;
> -		svc_xprt_get(xprt);
>  		rqstp->rq_reserved = serv->sv_max_mesg;
>  		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  		pool->sp_stats.threads_woken++;
> @@ -655,7 +655,6 @@
>  	xprt = svc_xprt_dequeue(pool);
>  	if (xprt) {
>  		rqstp->rq_xprt = xprt;
> -		svc_xprt_get(xprt);
>  		rqstp->rq_reserved = serv->sv_max_mesg;
>  		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  	} else {

