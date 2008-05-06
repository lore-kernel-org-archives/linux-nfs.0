From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  3/17] svcrdma: Fix return value in svc_rdma_send
Date: Mon, 05 May 2008 21:03:02 -0500
Message-ID: <C4452686.4957E%tom@opengridcomputing.com>
References: <20080505220817.GH12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:5444 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158AbYEFC2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 22:28:23 -0400
In-Reply-To: <20080505220817.GH12814@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 5/5/08 5:08 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 02, 2008 at 11:28:35AM -0500, Tom Tucker wrote:
>> Fix the return value on close to -ENOTCONN so caller knows to free context.
>> Also if a thread is waiting for free SQ space, check for close when waking
>> to avoid posting WR to a closing transport.
> 
> A random related question: svc_rdma_send_error() seems to have only one
> caller, which ignores its return value.  Should its return value be
> made void?

Honestly, I don't think this code path has ever been excercised. This is the
"protocol error" path. Given my experience with the "random transport error"
tests that resulted in the patchset your currently looking at, I'd be
inclined to defer this kind of thing until I've built a "protocol error" set
of tests and worked through the "evil client" scenarios.

Thoughts?
> 
> --b.
> 
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> 
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 14f83a1..8adb2f0 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -999,7 +999,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct
>> ib_send_wr *wr)
>> int ret;
>>  
>> if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
>> -  return 0;
>> +  return -ENOTCONN;
>>  
>> BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
>> BUG_ON(((struct svc_rdma_op_ctxt *)(unsigned long)wr->wr_id)->wr_op !=
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


