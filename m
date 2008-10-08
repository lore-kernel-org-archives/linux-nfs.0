From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 12/15] RPC/RDMA: correct a 5 second pause on
  reconnecting to an idle server.
Date: Wed, 08 Oct 2008 13:51:28 -0400
Message-ID: <RTPCLUEXC1-PRDjbDt300000076@RTPMVEXC1-PRD.hq.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
 <20081008154856.1336.18339.stgit@tmt3.nane.netapp.com>
 <1223487348.7361.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbYJHRwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:52:24 -0400
In-Reply-To: <1223487348.7361.20.camel@localhost>
References: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <20081008154856.1336.18339.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <1223487348.7361.20.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:35 PM 10/8/2008, Trond Myklebust wrote:
>On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
>> The RPC/RDMA code always performed a reconnect-with-backoff, even
>> when re-establishing a connection to a server after the RPC layer
>> closed it due to being idle.
>> ---
>> 
>>  net/sunrpc/xprtrdma/transport.c |    5 +++--
>>  net/sunrpc/xprtrdma/verbs.c     |    2 +-
>>  2 files changed, 4 insertions(+), 3 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/transport.c 
>b/net/sunrpc/xprtrdma/transport.c
>> index c7d2380..278a544 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -486,8 +486,9 @@ xprt_rdma_connect(struct rpc_task *task)
>>  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>>  
>>  	if (!xprt_test_and_set_connecting(xprt)) {
>> -		if (r_xprt->rx_ep.rep_connected != 0) {
>> -			/* Reconnect */
>> +		if (r_xprt->rx_ep.rep_connected &&
>> +		    r_xprt->rx_ep.rep_connected != -EPIPE) {
>> +			/* Reconnect with backoff */
>>  			schedule_delayed_work(&r_xprt->rdma_connect,
>>  				xprt->reestablish_timeout);
>>  		} else {
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index a63d0c0..9ef7e0d 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -317,7 +317,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, 
>struct rdma_cm_event *event)
>>  		connstate = -ECONNREFUSED;
>>  		goto connected;
>>  	case RDMA_CM_EVENT_DISCONNECTED:
>> -		connstate = -ECONNABORTED;
>> +		connstate = -EPIPE;
>>  		goto connected;
>>  	case RDMA_CM_EVENT_DEVICE_REMOVAL:
>>  		connstate = -ENODEV;
>
>Hmm... Why not rather do the same as the socket code: have the
>disconnect handler paths that don't require exponential backoff just
>reset xprt->reestablish_timeout to 0?

Because we do want a non-zero reestablishment timeout in general, and
the RDMA client has not implemented a connection backoff. So in effect
the value is constant for this code, and I thought treating it as such is
the safer fix. 

I'm not 100% convinced the TCP code is correct, btw. It appears to
zero out the reestablish timeout on idle-disconnect, but it's not obvious
to me where it sets it back to a non-zero value. It does try to double
it in xs_connect() though! :-)

I have that issue on my list to look into, of course, but I think it was
out of scope for RDMA.

Tom.

>
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

