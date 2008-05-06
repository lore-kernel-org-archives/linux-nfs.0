From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  2/3] svcrdma: Remove extra check for XPT_DEAD bit in
	svc_xprt_enqueue
Date: Tue, 6 May 2008 18:04:13 -0400
Message-ID: <20080506220413.GR13484@fieldses.org>
References: <12097450861136-git-send-email-tom@opengridcomputing.com> <12097450861293-git-send-email-tom@opengridcomputing.com> <12097450863435-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38654 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765AbYEFWEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 18:04:14 -0400
In-Reply-To: <12097450863435-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:18:05AM -0500, Tom Tucker wrote:
> Remove a redundant check for the XPT_DEAD bit in the svc_xprt_enqueue
> function. This same bit is checked below while holding the pool lock

Yeah, seems pointless.  I wonder how it got there.

--b.

> and prints a debug message if found to be dead.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/svc_xprt.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 74e52d4..fb8a785 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -296,8 +296,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  	if (!(xprt->xpt_flags &
>  	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
>  		return;
> -	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> -		return;
>  
>  	cpu = get_cpu();
>  	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
