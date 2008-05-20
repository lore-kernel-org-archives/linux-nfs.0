From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 03/04]  NFS/RDMA client stall patches
Date: Tue, 20 May 2008 09:20:54 -0400
Message-ID: <RTPCLUEXC1-PRDtrSBy00000126@RTPMVEXC1-PRD.hq.netapp.com>
References: <4830D86E.6040605@sgi.com>
 <RTPCLUEXC1-PRDBPaa700000101@RTPMVEXC1-PRD.hq.netapp.com>
 <48321FE2.6000703@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Peter Leckie <pleckie@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52188 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358AbYETNUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:20:52 -0400
In-Reply-To: <48321FE2.6000703@sgi.com>
References: <4830D86E.6040605@sgi.com>
 <RTPCLUEXC1-PRDBPaa700000101-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <48321FE2.6000703@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 08:48 PM 5/19/2008, Peter Leckie wrote:
>Well xprt_disconnect_done() is no more heavy weight then the 
>rpcrdma_conn_func()
>equivalent it simply clears the connected bit and labels the  queues as 
>not connected.
>The reason for calling xprt_disconnect_done() is to  make a single 
>disconnect function.

Aha - I agree and now realize that I misunderstood because your patch
calls xprt_disconnect(), which (IIRC) is an older heavier function that's no
longer in sunrpc. Is this the right patch then?

>The reason this change is needed is to allow the send and resend queues 
>to be drained on disconnect, patch 02 could have been changed to also 
>drain the these queues from rpcrdma_conn_func() however I think this is 
>a cleaner fix.

Sounds good - pending better understanding of which fix is right. :-)

...
>>> Index: linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
>>> ===================================================================
>>> --- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/rpc_rdma.c
>>> +++ linux-2.6.25.3/net/sunrpc/xprtrdma/rpc_rdma.c
>>> @@ -680,15 +680,13 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
...
>>> +               spin_unlock_bh(&xprt->transport_lock);
>>> +       } else
>>> +               xprt_disconnect(xprt);
>>> }
>>>

Tom.

