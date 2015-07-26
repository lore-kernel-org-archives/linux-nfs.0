Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52004 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856AbbGZSvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 14:51:04 -0400
Date: Sun, 26 Jul 2015 11:51:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 06/15] xprtrdma: Clean up rpcrdma_ia_open()
Message-ID: <20150726185101.GA27309@infradead.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190320.10997.40165.stgit@manet.1015granger.net>
 <20150726165337.GC9273@infradead.org>
 <B8761105-FE4E-4DD4-8E3D-77F30B170ADD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B8761105-FE4E-4DD4-8E3D-77F30B170ADD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 26, 2015 at 02:21:23PM -0400, Chuck Lever wrote:
> No, this patch is not strictly needed in 4.3, but my read of
> Jason?s series is that he does not touch xprtrdma. I don?t
> believe there will be a merge conflict.
> 
> The goal of this patch is to move xprtrdma forward so it will
> be straightforward to use pd->local_dma_key for RPC send and
> receive buffers. That?s a change that can be added after both
> this patch and Jason?s series is merged.
> 
> I prefer keeping this patch separate, because that makes it
> simpler to review and test this refactor. I don?t see a reason
> to delay it, but I can do that if it is needed.

You're right, Jason didn't touch xprtrdma. Sorry for the noise.
