Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42937 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbcFVQVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 12:21:42 -0400
Date: Wed, 22 Jun 2016 09:20:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Leon Romanovsky <leon@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages()
 array allocator
Message-ID: <20160622162051.GA23929@infradead.org>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
 <20160620161200.10809.45762.stgit@manet.1015granger.net>
 <576A9AE6.4070500@grimberg.me>
 <A9F49204-8E84-4B58-BAA4-5B4B360FD22F@oracle.com>
 <20160622155003.GI9762@leon.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160622155003.GI9762@leon.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, Jun 22, 2016 at 06:50:03PM +0300, Leon Romanovsky wrote:
> According to [1] dma_alloc_coherent doesn't allocate from pool, but
> calls to the __get_free_page().

Use the source luke!  dma_alloc_coherent implementations vary widely.
While some indeed use alloc_pages there are various complications,
especially on non-x86 architectures, or if the dma mask is not the full
64 bits allowed.

> "A DMA pool is an allocation mechanism for small, coherent DMA mappings.
> Mappings obtained from dma_alloc_coherent may have a minimum size of one
> page."

Just because it's not using the dma_pool_* API it could allocate from
various resource constrained pools.  A trivial example for that is
the swiotlb used for address limited devices if no hardware IOMMU
is available, but other architectures have even more complicated
implementations by default.  Take a look at
arch/arm/mm/dma-mapping.c:__dma_alloc() for fun.
