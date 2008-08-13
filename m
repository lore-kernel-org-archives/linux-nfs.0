From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH,RFC 02/02] xprtrdma: Update the RPC memory registration
 to use FRMR
Date: Wed, 13 Aug 2008 17:35:24 -0500
Message-ID: <48A361AC.8010705@opengridcomputing.com>
References: <48A30959.7060404@opengridcomputing.com> <1218649253.9042.11.camel@localhost> <1032B681-8E1C-4074-BF14-7521F34BB7E8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40073 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753091AbYHMWfZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:35:25 -0400
In-Reply-To: <1032B681-8E1C-4074-BF14-7521F34BB7E8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Aug 13, 2008, at 1:40 PM, Trond Myklebust wrote:
>> On Wed, 2008-08-13 at 11:18 -0500, Tom Tucker wrote:
>>> Use FRMR when registering client memory if the memory registration
>>> strategy is FRMR.
>>>
>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>
>>> ---
>>>  net/sunrpc/xprtrdma/verbs.c |  296 
>>> ++++++++++++++++++++++++++++++++++++++-----
>>>  1 files changed, 263 insertions(+), 33 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index 8ea283e..ed401f9 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -423,6 +423,7 @@ rpcrdma_clean_cq(struct ib_cq *cq)
>>>  int
>>>  rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, 
>>> int memreg)
>>>  {
>>> +    struct ib_device_attr devattr;
>>>      int rc;
>>>      struct rpcrdma_ia *ia = &xprt->rx_ia;
>>>
>>> @@ -443,6 +444,49 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, 
>>> struct sockaddr *addr, int memreg)
>>>      }
>>>
>>>      /*
>>> +     * Query the device to determine if the requested memory
>>> +     * registration strategy is supported. If it isnt't set the
>>> +     * strategy to a globally supported model.
>>> +     */
>>> +    rc = ib_query_device(ia->ri_id->device, &devattr);
>>> +    if (rc) {
>>> +        dprintk("RPC:       %s: ib_query_device failed %d\n",
>>> +            __func__, rc);
>>> +        goto out2;
>>> +    }
>>> +    switch (memreg) {
>>> +    case RPCRDMA_MEMWINDOWS:
>>> +    case RPCRDMA_MEMWINDOWS_ASYNC:
>>> +        if (!(devattr.device_cap_flags & IB_DEVICE_MEM_WINDOW)) {
>>> +            dprintk("RPC:       %s: MEMWINDOWS specified but not "
>>> +                "supported, using RPCRDMA_ALLPHYSICAL",
>>> +                __func__);
>>> +            memreg = RPCRDMA_ALLPHYSICAL;
>>> +        }
>>> +        break;
>>> +    case RPCRDMA_MTHCAFMR:
>>> +        if (!ia->ri_id->device->alloc_fmr) {
>>> +            dprintk("RPC:       %s: MTHCAFMR specified but not "
>>> +                "supported, using RPCRDMA_ALLPHYSICAL",
>>> +                __func__);
>>> +            memreg = RPCRDMA_ALLPHYSICAL;
>>> +        }
>>> +        break;
>>> +    case RPCRDMA_FASTREG:
>>> +        /* Requires both fast reg and global dma lkey */
>>> +        if ((0 ==
>>> +             (devattr.device_cap_flags & 
>>> IB_DEVICE_MEM_MGT_EXTENSIONS)) ||
>>> +            (0 == (devattr.device_cap_flags & 
>>> IB_DEVICE_LOCAL_DMA_LKEY))) {
>>> +            dprintk("RPC:       %s: FASTREG specified but not "
>>> +                "supported, using RPCRDMA_ALLPHYSICAL",
>>> +                __func__);
>>> +            memreg = RPCRDMA_ALLPHYSICAL;
>>> +        }
>>> +        break;
>>> +    }
>>> +    dprintk("RPC:       memory registration strategy is %d\n", memreg);
>>> +
>>> +    /*
>>>       * Optionally obtain an underlying physical identity mapping in
>>>       * order to do a memory window-based bind. This base registration
>>>       * is protected from remote access - that is enabled only by 
>>> binding
>>> @@ -450,7 +494,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct 
>>> sockaddr *addr, int memreg)
>>>       * revoked after the corresponding completion similar to a storage
>>>       * adapter.
>>>       */
>>> -    if (memreg > RPCRDMA_REGISTER) {
>>> +    if ((memreg > RPCRDMA_REGISTER) && (memreg != RPCRDMA_FASTREG)) {
>>>          int mem_priv = IB_ACCESS_LOCAL_WRITE;
>>>          switch (memreg) {
>>>  #if RPCRDMA_PERSISTENT_REGISTRATION
>>> @@ -475,7 +519,10 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, 
>>> struct sockaddr *addr, int memreg)
>>>              memreg = RPCRDMA_REGISTER;
>>>              ia->ri_bind_mem = NULL;
>>>          }
>>> +        ia->ri_dma_lkey = ia->ri_bind_mem->lkey;
>>>      }
>>> +    if (memreg == RPCRDMA_FASTREG)
>>> +        ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
>>>
>>>      /* Else will do memory reg/dereg for each chunk */
>>>      ia->ri_memreg_strategy = memreg;
>>> @@ -541,6 +588,12 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct 
>>> rpcrdma_ia *ia,
>>>      ep->rep_attr.srq = NULL;
>>>      ep->rep_attr.cap.max_send_wr = cdata->max_requests;
>>>      switch (ia->ri_memreg_strategy) {
>>> +    case RPCRDMA_FASTREG:
>>> +        /* Add room for fast reg and invalidate */
>>> +        ep->rep_attr.cap.max_send_wr *= 3;
>>> +        if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr)
>>> +            return -EINVAL;
>>> +        break;
>>>      case RPCRDMA_MEMWINDOWS_ASYNC:
>>>      case RPCRDMA_MEMWINDOWS:
>>>          /* Add room for mw_binds+unbinds - overkill! */
>>> @@ -623,6 +676,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct 
>>> rpcrdma_ia *ia,
>>>          break;
>>>      case RPCRDMA_MTHCAFMR:
>>>      case RPCRDMA_REGISTER:
>>> +    case RPCRDMA_FASTREG:
>>>          ep->rep_remote_cma.responder_resources = cdata->max_requests *
>>>                  (RPCRDMA_MAX_DATA_SEGS / 8);
>>>          break;
>>> @@ -866,6 +920,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, 
>>> struct rpcrdma_ep *ep,
>>>
>>>      buf->rb_max_requests = cdata->max_requests;
>>>      spin_lock_init(&buf->rb_lock);
>>> +    spin_lock_init(&buf->rb_frs_lock);
>>>      atomic_set(&buf->rb_credits, 1);
>>>
>>>      /* Need to allocate:
>>> @@ -874,6 +929,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, 
>>> struct rpcrdma_ep *ep,
>>>       *   3.  array of struct rpcrdma_rep for replies
>>>       *   4.  padding, if any
>>>       *   5.  mw's, if any
>>> +     *   6.  frmr's, if any
>>>       * Send/recv buffers in req/rep need to be registered
>>>       */
>>>
>>> @@ -881,6 +937,10 @@ rpcrdma_buffer_create(struct rpcrdma_buffer 
>>> *buf, struct rpcrdma_ep *ep,
>>>          (sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
>>>      len += cdata->padding;
>>>      switch (ia->ri_memreg_strategy) {
>>> +    case RPCRDMA_FASTREG:
>>> +        len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
>>> +                sizeof(struct rpcrdma_frmr);
>>> +        break;
>>>      case RPCRDMA_MTHCAFMR:
>>>          /* TBD we are perhaps overallocating here */
>>>          len += (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS *
>>> @@ -895,7 +955,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, 
>>> struct rpcrdma_ep *ep,
>>>          break;
>>>      }
>>>
>>> -    /* allocate 1, 4 and 5 in one shot */
>>> +    /* allocate 1, 4, 5 and 6 in one shot */
>>>      p = kzalloc(len, GFP_KERNEL);
>>>      if (p == NULL) {
>>>          dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
>>> @@ -927,7 +987,38 @@ rpcrdma_buffer_create(struct rpcrdma_buffer 
>>> *buf, struct rpcrdma_ep *ep,
>>>       * and also reduce unbind-to-bind collision.
>>>       */
>>>      INIT_LIST_HEAD(&buf->rb_mws);
>>> +    INIT_LIST_HEAD(&buf->rb_frs);
>>>      switch (ia->ri_memreg_strategy) {
>>> +    case RPCRDMA_FASTREG:
>>> +        {
>>
>> Can we please get rid of this kind of ugliness whereby we insert blocks
>> just in order to set up a temporary variable. I know Chuck is fond of
>> it, but as far as I'm concerned it just screws up readability of the
>> code.
>> If you feel you need to isolate a variable to a particular block of
>> code, then make a function, and that's particularly true of these huge
>> switch statements that are trying to do 100 entirely unrelated things in
>> one function.
> 
> Never fear, I have stopped the practice, and prefer to use a separate 
> function now.  I agree that these are not very readable.  The double 
> bracket at the end of such structures makes my eyes cross.
> 
> There are probably still some instances in my queued patch series, but 
> I've tried to cull them out before posting them.
>

I just copied the coding style of the function. So the proposal here is 
to refactor this function? If yes, then I'll make it happen.

Tom

> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

