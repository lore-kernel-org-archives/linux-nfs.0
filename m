Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28843 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbGLRwU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 13:52:20 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 05/12] xprtrdma: Account for RPC/RDMA header size when deciding to inline
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55A27B9D.5010002@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 13:52:15 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9A538A66-0769-4129-8BE2-F0A1230B962F@oracle.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net> <20150709204227.26247.51111.stgit@manet.1015granger.net> <55A27B9D.5010002@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi-


On Jul 12, 2015, at 10:37 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 7/9/2015 11:42 PM, Chuck Lever wrote:
>> When marshaling RPC/RDMA requests, ensure the combined size of
>> RPC/RDMA header and RPC header do not exceed the inline threshold.
>> Endpoints typically reject RPC/RDMA messages that exceed the size
>> of their receive buffers.
> 
> Did this solve a bug? because is seems like it does.
> Maybe it will be a good idea to describe this bug.

There’s no bugzilla for this, as no issue has been encountered
in the field so far. It’s hard to trigger and servers are
forgiving.

I added some text in the patch description.


>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  net/sunrpc/xprtrdma/rpc_rdma.c |   29 +++++++++++++++++++++++++++--
>>  1 file changed, 27 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index 84ea37d..8cf9402 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -71,6 +71,31 @@ static const char transfertypes[][12] = {
>>  };
>>  #endif
>> 
>> +/* The client can send a request inline as long as the RPCRDMA header
>> + * plus the RPC call fit under the transport's inline limit. If the
>> + * combined call message size exceeds that limit, the client must use
>> + * the read chunk list for this operation.
>> + */
>> +static bool rpcrdma_args_inline(struct rpc_rqst *rqst)
> 
> maybe static inline?

The final paragraph of Chapter 15 of Documentation/CodingStyle
suggests “static inline” is undesirable here. I think gcc makes
the correct inlining choice here by itself.


>> +{
>> +	unsigned int callsize = RPCRDMA_HDRLEN_MIN + rqst->rq_snd_buf.len;
>> +
>> +	return callsize <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
>> +}
>> +
>> +/* The client can’t know how large the actual reply will be. Thus it
>> + * plans for the largest possible reply for that particular ULP
>> + * operation. If the maximum combined reply message size exceeds that
>> + * limit, the client must provide a write list or a reply chunk for
>> + * this request.
>> + */
>> +static bool rpcrdma_results_inline(struct rpc_rqst *rqst)
>> +{
>> +	unsigned int repsize = RPCRDMA_HDRLEN_MIN + rqst->rq_rcv_buf.buflen;
>> +
>> +	return repsize <= RPCRDMA_INLINE_READ_THRESHOLD(rqst);
>> +}
>> +
>>  /*
>>   * Chunk assembly from upper layer xdr_buf.
>>   *
>> @@ -418,7 +443,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
>>  	 * a READ, then use write chunks to separate the file data
>>  	 * into pages; otherwise use reply chunks.
>>  	 */
>> -	if (rqst->rq_rcv_buf.buflen <= RPCRDMA_INLINE_READ_THRESHOLD(rqst))
>> +	if (rpcrdma_results_inline(rqst))
>>  		wtype = rpcrdma_noch;
>>  	else if (rqst->rq_rcv_buf.page_len == 0)
>>  		wtype = rpcrdma_replych;
>> @@ -441,7 +466,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
>>  	 * implies the op is a write.
>>  	 * TBD check NFSv4 setacl
>>  	 */
>> -	if (rqst->rq_snd_buf.len <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst))
>> +	if (rpcrdma_args_inline(rqst))
>>  		rtype = rpcrdma_noch;
>>  	else if (rqst->rq_snd_buf.page_len == 0)
>>  		rtype = rpcrdma_areadch;
>> 

--
Chuck Lever



