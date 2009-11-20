From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/11] SUNRPC: Use a cached RPC client and transport
	for rpcbind upcalls
Date: Fri, 20 Nov 2009 17:05:06 -0500
Message-ID: <20091120220506.GB13109@fieldses.org>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net> <20091105182319.2796.62305.stgit@matisse.1015granger.net> <1258748285.2494.84.camel@localhost> <560F5576-A0D0-4126-983D-F1DECA61CE02@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51437 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083AbZKTWE3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 17:04:29 -0500
In-Reply-To: <560F5576-A0D0-4126-983D-F1DECA61CE02@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2009 at 04:50:34PM -0500, Chuck Lever wrote:
> On Nov 20, 2009, at 3:18 PM, Trond Myklebust wrote:
>> On Thu, 2009-11-05 at 13:23 -0500, Chuck Lever wrote:
>>> +	static DEFINE_SPINLOCK(rpcb_create_local_lock);
>>> +	struct rpc_clnt *clnt, *clnt4;
>>> +	int result = 0;
>>> +
>>> +	spin_lock(&rpcb_create_local_lock);
>>> +	if (rpcb_local_clnt)
>>> +		goto out;
>>> +
>>> +	clnt = rpc_create(&args);
>>> +	if (IS_ERR(clnt)) {
>>> +		result = -PTR_ERR(clnt);
>>> +		goto out;
>>> +	}
>>>
>>> -	return rpc_create(&args);
>>> +	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
>>> +	if (IS_ERR(clnt4)) {
>>> +		result = -PTR_ERR(clnt4);
>>> +		rpc_shutdown_client(clnt);
>>> +		goto out;
>>> +	}
>>> +
>>> +	rpcb_local_clnt = clnt;
>>> +	rpcb_local_clnt4 = clnt4;
>>> +
>>> +out:
>>> +	spin_unlock(&rpcb_create_local_lock);
>>> +	return result;
>>> }
>>
>> You can't have tested this. At the very least you cannot have done so
>> with spinlock debugging enabled...
>
> I moved the rpcb_create_local_lock spinlock out of the function, enabled 
> every spinlock checkbox I could under kernel hacking,

Including CONFIG_DEBUG_SPINLOCK_SLEEP?

> and gave the guest 
> 2 CPUs.  The spinlock checker reported a problem almost immediately with 
> XFS (even with just one virtual CPU), so I know it's enabled and working.
>
> I can't reproduce any problems with the rpcbind upcall here.  Do you  
> have anything more specific?

Isn't there an rpc ping in rpc_bind_new_program?

--b.
