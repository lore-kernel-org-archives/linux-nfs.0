From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Wed, 21 May 2008 08:14:16 -0400
Message-ID: <48341218.10009@redhat.com>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net> <20080520202941.3851.61861.stgit@ellison.1015granger.net> <1211318498.26809.13.camel@localhost> <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758666AbYEUMOs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 08:14:48 -0400
In-Reply-To: <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>
> On May 20, 2008, at 5:21 PM, Trond Myklebust wrote:
>
>> On Tue, 2008-05-20 at 16:29 -0400, Chuck Lever wrote:
>>> Making debugging output a little cleaner in call_verify by 
>>> displaying the
>>> name of the RPC procedure instead of it's number.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> net/sunrpc/clnt.c |    4 ++--
>>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>>
>>>
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index adbc85c..5aa32fa 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1431,10 +1431,10 @@ call_verify(struct rpc_task *task)
>>>         error = -EPROTONOSUPPORT;
>>>         goto out_err;
>>>     case RPC_PROC_UNAVAIL:
>>> -        dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
>>> +        dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
>>>                 "version %u on server %s\n",
>>>                 task->tk_pid, __func__,
>>> -                task->tk_msg.rpc_proc,
>>> +                task->tk_msg.rpc_proc->p_name,
>>>                 task->tk_client->cl_prog,
>>>                 task->tk_client->cl_vers,
>>>                 task->tk_client->cl_server);
>>
>> This will cause a crash if you ever call it while somebody is calling
>> rpc_call_null. There may be other cases too.
>
> How could you ever get an RPC_PROC_UNAVAIL with a NULL RPC? 

I have seen servers which didn't implement the NULL_PROC procedure
for protocols like NFS_ACL.  Beats me why.

It would be good if the client didn't crash just because someone
got lazy in the server implementation though.

       ps
