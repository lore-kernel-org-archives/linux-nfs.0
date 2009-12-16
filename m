From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock restart
Date: Wed, 16 Dec 2009 14:33:20 -0500
Message-ID: <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:22401 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935487AbZLPTeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 14:34:23 -0500
In-Reply-To: <4B28B5FD.5000103@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 16, 2009, at 5:27 AM, Mi Jinlong wrote:
> Chuck Lever:
>> On Dec 15, 2009, at 5:02 AM, Mi Jinlong wrote:
>>> Hi,
>>>
>>> When testing the NLM at the latest kernel(2.6.32),  i find a bug.
>>> When a client hold locks, after server restart its nfslock service,
>>> server's statd will not synchronize with lockd.
>>> If server restart nfslock twice or more, client's lock will be lost.
>>>
>>> Test process:
>>>
>>> Step1: client open nfs file.
>>> Step2: client using fcntl to get lock.
>>> Step3: server restart it's nfslock service.
>>
>> I'll assume here that you mean the equivalent of "service nfslock
>> restart".  This restarts statd and possibly runs sm-notify, but it  
>> has
>> no effect on lockd.
>
>  Yes, i used "service nfslock restart".
>
>  It has effect on lockd too, when service stop, lockd will get a  
> KILL signal.
>  Lockd will release all client's locks, and go into grace_period and  
> wait
>  client reclaime it's lock.
>
>>
>> Again, this test seems artificial to me.  Is there a real world use  
>> case
>> where someone would deliberately restart statd while an NFS server is
>> serving files?  I pose this question because I've worked on statd  
>> only
>> for a year or so, and I am quite likely ignorant of all the ways it  
>> can
>> be deployed.
>
>  ^/^, but maybe someone will restart nfslock when an NFS server is  
> serving files.
>  It is inevitable.
>
>>> After step3, server's lockd records client holding locks, but  
>>> statd's
>>> /var/lib/nfs/statd/sm/ directory is empty. It means statd and  
>>> lockd are
>>> not sync. If server restart it's nfslock again, client's locks  
>>> will be
>>> lost.
>>>
>>> The Primary Reason:
>>>
>>> At step3, when client's reclaimed lock request is sent to server,
>>> client's host(the host struct) is reused but not be re-monitored at
>>> server's lockd. After that, statd and lockd are not sync.
>>
>> The kernel squashes SM_MON upcalls for hosts that it already believes
>> are monitored.  This is a scalability feature.
>
>  When statd start, it will move files from /var/lib/nfs/statd/sm/ to
>  /var/lib/nfs/statd/sm.bak/.

Well, it's really sm-notify that does this.  sm-notify is run by  
rpc.statd when it starts up.

However, sm-notify should only retire the monitor list the first time  
it is run after a reboot.  Simply restarting statd should not change  
the on-disk monitor list in the slightest.  If it does, there's some  
kind of problem with the way sm-notify's pid file is managed, or  
perhaps with the nfslock script.

> If lockd don't send a SM_MON to statd,
>  statd will not monitor those client which be monitored before statd  
> restart.
>
>>> Question:
>>>
>>> In my opinion, if lockd is allowed reuseing the client's host, it  
>>> should
>>> send a SM_MON to statd when reuse. If not allowed, the client's host
>>> should
>>> be destroyed immediately.
>>>
>>> What should lockd to do?  Reuse ? Destroy ? Or some other action?
>>
>> I don't immediately see why lockd should change it's behavior.   
>> Perhaps
>> statd/sm-notify were incorrect to delete the monitor list when you
>> restarted the nfslock service?
>
>  Sorry, maybe i did not express clearly.
>  I mean, lockd reuse the host struct which was created before statd  
> restart.
>
>  It seems have deleted the monitor list when nfslock restart.

lockd does not touch any user space files; the on-disk monitor list is  
managed by statd and sm-notify.  A remote peer rebooting does not  
clear the "monitored" flag for that peer in the local kernel's lockd,  
so it won't send another SM_MON request.

Now, it may be the case that "service nfslock start" uses a command  
line option that forces a fresh sm-notify run, and that is what is  
wiping the on-disk monitor list.  That would be the bug in this case  
-- sm-notify can and should be allowed to make its own determination  
of whether the monitor list gets retired.  Notification should not  
normally be forced by command line options in the nfslock script.

>> Can you show exactly how statd's state (ie it's on-disk monitor  
>> list in
>> /var/lib/nfs/statd/sm) changed across the restart?  Did sm-notify run
>> when you restarted statd?  If so, why didn't the sm-notify pid file  
>> stop
>> it?
>
>  The statd and lockd's state at server when nfslock restart:
>
>        lockd                   statd         |
>                                              |
>      host(monitored = 1)      /sm/client     |  client get locks  
> success at first
>          (locks)                             |
>                                              |
>      host(monitored = 1)      /sm/client     |  nfslock stop (lockd  
> release client's locks)
>          (no locks)                          |
>                                              |
>      host(monitored = 1)      /sm/           |  nfslock start  
> (client reclaim locks)
>          (locks)                             |                (but  
> statd don't monitor it)
>
>  note: host(monitored=1)  means: client's host struct is created,  
> and is marked be monitored.
>        (locks), (no locks)means: host strcut holds locks, or not.
>        /sm/client         means: there have a file under /var/lib/ 
> nfs/statd/sm directory
>        /sm/               means: /var/lib/nfs/statd/sm is empty!
>
>
> thanks,
> Mi Jinlong
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




