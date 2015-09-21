Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28459 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbbIUWm3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 18:42:29 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 08/18] xprtrdma: Pre-allocate Work Requests for backchannel
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBgD02fG4gLW53XnAaVHk7-6qzRwvjZb=TkZrLBGXSO7Nw@mail.gmail.com>
Date: Mon, 21 Sep 2015 15:41:55 -0700
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <99C6B545-1F74-44F7-893A-9FA4F91F1FB1@oracle.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204516.19671.34390.stgit@manet.1015granger.net> <CANjDDBgD02fG4gLW53XnAaVHk7-6qzRwvjZb=TkZrLBGXSO7Nw@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 21, 2015, at 3:33 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:
> 
> On Fri, Sep 18, 2015 at 2:15 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Pre-allocate extra send and receive Work Requests needed to handle
>> backchannel receives and sends.
>> 
>> The transport doesn't know how many extra WRs to pre-allocate until
>> the xprt_setup_backchannel() call, but that's long after the WRs are
>> allocated during forechannel setup.
>> 
>> So, use a fixed value for now.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/backchannel.c |    4 ++++
>> net/sunrpc/xprtrdma/verbs.c       |   14 ++++++++++++--
>> net/sunrpc/xprtrdma/xprt_rdma.h   |   10 ++++++++++
>> 3 files changed, 26 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
>> index c0a42ad..f5c7122 100644
>> --- a/net/sunrpc/xprtrdma/backchannel.c
>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>> @@ -123,6 +123,9 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
>>         * Twice as many rpc_rqsts are prepared to ensure there is
>>         * always an rpc_rqst available as soon as a reply is sent.
>>         */
>> +       if (reqs > RPCRDMA_BACKWARD_WRS >> 1)
>> +               goto out_err;
>> +
>>        for (i = 0; i < (reqs << 1); i++) {
>>                rqst = kzalloc(sizeof(*rqst), GFP_KERNEL);
>>                if (!rqst) {
>> @@ -159,6 +162,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
>> out_free:
>>        xprt_rdma_bc_destroy(xprt, reqs);
>> 
>> +out_err:
>>        pr_err("RPC:       %s: setup backchannel transport failed\n", __func__);
>>        return -ENOMEM;
>> }
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 1e4a948..133c720 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -614,6 +614,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>>        struct ib_device_attr *devattr = &ia->ri_devattr;
>>        struct ib_cq *sendcq, *recvcq;
>>        struct ib_cq_init_attr cq_attr = {};
>> +       unsigned int max_qp_wr;
>>        int rc, err;
>> 
>>        if (devattr->max_sge < RPCRDMA_MAX_IOVS) {
>> @@ -622,18 +623,27 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>>                return -ENOMEM;
>>        }
>> 
>> +       if (devattr->max_qp_wr <= RPCRDMA_BACKWARD_WRS) {
>> +               dprintk("RPC:       %s: insufficient wqe's available\n",
>> +                       __func__);
>> +               return -ENOMEM;
>> +       }
>> +       max_qp_wr = devattr->max_qp_wr - RPCRDMA_BACKWARD_WRS;
>> +
>>        /* check provider's send/recv wr limits */
>> -       if (cdata->max_requests > devattr->max_qp_wr)
>> -               cdata->max_requests = devattr->max_qp_wr;
>> +       if (cdata->max_requests > max_qp_wr)
>> +               cdata->max_requests = max_qp_wr;
> 
> should we
> cdata->max_request = max_qp_wr - RPCRDMA_BACKWARD_WRS?

cdata->max_request is an input parameter to rpcrdma_ep_create().
We can’t simply overwrite it here with a new larger value.


>>        ep->rep_attr.event_handler = rpcrdma_qp_async_error_upcall;
>>        ep->rep_attr.qp_context = ep;
>>        ep->rep_attr.srq = NULL;
>>        ep->rep_attr.cap.max_send_wr = cdata->max_requests;
>> +       ep->rep_attr.cap.max_send_wr += RPCRDMA_BACKWARD_WRS;
> 
> Looks like will cause a qp-create failure if any hypothetical device
> supports devattr->max_qp_wr = cdata->max_requests

We’ve already capped cdata->max_requests at
“devattr->max_qp_wr - RPCRDMA_BACKWARD_WRS” above. So, the logic
should prevent that, unless I’ve made a mistake.


>>        rc = ia->ri_ops->ro_open(ia, ep, cdata);
>>        if (rc)
>>                return rc;
>>        ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
>> +       ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
>>        ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_IOVS;
>>        ep->rep_attr.cap.max_recv_sge = 1;
>>        ep->rep_attr.cap.max_inline_data = 0;
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index 2ca0567..37d0d7f 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -101,6 +101,16 @@ struct rpcrdma_ep {
>>  */
>> #define RPCRDMA_IGNORE_COMPLETION      (0ULL)
>> 
>> +/* Pre-allocate extra Work Requests for handling backward receives
>> + * and sends. This is a fixed value because the Work Queues are
>> + * allocated when the forward channel is set up.
>> + */
>> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
>> +#define RPCRDMA_BACKWARD_WRS           (8)
>> +#else
>> +#define RPCRDMA_BACKWARD_WRS           (0)
>> +#endif
>> +
>> /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV
>>  *
>>  * The below structure appears at the front of a large region of kmalloc'd
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



