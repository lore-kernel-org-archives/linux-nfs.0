Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34588 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbcDZUQQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:16:16 -0400
Subject: Re: [PATCH v2 13/18] xprtrdma: Refactor the FRWR recovery worker
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192234.3566.63698.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FCC8C.5040503@grimberg.me>
Date: Tue, 26 Apr 2016 23:16:12 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192234.3566.63698.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> +static void
> +__frwr_reset_and_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
> +{
> +	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
> +	struct rpcrdma_frmr *f = &mw->frmr;
> +	int rc;
> +
> +	rc = __frwr_reset_mr(ia, mw);
> +	ib_dma_unmap_sg(ia->ri_device, f->fr_sg, f->fr_nents, f->fr_dir);
> +	if (rc)
> +		return;
> +
> +	rpcrdma_put_mw(r_xprt, mw);
> +}
> +

If this is not being called from other sites I'd say just
do it in __frwr_recovery_worker instead of having it just bouncing
the call...
