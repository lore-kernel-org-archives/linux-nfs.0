From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
 restart
Date: Thu, 17 Dec 2009 18:07:02 +0800
Message-ID: <4B2A02C6.6080501@cn.fujitsu.com>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60349 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1764273AbZLQKFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 05:05:12 -0500
In-Reply-To: <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever :
> On Dec 16, 2009, at 5:27 AM, Mi Jinlong wrote:
>> Chuck Lever:
>>> On Dec 15, 2009, at 5:02 AM, Mi Jinlong wrote:
>>>> Hi,

...snip...

>>>>
>>>> The Primary Reason:
>>>>
>>>> At step3, when client's reclaimed lock request is sent to server,
>>>> client's host(the host struct) is reused but not be re-monitored at
>>>> server's lockd. After that, statd and lockd are not sync.
>>>
>>> The kernel squashes SM_MON upcalls for hosts that it already believes
>>> are monitored.  This is a scalability feature.
>>
>>  When statd start, it will move files from /var/lib/nfs/statd/sm/ to
>>  /var/lib/nfs/statd/sm.bak/.
> 
> Well, it's really sm-notify that does this.  sm-notify is run by
> rpc.statd when it starts up.
> 
> However, sm-notify should only retire the monitor list the first time it
> is run after a reboot.  Simply restarting statd should not change the
> on-disk monitor list in the slightest.  If it does, there's some kind of
> problem with the way sm-notify's pid file is managed, or perhaps with
> the nfslock script.

  When starting, statd will call run_sm_notify() function to run sm-notify.
  Using command "service nfslock restart" will case statd stop and start,
  so sm-notify will be run. If sm-notify run, the on-disk monitor list 
  will be changed.

> 
>> If lockd don't send a SM_MON to statd,
>>  statd will not monitor those client which be monitored before statd
>> restart.
>>
>>>> Question:
>>>>
>>>> In my opinion, if lockd is allowed reuseing the client's host, it
>>>> should
>>>> send a SM_MON to statd when reuse. If not allowed, the client's host
>>>> should
>>>> be destroyed immediately.
>>>>
>>>> What should lockd to do?  Reuse ? Destroy ? Or some other action?
>>>
>>> I don't immediately see why lockd should change it's behavior.  Perhaps
>>> statd/sm-notify were incorrect to delete the monitor list when you
>>> restarted the nfslock service?
>>
>>  Sorry, maybe i did not express clearly.
>>  I mean, lockd reuse the host struct which was created before statd
>> restart.
>>
>>  It seems have deleted the monitor list when nfslock restart.
> 
> lockd does not touch any user space files; the on-disk monitor list is
> managed by statd and sm-notify.  A remote peer rebooting does not clear
> the "monitored" flag for that peer in the local kernel's lockd, so it
> won't send another SM_MON request.

  Yes, that's right.

  But, this case refers to server's lockd, not the remote peer.
  I thank, when local system's nfslock restart, local kernel's lockd 
  clear all other client's host strcut's "monitored" flag.

> 
> Now, it may be the case that "service nfslock start" uses a command line
> option that forces a fresh sm-notify run, and that is what is wiping the
> on-disk monitor list.  That would be the bug in this case -- sm-notify
> can and should be allowed to make its own determination of whether the
> monitor list gets retired.  Notification should not normally be forced
> by command line options in the nfslock script.

  A fresh sm-notify run is cause by statd start. 
  I find it through codes by followed.

 utils/statd/statd.c
 ...
 478         if (! (run_mode & MODE_NO_NOTIFY))
 479                 switch (pid = fork()) {
 480                 case 0:
 481                         run_sm_notify(out_port);
 482                         break;
 483                 case -1:
 484                         break;
 485                 default:
 486                         waitpid(pid, NULL, 0);
 487                 }
 ....


 I thank, when statd restart and call sm-notify, the on-disk monitor list will 
 be deleted, so lockd should clear all other client's host strcut's "monitored" flag.
 After that, a reused host struct will be re-monitored, a on-disk monitor 
 will be re-created. Like that, lockd and statd will sync .


thanks,
Mi Jinlong

