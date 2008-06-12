From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 01/04]  NFS/RDMA client stall patches
Date: Thu, 12 Jun 2008 18:45:36 +1000
Message-ID: <4850E230.3010101@sgi.com>
References: <4830F91C.7070206@sgi.com> <1213125899.20459.34.camel@localhost> <484F86B7.7040109@sgi.com> <RTPCLUEXC1-PRDaogxL000001eb@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, talpey@netapp.com,
	linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:46893 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754468AbYFLIqB (ORCPT
	<rfc822;@sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 04:46:01 -0400
In-Reply-To: <RTPCLUEXC1-PRDaogxL000001eb-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Talpey, Thomas wrote:
> At 04:03 AM 6/11/2008, Peter Leckie wrote:
>   
>> That's a good point you raise there I was looking to closely at the tcp 
>> equivalent, the correct fix for this issue would be to implement a timer 
>> function for NFS/RDMA pretty much identical to xs_udp_timer(), as follows:
>>     
>
> Hmm, in fact that runs into a different issue - retransmitting over RDMA
> isn't allowed, since it consumes server credits and therefore will eventually
> overrun the connection's receive queue. I have a patch in my queue to
> force a disconnect in fact, which is the appropriate action. I will send them
> out soon, it's in with some other post-Connectathon work.
>
> I think with your earlier patch to avoid the 5-second pause, the disconnect
> action will be prompt and accurate. However, I would still be concerned why
> the RPC was timing out in the first place. Was there an issue in the server?
>   
So this is not a typical runtime issue it was just another reason the 
NFS/RDMA client failed to reconnect after
the server disconnects us. Under this circumstance the client is stalled 
on congestion and has not received the
disconnection event. So what both these patches do is allow the client 
to try and resend another RPC, this causes
rpcrdma_conn_upcall() to be called with an event of 
RDMA_CM_EVENT_CONNECT_ERROR which
then allows the xprt to be disconnected and reconnected. Without this 
change what happens is the client sits there
for ever waiting for the congestion to drop.

This does ask another question why didn't the DREQ from the server cause 
the xprt on the client to disconnect.
Umm I might try and reproduce this error and see what's happening.

Thanks,
Pete



