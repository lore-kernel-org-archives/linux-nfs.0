From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/11] SUNRPC: Use a cached RPC client and transport
	for rpcbind upcalls
Date: Fri, 20 Nov 2009 17:36:44 -0500
Message-ID: <20091120223644.GB13840@fieldses.org>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net> <20091105182319.2796.62305.stgit@matisse.1015granger.net> <1258748285.2494.84.camel@localhost> <560F5576-A0D0-4126-983D-F1DECA61CE02@oracle.com> <20091120220506.GB13109@fieldses.org> <8EA5EB4E-A6EF-4501-AE13-856105142F9A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34582 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbZKTWgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 17:36:05 -0500
In-Reply-To: <8EA5EB4E-A6EF-4501-AE13-856105142F9A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2009 at 05:24:43PM -0500, Chuck Lever wrote:
> On Nov 20, 2009, at 5:05 PM, J. Bruce Fields wrote:
>> On Fri, Nov 20, 2009 at 04:50:34PM -0500, Chuck Lever wrote:
>>> On Nov 20, 2009, at 3:18 PM, Trond Myklebust wrote:
>>>> On Thu, 2009-11-05 at 13:23 -0500, Chuck Lever wrote:
>>>>> +	static DEFINE_SPINLOCK(rpcb_create_local_lock);
>>>>> +	struct rpc_clnt *clnt, *clnt4;
>>>>> +	int result = 0;
>>>>> +
>>>>> +	spin_lock(&rpcb_create_local_lock);
>>>>> +	if (rpcb_local_clnt)
>>>>> +		goto out;
>>>>> +
>>>>> +	clnt = rpc_create(&args);
>>>>> +	if (IS_ERR(clnt)) {
>>>>> +		result = -PTR_ERR(clnt);
>>>>> +		goto out;
>>>>> +	}
>>>>>
>>>>> -	return rpc_create(&args);
>>>>> +	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
>>>>> +	if (IS_ERR(clnt4)) {
>>>>> +		result = -PTR_ERR(clnt4);
>>>>> +		rpc_shutdown_client(clnt);
>>>>> +		goto out;
>>>>> +	}
>>>>> +
>>>>> +	rpcb_local_clnt = clnt;
>>>>> +	rpcb_local_clnt4 = clnt4;
>>>>> +
>>>>> +out:
>>>>> +	spin_unlock(&rpcb_create_local_lock);
>>>>> +	return result;
>>>>> }
>>>>
>>>> You can't have tested this. At the very least you cannot have done  
>>>> so
>>>> with spinlock debugging enabled...
>>>
>>> I moved the rpcb_create_local_lock spinlock out of the function,  
>>> enabled
>>> every spinlock checkbox I could under kernel hacking,
>>
>> Including CONFIG_DEBUG_SPINLOCK_SLEEP?
>
> Yes.  I even rebuilt the kernel under test from scratch.
>
>>> and gave the guest
>>> 2 CPUs.  The spinlock checker reported a problem almost immediately  
>>> with
>>> XFS (even with just one virtual CPU), so I know it's enabled and  
>>> working.
>>>
>>> I can't reproduce any problems with the rpcbind upcall here.  Do you
>>> have anything more specific?
>>
>> Isn't there an rpc ping in rpc_bind_new_program?
>
> Hrm, I suppose there is.  That's weird, clearly I didn't see the  
> rpc_ping() call, even though I was looking for it when I wrote this.  A 
> GFP_KERNEL memory allocation can sleep too, can't it?

Yes.  I'd be really curious to know how that got through--if
CONFIG_DEBUG_SPINLOCK_SLEEP can't catch a case that cut-and-dried, then
it's totally broken....

--b.
