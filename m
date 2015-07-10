Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18359 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932579AbbGJTlc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 15:41:32 -0400
Subject: Re: [PATCH v1 02/12] xprtrdma: Raise maximum payload size to one
 megabyte
To: Chuck Lever <chuck.lever@oracle.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204159.26247.44592.stgit@manet.1015granger.net>
 <55A01B56.2020107@Netapp.com>
 <F9717330-F362-477B-915D-D6AAE7B5DDDB@oracle.com>
CC: <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55A01FE9.8000309@Netapp.com>
Date: Fri, 10 Jul 2015 15:41:29 -0400
MIME-Version: 1.0
In-Reply-To: <F9717330-F362-477B-915D-D6AAE7B5DDDB@oracle.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/10/2015 03:33 PM, Chuck Lever wrote:
> 
> On Jul 10, 2015, at 3:21 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> Hi Chuck,
>>
>> On 07/09/2015 04:41 PM, Chuck Lever wrote:
>>> The point of larger rsize and wsize is to reduce the per-byte cost
>>> of memory registration and deregistration. Modern HCAs can typically
>>> handle a megabyte or more with a single registration operation.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
>>> 1 file changed, 1 insertion(+), 2 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> index f49dd8b..abee472 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -165,8 +165,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
>>>  * struct rpcrdma_buffer. N is the max number of outstanding requests.
>>>  */
>>>
>>> -/* temporary static scatter/gather max */
>>> -#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
>>> +#define RPCRDMA_MAX_DATA_SEGS	((1 * 1024 * 1024) / PAGE_SIZE)
>>                                         ^^^
>> What is the significance of the 1 here?
> 
> This echoes the definition of RPCSVC_MAXPAYLOAD.
> 
> “1” documents “one” megabyte, I assume.

Makes sense.  Thanks!

> 
> 
>> Thanks,
>> Anna
>>
>>> #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>>>
>>> struct rpcrdma_buffer;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 

