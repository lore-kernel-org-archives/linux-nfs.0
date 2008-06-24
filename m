From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 01/11] svcrdma: Add a type for keeping NFS RPC mapping
Date: Tue, 24 Jun 2008 23:31:14 +0300
Message-ID: <48615992.3080007@panasas.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com> <20080616194858.GA29446@fieldses.org> <485D2CEF.404@opengridcomputing.com> <20080623182707.GC24373@fieldses.org> <486062CD.6010800@opengridcomputing.com> <20080624195838.GE15786@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:30676 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752291AbYFXUbm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:31:42 -0400
In-Reply-To: <20080624195838.GE15786@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Jun 23, 2008 at 09:58:21PM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Sat, Jun 21, 2008 at 11:31:43AM -0500, Tom Tucker wrote:
>>>   
>>>> J. Bruce Fields wrote:
>>>>     
>>>>> On Thu, May 29, 2008 at 12:54:46PM -0500, Tom Tucker wrote:
>>>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
>>>>>> index 88c0ca2..545ea72 100644
>>>>>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>>>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>>>>>> @@ -69,6 +69,9 @@ atomic_t rdma_stat_rq_prod;
>>>>>>  atomic_t rdma_stat_sq_poll;
>>>>>>  atomic_t rdma_stat_sq_prod;
>>>>>>  +/* Temporary NFS request map cache */
>>>>>> +struct kmem_cache *svc_rdma_map_cachep = NULL;
>>>>>>             
>>>>> No need to initialize globals to NULL.
>>>>>
>>>>>         
>>>> I thought only static objects were initialized per the C standard. Or 
>>>>  are you saying that this particular
>>>> global doesn't need to be initialized because of the way it is used?
>>>>     
>>> I don't know if the initialization is mandated by the standards or
>>> whether it's just gcc behavior, but I know I get a complaint every time
>>> somebody finds one of those....

The implicit initialization to zero was defined back then by K&R:
http://www.cs.utah.edu/~phister/K_n_R/chapter4.html#s4.9
"In the absence of explicit initialization, external and static variables
are guaranteed to be initialized to zero"

AFAIK this convention was kept by the C standards ever since.

>>>
>>>   
>> In this case, the initialization is unnecessary, so it can be safely dumped.
>>
>>> That may partly just be a preference for conciseness, but I think it may
>>> also allow gcc to put the thing in a different section and save some
>>> space in the on-disk kernel--I don't know.
>>>
>>>   
>> Right -- un-initialized data goes in a different section, the .bss  
>> section in particular. Since the .bss section is not "initialized",  
>> there are no values (zeroes in this case) sitting in the object file  
>> ready to be mapped into whatever location becomes .bss. By contrast, the  
>> .data section contains initialized data and the initial values are  
>> sitting in the object file.
>>
>> So my question here is a little subtler:
>>
>> A. Do we discard _all_ zero initializations of non-static globals  
>> because we can safely assume that .bss is initialzed (not a fan of  
>> this),  or

Also static locals...  What matters is that the variable has
static allocation, its scope is irrelevant to the initialization
issue.

Benny

>>
>> B. Don't be an idiot and initialize objects unnecessarily because it  
>> bloats the kernel object file?
>>
>> An idiot voting for  B,
> 
> My understanding is that it's A--e.g. checkpatch.pl has a dumb regex
> that just checks for these assignments and whines about them however
> they're used.
> 
> Google doesn't find me any more detailed discussion of the policy.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

