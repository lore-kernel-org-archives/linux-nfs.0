From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Tue, 20 May 2008 17:39:43 -0400
Message-ID: <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net> <20080520202941.3851.61861.stgit@ellison.1015granger.net> <1211318498.26809.13.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32341 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932896AbYETVlp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 17:41:45 -0400
In-Reply-To: <1211318498.26809.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 20, 2008, at 5:21 PM, Trond Myklebust wrote:

> On Tue, 2008-05-20 at 16:29 -0400, Chuck Lever wrote:
>> Making debugging output a little cleaner in call_verify by  
>> displaying the
>> name of the RPC procedure instead of it's number.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/clnt.c |    4 ++--
>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index adbc85c..5aa32fa 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1431,10 +1431,10 @@ call_verify(struct rpc_task *task)
>> 		error = -EPROTONOSUPPORT;
>> 		goto out_err;
>> 	case RPC_PROC_UNAVAIL:
>> -		dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
>> +		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
>> 				"version %u on server %s\n",
>> 				task->tk_pid, __func__,
>> -				task->tk_msg.rpc_proc,
>> +				task->tk_msg.rpc_proc->p_name,
>> 				task->tk_client->cl_prog,
>> 				task->tk_client->cl_vers,
>> 				task->tk_client->cl_server);
>
> This will cause a crash if you ever call it while somebody is calling
> rpc_call_null. There may be other cases too.

How could you ever get an RPC_PROC_UNAVAIL with a NULL RPC?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
