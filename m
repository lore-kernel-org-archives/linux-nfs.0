From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 01/04]  NFS/RDMA client stall patches
Date: Wed, 11 Jun 2008 18:03:03 +1000
Message-ID: <484F86B7.7040109@sgi.com>
References: <4830F91C.7070206@sgi.com> <1213125899.20459.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: talpey@netapp.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:36894 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751714AbYFKIEs (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 04:04:48 -0400
In-Reply-To: <1213125899.20459.34.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2008-05-19 at 13:50 +1000, Peter Leckie wrote:
>   
>> Don't call __xprt_get_cong() if this is a retransmit.
>> This prevents __xprt_get_cong() from recursively
>> incrementing the congestion avoidance window for
>> retransmitted data.
>>
>> Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>> Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>> X-Sgi-Pv: 971446
>>  <http://bugworks/query.cgi/971446>---
>> Index: linux-2.6.25.3/net/sunrpc/xprt.c
>> ===================================================================
>> --- linux-2.6.25.3.orig/net/sunrpc/xprt.c
>> +++ linux-2.6.25.3/net/sunrpc/xprt.c
>> @@ -224,7 +224,8 @@ int xprt_reserve_xprt_cong(struct rpc_ta
>>                         return 1;
>>                 goto out_sleep;
>>         }
>> -       if (__xprt_get_cong(xprt, task)) {
>> +     /*If this is a retransmit don't increment cong*/
>> +       if ((req && req->rq_ntrans) ||__xprt_get_cong(xprt, task)) {
>>                 xprt->snd_task = task;
>>                 if (req) {
>>                         req->rq_bytes_sent = 0;
>>
>>     
>
> Why would we not want to increment the congestion avoidance window on
> retransmitted data? On timeout, xprt_adjust_cwnd will call
> __xprt_put_cong() prior to the retransmission, so I can't see how this
> is a 'recursive increment'.
>
> Trond

That's a good point you raise there I was looking to closely at the tcp 
equivalent, the correct fix for this issue would be to implement a timer 
function for NFS/RDMA pretty much identical to xs_udp_timer(), as follows:


Implement xprt_rdma_timer() to be called when an RPC times out.
This is needed to decrement the cong after an rpc times out preventing
the congestion aviodance from tripping under retransmitts.

Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

Index: linux-2.6.25.3/net/sunrpc/xprtrdma/transport.c
===================================================================
--- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/transport.c
+++ linux-2.6.25.3/net/sunrpc/xprtrdma/transport.c
@@ -450,6 +450,18 @@ out1:
 }

 /*
+ * xprt_rdma_timer - called when a retransmit timeout occurs on a RDMA 
transport
+ * @task: task that timed out
+ *
+ * Adjust the congestion window after a retransmit timeout has occurred.
+ */
+static void
+xprt_rdma_timer(struct rpc_task *task)
+{
+       xprt_adjust_cwnd(task, -ETIMEDOUT);
+}
+
+/*
  * Close a connection, during shutdown or timeout/reconnect
  */
 static void
@@ -755,7 +767,8 @@ static struct rpc_xprt_ops xprt_rdma_pro
        .send_request           = xprt_rdma_send_request,
        .close                  = xprt_rdma_close,
        .destroy                = xprt_rdma_destroy,
-       .print_stats            = xprt_rdma_print_stats
+       .print_stats            = xprt_rdma_print_stats,
+       .timer                  = xprt_rdma_timer
 };

 static struct xprt_class xprt_rdma = {


Thanks,
Pete

