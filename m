Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16516 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932625AbbGJTeJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 15:34:09 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 02/12] xprtrdma: Raise maximum payload size to one megabyte
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55A01B56.2020107@Netapp.com>
Date: Fri, 10 Jul 2015 15:33:55 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F9717330-F362-477B-915D-D6AAE7B5DDDB@oracle.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net> <20150709204159.26247.44592.stgit@manet.1015granger.net> <55A01B56.2020107@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2015, at 3:21 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hi Chuck,
> 
> On 07/09/2015 04:41 PM, Chuck Lever wrote:
>> The point of larger rsize and wsize is to reduce the per-byte cost
>> of memory registration and deregistration. Modern HCAs can typically
>> handle a megabyte or more with a single registration operation.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
>> 1 file changed, 1 insertion(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index f49dd8b..abee472 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -165,8 +165,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
>>  * struct rpcrdma_buffer. N is the max number of outstanding requests.
>>  */
>> 
>> -/* temporary static scatter/gather max */
>> -#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
>> +#define RPCRDMA_MAX_DATA_SEGS	((1 * 1024 * 1024) / PAGE_SIZE)
>                                         ^^^
> What is the significance of the 1 here?

This echoes the definition of RPCSVC_MAXPAYLOAD.

“1” documents “one” megabyte, I assume.


> Thanks,
> Anna
> 
>> #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>> 
>> struct rpcrdma_buffer;
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



