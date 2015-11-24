Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30843 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbKXAxI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 19:53:08 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 8/8] svcrdma: Remove svc_rdma_fastreg_mr::access_flags field
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5653B4CA.5050806@talpey.com>
Date: Mon, 23 Nov 2015 19:53:04 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net> <20151123222118.13040.24258.stgit@klimt.1015granger.net> <5653B4CA.5050806@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 23, 2015, at 7:52 PM, Tom Talpey <tom@talpey.com> wrote:
> 
> On 11/23/2015 5:21 PM, Chuck Lever wrote:
>> Clean up: The access_flags field is not used outside of
>> rdma_read_chunk_frmr() and is always set to the same value.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  include/linux/sunrpc/svc_rdma.h         |    1 -
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 +--
>>  2 files changed, 1 insertion(+), 3 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 243edf4..eee2a0d 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -107,7 +107,6 @@ struct svc_rdma_fastreg_mr {
>>  	struct ib_mr *mr;
>>  	struct scatterlist *sg;
>>  	int sg_nents;
>> -	unsigned long access_flags;
>>  	enum dma_data_direction direction;
>>  	struct list_head frmr_list;
>>  };
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index 9480043..8ab1ab5 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -240,7 +240,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>>  	read = min_t(int, (nents << PAGE_SHIFT) - *page_offset, rs_length);
>> 
>>  	frmr->direction = DMA_FROM_DEVICE;
>> -	frmr->access_flags = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
>>  	frmr->sg_nents = nents;
>> 
>>  	for (pno = 0; pno < nents; pno++) {
>> @@ -308,7 +307,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>>  	reg_wr.wr.num_sge = 0;
>>  	reg_wr.mr = frmr->mr;
>>  	reg_wr.key = frmr->mr->lkey;
>> -	reg_wr.access = frmr->access_flags;
>> +	reg_wr.access = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
> 
> Wait, the REMOTE_WRITE is there to support iWARP, but it isn't
> needed for IB or RoCE. Shouldn't this be updated to peek at those
> new attributes to decide, instead of remaining unconditional?

That’s coming in another patch from Christoph.


> 
> 
>>  	reg_wr.wr.next = &read_wr.wr;
>> 
>>  	/* Prepare RDMA_READ */
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 

--
Chuck Lever




