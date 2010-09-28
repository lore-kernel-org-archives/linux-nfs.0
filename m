Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38917 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755072Ab0I1Qvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 12:51:35 -0400
Message-ID: <4CA21D07.4070900@parallels.com>
Date: Tue, 28 Sep 2010 20:51:19 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] sunrpc: Factor out rpc_xprt allocation
References: <4CA20651.4070605@parallels.com> <4CA20689.6060405@parallels.com> <10FA0502-F580-460A-BADC-9AEEA7ADE4A3@oracle.com>
In-Reply-To: <10FA0502-F580-460A-BADC-9AEEA7ADE4A3@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> +struct rpc_xprt *xprt_alloc(int size, int max_req)
>> +{
>> +	struct rpc_xprt *xprt;
>> +
>> +	xprt = kzalloc(size, GFP_KERNEL);
>> +	if (xprt == NULL)
>> +		goto out;
>> +
>> +	xprt->max_reqs = max_req;
>> +	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
>> +	if (xprt->slot == NULL)
>> +		goto out_free;
>> +
>> +	return xprt;
>> +
>> +out_free:
>> +	kfree(xprt);
>> +out:
>> +	return NULL;
>> +}
>> +EXPORT_SYMBOL_GPL(xprt_alloc);
> 
> If xprt_alloc is a generic function, used by different transport capabilities, 
> then it belongs in net/sunrpc/xprt.c, not in a transport-specific source file
> like xprtsock.c .

Will do.

> Also, would it makes sense to allocate these via a single kcalloc request, or
>  would that possibly result in a high-order (ie non-zero) allocation in some cases?

The kcalloc is used to allocate n elements of an equal size, but the first
element in this hypothetical allocation will be of another size...
