From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
	not stop?
Date: Thu, 11 Mar 2010 10:58:57 -0500
Message-ID: <20100311155857.GC22587@fieldses.org>
References: <4B9772EB.9010909@cn.fujitsu.com> <20100310182401.GA23340@fieldses.org> <4B98413F.1080609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751931Ab0CKP5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Mar 2010 10:57:34 -0500
In-Reply-To: <4B98413F.1080609@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 11, 2010 at 09:02:55AM +0800, Mi Jinlong wrote:
> 
> J. Bruce Fields :
> > On Wed, Mar 10, 2010 at 06:22:35PM +0800, Mi Jinlong wrote:
> >> Hi,
> >>
> >>    When using command "service nfslock stop" and "service nfsklock start"
> >> to restart the nfslock service at RHEL with kernel 2.6.31, if start the service
> >> after stop it more than the grace_period time, lock which lockd get before
> >> cann't be reclaimed for the grace_period is timeout.
> >>
> >> So, IMO, the lockd should get into grace_period when statd start not stop?
> > 
> > Sorry, I'm not sure I understand.
> > 
> > Are you saying that lockd's grace period starts when the last lock is
> > shut down, instead of when the new lockd is started?  That would be a
> > bug, I agree.
> 
>   I means that using command "service nfslock stop" to stop the nfslock service
>   at RHEL, it only case statd stop, but lockd is still running. 
> 
>   When statd stop, it send a KILL signal to lockd, lockd will release all locks
>   and get into grace_period state to wait reclaimed lock request. It means lockd
>   get into grace_period state when statd stop.
> 
>   But the reclaimed lock request only be caused when client receive a SM_NOTIFY 
>   which is send by server's statd at start. If statd start when lockd isn't at 
>   grace_period state, the reclaimed lock cann't be reclaimed.
> 
>   So, I think, lockd should get into grace_period state when statd start, not stop.
> 
> > 
> > But are you really shutting down lockd completely?
> 
>   Lockd don't shut down when nfslock service stop, the service stop only case lockd stop
>   at RHEL.

OK, so that's the problem.  Lockd doesn't shut down completely, if I
remember correctly, until nfsd server and all clients do.

Our current NFS implementation just isn't designed to be able to shut
down some components while leaving others running.

Is there some reason you *need* to do what you're doing?

--b.
