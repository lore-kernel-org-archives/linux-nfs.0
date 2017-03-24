Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19445 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755019AbdCXWT2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Mar 2017 18:19:28 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 05/14] svcrdma: Introduce local rdma_rw API helpers
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1CAD2542-A121-47ED-A47C-624E188EB54F@oracle.com>
Date: Fri, 24 Mar 2017 18:19:04 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <256CD89A-1967-45C8-8AE1-5A56B09AB6F5@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net> <20170316155306.4482.68041.stgit@klimt.1015granger.net> <cfa49433-ab26-d2f0-27d4-2a96ff0adaba@grimberg.me> <1CAD2542-A121-47ED-A47C-624E188EB54F@oracle.com>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 22, 2017, at 11:41 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Mar 22, 2017, at 10:17 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
>> 
>>> 
>>> The plan is to replace the local bespoke code that constructs and
>>> posts RDMA Read and Write Work Requests with calls to the rdma_rw
>>> API. This shares code with other RDMA-enabled ULPs that manages the
>>> gory details of buffer registration and posting Work Requests.
>>> 
>>> Some design notes:
>>> 
>>> o svc_xprt reference counting is modified, since one rdma_rw_ctx
>>>  generates one completion, no matter how many Write WRs are
>>>  posted. To accommodate the new reference counting scheme, a new
>>>  version of svc_rdma_send() is introduced.
>>> 
>>> o The structure of RPC-over-RDMA transport headers is flexible,
>>>  allowing multiple segments per Reply with arbitrary alignment.
>>>  Thus I did not take the further step of chaining Write WRs with
>>>  the Send WR containing the RPC Reply message. The Write and Send
>>>  WRs continue to be built by separate pieces of code.
>>> 
>>> o The current code builds the transport header as it is construct-
>>>  ing Write WRs. I've replaced that with marshaling of transport
>>>  header data items in a separate step. This is because the exact
>>>  structure of client-provided segments may not align with the
>>>  components of the server's reply xdr_buf, or the pages in the
>>>  page list. Thus parts of each client-provided segment may be
>>>  written at different points in the send path.
>>> 
>>> o Since the Write list and Reply chunk marshaling code is being
>>>  replaced, I took the opportunity to replace some of the C
>>>  structure-based XDR encoding code with more portable code that
>>>  instead uses pointer arithmetic.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> 
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>>> new file mode 100644
>>> index 0000000..1e76227
>>> --- /dev/null
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>>> @@ -0,0 +1,785 @@
>>> +/*
>>> + * Copyright (c) 2016 Oracle.  All rights reserved.
>>> + *
>>> + * Use the core R/W API to move RPC-over-RDMA Read and Write chunks.
>>> + */
>>> +
>>> +#include <linux/sunrpc/rpc_rdma.h>
>>> +#include <linux/sunrpc/svc_rdma.h>
>>> +#include <linux/sunrpc/debug.h>
>>> +
>>> +#include <rdma/rw.h>
>>> +
>>> +#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>>> +
>>> +/* Each R/W context contains state for one chain of RDMA Read or
>>> + * Write Work Requests (one RDMA segment to be read from or written
>>> + * back to the client).
>>> + *
>>> + * Each WR chain handles a single contiguous server-side buffer,
>>> + * because some registration modes (eg. FRWR) do not support a
>>> + * discontiguous scatterlist.
>>> + *
>>> + * Each WR chain handles only one R_key. Each RPC-over-RDMA segment
>>> + * from a client may contain a unique R_key, so each WR chain moves
>>> + * one segment (or less) at a time.
>>> + *
>>> + * The scatterlist makes this data structure just over 8KB in size
>>> + * on 4KB-page platforms. As the size of this structure increases
>>> + * past one page, it becomes more likely that allocating one of these
>>> + * will fail. Therefore, these contexts are created on demand, but
>>> + * cached and reused until the controlling svcxprt_rdma is destroyed.
>>> + */
>>> +struct svc_rdma_rw_ctxt {
>>> +	struct list_head	rw_list;
>>> +	struct ib_cqe		rw_cqe;
>>> +	struct svcxprt_rdma	*rw_rdma;
>>> +	int			rw_nents;
>>> +	int			rw_wrcount;
>>> +	enum dma_data_direction	rw_dir;
>>> +	struct svc_rdma_op_ctxt	*rw_readctxt;
>>> +	struct rdma_rw_ctx	rw_ctx;
>>> +	struct scatterlist	rw_sg[RPCSVC_MAXPAGES];
>> 
>> Have you considered using sg_table with sg_alloc_table_chained?
>> 
>> See lib/sg_pool.c and nvme-rdma as a consumer.
> 
> That might be newer than my patches. I'll have a look.

I looked at the consumers of sg_alloc_table_chained, and
all these callers are immediately doing ib_dma_map_sg.

Nothing in svc_rdma_rw.c does a DMA map. It relies on
rdma_rw_ctx_init for that, and that API is passed a
scatterlist.

I don't see how I could use sg_alloc_table_chained here,
unless rdma_rw_ctx_init was modified to take a chained
sg_table instead of a scatterlist argument.

I suppose I could convert the client side to use it?
What do you think?


>>> +};
>>> +
>>> +static struct svc_rdma_rw_ctxt *
>>> +svc_rdma_get_rw_ctxt(struct svcxprt_rdma *rdma)
>>> +{
>>> +	struct svc_rdma_rw_ctxt *ctxt;
>>> +
>>> +	svc_xprt_get(&rdma->sc_xprt);
>>> +
>>> +	spin_lock(&rdma->sc_rw_ctxt_lock);
>>> +	if (list_empty(&rdma->sc_rw_ctxts))
>>> +		goto out_empty;
>>> +
>>> +	ctxt = list_first_entry(&rdma->sc_rw_ctxts,
>>> +				struct svc_rdma_rw_ctxt, rw_list);
>>> +	list_del_init(&ctxt->rw_list);
>>> +	spin_unlock(&rdma->sc_rw_ctxt_lock);
>>> +
>>> +out:
>>> +	ctxt->rw_dir = DMA_NONE;
>>> +	return ctxt;
>>> +
>>> +out_empty:
>>> +	spin_unlock(&rdma->sc_rw_ctxt_lock);
>>> +
>>> +	ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
>>> +	if (!ctxt) {
>>> +		svc_xprt_put(&rdma->sc_xprt);
>>> +		return NULL;
>>> +	}
>>> +
>>> +	ctxt->rw_rdma = rdma;
>>> +	INIT_LIST_HEAD(&ctxt->rw_list);
>>> +	sg_init_table(ctxt->rw_sg, ARRAY_SIZE(ctxt->rw_sg));
>>> +	goto out;
>>> +}
>>> +
>>> +static void svc_rdma_put_rw_ctxt(struct svc_rdma_rw_ctxt *ctxt)
>>> +{
>>> +	struct svcxprt_rdma *rdma = ctxt->rw_rdma;
>>> +
>>> +	if (ctxt->rw_dir != DMA_NONE)
>>> +		rdma_rw_ctx_destroy(&ctxt->rw_ctx, rdma->sc_qp,
>>> +				    rdma->sc_port_num,
>>> +				    ctxt->rw_sg, ctxt->rw_nents,
>>> +				    ctxt->rw_dir);
>>> +
>> 
>> its a bit odd to see put_rw_ctxt that also destroys the context
>> which isn't exactly pairs with get_rw_ctxt.
>> 
>> Maybe it'd be useful to explicitly do that outside the put.
> 
> The pairing is not obvious, but it is this:
> 
> svc_rdma_send_writes() does the svc_rdma_get_rw_ctx.
> 
> -> If posting succeeds, svc_rdma_wc_write_ctx puts the ctx.
> 
> -> If posting fails, svc_rdma_send_writes puts the ctx.
> 
> Do you have a suggestion about how this could be more
> intuitively documented?
> 
> IIRC I combined these because the rdma_rw_ctx_destroy is
> always done just before putting the ctx back on the free
> list. It eliminates some code duplication, and ensures
> the ctx is always ready for the next svc_rdma_get_rw_ctx.

I fixed this up, I think it is an improvement. Thanks for
the suggestion.


--
Chuck Lever



