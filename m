From: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Wed, 5 Nov 2008 23:19:10 -0800
Message-ID: <89EF203E-20FF-4A0B-BE41-FB6A62BE76DA@netapp.com>
References: <273FE88A07F5D445824060902F70034402975078@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Benny Halevy" <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38256 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYKFHTy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2008 02:19:54 -0500
In-Reply-To: <273FE88A07F5D445824060902F70034402975078-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 5, 2008, at 7:05 PM, Labiaga, Ricardo wrote:

>>>>>
>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>> ---
>>>>>
>>>>> Trond, I'm not sure if this can happen without nfs41.
>>>>> However, please consider this patch for upstream since
>>>>> it is safe to do in any case.
>>>>>
>>>>> Benny
>>>>>
>>>>> net/sunrpc/clnt.c |    8 +++++---
>>>>> 1 files changed, 5 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>>> index 78fc483..b555d9f 100644
>>>>> --- a/net/sunrpc/clnt.c
>>>>> +++ b/net/sunrpc/clnt.c
>>>>> @@ -1206,7 +1206,8 @@ call_status(struct rpc_task *task)
>>>>> 		break;
>>>>> 	case -ECONNREFUSED:
>>>>> 	case -ENOTCONN:
>>>>> -		rpc_force_rebind(clnt);
>>>>> +		if (clnt)
>>>>> +			rpc_force_rebind(clnt);
>>>>> 		task->tk_action = call_bind;
>>>>> 		break;
>>>>> 	case -EAGAIN:
>>>>> @@ -1217,9 +1218,10 @@ call_status(struct rpc_task *task)
>>>>> 		rpc_exit(task, status);
>>>>> 		break;
>>>>> 	default:
>>>>> -		if (clnt->cl_chatty)
>>>>> +		if (!clnt || clnt->cl_chatty)
>>>>> 			printk("%s: RPC call returned error %d\n",
>>>>> -			       clnt->cl_protname, -status);
>>>>> +			       clnt ? clnt->cl_protname : "<unknown
>>> protocol>",
>>>>> +			       -status);
>>>>> 		rpc_exit(task, status);
>>>>> 	}
>>>>> }
>>>> BIG NACK!
>>>>
>>>> How does even it make sense for a task to get past call_transmit
> and
>>>> call_status without having task->tk_client set? This sounds like
>>> serious
>>>> borkenness in the nfsv4.1 patches...
>>
>> Ricardo,
>>
>> rpc_run_bc_task sets no task_setup_data.rpc_client when calling
>> rpc_new_task.
>> We might be able to use to fore channel rpc client,
>
> We could, though it would cause the reconnection to occur in the
> backchannel code path.  Haven't thought it through, but it sounds
> cleaner to rebind the session (or reset it if the server went away) in
> the forechannel context.  I wonder if it would be acceptable to simply
> drop the backchannel request, and have the forechannel reestablish the
> connection (on a retransmission)?
>
>> but
>> I'm still concerned that using this path for sending the callback
>> replies is wrong.
>
> The mainline RPC call_transmit() is already able to deal with RPC
> transmissions that don't expect a reply.  This is pretty similar to
> sending a reply, so we're leveraging the existing rpc_xprt.
>
> One alternative could be to construct an svc_xprt for the backchannel
> and use svc_send() for the reply.  I wonder if it's really a better
> approach since we already have the rpc_xprt available.

I failed to mention that with the existing approach we're able to  
synchronize forechannel calls and backchannel replies on the rpc_xprt  
(XPRT_LOCKED bit).  It uses the synchronization mechanism already in  
mainline to prevent mixing the payload of requests and replies.

- ricardo

>
>>>
>>> The "Callback slot table overflowed" message means we couldn't
> obtain a
>>> pre-allocated rpc_rqst to process the callback.  When this occurs,
> the
>>> client sets the XPRT_CLOSE_WAIT bit to close the connection.  (As an
>>> aside, should we be using xprt_force_disconnect() instead?).
>>
>> could be, but we might be doing the right thing on the client side
>> in this case already.
>
> We're correctly closing the connection, but doesn't seem like we're
> acquiring the lock, as it is done in xprt_force_disconnect().
> xprt_force_disconnect() wasn't around when I first added the autoclose
> code in xs_tcp_read_callback().
>
>>
>>>
>>> This leads me to believe the server exceeded the number of
> outstanding
>>> requests allowed on the backchannel (slot count of one at the
> moment),
>>> the new request caused us to close the connection and pulled the rug
>>> from under the callback service.  I'll investigate further.
>>
>> We simply got ENOTCONN back (see value of RBX)
>
> Right, I was trying to explain what may have caused the connection
> closed error.  I'm suggesting the unexpected request closed the
> connection, and was dropped on the floor by xs_tcp_read_callback().
> After the first request was processed, it encountered a closed
> connection during the reply.  This is why the original request dies  
> with
> ENOTCONN.
>
> I'll take a look at the svc_send() path using svc_xprt.  Though I  
> think
> your proposed patch to not force a rebind in the backchannel is
> appropriate.  I guess I'm pleading to Trond to reconsider the Big NACK
> :-)
>
> - ricardo
>
>>
>>>
>>> Is this reproducible?
>>
>> Not yet.
>>
>> Benny
>>
>>>
>>> - ricardo
>>>
>>>
>>>> Trond
>>>> ...
>>>>

