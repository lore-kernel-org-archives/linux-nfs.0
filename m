Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:59995 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764862AbZLQQTt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Dec 2009 11:19:49 -0500
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>
Message-Id: <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: "Trond.Myklebust Myklebust" <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4B2A02C6.6080501@cn.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock restart
Date: Thu, 17 Dec 2009 11:18:53 -0500
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com> <4B2A02C6.6080501@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Dec 17, 2009, at 5:07 AM, Mi Jinlong wrote:
> Chuck Lever :
>> On Dec 16, 2009, at 5:27 AM, Mi Jinlong wrote:
>>> Chuck Lever:
>>>> On Dec 15, 2009, at 5:02 AM, Mi Jinlong wrote:
>>>>> Hi,
>
> ...snip...
>
>>>>>
>>>>> The Primary Reason:
>>>>>
>>>>> At step3, when client's reclaimed lock request is sent to server,
>>>>> client's host(the host struct) is reused but not be re-monitored  
>>>>> at
>>>>> server's lockd. After that, statd and lockd are not sync.
>>>>
>>>> The kernel squashes SM_MON upcalls for hosts that it already  
>>>> believes
>>>> are monitored.  This is a scalability feature.
>>>
>>> When statd start, it will move files from /var/lib/nfs/statd/sm/ to
>>> /var/lib/nfs/statd/sm.bak/.
>>
>> Well, it's really sm-notify that does this.  sm-notify is run by
>> rpc.statd when it starts up.
>>
>> However, sm-notify should only retire the monitor list the first  
>> time it
>> is run after a reboot.  Simply restarting statd should not change the
>> on-disk monitor list in the slightest.  If it does, there's some  
>> kind of
>> problem with the way sm-notify's pid file is managed, or perhaps with
>> the nfslock script.
>
>  When starting, statd will call run_sm_notify() function to run sm- 
> notify.
>  Using command "service nfslock restart" will case statd stop and  
> start,
>  so sm-notify will be run. If sm-notify run, the on-disk monitor list
>  will be changed.
>
>>
>>> If lockd don't send a SM_MON to statd,
>>> statd will not monitor those client which be monitored before statd
>>> restart.
>>>
>>>>> Question:
>>>>>
>>>>> In my opinion, if lockd is allowed reuseing the client's host, it
>>>>> should
>>>>> send a SM_MON to statd when reuse. If not allowed, the client's  
>>>>> host
>>>>> should
>>>>> be destroyed immediately.
>>>>>
>>>>> What should lockd to do?  Reuse ? Destroy ? Or some other action?
>>>>
>>>> I don't immediately see why lockd should change it's behavior.   
>>>> Perhaps
>>>> statd/sm-notify were incorrect to delete the monitor list when you
>>>> restarted the nfslock service?
>>>
>>> Sorry, maybe i did not express clearly.
>>> I mean, lockd reuse the host struct which was created before statd
>>> restart.
>>>
>>> It seems have deleted the monitor list when nfslock restart.
>>
>> lockd does not touch any user space files; the on-disk monitor list  
>> is
>> managed by statd and sm-notify.  A remote peer rebooting does not  
>> clear
>> the "monitored" flag for that peer in the local kernel's lockd, so it
>> won't send another SM_MON request.
>
>  Yes, that's right.
>
>  But, this case refers to server's lockd, not the remote peer.
>  I thank, when local system's nfslock restart, local kernel's lockd
>  clear all other client's host strcut's "monitored" flag.
>
>>
>> Now, it may be the case that "service nfslock start" uses a command  
>> line
>> option that forces a fresh sm-notify run, and that is what is  
>> wiping the
>> on-disk monitor list.  That would be the bug in this case -- sm- 
>> notify
>> can and should be allowed to make its own determination of whether  
>> the
>> monitor list gets retired.  Notification should not normally be  
>> forced
>> by command line options in the nfslock script.
>
>  A fresh sm-notify run is cause by statd start.
>  I find it through codes by followed.
>
> utils/statd/statd.c
> ...
> 478         if (! (run_mode & MODE_NO_NOTIFY))
> 479                 switch (pid = fork()) {
> 480                 case 0:
> 481                         run_sm_notify(out_port);
> 482                         break;
> 483                 case -1:
> 484                         break;
> 485                 default:
> 486                         waitpid(pid, NULL, 0);
> 487                 }
> ....
>
>
> I thank, when statd restart and call sm-notify, the on-disk monitor  
> list will
> be deleted, so lockd should clear all other client's host strcut's  
> "monitored" flag.
> After that, a reused host struct will be re-monitored, a on-disk  
> monitor
> will be re-created. Like that, lockd and statd will sync .

run_sm_notify() simply forks and execs the sm-notify program.  This  
program checks for the existence of a pid file.  If the pid file  
exists, then sm-notify exits.  If it does not, then sm-notify retires  
the records in /var/lib/nfs/statd/sm and posts reboot notifications.

Jeff Layton pointed out to me yesterday that Red Hat's nfslock script  
unconditionally deletes sm-notify's pid file every time "service  
nfslock start" is done, which effectively defeats sm-notify's reboot  
detection.

sm-notify was written by a developer at SuSE.  SuSE Linux uses a tmpfs  
for /var/run, but Red Hat uses permanent storage for this directory.   
Thus on SuSE, the pid file gets deleted automatically by a reboot, but  
on Red Hat, the pid file must be deleted "by hand" or reboot  
notification never occurs.

So the root cause of this problem is that the current mechanism sm- 
notify uses to detect a reboot is not portable across distributions.

My new-statd prototype used a semaphor instead of a pid file to detect  
reboots.  A semaphor is shared (visible to other processes) and will  
continue to exist until it is deleted or the system reboots.  It is a  
resource that is not destroyed automatically when the sm-notify  
process exits.  If creating the semaphor fails, sm-notify exits.  If  
creating it succeeds, it runs.

Would anyone strongly object to using a semaphor instead of a pid file  
here?  Is support for semaphors always built into kernels?  Would  
there be any problems with the small size of the semaphor name space?   
Is there another similar facility that might be better?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




