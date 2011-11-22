Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:42626 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1KVMeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 07:34:37 -0500
Message-ID: <4ECB96DA.9030202@citrix.com>
Date: Tue, 22 Nov 2011 12:34:34 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
References: <4EC6A681.30902@citrix.com>			  <1321642368.2653.35.camel@lade.trondhjem.org>	 <4EC6AC47.60404@citrix.com>		 <1321643673.2653.41.camel@lade.trondhjem.org>		 <4EC6B82B.3000701@citrix.com>	 <4ECA94F9.4090503@citrix.com>		 <1321961913.3323.67.camel@lade.trondhjem.org> <4ECB8F47.105@citrix.com>	 <1321963839.7645.5.camel@lade.trondhjem.org> <4ECB9294.20002@citrix.com> <1321964578.7645.9.camel@lade.trondhjem.org>
In-Reply-To: <1321964578.7645.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/11/11 12:22, Trond Myklebust wrote:
> On Tue, 2011-11-22 at 12:16 +0000, Andrew Cooper wrote: 
>> On 22/11/11 12:10, Trond Myklebust wrote:
>>> On Tue, 2011-11-22 at 12:02 +0000, Andrew Cooper wrote: 
>>>> On 22/11/11 11:38, Trond Myklebust wrote:
>>>>> On Mon, 2011-11-21 at 18:14 +0000, Andrew Cooper wrote: 
>>>>>> Following some debugging, I believe that the attached patch fixes the
>>>>>> problem.
>>>>>>
>>>>>> Simply returning EAGAIN is not sufficient, as the task does not get
>>>>>> requeued, and times out 13 seconds later (as per our mount options). 
>>>>>> Setting the SOCK_ASYNC_NOSPACE bit causes the requeue to happen.
>>>>>>
>>>>>> I realize that this is a gross hack and I should probably not be using
>>>>>> SOCK_ASYNC_NOSPACE in that way.  Is there a better way to achieve the
>>>>>> same solution?
>>>>>>
>>>>> What you are doing will cause the request to be put to sleep with no
>>>>> guarantee that it will ever be woken up. Why would we want to do that if
>>>>> there is no report of a tcp window/buffer space congestion?
>>>> But the reason we get to this code is because there was a report of
>>>> space collision.  What would you suggest instead?  Changing
>>>> xs_{tcp,udp}_send_request() to retry in this case would defeat the point
>>>> of having xs_nospace().
>>> I suggest doing absolutely nothing: do what you originally proposed,
>>> which is to report the EAGAIN so that the client state machine retries
>>> the socket write.
>>>
>>> My point is that this is a context which is _not_ atomic with the
>>> original report of tcp window/buffer space congestion. There are no
>>> locks or anything else that will guarantee that the congestion still
>>> exists, and the fact that the SOCK_ASYNC_NOSPACE flag is now clear
>>> indicates that this is the case.
>>> The whole purpose of xs_nospace() is to wait until a congestion
>>> condition clears. If the congestion clears before we get here, then we
>>> have no reason to do anything special other than retry.
>>>
>>> Trond
>> I am slightly confused as to what you mean now.
>>
>> When you take out the if(test_bit test and always set ret to EAGAIN and
>> requeue the request, the next time it wakes up is when it is killed due
>> to timeout.  This results in substantially worse effects for the
>> userspace, as the NFS session is killed.
> What is putting the request to sleep? It should be awake when it enters
> xs_nospace(), and nothing in or after that function should be putting it
> to sleep until we've retried with call_transmit().
>

I presume it is the call to xprt_wait_for_buffer_space() which calls
rpc_sleep_on().  There is xs_tcp_write_space which appears to wake it up
based on sk->sk_write_space which is triggered on the sock gaining more
space, which has already happened in this specific case.

Sorry if I am being a bit slow here - I am still learning my way round
an unfamiliar codebase.

>> Did you mean something else when you said "always report EAGAIN"?
> Nope.
>

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

