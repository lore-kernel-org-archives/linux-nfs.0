From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Fri, 21 Dec 2007 12:51:25 -0500
Message-ID: <58F4CCD3-1E95-4B53-8FF3-F979B984D533@oracle.com>
References: <1198250890-25571-1-git-send-email-jlayton@redhat.com> <1198250890-25571-2-git-send-email-jlayton@redhat.com> <1198250890-25571-3-git-send-email-jlayton@redhat.com> <1198250890-25571-4-git-send-email-jlayton@redhat.com> <1198250890-25571-5-git-send-email-jlayton@redhat.com> <1198250890-25571-6-git-send-email-jlayton@redhat.com> <1198250890-25571-7-git-send-email-jlayton@redhat.com> <213379F3-BB83-47CB-9488-436D246026B5@oracle.com> <20071221120215.03beada0@tleilax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:51635 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbXLURxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2007 12:53:00 -0500
In-Reply-To: <20071221120215.03beada0-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 21, 2007, at 12:02 PM, Jeff Layton wrote:
> On Fri, 21 Dec 2007 11:43:20 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> Hi Jeff-
>>
>> On Dec 21, 2007, at 10:28 AM, Jeff Layton wrote:
>>> ...and only have lockd exit when the last reference is dropped.
>>>
>>> The problem is this:
>>>
>>> When a lock that a client is blocking on comes free, lockd does
>>> this in
>>> nlmsvc_grant_blocked():
>>>
>>>     nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG,
>>> &nlmsvc_grant_ops);
>>>
>>> the callback from this call is nlmsvc_grant_callback(). That
>>> function does this at the end to wake up lockd:
>>>
>>>     svc_wake_up(block->b_daemon);
>>>
>>> However there is no guarantee that lockd will be up when this
>>> happens. If someone shuts down or restarts lockd before the async
>>> call completes,
>>> then the b_daemon pointer will point to freed memory and the
>>> kernel may
>>> oops.
>>
>> Here is perhaps a naive question.
>>
>> If there is a network partition between client and server while one
>> of these async requests is outstanding, and someone does a lockd_down
>> () during the partition, will lockd hang until the network is
>> restored?
>
> Yes. lockd stays up indefinitely.

But it's still responsive, yes?  So this isn't a livelock hang in  
that situation.

>> If it does, is there any indication to administrators or
>> users what may be causing the hang?
>>
>
> No, though that's a good point. Perhaps there should be. I'll think
> about how we could add a notification.

You could easily post a message to the kernel log that says "lockd  
was signaled to stop, but is waiting for outstanding requests to  
complete."

>> Current behavior is either a crash or a clean lockd restart, yes?
>> Would the new behavior be a hang?
>
> Current behavior is a crash period (well, a crash if memory poisoning
> is on, otherwise YMMV). If lockd is restarted the svc_wake_up still
> wakes up a non-existent b_daemon.
>
> The new behavior is not a "hang" per-se. lockd will just stay up and
> processing until nlmsvc_ref goes to 0, which will never happen if
> there's a network partition. If the partition is removed, the callback
> will complete and lockd will go down. If a lockd_up is done before the
> callback completes, then the existing lockd will just stay up,  
> though it
> will have been signalled and will have dropped all of its existing
> locks.
>
> My original patch for this changed the svc_wake_up() call to a call to
> wake up whatever lockd happened to be up at the time. Trond seemed to
> think that lockd should just stay up in this situation, and this
> patchset is an attempt to implement that.

Appropriate shutdown processing and not dropping requests in progress  
may have conflicting purposes here.  :-)

Continuing to operate makes sense if there's another lockd waiting to  
start up; but during system shutdown processing, we may just want to  
pull the rug out.

Would it make sense to time out the requests so lockd could shutdown  
in an orderly fashion?  Or perhaps somehow teach lockd to distinguish  
between a daemon restart and a system shutdown?  Maybe it's not worth  
the effort.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
