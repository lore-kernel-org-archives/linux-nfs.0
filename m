From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After server stop nfslock service, client still can get lock success
Date: Wed, 18 Nov 2009 12:03:42 -0500
Message-ID: <799834E0-C52E-462A-A036-64B4C4DF5C06@oracle.com>
References: <4B027123.4060100@cn.fujitsu.com> <84C94F5A-0192-4F6D-858D-0CCA92574625@oracle.com> <4B03C366.8050009@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53204 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757916AbZKRREA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Nov 2009 12:04:00 -0500
In-Reply-To: <4B03C366.8050009@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 18, 2009, at 4:50 AM, Mi Jinlong wrote:

> Hi
>
> Chuck Lever:
>>
>> On Nov 17, 2009, at 4:47 AM, Mi Jinlong wrote:
>>
>>> When testing NLM, i find a bug.
>>> After server stop nfslock service, client still can get lock success
>>>
>>> Test process:
>>>
>>> Step1: client open nfs file.
>>> Step2: client using fcntl to get lock.
>>> Step3: client using fcntl to release lock.
>>> Step4: service stop it's nfslock service.
>>> Step5: client using fcntl to get lock again.
>>>
>>> At step5, client should get lock fail, but it's success.
>>>
>>> Reason:
>>> When server stop nfslock service, client's host struct not be
>>> unmonitor at server. When client get lock again, the client's
>>> host struct will be reuse but don't monitor again.
>>> So that, at step5 client can get lock success.
>>
>> Effectively, the client is still monitored, since it is still in  
>> statd's
>> monitored list.  Shutting down statd does not remove it from the  
>> monitor
>> list.  If the local host reboots, sm-notify will still send the  
>> remote
>> an SM_NOTIFY request, which is correct.
>>
>> Additionally, new clients attempting to lock files when statd is down
>> will fail, which is correct if statd is not available.
>>
>> Conversely, if a monitored remote reboots, there is no way to  
>> notify the
>> local lockd of the reboot, since statd normally relays the  
>> SM_NOTIFY to
>> lockd, but isn't running.  That might be a problem.
>
>  Yes, it seems a problem.
>
>  I don't confirm it, so i want get your opinion.

Currently, there isn't a high degree of coordination between lockd and  
statd.  This is to maintain good scalability when serving NFS lock  
requests.  You offered a couple of alternatives for improving this  
specific situation, but my opinion is that there are larger, more  
general coordination issues here, and that what you observed is  
expected behavior for the current design.

This still seems to me like a case of "Patient: Doctor, it hurts when  
I do that." "Doctor: Well, then, don't do that."  In other words, we  
assume that "service nfslock stop" won't be used under normal  
operating conditions, and we know that NLM will misbehave if you stop  
statd during normal operation.

>> However, shutting down statd during normal operation is not a  
>> normal or
>> supported thing to do.
>>
>>> Question:
>>> 1. Should unmonitor the client's host struct at server
>>>    when server stop nfslock service ?
>>>
>>> 2. Whether let rpc.statd tell kernel it's status(when start and  
>>> stop)
>>>    by send a SM_NOTIFY ?
>>
>> There are a number of other coordination issues around statd start-up
>> and shut down.  The server's grace period, for instance, is not
>> synchronized with sending reboot notifications.  So, we do recognize
>> this is a general problem.
>>
>> In this case, however, I would expect indeterminate behavior if  
>> statd is
>> shut down during normal operation, and that's exactly what we get.   
>> I'm
>> not sure it's even reasonable to support this use case.  Why would
>> someone shut down statd and expect reliable NFSv2/v3 locking  
>> behavior?
>> In other words, with due respect, what problem would we solve by  
>> fixing
>> this, other than making your test case work?
>
>  When server's nfslock service is stop, client can get lock success  
> sometimes
>  and can't get success sometimes, it's puzzled.

On Linux, the user space "nfslock" service is actually nothing more  
than statd.  Linux's NLM service is handled in the kernel, and is  
started and stopped when either a) there are NFS mounts, or b) NFSD is  
started.  The kernel's NLM service has nothing to do with "service  
nfslock start" any more.  I think there used to be a user space NLM  
implementation.

>> Out of curiosity, what happens if you try this on a Solaris server?
>
>  I'm a new man for Solaris.
>  When Solaris's nlockmgr is stop, client can't get lock immediately.

I should have been more clear: if you stop Solaris' user space NSM  
daemon, can you lock files consistently?  My bet is that Solaris will  
demonstrate a similar degree of inconsistent behavior if you try NFSv2/ 
v3 locking while starting and stopping its NSM service daemon.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



