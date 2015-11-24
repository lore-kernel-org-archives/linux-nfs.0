Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:41272 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbbKXHMV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 02:12:21 -0500
Date: Tue, 24 Nov 2015 00:12:15 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>, santosh.shilimkar@oracle.com
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
Message-ID: <20151124071215.GC23597@obsidianresearch.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com>
 <20151124065225.GB29141@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151124065225.GB29141@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2015 at 10:52:26PM -0800, Christoph Hellwig wrote:
> 
> So at lest for 4.5 we're unlikely to be able to get rid of it alone
> due to the RDS issue.  We'll then need performance numbers for mlx4,
> and figure out how much we care about mthca.

mthca is unfortunately very popular in the used market, it is very
easy to get cards, build a cheap test cluster, etc. :(

Jason
