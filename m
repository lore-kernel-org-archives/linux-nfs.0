From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NLM: don't let lockd exit on unexpected svc_recv
	errors (try #2)
Date: Tue, 08 Apr 2008 16:15:58 -0400
Message-ID: <1207685758.11699.28.camel@heimdal.trondhjem.org>
References: <1207683608-17550-1-git-send-email-jlayton@redhat.com>
	 <1207683608-17550-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:58416 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbYDHUQL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 16:16:11 -0400
In-Reply-To: <1207683608-17550-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 15:40 -0400, Jeff Layton wrote:
> When svc_recv returns an unexpected error, lockd will print a warning
> and exit. This problematic for several reasons. In particular, it will
> cause the reference counts for the thread to be wrong, and can lead to a
> potential BUG() call.
> 
> Rather than exiting on error from svc_recv, have the thread do a 1s
> sleep and then retry the loop. This is unlikely to cause any harm, and
> if the error turns out to be something temporary then it may be able to
> recover.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/svc.c |   18 ++++++++++++------
>  1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 66b5c98..cf977bb 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -112,7 +112,7 @@ static inline void clear_grace_period(void)
>  static int
>  lockd(void *vrqstp)
>  {
> -	int		err = 0;
> +	int		err = 0, preverr = 0;
>  	struct svc_rqst *rqstp = vrqstp;
>  	unsigned long grace_period_expire;
>  
> @@ -172,14 +172,20 @@ lockd(void *vrqstp)
>  		 * recvfrom routine.
>  		 */
>  		err = svc_recv(rqstp, timeout);
> -		if (err == -EAGAIN || err == -EINTR)
> +		if (err == -EAGAIN || err == -EINTR) {
> +			preverr = err;
>  			continue;
> +		}
>  		if (err < 0) {
> -			printk(KERN_WARNING
> -			       "lockd: terminating on error %d\n",
> -			       -err);
> -			break;
> +			if (err != preverr) {
> +				printk(KERN_WARNING "%s: unexpected error "
> +					"from svc_recv (%d)\n", __func__, err);
> +				preverr = err;
> +			}
> +			schedule_timeout_interruptible(HZ);

Why not use an uninterruptible sleep?

Trond

