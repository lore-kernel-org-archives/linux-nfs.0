Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42429 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcFVOFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 10:05:17 -0400
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <576A9AE6.4070500@grimberg.me>
Date: Wed, 22 Jun 2016 17:04:22 +0300
MIME-Version: 1.0
In-Reply-To: <20160620161200.10809.45762.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> +	/* This is overkill, but hardware requires that the
> +	 * PBL array begins at a properly aligned address and
> +	 * never occupies the last 8 bytes of a page.
> +	 */
> +	mr->pages = (__be64 *)get_zeroed_page(GFP_KERNEL);
> +	if (!mr->pages)
>   		return -ENOMEM;

Again, I'm not convinced that this is a better choice then allocating
the exact needed size as dma coherent, but given that the dma coherent
allocations are always page aligned I wander if it's not the same
effect...

In any event, we can move forward with this for now:

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
