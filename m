From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After server stop nfslock service, client still can get lock success
Date: Tue, 17 Nov 2009 10:34:40 -0500
Message-ID: <84C94F5A-0192-4F6D-858D-0CCA92574625@oracle.com>
References: <4B027123.4060100@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:38548 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbZKQPfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2009 10:35:04 -0500
In-Reply-To: <4B027123.4060100@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 17, 2009, at 4:47 AM, Mi Jinlong wrote:

> When testing NLM, i find a bug.
> After server stop nfslock service, client still can get lock success
>
> Test process:
>
>  Step1: client open nfs file.
>  Step2: client using fcntl to get lock.
>  Step3: client using fcntl to release lock.
>  Step4: service stop it's nfslock service.
>  Step5: client using fcntl to get lock again.
>
> At step5, client should get lock fail, but it's success.
>
> Reason:
>  When server stop nfslock service, client's host struct not be
>  unmonitor at server. When client get lock again, the client's
>  host struct will be reuse but don't monitor again.
>  So that, at step5 client can get lock success.

Effectively, the client is still monitored, since it is still in  
statd's monitored list.  Shutting down statd does not remove it from  
the monitor list.  If the local host reboots, sm-notify will still  
send the remote an SM_NOTIFY request, which is correct.

Additionally, new clients attempting to lock files when statd is down  
will fail, which is correct if statd is not available.

Conversely, if a monitored remote reboots, there is no way to notify  
the local lockd of the reboot, since statd normally relays the  
SM_NOTIFY to lockd, but isn't running.  That might be a problem.

However, shutting down statd during normal operation is not a normal  
or supported thing to do.

> Question:
>  1. Should unmonitor the client's host struct at server
>     when server stop nfslock service ?
>
>  2. Whether let rpc.statd tell kernel it's status(when start and stop)
>     by send a SM_NOTIFY ?

There are a number of other coordination issues around statd start-up  
and shut down.  The server's grace period, for instance, is not  
synchronized with sending reboot notifications.  So, we do recognize  
this is a general problem.

In this case, however, I would expect indeterminate behavior if statd  
is shut down during normal operation, and that's exactly what we get.   
I'm not sure it's even reasonable to support this use case.  Why would  
someone shut down statd and expect reliable NFSv2/v3 locking  
behavior?  In other words, with due respect, what problem would we  
solve by fixing this, other than making your test case work?

Out of curiosity, what happens if you try this on a Solaris server?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



