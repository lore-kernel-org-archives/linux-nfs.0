Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40910 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755410Ab0DEPuR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Apr 2010 11:50:17 -0400
Message-ID: <4BBA06B8.3090201@opengridcomputing.com>
Date: Mon, 05 Apr 2010 10:50:16 -0500
From: Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Tom Tucker <tom@ogc.us>,
        Steve Wise <swise@opengridcomputing.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: RDMA support not yet compatible with RPC6
References: <4BB74241.4060308@ogc.us> <4BB9F9D0.1040203@oracle.com> <20100405154850.GG16370@fieldses.org>
In-Reply-To: <20100405154850.GG16370@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Mon, Apr 05, 2010 at 10:55:12AM -0400, Chuck Lever wrote:
>   
>> On 04/03/2010 09:27 AM, Tom Tucker wrote:
>>     
>>> RPC6 requires that it be possible to create endpoints that listen
>>> exclusively for IPv4 or IPv6 connection requests. This is not currently
>>> supported by the RDMA API.
>>>
>>> Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
>>> Tested-by: Steve Wise<swise@opengridcomputing.com>
>>>       
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>     
>
> Thanks to all.  I take it the problem began with 37498292a "NFSD: Create
> PF_INET6 listener in write_ports"?
>
>   

Yes.

Tom

> --b.
>
>   
>>> ---
>>>
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c | 5 ++++-
>>> 1 files changed, 4 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> index 3fa5751..4e6bbf9 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> @@ -678,7 +678,10 @@ static struct svc_xprt *svc_rdma_create(struct
>>> svc_serv *serv,
>>> int ret;
>>>
>>> dprintk("svcrdma: Creating RDMA socket\n");
>>> -
>>> + if (sa->sa_family != AF_INET) {
>>> + dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
>>> + return ERR_PTR(-EAFNOSUPPORT);
>>> + }
>>> cma_xprt = rdma_create_xprt(serv, 1);
>>> if (!cma_xprt)
>>> return ERR_PTR(-ENOMEM);
>>>
>>>       
>> -- 
>> chuck[dot]lever[at]oracle[dot]com
>>     
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

