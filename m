Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44178 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbaKFTse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2014 14:48:34 -0500
Date: Thu, 6 Nov 2014 14:48:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: imc@cs.ox.ac.uk, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: ratelimit "lockd: cannot monitor" messages
Message-ID: <20141106194832.GB22638@fieldses.org>
References: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 31, 2014 at 08:28:29AM -0400, Jeff Layton wrote:
> When lockd can't talk to a remote statd, it'll spew a warning message
> to the ring buffer. If the application is really hammering on locks
> however, it's possible for that message to spam the logs. Ratelimit it
> to minimize the potential for harm.

Thanks, applying for 3.19.--b.

> 
> Reported-by: Ian Collier <imc@cs.ox.ac.uk>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/lockd/mon.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 9106f42c472c..1cc6ec51e6b1 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -214,7 +214,7 @@ int nsm_monitor(const struct nlm_host *host)
>  	if (unlikely(res.status != 0))
>  		status = -EIO;
>  	if (unlikely(status < 0)) {
> -		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
> +		pr_notice_ratelimited("lockd: cannot monitor %s\n", nsm->sm_name);
>  		return status;
>  	}
>  
> -- 
> 1.9.3
> 
