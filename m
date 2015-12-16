Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32858 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbbLPN6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 08:58:03 -0500
Received: by mail-lf0-f47.google.com with SMTP id p203so30013343lfa.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2015 05:58:01 -0800 (PST)
Subject: Re: [PATCH v3 06/11] xprtrdma: Add ro_unmap_sync method for FRWR
To: Chuck Lever <chuck.lever@oracle.com>, anna.schumaker@netapp.com
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
 <20151214211827.16295.76338.stgit@manet.1015granger.net>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56716DE4.8080403@dev.mellanox.co.il>
Date: Wed, 16 Dec 2015 15:57:56 +0200
MIME-Version: 1.0
In-Reply-To: <20151214211827.16295.76338.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> +static void
> +__frwr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
> +		 int rc)
> +{
> +	struct ib_device *device = r_xprt->rx_ia.ri_device;
> +	struct rpcrdma_mw *mw = seg->rl_mw;
> +	int nsegs = seg->mr_nsegs;
> +
> +	seg->rl_mw = NULL;
> +
> +	while (nsegs--)
> +		rpcrdma_unmap_one(device, seg++);

Chuck, shouldn't this be replaced with ib_dma_unmap_sg?

Sorry for the late comment (Didn't find enough time to properly
review this...)
