From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
 not stop?
Date: Fri, 12 Mar 2010 17:42:18 +0800
Message-ID: <4B9A0C7A.1000001@cn.fujitsu.com>
References: <4B9772EB.9010909@cn.fujitsu.com> <20100310182401.GA23340@fieldses.org> <4B98413F.1080609@cn.fujitsu.com> <20100311155857.GC22587@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65244 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756326Ab0CLJlI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 04:41:08 -0500
In-Reply-To: <20100311155857.GC22587@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields:
> On Thu, Mar 11, 2010 at 09:02:55AM +0800, Mi Jinlong wrote:
>> J. Bruce Fields :
>>> On Wed, Mar 10, 2010 at 06:22:35PM +0800, Mi Jinlong wrote:
>>>> Hi,
>>>>
>>>>    When using command "service nfslock stop" and "service nfsklock start"
>>>> to restart the nfslock service at RHEL with kernel 2.6.31, if start the service
>>>> after stop it more than the grace_period time, lock which lockd get before
>>>> cann't be reclaimed for the grace_period is timeout.
>>>>
>>>> So, IMO, the lockd should get into grace_period when statd start not stop?
>>> Sorry, I'm not sure I understand.
>>>
>>> Are you saying that lockd's grace period starts when the last lock is
>>> shut down, instead of when the new lockd is started?  That would be a
>>> bug, I agree.
>>   I means that using command "service nfslock stop" to stop the nfslock service
>>   at RHEL, it only case statd stop, but lockd is still running. 
>>
>>   When statd stop, it send a KILL signal to lockd, lockd will release all locks
>>   and get into grace_period state to wait reclaimed lock request. It means lockd
>>   get into grace_period state when statd stop.
>>
>>   But the reclaimed lock request only be caused when client receive a SM_NOTIFY 
>>   which is send by server's statd at start. If statd start when lockd isn't at 
>>   grace_period state, the reclaimed lock cann't be reclaimed.
>>
>>   So, I think, lockd should get into grace_period state when statd start, not stop.
>>
>>> But are you really shutting down lockd completely?
>>   Lockd don't shut down when nfslock service stop, the service stop only case lockd stop
>>   at RHEL.
> 
> OK, so that's the problem.  Lockd doesn't shut down completely, if I
> remember correctly, until nfsd server and all clients do.
> 
> Our current NFS implementation just isn't designed to be able to shut
> down some components while leaving others running.

  Really? But the lockd started with nfs service start, but not nfslock service.
  And, lockd can't stop with statd at the same time. 
  Sometimes, the lockd will not synchronous with statd. Maybe this problem is a good example.

> 
> Is there some reason you *need* to do what you're doing?

  When using the NFSv3 at RHEL, I restart the nfslock service with intermediate wait 90s,
  those lock that lockd get before can't be reclaimed.
  I think it's a bug of the kernel, so I want geting some opinion.

  If you think it's a bug too, I will try to make a patch as below to fix it.

   1) When statd stop, it send a KILL signal to lockd,
      and lockd only release the lock, but don't get into grace_period.
   2) When statd start, it send one some other signal to lockd,
      and lockd only get into grace_period. The lock will be reclaimed.

thanks,
Mi Jinlong

