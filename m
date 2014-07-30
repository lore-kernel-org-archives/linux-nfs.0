Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56768 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751351AbaG3T7a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 15:59:30 -0400
Message-ID: <53D94EA6.10201@opengridcomputing.com>
Date: Wed, 30 Jul 2014 14:59:34 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: David Miller <davem@davemloft.net>, himangi774@gmail.com
CC: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
Subject: Re: [PATCH] svcrdma: delete double assignment
References: <20140728152938.GA3040@himangi-Dell> <20140729.155050.311148635959938226.davem@davemloft.net>
In-Reply-To: <20140729.155050.311148635959938226.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/29/2014 5:50 PM, David Miller wrote:
> From: Himangi Saraogi <himangi774@gmail.com>
> Date: Mon, 28 Jul 2014 20:59:38 +0530
>
>> Delete successive assignments to the same location.
>>
>> A simplified version of Coccinelle semantic match that finds this problem is as
>> follows:
>>
>> // <smpl>
>> @@
>> expression i;
>> @@
>>
>> *i = ...;
>>   i = ...;
>> // </smpl>
>>
>> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> I am not so sure about this change either.
>
>> @@ -956,7 +956,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>   			dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
>>   			goto errout;
>>   		}
>> -		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
>>   		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
>>   		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
>>   		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
> ->sc_max_sge is used to limit the number of segments used during sends,
> currently in this code.  Grep for where it is used.
>
> Therefore, if anything, the correct thing to do would be to retain the
> first line rather than the second line.
>
> Someone who actually works on this code and understands it should
> really take a close look at this before anyone even thinks about
> applying this patch.

We should remove that whole block that tries to recover from a 
rdma_create_qp() failure.   I don't believe we would ever hit it. The 
value initially stored in sc_max_sge is from the device attribute 
max_sge returned from ib_query_device() just above the code we're 
talking about.  If rdma_create_qp() fails, it would not be because the 
max_send_sge and max_recv_sge values passed in exceed the device's max...

Like this:

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c 
b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index e7323fb..282a43b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -942,23 +942,8 @@ static struct svc_xprt *svc_rdma_accept(struct 
svc_xprt *xprt)

         ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
         if (ret) {
-               /*
-                * XXX: This is a hack. We need a xx_request_qp interface
-                * that will adjust the qp_attr's with a best-effort
-                * number
-                */
-               qp_attr.cap.max_send_sge -= 2;
-               qp_attr.cap.max_recv_sge -= 2;
-               ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd,
-                                    &qp_attr);
-               if (ret) {
-                       dprintk("svcrdma: failed to create QP, 
ret=%d\n", ret);
-                       goto errout;
-               }
-               newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
-               newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
-               newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
-               newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
+               dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
+               goto errout;
         }
         newxprt->sc_qp = newxprt->sc_cm_id->qp;


Steve.




