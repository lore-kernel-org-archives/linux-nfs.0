Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46871 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758207Ab0HDDVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 23:21:42 -0400
Message-ID: <4C58DCC2.1050109@opengridcomputing.com>
Date: Tue, 03 Aug 2010 21:21:38 -0600
From: Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Tom Tucker <tom@ogc.us>, bfields@fieldses.org, linux-nfs@vger.kernel.org,
        swise@ogc.us
Subject: Re: [PATCH 4/4] rpcrdma: Fix SQ size calculation when memreg is FRMR
References: <20100803164411.2567.31416.stgit@build.ogc.int>	 <20100803164517.2567.50208.stgit@build.ogc.int> <1280889614.24669.29.camel@heimdal.trondhjem.org>
In-Reply-To: <1280889614.24669.29.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> Hi Tom
>
> On Tue, 2010-08-03 at 11:45 -0500, Tom Tucker wrote:
>   
>> This patch updates the computation to include the worst case situation
>> where three FRMR are required to map a single RPC REQ.
>>
>> Signed-off-by: Tom Tucker <tom@ogc.us>
>> ---
>>
>>  net/sunrpc/xprtrdma/rpc_rdma.c |    2 ++
>>  net/sunrpc/xprtrdma/verbs.c    |   20 ++++++++++++++++----
>>  2 files changed, 18 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index e5e28d1..2ac3f6e 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -249,6 +249,8 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
>>  	req->rl_nchunks = nchunks;
>>  
>>  	BUG_ON(nchunks == 0);
>> +	BUG_ON((r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
>> +	       && (nchunks > 3));
>>     
>
> Where does the number 3 come from?
>   

The assumption below is based on the premise that there is one chunk for 
the header, one for the pagelist, and one for the tail == 3. I guess I 
should have a comment -- sorry :-\

>   
>>  	/*
>>  	 * finish off header. If write, marshal discrim and nchunks.
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 3bdbd9f..5f4c7b3 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -650,10 +650,22 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>>  	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
>>  	switch (ia->ri_memreg_strategy) {
>>  	case RPCRDMA_FRMR:
>> -		/* Add room for frmr register and invalidate WRs */
>> -		ep->rep_attr.cap.max_send_wr *= 3;
>> -		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr)
>> -			return -EINVAL;
>> +		/* Add room for frmr register and invalidate WRs.
>> +		 * 1. FRMR reg WR for head
>> +		 * 2. FRMR invalidate WR for head
>> +		 * 3. FRMR reg WR for pagelist
>> +		 * 4. FRMR invalidate WR for pagelist
>> +		 * 5. FRMR reg WR for tail
>> +		 * 6. FRMR invalidate WR for tail
>> +		 * 7. The RDMA_SEND WR
>> +		 */
>> +		ep->rep_attr.cap.max_send_wr *= 7;
>> +		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr) {
>> +			cdata->max_requests = devattr.max_qp_wr / 7;
>> +			if (!cdata->max_requests)
>> +				return -EINVAL;
>> +			ep->rep_attr.cap.max_send_wr = cdata->max_requests * 7;
>> +		}
>>  		break;
>>  	case RPCRDMA_MEMWINDOWS_ASYNC:
>>  	case RPCRDMA_MEMWINDOWS:
>>
>>     
>
>   

