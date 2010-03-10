From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
	not stop?
Date: Wed, 10 Mar 2010 13:24:01 -0500
Message-ID: <20100310182401.GA23340@fieldses.org>
References: <4B9772EB.9010909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54170 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754500Ab0CJSWl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Mar 2010 13:22:41 -0500
In-Reply-To: <4B9772EB.9010909@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 10, 2010 at 06:22:35PM +0800, Mi Jinlong wrote:
> Hi,
> 
>    When using command "service nfslock stop" and "service nfsklock start"
> to restart the nfslock service at RHEL with kernel 2.6.31, if start the service
> after stop it more than the grace_period time, lock which lockd get before
> cann't be reclaimed for the grace_period is timeout.
> 
> So, IMO, the lockd should get into grace_period when statd start not stop?

Sorry, I'm not sure I understand.

Are you saying that lockd's grace period starts when the last lock is
shut down, instead of when the new lockd is started?  That would be a
bug, I agree.

But are you really shutting down lockd completely?

--b.

> 
> Some code at kernel: fs/lockd/svclock.c
>  ....
>  411         if (locks_in_grace() && !reclaim) {
>  412                 ret = nlm_lck_denied_grace_period;
>  413                 goto out;
>  414         }
>  415         if (reclaim && !locks_in_grace()) {
>  416                 ret = nlm_lck_denied_grace_period;
>  417                 goto out;
>  418         }
>  ....
> 
> I think it can implement it like that:
>   1) When statd stop, it send a KILL signal to lockd,
>      and lockd only release the lock, but don't get into grace_period.
>   2) When statd start, it send one some other signal to lockd,
>      and lockd only get into grace_period. The lock will be reclaimed.
> 
> thanks,
> Mi Jinlong
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
