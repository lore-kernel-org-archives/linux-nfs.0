Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47707 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932137AbdJZQhQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Oct 2017 12:37:16 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: how to use XPT_CLOSE
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171026154253.GC12017@parsley.fieldses.org>
Date: Thu, 26 Oct 2017 12:37:11 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6AD20205-6A27-4C4F-A6AA-610FA8BD277C@oracle.com>
References: <4CCAF89B-8843-45C2-8E8A-89CF42FD25FF@oracle.com> <20171026154253.GC12017@parsley.fieldses.org>
To: Bruce Fields <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 26, 2017, at 11:42 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> 
> On Wed, Oct 25, 2017 at 04:03:07PM -0400, Chuck Lever wrote:
>> Hi Bruce-
>> 
>> svc_rdma_transport.c :: svc_rdma_wc_send has this snippet:
>> 
>> 355         ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
>> 356         svc_rdma_unmap_dma(ctxt);
>> 357         svc_rdma_put_context(ctxt, 1);
>> 358 
>> 359         if (unlikely(wc->status != IB_WC_SUCCESS)) {
>> 360                 set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>> 361                 if (wc->status != IB_WC_WR_FLUSH_ERR)
>> 362                         pr_err("svcrdma: Send: %s (%u/0x%x)\n",
>> 363                                ib_wc_status_msg(wc->status),
>> 364                                wc->status, wc->vendor_err);
>> 365         }
>> 
>> This releases resources that were used to send a Reply. It's
>> the last thing that is done for each RPC.
>> 
>> I'm wondering about the set_bit(XPT_CLOSE). In order to
>> guarantee that the svc layer will see this bit, should this
>> code also call svc_enqueue_xprt?
>> 
>> There are several other places in the svc_rdma code that set
>> XPT_CLOSE but do not also enqueue the xprt.
> 
> Yes, that sounds wrong to me.  You may just want to check to make sure
> that's not already done later by callers?

The above sample is the last code that executes as part of
an RPC. If the client sends no more requests, then I can't
see where there is another opportunity to invoke
svc_enqueue_xprt. I suspect many of the other sites that
set XPT_CLOSE are similar.

Was also wondering if svc_xprt_close would be a better
choice here.


> (In which case it might still be worth a comment here.)
> 
> I can't think of any reason *not* to call svc_xprt_enqueue.  It should
> be safe to call from almost any context.

These completion handlers are now running in process
context (ib_poll workqueue), thankfully.


--
Chuck Lever



