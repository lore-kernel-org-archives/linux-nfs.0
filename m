Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23677 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab0DSXgz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 19:36:55 -0400
Message-ID: <4BCCE8CC.3050102@oracle.com>
Date: Mon, 19 Apr 2010 19:35:40 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fail over more quickly on connect errors
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>	 <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>	 <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>	 <1271450871-10777-4-git-send-email-Trond.Myklebust@netapp.com> <1271456992.3098.20.camel@localhost.localdomain>
In-Reply-To: <1271456992.3098.20.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/16/2010 06:29 PM, Trond Myklebust wrote:
> On Fri, 2010-04-16 at 16:47 -0400, Trond Myklebust wrote:
>> We should not allow soft tasks to wait for longer than the major timeout
>> period when waiting for a reconnect to occur.
>>
>> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
>> ---
>>   net/sunrpc/xprt.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index c71d835..01449a3 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -710,7 +710,7 @@ void xprt_connect(struct rpc_task *task)
>>   		if (task->tk_rqstp)
>>   			task->tk_rqstp->rq_bytes_sent = 0;
>>
>> -		task->tk_timeout = xprt->connect_timeout;
>> +		task->tk_timeout = min(req->rq_timeout, xprt->connect_timeout);
>                                           ^^^ task->tk_rqstp->rq_timeout
>
> Apologies. I though I had tested that...
>
>> 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
>>
>>   		if (test_bit(XPRT_CLOSING,&xprt->state))

I tested this series of patches with soft mounts, and RPC requests now 
fail, after the timeout period, if the client can't reconnect.

I also observed appropriate exponential back-off behavior as the client 
attempts to reconnect.  I would suggest one more patch to reduce the 
reestablish timeout maximum to 30 seconds.

For the series:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

   and/or

Tested-by: Chuck Lever <chuck.lever@oracle.com>

-- 
chuck[dot]lever[at]oracle[dot]com
