Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44691 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752337Ab2BUVIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2012 16:08:49 -0500
Message-ID: <4F4407E1.7030400@opengridcomputing.com>
Date: Tue, 21 Feb 2012 15:08:49 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] svcrdma: silence a Sparse warning
References: <20120221072804.GA6896@elgon.mountain> <20120221210603.GA4326@fieldses.org>
In-Reply-To: <20120221210603.GA4326@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is my bad. I don't know why my sparse didn't catch it, it seems like 
it should have. Thanks for
fixing it Dan.

Tom


On 2/21/12 3:06 PM, J. Bruce Fields wrote:
> (Cc'ing Tom).
>
> On Tue, Feb 21, 2012 at 10:28:04AM +0300, Dan Carpenter wrote:
>> Sparse complains that the definition function definition and the
>> implementation aren't anotated the same way.
>>
>> Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>
>>
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index d205e9f..0b8e3e6 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -190,7 +190,7 @@ extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
>>   extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
>>   extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
>>   extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
>> -					    u32, u64, u32);
>> +					    __be32, __be64, u32);
>>   extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *,
>>   					     struct rpcrdma_msg *,
>>   					     struct rpcrdma_msg *,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

