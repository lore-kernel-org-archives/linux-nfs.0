From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: Set address family before calling
	nlm_host_rebooted()
Date: Thu, 23 Oct 2008 16:58:20 -0400
Message-ID: <20081023205820.GB26419@fieldses.org>
References: <20081023044245.15258.55293.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbYJWU6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 16:58:22 -0400
In-Reply-To: <20081023044245.15258.55293.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2008 at 12:50:35AM -0400, Chuck Lever wrote:
> The nlm_host_rebooted() function uses nlm_cmp_addr() to find an
> nsm_handle that matches the rebooted peer.  In order for this to work,
> the passed-in address must have a proper address family.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 

Thanks!

> Bruce - since we dropped the remaining NSM IPv6 patches for 2.6.28, I
> think we need to add this one to make sure lock recovery continues to
> work.

So this is a regression?  (If so, when was it introduced?)

Have you tested lock recovery?  I'll see if I can get some sort of lock
recovery test running as part of my default regression tests this
weekend....  It seems to be something that hasn't been watched closely
enough.

--b.


> 
> Please consider this one for 2.6.28.
> 
>  fs/lockd/svc4proc.c |    1 +
>  fs/lockd/svcproc.c  |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index 014f6ce..4dfdcbc 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -434,6 +434,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  	 * reclaim all locks we hold on this server.
>  	 */
>  	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
>  	saddr.sin_addr.s_addr = argp->addr;
>  	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>  
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 548b0bb..3ca89e2 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -466,6 +466,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  	 * reclaim all locks we hold on this server.
>  	 */
>  	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
>  	saddr.sin_addr.s_addr = argp->addr;
>  	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
