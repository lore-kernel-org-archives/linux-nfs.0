Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932255AbdJZPm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Oct 2017 11:42:58 -0400
Date: Thu, 26 Oct 2017 11:42:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: how to use XPT_CLOSE
Message-ID: <20171026154253.GC12017@parsley.fieldses.org>
References: <4CCAF89B-8843-45C2-8E8A-89CF42FD25FF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CCAF89B-8843-45C2-8E8A-89CF42FD25FF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 25, 2017 at 04:03:07PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> svc_rdma_transport.c :: svc_rdma_wc_send has this snippet:
> 
>  355         ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
>  356         svc_rdma_unmap_dma(ctxt);
>  357         svc_rdma_put_context(ctxt, 1);
>  358 
>  359         if (unlikely(wc->status != IB_WC_SUCCESS)) {
>  360                 set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>  361                 if (wc->status != IB_WC_WR_FLUSH_ERR)
>  362                         pr_err("svcrdma: Send: %s (%u/0x%x)\n",
>  363                                ib_wc_status_msg(wc->status),
>  364                                wc->status, wc->vendor_err);
>  365         }
> 
> This releases resources that were used to send a Reply. It's
> the last thing that is done for each RPC.
> 
> I'm wondering about the set_bit(XPT_CLOSE). In order to
> guarantee that the svc layer will see this bit, should this
> code also call svc_enqueue_xprt?
> 
> There are several other places in the svc_rdma code that set
> XPT_CLOSE but do not also enqueue the xprt.

Yes, that sounds wrong to me.  You may just want to check to make sure
that's not already done later by callers?  (In which case it might still
be worth a comment here.)

I can't think of any reason *not* to call svc_xprt_enqueue.  It should
be safe to call from almost any context.

--b.
