Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34548 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbbGZQuc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 12:50:32 -0400
Date: Sun, 26 Jul 2015 09:50:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 04/15] xprtrdma: Don't fall back to PHYSICAL memory
 registration
Message-ID: <20150726165031.GB9273@infradead.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190302.10997.86410.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150720190302.10997.86410.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:03:02PM -0400, Chuck Lever wrote:
> PHYSICAL memory registration uses a single rkey for all of the
> client's memory, thus is insecure. It is still useful in some cases
> for testing.
> 
> Retain the ability to select PHYSICAL memory registration capability
> via /proc/sys/sunrpc/rdma_memreg_strategy, but don't fall back to it
> if the HCA does not support FRWR or FMR.
> 
> This means amso1100 no longer works out of the box with NFS/RDMA.
> When using amso1100 HCAs, set the memreg_strategy sysctl to 6 before
> performing NFS/RDMA mounts.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
