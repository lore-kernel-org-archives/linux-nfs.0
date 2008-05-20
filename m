From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 03/04]  NFS/RDMA client stall patches
Date: Tue, 20 May 2008 10:48:34 +1000
Message-ID: <48321FE2.6000703@sgi.com>
References: <4830D86E.6040605@sgi.com> <RTPCLUEXC1-PRDBPaa700000101@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:37751 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751430AbYETAsr (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 20:48:47 -0400
In-Reply-To: <RTPCLUEXC1-PRDBPaa700000101-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Talpey, Thomas wrote:
> At 09:31 PM 5/18/2008, Peter Leckie wrote:
>   
>> This patch changes rpcrdma_conn_func() to directly call
>> xprt_disconnect() instead of directly waking the pending
>> task queue. 
>>     
>
> Does this fix some issue, or is it simply more efficient to initiate the
> disconnect immediately? Because the conn_func is called directly
> from the RDMA provider's connection upcall, it may be entered in
> an arbitrary context, so xprt_disconnect() could be a bit heavyweight
> and lead to deadlock. Have you satisified yourself this is not the
> case?
>   
Well xprt_disconnect_done() is no more heavy weight then the 
rpcrdma_conn_func()
equivalent it simply clears the connected bit and labels the  queues as 
not connected.
The reason for calling xprt_disconnect_done() is to  make a single 
disconnect function.

The reason this change is needed is to allow the send and resend queues 
to be drained on disconnect, patch 02 could have been changed to also 
drain the these queues from rpcrdma_conn_func() however I think this is 
a cleaner fix.

Thanks
Pete

>   
>> Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>> Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>> X-Sgi-Pv: 970244
>> <http://bugworks/query.cgi/970244>---
>> Index: linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
>> ===================================================================
>> --- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -680,15 +680,13 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
>> {
>>        struct rpc_xprt *xprt = ep->rep_xprt;
>>
>> -       spin_lock_bh(&xprt->transport_lock);
>>        if (ep->rep_connected > 0) {
>> +               spin_lock_bh(&xprt->transport_lock);
>>                if (!xprt_test_and_set_connected(xprt))
>>                        xprt_wake_pending_tasks(xprt, 0);
>> -       } else {
>> -               if (xprt_test_and_clear_connected(xprt))
>> -                       xprt_wake_pending_tasks(xprt, ep->rep_connected);
>> -       }
>> -       spin_unlock_bh(&xprt->transport_lock);
>> +               spin_unlock_bh(&xprt->transport_lock);
>> +       } else
>> +               xprt_disconnect(xprt);
>> }
>>
>> /*
>>
>>
>>
>>     
>
>
>   

