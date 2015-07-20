Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48798 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755492AbbGTW0J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 18:26:09 -0400
Date: Mon, 20 Jul 2015 16:26:08 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Message-ID: <20150720222608.GA12005@obsidianresearch.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150720190311.10997.12636.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:03:11PM -0400, Chuck Lever wrote:
> +	iov->length = size;
> +	iov->lkey = ia->ri_have_dma_lkey ?
> +				ia->ri_dma_lkey : ia->ri_bind_mem->lkey;
> +	rb->rg_size = size;
> +	rb->rg_owner = NULL;
>  	return rb;

There is something odd looking about this..

ri_bind_mem is only setup in the RPCRDMA_ALLPHYSICAL and
RPCRDMA_MTHCAFMR cases.

RPCRDMA_FRMR doesn't set it up.

So this code in rpcrdma_alloc_regbuf is never called for the FRMR
case?

If yes, then, how is FRMR working? There is absolutely no reason to
use FRMR to register local send buffers, just use the global all
memory lkey...

If no, then that is an oops?

Jason
