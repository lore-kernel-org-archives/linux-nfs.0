From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 01/85] sunrpc: get rid of rpc_rqst.rq_bufsize
Date: Tue, 18 Nov 2008 10:42:13 +0200
Message-ID: <49227FE5.3070304@panasas.com>
References: <1226347159-6561-1-git-send-email-bhalevy@panasas.com> <49216F05.4090706@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:19870 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751050AbYKRImS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 03:42:18 -0500
In-Reply-To: <49216F05.4090706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov. 17, 2008, 15:17 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> On Nov. 10, 2008, 21:59 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
>> rq_bufsize is not used.
>>
>> Signed-off-by: Mike Sager <Mike.Sager@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  include/linux/sunrpc/xprt.h |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>> index 4d80a11..11fc71d 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -76,8 +76,7 @@ struct rpc_rqst {
>>  	struct list_head	rq_list;
>>  
>>  	__u32 *			rq_buffer;	/* XDR encode buffer */
>> -	size_t			rq_bufsize,
> 
> review 11-14: this was used in the past as a sanity check.
> find out when/why this functionality was ripped out.

Since commit c5a4dd8b7c15927a8fbff83171b57cad675a79b9
we encode the buffer size "inline", prepending the buffer contents.
Therefore there is indeed no use of rq_bufsize anymore.

Benny

> 
>> -				rq_callsize,
>> +	size_t			rq_callsize,
>>  				rq_rcvsize;
>>  
>>  	struct xdr_buf		rq_private_buf;		/* The receive buffer
>> -- 
>> 1.6.0.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

