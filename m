Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41980 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbdAMSbD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 13:31:03 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 4/5] xprtrdma: Reduce required number of send SGEs
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <VI1PR0502MB30080923A8B244BBAD059358D1780@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Date: Fri, 13 Jan 2017 13:30:56 -0500
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <706404D7-A179-4E54-A2C7-534FCC1B5745@oracle.com>
References: <20170113173023.32692.30661.stgit@manet.1015granger.net> <20170113174322.32692.66126.stgit@manet.1015granger.net> <VI1PR0502MB30080923A8B244BBAD059358D1780@VI1PR0502MB3008.eurprd05.prod.outlook.com>
To: Parav Pandit <parav@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 13, 2017, at 1:01 PM, Parav Pandit <parav@mellanox.com> wrote:
> 
> Hi Chuck,
> 
>> -----Original Message-----
>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>> Sent: Friday, January 13, 2017 11:43 AM
>> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
>> Subject: [PATCH v1 4/5] xprtrdma: Reduce required number of send SGEs
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c
>> b/net/sunrpc/xprtrdma/rpc_rdma.c index 4909758..ab699f9 100644
> 
>> /* The client can't know how large the actual reply will be. Thus it diff --git
>> a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c index
>> 12e8242..5dcdd0b 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -488,18 +488,19 @@ static void rpcrdma_destroy_id(struct rdma_cm_id
>> *id)
>>  */
>> int
>> rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>> -				struct rpcrdma_create_data_internal *cdata)
>> +		  struct rpcrdma_create_data_internal *cdata)
>> {
>> 	struct rpcrdma_connect_private *pmsg = &ep->rep_cm_private;
>> +	unsigned int max_qp_wr, max_sge;
>> 	struct ib_cq *sendcq, *recvcq;
>> -	unsigned int max_qp_wr;
>> 	int rc;
>> 
>> -	if (ia->ri_device->attrs.max_sge < RPCRDMA_MAX_SEND_SGES) {
>> -		dprintk("RPC:       %s: insufficient sge's available\n",
>> -			__func__);
>> +	max_sge = min(ia->ri_device->attrs.max_sge,
>> RPCRDMA_MAX_SEND_SGES);
>> +	if (max_sge < 3) {
>> +		pr_warn("rpcrdma: HCA provides only %d send SGEs\n",
>> max_sge);
>> 		return -ENOMEM;
>> 	}
>> +	ia->ri_max_sgeno = max_sge - 3;
>> 
> 
> I didn't noticed this new ri_max_sgeno variable being used in this patch set. Did I miss?

Yes, you snipped out the other hunk where it is used.


> You also might want to rename it to ri_max_sge_num.
> Regardless for some device with 3 SGEs, ri_max_sgeno will become zero. Is that fine?

Yes, that's OK, and tested. Zero means that NFS WRITE and SYMLINK
payloads will always be sent in a Read chunk.


> You wanted to check for value of 5?
> It would be good to have define for this minimum required 3 SGEs header file such as RPCRDMA_MIN_REQ_RECV_SGE.

OK.


> 
> 
>> 	if (ia->ri_device->attrs.max_qp_wr <= RPCRDMA_BACKWARD_WRS) {
>> 		dprintk("RPC:       %s: insufficient wqe's available\n",
>> @@ -524,7 +525,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id
>> *id)
>> 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
>> 	ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
>> 	ep->rep_attr.cap.max_recv_wr += 1;	/* drain cqe */
>> -	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_SEND_SGES;
>> +	ep->rep_attr.cap.max_send_sge = max_sge;
>> 	ep->rep_attr.cap.max_recv_sge = 1;
>> 	ep->rep_attr.cap.max_inline_data = 0;
>> 	ep->rep_attr.sq_sig_type = IB_SIGNAL_REQ_WR; diff --git
>> a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index f495df0c..c134d0b 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -74,6 +74,7 @@ struct rpcrdma_ia {
>> 	unsigned int		ri_max_frmr_depth;
>> 	unsigned int		ri_max_inline_write;
>> 	unsigned int		ri_max_inline_read;
>> +	unsigned int		ri_max_sgeno;
>> 	bool			ri_reminv_expected;
>> 	bool			ri_implicit_padding;
>> 	enum ib_mr_type		ri_mrtype;
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the
>> body of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
> N§ēæėrļyúčØbēXŽķĮ§vØ^)Þš{.nĮ+·Ĩ{ą­Ų{ayšĘÚë,j­ĒfĢĒ·hāzđŪwĨĒļĒ·Ķj:+vĻwčjØmķĸūŦęįzZ+ųÝĒj"ú!

--
Chuck Lever



