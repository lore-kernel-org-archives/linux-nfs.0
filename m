From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH]lockd: fix handling of grace period after long periods
	of inactivity
Date: Thu, 14 Aug 2008 15:06:52 -0400
Message-ID: <20080814190652.GE23859@fieldses.org>
References: <48A41220.8030203@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56979 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732AbYHNTHF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 15:07:05 -0400
In-Reply-To: <48A41220.8030203-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2008 at 08:08:16PM +0900, NAKANO Hiroaki wrote:
> lockd uses time_before() to determine whether the grace period has
> expired. This would seem to be enough to avoid timer wrap-around issues,
> but, unfortunately, that is not the case. The time_* family of
> comparison functions can be safely used to compare jiffies relatively
> close in time, but they stop working after approximately LONG_MAX/2
> ticks. nfsd can suffer this problem because the time_before() comparison
> in lockd() is not performed until the first request comes in, which
> means that if there is no lockd traffic for more than LONG_MAX/2 ticks
> we are screwed.
> 
> The implication of this is that once time_before() starts misbehaving
> any attempt from a NFS client to execute fcntl() will be received with a
> NLM_LCK_DENIED_GRACE_PERIOD message for 25 days (assuming HZ=1000). In
> other words, the 50 seconds grace period could turn into a grace period
> of 50 days or more.
> 
> This patch corrects this behavior by implementing grace period with a
> (retriggerable) timer.
> 
> Note: This bug was analyzed independently by Oda-san <oda-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> and myself.

Good catch!  Did you actually run across this in practice?  I would've
thought it relatively unusual to have a lockd that didn't receive its
first lock request until 25 days after startup.

I've actually had a patch that does roughly the same thing for a while
at:

	git://linux-nfs.org/~bfields/linux.git failover

3ff893a7.. "lockd: don't depend on lockd main loop to end grace" but
hadn't submitted it since I didn't see the bug you found.  (I had other
reasons I wanted to do this).  Difference that I can see off-hand:

	- I used schedule_delayed_work instead of a timer.
	- I forgot to delete the thing before exiting!

So I think my solution has a bug that yours doesn't.  (I don't see what
would stop the module being removed before my work gets scheduled.)

I still have a mild preference for a work struct just in case we end up
wanting to do something slightly more complicated to end the grace
period, but I don't really have anything in mind.

--b.

> 
> Signed-off-by: Nakano Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
> ---
> 
> diff -Nrup linux-2.6.27-rc3/fs/lockd/svc.c b/fs/lockd/svc.c
> --- linux-2.6.27-rc3/fs/lockd/svc.c	2008-08-14 16:54:24.000000000 +0900
> +++ b/fs/lockd/svc.c	2008-08-14 17:04:15.000000000 +0900
> @@ -53,6 +53,7 @@ static struct task_struct	*nlmsvc_task;
>  static struct svc_rqst		*nlmsvc_rqst;
>  int				nlmsvc_grace_period;
>  unsigned long			nlmsvc_timeout;
> +static struct timer_list        nlm_period_timer;
> 
>  /*
>   * These can be set at insmod time (useful for NFS as root filesystem),
> @@ -141,6 +142,12 @@ lockd(void *vrqstp)
> 
>  	grace_period_expire = set_grace_period();
> 
> +	init_timer(&nlm_period_timer);
> +	nlm_period_timer.function = clear_grace_period;
> +	nlm_period_timer.expires = grace_period_expire;
> +
> +	add_timer(&nlm_period_timer);
> +
>  	/*
>  	 * The main request loop. We don't terminate until the last
>  	 * NFS mount or NFS daemon has gone away.
> @@ -154,6 +161,7 @@ lockd(void *vrqstp)
>  			if (nlmsvc_ops) {
>  				nlmsvc_invalidate_all();
>  				grace_period_expire = set_grace_period();
> +				mod_timer(&nlm_period_timer, grace_period_expire);
>  			}
>  			continue;
>  		}
> @@ -164,10 +172,8 @@ lockd(void *vrqstp)
>  		 * (Theoretically, there shouldn't even be blocked locks
>  		 * during grace period).
>  		 */
> -		if (!nlmsvc_grace_period) {
> +		if (!nlmsvc_grace_period)
>  			timeout = nlmsvc_retry_blocked();
> -		} else if (time_before(grace_period_expire, jiffies))
> -			clear_grace_period();
> 
>  		/*
>  		 * Find a socket with data available and call its
> @@ -195,6 +201,7 @@ lockd(void *vrqstp)
>  		svc_process(rqstp);
>  	}
>  	flush_signals(current);
> +	del_timer(&nlm_period_timer);
>  	if (nlmsvc_ops)
>  		nlmsvc_invalidate_all();
>  	nlm_shutdown_hosts();
> 
> -- 
> (NAKANO, Hiroaki) <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
