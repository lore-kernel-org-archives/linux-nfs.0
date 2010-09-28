Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29198 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755688Ab0I1REP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 13:04:15 -0400
Subject: Re: [PATCH 1/7] sunrpc: Factor out rpc_xprt allocation
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA21D07.4070900@parallels.com>
Date: Tue, 28 Sep 2010 13:02:21 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <D899AB48-76EC-4557-9B91-4C150AAC6A8D@oracle.com>
References: <4CA20651.4070605@parallels.com> <4CA20689.6060405@parallels.com> <10FA0502-F580-460A-BADC-9AEEA7ADE4A3@oracle.com> <4CA21D07.4070900@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 28, 2010, at 12:51 PM, Pavel Emelyanov wrote:

>>> +struct rpc_xprt *xprt_alloc(int size, int max_req)
>>> +{
>>> +	struct rpc_xprt *xprt;
>>> +
>>> +	xprt = kzalloc(size, GFP_KERNEL);
>>> +	if (xprt == NULL)
>>> +		goto out;
>>> +
>>> +	xprt->max_reqs = max_req;
>>> +	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
>>> +	if (xprt->slot == NULL)
>>> +		goto out_free;
>>> +
>>> +	return xprt;
>>> +
>>> +out_free:
>>> +	kfree(xprt);
>>> +out:
>>> +	return NULL;
>>> +}
>>> +EXPORT_SYMBOL_GPL(xprt_alloc);
>> 
>> If xprt_alloc is a generic function, used by different transport capabilities, 
>> then it belongs in net/sunrpc/xprt.c, not in a transport-specific source file
>> like xprtsock.c .
> 
> Will do.
> 
>> Also, would it makes sense to allocate these via a single kcalloc request, or
>> would that possibly result in a high-order (ie non-zero) allocation in some cases?
> 
> The kcalloc is used to allocate n elements of an equal size, but the first
> element in this hypothetical allocation will be of another size...

You can compute the needed total allocation size by hand, and then use kzalloc.  Just a thought.

Again, not a requirement, but might be an interesting optimization.

-- 
chuck[dot]lever[at]oracle[dot]com




