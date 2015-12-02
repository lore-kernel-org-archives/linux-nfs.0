Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35771 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717AbbLBM1q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 07:27:46 -0500
Date: Wed, 2 Dec 2015 04:27:45 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>,
        santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
Message-ID: <20151202122745.GB28278@infradead.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com>
 <20151124065225.GB29141@infradead.org>
 <20151124071215.GC23597@obsidianresearch.com>
 <AE86B182-6000-4437-8502-9D2C5EC3B09D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AE86B182-6000-4437-8502-9D2C5EC3B09D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 01, 2015 at 10:33:18AM -0500, Chuck Lever wrote:
> Oracle recently announced Sonoma, which is a SPARC CPU with
> an on-chip IB HCA. Oracle plans to publish an open-source
> GPL device driver that enables this HCA in Linux for SPARC.
> We???d eventually like to contribute it to the upstream
> Linux kernel.
> 
> At the moment, the device and driver support only FMR. As
> you might expect, Oracle needs it to work at least with
> in-kernel RDS. Thus we hope to see the life of in-kernel
> FMR extended for a bit to accommodate this new device.

Oh, that's pretty sad news.  I wonder what the engineers where smoking..
