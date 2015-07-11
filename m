Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45571 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbbGKKe2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 06:34:28 -0400
Date: Sat, 11 Jul 2015 03:34:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 04/12] xprtrdma: Remove last ib_reg_phys_mr() call site
Message-ID: <20150711103428.GD14741@infradead.org>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204218.26247.67243.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150709204218.26247.67243.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 04:42:18PM -0400, Chuck Lever wrote:
> All HCA providers have an ib_get_dma_mr() verb. Thus
> rpcrdma_ia_open() will either grab the device's local_dma_key if one
> is available, or it will call ib_get_dma_mr() which is a 100%
> guaranteed fallback. There is never any need to use the
> ib_reg_phys_mr() code path in rpcrdma_register_internal(), so it can
> be removed.

Can you also send a follow-on to remove ib_reg_phys_mr entirely from
all core (= non-staging) code?

