From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Thu, 06 Nov 2008 09:48:43 +0200
Message-ID: <4912A15B.4070009@panasas.com>
References: <273FE88A07F5D445824060902F70034402975078@SACMVEXC1-PRD.hq.netapp.com> <89EF203E-20FF-4A0B-BE41-FB6A62BE76DA@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:22901 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752034AbYKFHsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 02:48:47 -0500
In-Reply-To: <89EF203E-20FF-4A0B-BE41-FB6A62BE76DA@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 06, 2008, 9:19 +0200, Ricardo Labiaga <ricardo.labiaga@netapp.com> wrote:
> On Nov 5, 2008, at 7:05 PM, Labiaga, Ricardo wrote:
> 
>>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>>> ---
>>>>>>
>>>>>> Trond, I'm not sure if this can happen without nfs41.
>>>>>> However, please consider this patch for upstream since
>>>>>> it is safe to do in any case.
>>>>>>
>>>>>> Benny
>>>>>>
>>>>>> net/sunrpc/clnt.c |    8 +++++---
>>>>>> 1 files changed, 5 insertions(+), 3 deletions(-)
>>>>>>
>>>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>>>> index 78fc483..b555d9f 100644
>>>>>> --- a/net/sunrpc/clnt.c
>>>>>> +++ b/net/sunrpc/clnt.c
>>>>>> @@ -1206,7 +1206,8 @@ call_status(struct rpc_task *task)
>>>>>> 		break;
>>>>>> 	case -ECONNREFUSED:
>>>>>> 	case -ENOTCONN:
>>>>>> -		rpc_force_rebind(clnt);
>>>>>> +		if (clnt)
>>>>>> +			rpc_force_rebind(clnt);
>>>>>> 		task->tk_action = call_bind;
>>>>>> 		break;
>>>>>> 	case -EAGAIN:
>>>>>> @@ -1217,9 +1218,10 @@ call_status(struct rpc_task *task)
>>>>>> 		rpc_exit(task, status);
>>>>>> 		break;
>>>>>> 	default:
>>>>>> -		if (clnt->cl_chatty)
>>>>>> +		if (!clnt || clnt->cl_chatty)
>>>>>> 			printk("%s: RPC call returned error %d\n",
>>>>>> -			       clnt->cl_protname, -status);
>>>>>> +			       clnt ? clnt->cl_protname : "<unknown
>>>> protocol>",
>>>>>> +			       -status);
>>>>>> 		rpc_exit(task, status);
>>>>>> 	}
>>>>>> }
>>>>> BIG NACK!
>>>>>
>>>>> How does even it make sense for a task to get past call_transmit
>> and
>>>>> call_status without having task->tk_client set? This sounds like
>>>> serious
>>>>> borkenness in the nfsv4.1 patches...
>>> Ricardo,
>>>
>>> rpc_run_bc_task sets no task_setup_data.rpc_client when calling
>>> rpc_new_task.
>>> We might be able to use to fore channel rpc client,
>> We could, though it would cause the reconnection to occur in the
>> backchannel code path.  Haven't thought it through, but it sounds
>> cleaner to rebind the session (or reset it if the server went away) in
>> the forechannel context.  I wonder if it would be acceptable to simply
>> drop the backchannel request, and have the forechannel reestablish the
>> connection (on a retransmission)?
>>
>>> but
>>> I'm still concerned that using this path for sending the callback
>>> replies is wrong.
>> The mainline RPC call_transmit() is already able to deal with RPC
>> transmissions that don't expect a reply.  This is pretty similar to
>> sending a reply, so we're leveraging the existing rpc_xprt.
>>
>> One alternative could be to construct an svc_xprt for the backchannel
>> and use svc_send() for the reply.  I wonder if it's really a better
>> approach since we already have the rpc_xprt available.
> 
> I failed to mention that with the existing approach we're able to  
> synchronize forechannel calls and backchannel replies on the rpc_xprt  
> (XPRT_LOCKED bit).  It uses the synchronization mechanism already in  
> mainline to prevent mixing the payload of requests and replies.

Right, but we need to do this at the xprt layer.  I don't think that
this mandates starting the reply process from the rpc layer
as we do today in bc_send.

Note that bc_svc_process gets both an rpc_rqst and a svc_rqst.
Although we forge a svc_rqst including setting up its rq_xprt
which is a svc_xprt, I'm not sure what exactly it is used for.
Eventually, we end up sending the reply (via bc_send) using
the rpc_rqst and its associated rpc_xprt.  This will allow
us to synchronize properly on the bi-directional channel.

> 
> - ricardo
> 

[snip]
