From: Peter Staubach <staubach@redhat.com>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 17:20:29 -0500
Message-ID: <490F792D.6010208@redhat.com>
References: <1225724721.2247.29.camel@brian-laptop> <1225731544.6958.6.camel@heimdal.trondhjem.org> <20081103172529.GA9008@citi.umich.edu> <1225733834.6958.12.camel@heimdal.trondhjem.org> <2C93A491-1277-42B6-9CED-FC06A85174D5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jim Rees <rees@umich.edu>,
	"Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56840 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbYKCWUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 17:20:51 -0500
In-Reply-To: <2C93A491-1277-42B6-9CED-FC06A85174D5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Nov 3, 2008, at Nov 3, 2008, 12:37 PM, Trond Myklebust wrote:
>> On Mon, 2008-11-03 at 12:25 -0500, Jim Rees wrote:
>>> Trond Myklebust wrote:
>>>
>>>  BTW: NFSv4 + soft == BAD BAD BAD!
>>>
>>> Maybe this combination should be prohibited.  Does it make any sense 
>>> given
>>> the stateful nature of v4?
>>
>> It might make sense if we were to fix up the granularity of the recovery
>> routines so that we are able to recover all the state associated with
>> just a single open owner or lock owner. Currently we'd have to recover
>> all the state associated with that server.
>>
>> IOW: we might be able to fix things up in the future, but right now,
>> NFSv4+soft is not a good idea.
>
> Two cents worth:  Until NFSv4+soft works reasonably well, I wouldn't 
> have any problem with making "soft" a no-op for nfs4 mounts. 

It may be the right thing to do in the short term, but it will
generate calls to support organizations.  Anyone trying it will
wonder why it doesn't work "as it used to".  That sort of thing.
When that happens, we will be forced to do something and not at
our choice of time.

Perhaps we should deny such mount attempts because at least that
would be obvious what was happening?  Perhaps we should also
deny NFSv4 mounting over UDP?

       ps
