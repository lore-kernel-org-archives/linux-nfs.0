From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 3/3] lockd: reject reclaims outside the grace period
Date: Mon, 29 Sep 2008 21:48:48 -0700
Message-ID: <OF00072D17.F38B2A1C-ON882574D4.0019CC91-882574D4.001A6F58@us.ibm.com>
References: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu> <1222742643-31541-2-git-send-email-bfields@citi.umich.edu> <1222742643-31541-3-git-send-email-bfields@citi.umich.edu> <1222742643-31541-4-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54136 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbYI3Esx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 00:48:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8U4mpPJ024476
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2008 00:48:51 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8U4mpWR261620
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2008 00:48:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8U4mpP7004643
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2008 00:48:51 -0400
In-Reply-To: <1222742643-31541-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unfortunately the application don't get notified when the reclaim failed. 
Now you are making sure that application will fail because if they missed 
the reclaim window they will not get the lock back and the application 
will continue to run without a lock. Not sure this is better behavior.
Marc.


linux-nfs-owner@vger.kernel.org wrote on 09/29/2008 07:44:03 PM:

> 
> [PATCH 3/3] lockd: reject reclaims outside the grace period
> 
> The current lockd does not reject reclaims that arrive outside of the
> grace period.
> 
> Accepting a reclaim means promising to the client that no conflicting
> locks were granted since last it held the lock.  We can meet that
> promise if we assume the only lockers are nfs clients, and that they are
> sufficiently well-behaved to reclaim only locks that they held before,
> and that only reclaim locks have been permitted so far.  Once we leave
> the grace period (and start permitting non-reclaims), we can no longer
> keep that promise.  So we must start rejecting reclaims at that point.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/lockd/svclock.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 808d246..6063a8e 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -410,6 +410,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct 
> nlm_file *file,
>        ret = nlm_lck_denied_grace_period;
>        goto out;
>     }
> +   if (reclaim && !locks_in_grace()) {
> +      ret = nlm_lck_denied_grace_period;
> +      goto out;
> +   }
> 
>     if (!wait)
>        lock->fl.fl_flags &= ~FL_SLEEP;
> -- 
> 1.5.5.rc1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

