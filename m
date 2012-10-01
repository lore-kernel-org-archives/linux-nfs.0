Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38377 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab2JAPre convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 11:47:34 -0400
Message-ID: <5069BB04.7050509@parallels.com>
Date: Mon, 1 Oct 2012 19:47:16 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 0/2] nfsd: add a usermodehelper upcall for client id tracking
References: <1349092298-23872-1-git-send-email-jlayton@redhat.com> <5069A345.3060807@parallels.com> <20121001141239.GA18400@fieldses.org> <5069A8FA.1060401@parallels.com> <20121001144836.GB18400@fieldses.org>
In-Reply-To: <20121001144836.GB18400@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

01.10.2012 18:48, bfields@fieldses.org пишет:
> On Mon, Oct 01, 2012 at 06:30:18PM +0400, Stanislav Kinsbursky wrote:
>> 01.10.2012 18:12, bfields@fieldses.org пишет:
>>> On Mon, Oct 01, 2012 at 06:05:57PM +0400, Stanislav Kinsbursky wrote:
>>>> 01.10.2012 15:51, Jeff Layton пишет:
>>>>> - Do we need to switch to a different mount namespace somehow based on
>>>>>    the net namespace? Eventually we want to allow nfsd to run in a
>>>>>    container. At some point we'll need a mechanism to ensure that the
>>>>>    upcall runs within the correct container. Stanislav, I'd appreciate
>>>>>    your input here...
>>>>
>>>> Hello, Jeff.
>>>> As far as I can see - yes, we have to switch to desired mount
>>>> namespace in kernel (because we can't do this in user namespace).
>>>> Moreover, for NFSd mount namespace looks even more important than
>>>> net namespace. I.e. we can't share one NFSd between mount namespaces
>>>> (at least, I don't understand how to do this safely).
>>>> So, if we are going to have NFSd per container, we have to tie NFSd
>>>> and mount namespace somehow.
>>>> Having one NFSd for more than one network namespace looks feasible.
>>>> But we have some races with creation and destruction of service
>>>> per-net transports, and Bruce was suggesting to think about maybe we
>>>> can just simplify all that stuff and create service per network
>>>> namespace.
>>>>
>>>> BTW, is it possible to split service (trasports, etc.) and it's
>>>> "executors" (kernel threads)? If we could do it, then it would be
>>>> really easy to create as many services (with it's unique namespaces
>>>> combination) as required and teach "executors" to switch to desired
>>>> namespaces while handling service requests.
>>>
>>> I'm sure it is possible, and would be more efficient than requiring
>>> (number of containers) * (number of threads per container) threads.
>>>
>>> But I think it's also a little more complicated to do, and that to start
>>> off we'd be better off just keeping the services entirely separate.
>>>
>>
>> At first sight, this two solutions (split of service/threads and
>> service per namespace) doesn't look like they can share a lot of
>> code base.
>> I believe, that we have to think about mount namespaces during NFSd
>> containerization. And, if I understand you right, when you say about
>> "entirely separated services", you mean separated by networks
>> namespace.
>> Separations per mount namespace as a second step will take actually
>> the same time and amount of code, as it would be a first step.
>>
>> So, as I can see it, the real question is: do we really want limited
>> (only per-net) NFSd containerisation as soon as possible (and in
>> this case it's much simpler to create NFSd/Lockd service and it's
>> threads per network namespace) or we should skip this step and
>> concentrate on proper implementation from the very beginning (split
>> of service and it's threads and tie NFSd to mount namespace)?
>
> Sorry, I'm not following you:
>
> 	- tying to network namespace vs tying to mount namespace is a
> 	  completely separate issue from splitting service and threads,
> 	  right?

Not really, I guess. I.e. we already tied service to network namespace. All we 
need to implement fully separated per network namespace services is to drop 
service per-net resources allocation and replace it by full service per-net 
creation network namespace (including staring new kthreads).

> 	- in detail, what would be the difference between tying to
> 	  network namespace and mount namespace?  How do you see
> 	  tying to mount namespace working, and why is that better?
>

If we want to tie NFSd also (!) to mount namespace, then we can't do that 
easily. And the simplest (and currently looks suitable) way I see so far is to:

1) separate service network part from service process part and
2) tie service network part to mount (!) namespace, leaving service process part 
in main pid namespace.

The issue is not in mount namespace itself,  but in second namespace to tie to. 
And it looks like for NFSd mount namespace is more important, because we can 
share it between service instances.
This means also, that one mount namespace could be used by more that one NFSd 
service in case their network namespaces are different.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
