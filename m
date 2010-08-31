Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754508Ab0HaRS4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 13:18:56 -0400
Message-ID: <4C7D3976.8070209@RedHat.com>
Date: Tue, 31 Aug 2010 13:18:46 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
References: <4C7BE1FC.2020400@RedHat.com> <20100830134801.1696dffa@tlielax.poochiereds.net> <4C7CF499.5090003@RedHat.com> <20100831084323.02a1abf5@corrin.poochiereds.net> <4C7D1694.6000708@RedHat.com> <20100831111008.157618f4@corrin.poochiereds.net> <20100831151342.GA3071@fieldses.org> <4C7D1D3B.1030607@RedHat.com> <20100831155128.GB3071@fieldses.org> <4C7D2A20.1040806@RedHat.com> <20100831161547.GD3071@fieldses.org>
In-Reply-To: <20100831161547.GD3071@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/31/2010 12:15 PM, J. Bruce Fields wrote:
> On Tue, Aug 31, 2010 at 12:13:20PM -0400, Steve Dickson wrote:
>>
>>
>> On 08/31/2010 11:51 AM, J. Bruce Fields wrote:
>>> On Tue, Aug 31, 2010 at 11:18:19AM -0400, Steve Dickson wrote:
>>>>
>>>>
>>>> On 08/31/2010 11:13 AM, J. Bruce Fields wrote:
>>>>> On Tue, Aug 31, 2010 at 11:10:08AM -0400, Jeff Layton wrote:
>>>>>> I was just pointing out that checking the return code from the system()
>>>>>> call isn't sufficient. Because of the way most people have modprobe set
>>>>>> up, it can return an error even though nfsdfs ended up being mounted
>>>>>> anyway. Checking for the presence of the file after attempting the
>>>>>> mount would be a more reliable test.
>>>>>>
>>>>>> Assuming we're in agreement there, we have another question to
>>>>>> settle...If the mount attempt fails, what should we do about it?
>>>>>>
>>>>>> With my original patch, we fall back to using nfsctl(). You're
>>>>>> suggesting that we should error out there. I'm not opposed to that, but
>>>>>> it does mean dropping support for some really old kernels. It also
>>>>>> means that we can remove some dead code in rpc.nfsd.
>>>>>>
>>>>>> OTOH, the fallback might allow nfsd to keep working for some people.
>>>>>> Maybe it would be better to just log a scary warning and fall back to
>>>>>> using nfsctl() for now.
>>>>>>
>>>>>> In a couple of releases, we could start returning an error there and
>>>>>> rip out the legacy interface code, or compile it out by default and
>>>>>> allow people to compile it in via a configure option?
>>>>>
>>>>> Yes, let's just add the additional mount attempt for now, and figure out
>>>>> what to do about the legacy interface as a next step.
>>>> When the mount fails, I think we should exit... basically eliminating the
>>>> legacy interface code
>>>
>>> Maybe.  But as I say, make it two separate steps:
>>>
>>> 	1. Add code to attempt the mount.
>> But the question comes do to, what do we do when the mount 
>> fails? It sounds like you are advocating ignoring the error
>> and allow the nfsd threads to be started via the nfsctl(NFSCTL_SVC)
>> call... 
> 
> Yes.
Even if not failing could bring instability... Do we really know what
will happen when the portlist and version files are not set up correctly??
I know I do not test that configuration.... Does anybody? 

> 
>> I'm advocating that we exit on the mount error, because even thought
>> the nfsd threads may be set up correctly, the protocols and versions
>> will not be set up correctly because there is no nfsctl() calls to
>> set them up correctly... especially with IPV6 enabled... 
> 
> Perhaps so.  But that should be done as a *separate* follow-up patch
> that is clearly labelled "drop support for kernel versions before
> x.y.z".
Fine... put it in a separate patch but include it in this patch
series... I really don't think we need to rip the guts out of 
mountd and exportfs just to remove this one nfsctl() in rpc.nfsd.

> 
> Dropping backwards compatibility may be a reasonable thing to do, but
> it's something that we should be very clear about, and that we should
> put in a patch that does that and nothing else.
So you are talking about doing a complete rewrite of mountd and exportfs
just to take out that one call from rpc.nfsd... I just don't see the
justification... If we are going to do that, let just think about rewriting
all the tools to make the more v4 friendly... something we talked about
at the last bakeathon...

steved.
