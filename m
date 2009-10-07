From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/7] SUNRPC: Clean up call_transmit_status()
Date: Wed, 7 Oct 2009 19:02:38 -0400
Message-ID: <EC5A7F29-AECC-4ECD-828E-D0E2487BDA4B@oracle.com>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net> <20091007220239.1844.1995.stgit@matisse.1015granger.net> <1254954158.7045.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:23948 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbZJGXf0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 19:35:26 -0400
In-Reply-To: <1254954158.7045.33.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 7, 2009, at 6:22 PM, Trond Myklebust wrote:
> On Wed, 2009-10-07 at 18:02 -0400, Chuck Lever wrote:
>> Clean up: re-arrange the cases in call_transmit_status() to make the
>> code easier to read.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/clnt.c |   24 ++++++++++++------------
>> 1 files changed, 12 insertions(+), 12 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 57f39b7..c26669c 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1175,25 +1175,21 @@ call_transmit(struct rpc_task *task)
>>
>> /*
>>  * 5a.	Handle cleanup after a transmission
>> + *	If we've been waiting on the socket's write_space()
>> + *	callback, or if the server is temporarily unreachable,
>> + *	continue holding the transport lock.
>>  */
>> static void
>> call_transmit_status(struct rpc_task *task)
>> {
>> +	dprint_status(task);
>> +
>> 	task->tk_action = call_status;
>> +
>> 	switch (task->tk_status) {
>> -	case -EAGAIN:
>> -		break;
>> -	default:
>> -		xprt_end_transmit(task);
>> -		rpc_task_force_reencode(task);
>> +	case -EAGAIN:			/* no write space */
>> 		break;
>> -		/*
>> -		 * Special cases: if we've been waiting on the
>> -		 * socket's write_space() callback, or if the
>> -		 * socket just returned a connection error,
>> -		 * then hold onto the transport lock.
>> -		 */
>> -	case -ECONNREFUSED:
>> +	case -ECONNREFUSED:		/* connection problems */
>> 	case -ECONNRESET:
>> 	case -ENOTCONN:
>> 	case -EHOSTDOWN:
>> @@ -1206,6 +1202,10 @@ call_transmit_status(struct rpc_task *task)
>> 			break;
>> 		}
>> 		rpc_task_force_reencode(task);
>> +		break;
>> +	default:			/* success, or some other error */
>> +		xprt_end_transmit(task);
>> +		rpc_task_force_reencode(task);
>> 	}
>> }
>
> This puts the most common case (success) at the very end of the switch
> statement. Most compilers will generate the most efficient code when  
> it
> is at the very beginning...

I dropped this one, since it's not that important.

But I wouldn't expect the compiler could optimize the default: case  
the way you described.  No matter what order you write these in, the  
code has to check each of the other cases first before deciding to  
execute the default: arm.  If it's that important, maybe we should add  
a "case 0:" arm?

>
> Trond
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



