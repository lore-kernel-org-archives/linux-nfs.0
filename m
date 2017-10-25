Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19907 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdJYUDP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Oct 2017 16:03:15 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: how to use XPT_CLOSE
Date: Wed, 25 Oct 2017 16:03:07 -0400
Message-Id: <4CCAF89B-8843-45C2-8E8A-89CF42FD25FF@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

svc_rdma_transport.c :: svc_rdma_wc_send has this snippet:

 355         ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
 356         svc_rdma_unmap_dma(ctxt);
 357         svc_rdma_put_context(ctxt, 1);
 358 
 359         if (unlikely(wc->status != IB_WC_SUCCESS)) {
 360                 set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
 361                 if (wc->status != IB_WC_WR_FLUSH_ERR)
 362                         pr_err("svcrdma: Send: %s (%u/0x%x)\n",
 363                                ib_wc_status_msg(wc->status),
 364                                wc->status, wc->vendor_err);
 365         }

This releases resources that were used to send a Reply. It's
the last thing that is done for each RPC.

I'm wondering about the set_bit(XPT_CLOSE). In order to
guarantee that the svc layer will see this bit, should this
code also call svc_enqueue_xprt?

There are several other places in the svc_rdma code that set
XPT_CLOSE but do not also enqueue the xprt.

Thoughts?


--
Chuck Lever



