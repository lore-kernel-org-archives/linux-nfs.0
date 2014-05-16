Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:45031 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753717AbaEPOOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 May 2014 10:14:07 -0400
Message-ID: <53761D28.3070704@opengridcomputing.com>
Date: Fri, 16 May 2014 09:14:00 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
CC: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH V3 01/17] xprtrdma: mind the device's max fast register
 page	list depth
References: <20140430191433.5663.16217.stgit@manet.1015granger.net> <20140430192936.5663.66537.stgit@manet.1015granger.net> <EE7902D3F51F404C82415C4803930ACD3FDFBDA9@CMEXMB1.ad.emulex.com> <53761C63.4050908@opengridcomputing.com>
In-Reply-To: <53761C63.4050908@opengridcomputing.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, Devesh:  Is the device advertising FRMR support, yet setting 
the max page list len to zero?  That's a driver bug...



On 5/16/2014 9:10 AM, Steve Wise wrote:
> I guess the client code doesn't verify that the device supports the 
> chosen memreg mode.  That's not good.   Lemme fix this and respin this 
> patch.
>
>
> On 5/16/2014 2:08 AM, Devesh Sharma wrote:
>> Chuck
>>
>> This patch is causing a CPU soft-lockup if underlying vendor reports 
>> devattr.max_fast_reg_pagr_list_len = 0 and ia->ri_memreg_strategy = 
>> FRMR (Default option).
>> I think there is need to refer to device capability flags. If 
>> strategy = FRMR is forced and devattr.max_fast_reg_pagr_list_len=0 
>> then flash an error and fail RPC with -EIO.
>>
>> See inline:
>>
>>> -----Original Message-----
>>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>> Sent: Thursday, May 01, 2014 1:00 AM
>>> To: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
>>> Cc: Anna.Schumaker@netapp.com
>>> Subject: [PATCH V3 01/17] xprtrdma: mind the device's max fast register
>>> page list depth
>>>
>>> From: Steve Wise <swise@opengridcomputing.com>
>>>
>>> Some rdma devices don't support a fast register page list depth of 
>>> at least
>>> RPCRDMA_MAX_DATA_SEGS.  So xprtrdma needs to chunk its fast register
>>> regions according to the minimum of the device max supported depth or
>>> RPCRDMA_MAX_DATA_SEGS.
>>>
>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>>   net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ---
>>>   net/sunrpc/xprtrdma/verbs.c     |   47 +++++++++++++++++++++++++++++-
>>> ---------
>>>   net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>>>   3 files changed, 36 insertions(+), 16 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c
>>> b/net/sunrpc/xprtrdma/rpc_rdma.c index 96ead52..400aa1b 100644
>>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>>> @@ -248,10 +248,6 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, 
>>> struct
>>> xdr_buf *target,
>>>       /* success. all failures return above */
>>>       req->rl_nchunks = nchunks;
>>>
>>> -    BUG_ON(nchunks == 0);
>>> -    BUG_ON((r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
>>> -           && (nchunks > 3));
>>> -
>>>       /*
>>>        * finish off header. If write, marshal discrim and nchunks.
>>>        */
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index 9372656..55fb09a 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -539,6 +539,11 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct
>>> sockaddr *addr, int memreg)
>>>                   __func__);
>>>               memreg = RPCRDMA_REGISTER;
>>>   #endif
>>> +        } else {
>>> +            /* Mind the ia limit on FRMR page list depth */
>>> +            ia->ri_max_frmr_depth = min_t(unsigned int,
>>> +                RPCRDMA_MAX_DATA_SEGS,
>>> +                devattr.max_fast_reg_page_list_len);
>>>           }
>>>           break;
>>>       }
>>> @@ -659,24 +664,42 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct
>>> rpcrdma_ia *ia,
>>>       ep->rep_attr.srq = NULL;
>>>       ep->rep_attr.cap.max_send_wr = cdata->max_requests;
>>>       switch (ia->ri_memreg_strategy) {
>>> -    case RPCRDMA_FRMR:
>>> +    case RPCRDMA_FRMR: {
>>> +        int depth = 7;
>>> +
>>>           /* Add room for frmr register and invalidate WRs.
>>>            * 1. FRMR reg WR for head
>>>            * 2. FRMR invalidate WR for head
>>> -         * 3. FRMR reg WR for pagelist
>>> -         * 4. FRMR invalidate WR for pagelist
>>> +         * 3. N FRMR reg WRs for pagelist
>>> +         * 4. N FRMR invalidate WRs for pagelist
>>>            * 5. FRMR reg WR for tail
>>>            * 6. FRMR invalidate WR for tail
>>>            * 7. The RDMA_SEND WR
>>>            */
>>> -        ep->rep_attr.cap.max_send_wr *= 7;
>>> +
>>> +        /* Calculate N if the device max FRMR depth is smaller than
>>> +         * RPCRDMA_MAX_DATA_SEGS.
>>> +         */
>>> +        if (ia->ri_max_frmr_depth < RPCRDMA_MAX_DATA_SEGS) {
>>> +            int delta = RPCRDMA_MAX_DATA_SEGS -
>>> +                    ia->ri_max_frmr_depth;
>>> +
>>> +            do {
>>> +                depth += 2; /* FRMR reg + invalidate */
>>> +                delta -= ia->ri_max_frmr_depth;
>> If ia->ri_max_frmr_depth is = 0. This loop becomes infinite loop.
>>
>>> +            } while (delta > 0);
>>> +
>>> +        }
>>> +        ep->rep_attr.cap.max_send_wr *= depth;
>>>           if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr) {
>>> -            cdata->max_requests = devattr.max_qp_wr / 7;
>>> +            cdata->max_requests = devattr.max_qp_wr / depth;
>>>               if (!cdata->max_requests)
>>>                   return -EINVAL;
>>> -            ep->rep_attr.cap.max_send_wr = cdata-
>>>> max_requests * 7;
>>> +            ep->rep_attr.cap.max_send_wr = cdata-
>>>> max_requests *
>>> +                               depth;
>>>           }
>>>           break;
>>> +    }
>>>       case RPCRDMA_MEMWINDOWS_ASYNC:
>>>       case RPCRDMA_MEMWINDOWS:
>>>           /* Add room for mw_binds+unbinds - overkill! */ @@ -
>>> 1043,16 +1066,16 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf,
>>> struct rpcrdma_ep *ep,
>>>       case RPCRDMA_FRMR:
>>>           for (i = buf->rb_max_requests * RPCRDMA_MAX_SEGS; i; i--
>>> ) {
>>>               r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
>>> -
>>> RPCRDMA_MAX_SEGS);
>>> +                        ia->ri_max_frmr_depth);
>>>               if (IS_ERR(r->r.frmr.fr_mr)) {
>>>                   rc = PTR_ERR(r->r.frmr.fr_mr);
>>>                   dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
>>>                       " failed %i\n", __func__, rc);
>>>                   goto out;
>>>               }
>>> -            r->r.frmr.fr_pgl =
>>> -                ib_alloc_fast_reg_page_list(ia->ri_id-
>>>> device,
>>> -
>>> RPCRDMA_MAX_SEGS);
>>> +            r->r.frmr.fr_pgl = ib_alloc_fast_reg_page_list(
>>> +                        ia->ri_id->device,
>>> +                        ia->ri_max_frmr_depth);
>>>               if (IS_ERR(r->r.frmr.fr_pgl)) {
>>>                   rc = PTR_ERR(r->r.frmr.fr_pgl);
>>>                   dprintk("RPC:       %s: "
>>> @@ -1498,8 +1521,8 @@ rpcrdma_register_frmr_external(struct
>>> rpcrdma_mr_seg *seg,
>>>       seg1->mr_offset -= pageoff;    /* start of page */
>>>       seg1->mr_len += pageoff;
>>>       len = -pageoff;
>>> -    if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>>> -        *nsegs = RPCRDMA_MAX_DATA_SEGS;
>>> +    if (*nsegs > ia->ri_max_frmr_depth)
>>> +        *nsegs = ia->ri_max_frmr_depth;
>>>       for (page_no = i = 0; i < *nsegs;) {
>>>           rpcrdma_map_one(ia, seg, writing);
>>>           pa = seg->mr_dma;
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> b/net/sunrpc/xprtrdma/xprt_rdma.h index cc1445d..98340a3 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -66,6 +66,7 @@ struct rpcrdma_ia {
>>>       struct completion    ri_done;
>>>       int            ri_async_rc;
>>>       enum rpcrdma_memreg    ri_memreg_strategy;
>>> +    unsigned int        ri_max_frmr_depth;
>>>   };
>>>
>>>   /*
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe 
>>> linux-rdma" in the
>>> body of a message to majordomo@vger.kernel.org More majordomo info at
>>> http://vger.kernel.org/majordomo-info.html
>> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z� ��h����&�� 
>> �G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�mml==
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

