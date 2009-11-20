From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/11] SUNRPC: Use a cached RPC client and transport for rpcbind upcalls
Date: Fri, 20 Nov 2009 17:24:43 -0500
Message-ID: <8EA5EB4E-A6EF-4501-AE13-856105142F9A@oracle.com>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net> <20091105182319.2796.62305.stgit@matisse.1015granger.net> <1258748285.2494.84.camel@localhost> <560F5576-A0D0-4126-983D-F1DECA61CE02@oracle.com> <20091120220506.GB13109@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30683 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbZKTWZ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2009 17:25:28 -0500
In-Reply-To: <20091120220506.GB13109@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 20, 2009, at 5:05 PM, J. Bruce Fields wrote:
> On Fri, Nov 20, 2009 at 04:50:34PM -0500, Chuck Lever wrote:
>> On Nov 20, 2009, at 3:18 PM, Trond Myklebust wrote:
>>> On Thu, 2009-11-05 at 13:23 -0500, Chuck Lever wrote:
>>>> +	static DEFINE_SPINLOCK(rpcb_create_local_lock);
>>>> +	struct rpc_clnt *clnt, *clnt4;
>>>> +	int result = 0;
>>>> +
>>>> +	spin_lock(&rpcb_create_local_lock);
>>>> +	if (rpcb_local_clnt)
>>>> +		goto out;
>>>> +
>>>> +	clnt = rpc_create(&args);
>>>> +	if (IS_ERR(clnt)) {
>>>> +		result = -PTR_ERR(clnt);
>>>> +		goto out;
>>>> +	}
>>>>
>>>> -	return rpc_create(&args);
>>>> +	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
>>>> +	if (IS_ERR(clnt4)) {
>>>> +		result = -PTR_ERR(clnt4);
>>>> +		rpc_shutdown_client(clnt);
>>>> +		goto out;
>>>> +	}
>>>> +
>>>> +	rpcb_local_clnt = clnt;
>>>> +	rpcb_local_clnt4 = clnt4;
>>>> +
>>>> +out:
>>>> +	spin_unlock(&rpcb_create_local_lock);
>>>> +	return result;
>>>> }
>>>
>>> You can't have tested this. At the very least you cannot have done  
>>> so
>>> with spinlock debugging enabled...
>>
>> I moved the rpcb_create_local_lock spinlock out of the function,  
>> enabled
>> every spinlock checkbox I could under kernel hacking,
>
> Including CONFIG_DEBUG_SPINLOCK_SLEEP?

Yes.  I even rebuilt the kernel under test from scratch.

>> and gave the guest
>> 2 CPUs.  The spinlock checker reported a problem almost immediately  
>> with
>> XFS (even with just one virtual CPU), so I know it's enabled and  
>> working.
>>
>> I can't reproduce any problems with the rpcbind upcall here.  Do you
>> have anything more specific?
>
> Isn't there an rpc ping in rpc_bind_new_program?

Hrm, I suppose there is.  That's weird, clearly I didn't see the  
rpc_ping() call, even though I was looking for it when I wrote this.   
A GFP_KERNEL memory allocation can sleep too, can't it?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



