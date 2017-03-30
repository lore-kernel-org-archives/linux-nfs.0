Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:37753 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933334AbdC3MGl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2017 08:06:41 -0400
Date: Thu, 30 Mar 2017 05:06:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 01/13] svcrdma: Move send_wr to svc_rdma_op_ctxt
Message-ID: <20170330120639.GA31144@infradead.org>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
 <20170327134802.5585.70150.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170327134802.5585.70150.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	svc_rdma_build_send_wr(ctxt, sge_no);
> +	send_wr = &ctxt->send_wr;
> +	if (inv_rkey) {
> +		send_wr->opcode = IB_WR_SEND_WITH_INV;
> +		send_wr->ex.invalidate_rkey = inv_rkey;
> +	}

Seems a bit odd to overwrite the work that svc_rdma_build_send_wr in
the caller.  I would propbably add this work to svc_rdma_build_send_wr.

Also any reason svc_rdma_build_send_wr can't call svc_rdma_send
directly (although it would probably need a new name then)?
