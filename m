Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50560 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJMTFm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Oct 2017 15:05:42 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 2/3] xprtrdma: Use ro_unmap_sync in xprt_rdma_send_request
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <11D8512F-8E28-4F4C-9062-615738537E3D@oracle.com>
Date: Fri, 13 Oct 2017 15:05:31 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E7589A22-8B0A-4A14-8BE7-2513F063D57C@oracle.com>
References: <20171009155524.18726.32086.stgit@manet.1015granger.net> <20171009160334.18726.33163.stgit@manet.1015granger.net> <ce6f5ccc-cddb-b793-abe4-2e3dcf11c15f@Netapp.com> <11D8512F-8E28-4F4C-9062-615738537E3D@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 13, 2017, at 1:55 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Oct 13, 2017, at 1:43 PM, Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:
>> 
>> Hi Chuck,
>> 
>> On 10/09/2017 12:03 PM, Chuck Lever wrote:
>>> The "safe" version of ro_unmap is used here to avoid waiting
>>> unnecessarily. However:
>>> 
>>> - It is safe to wait. After all, we have to wait anyway when using
>>>  FMR to register memory.
>>> 
>>> - This case is rare: it occurs only after a reconnect.
>> 
>> I'm just double checking that this really is safe?  I'm seeing the hung task killer running more often after applying this patch:
>> 
>> [  245.376879] INFO: task kworker/0:5:193 blocked for more than 120 seconds.
>> [  245.379909]       Not tainted 4.14.0-rc4-ANNA+ #10934
>> [  245.382001] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> [  245.385926] kworker/0:5     D    0   193      2 0x80000080
>> [  245.388148] Workqueue: rpciod rpc_async_schedule [sunrpc]
>> [  245.389386] Call Trace:
>> [  245.390070]  __schedule+0x23d/0x850
>> [  245.390673]  schedule+0x46/0xa0
>> [  245.391219]  schedule_timeout+0x230/0x480
>> [  245.391817]  ? ib_send_mad+0x32d/0x430
>> [  245.392387]  ? __slab_alloc.isra.24+0x3e/0x60
>> [  245.392988]  wait_for_common+0xc9/0x190
>> [  245.393574]  ? wait_for_common+0xc9/0x190
>> [  245.395290]  ? wake_up_q+0x90/0x90
>> [  245.396239]  wait_for_completion+0x30/0x40
>> [  245.397279]  frwr_op_unmap_sync+0x139/0x2a0 [rpcrdma]
>> [  245.398401]  ? call_decode+0x830/0x830 [sunrpc]
>> [  245.399435]  xprt_rdma_send_request+0xdc/0xf0 [rpcrdma]
>> [  245.400558]  xprt_transmit+0x7f/0x370 [sunrpc]
>> [  245.401500]  ? call_decode+0x830/0x830 [sunrpc]
>> [  245.402079]  call_transmit+0x1c4/0x2a0 [sunrpc]
>> [  245.402652]  ? call_decode+0x830/0x830 [sunrpc]
>> [  245.403194]  __rpc_execute+0x92/0x430 [sunrpc]
>> [  245.403737]  ? rpc_wake_up+0x7e/0x90 [sunrpc]
>> [  245.404264]  rpc_async_schedule+0x25/0x30 [sunrpc]
>> [  245.404796]  process_one_work+0x1ed/0x430
>> [  245.405276]  worker_thread+0x45/0x3f0
>> [  245.405730]  kthread+0x134/0x150
>> [  245.406144]  ? process_one_work+0x430/0x430
>> [  245.406627]  ? kthread_create_on_node+0x80/0x80
>> [  245.407114]  ret_from_fork+0x25/0x30
>> 
>> I see this when running cthon tests over NFS v3 with kvm / softroce configured on my client and server.  I'm willing to accept that the problem might be on my end, but I still want to check with you first :)
> 
> My guess is that this is because your RDMA layer is dropping the
> connection frequently, so you're hitting this case a lot. If
> LocalInvalidation is taking a long time, that's a bug in the
> provider, I'd say.
> 
> But I'm just speculating. You need to look into this and figure
> out what's going on. ftrace with function_graph should give
> some impression of where the waiting is going on.

Reproduced here. Trying to figure out why the client is not
reconnecting.


>> Thanks,
>> Anna
>> 
>>> 
>>> By switching this call site to ro_unmap_sync, the final use of
>>> ro_unmap_safe is removed.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> net/sunrpc/xprtrdma/transport.c |    3 ++-
>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>> 
>>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>>> index 8cf5ccf..eb46d24 100644
>>> --- a/net/sunrpc/xprtrdma/transport.c
>>> +++ b/net/sunrpc/xprtrdma/transport.c
>>> @@ -728,7 +728,8 @@
>>> 
>>> 	/* On retransmit, remove any previously registered chunks */
>>> 	if (unlikely(!list_empty(&req->rl_registered)))
>>> -		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
>>> +		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
>>> +						    &req->rl_registered);
>>> 
>>> 	rc = rpcrdma_marshal_req(r_xprt, rqst);
>>> 	if (rc < 0)
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



