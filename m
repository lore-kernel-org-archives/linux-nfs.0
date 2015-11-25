Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52390 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbbKYJAM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 04:00:12 -0500
Date: Wed, 25 Nov 2015 01:00:09 -0800
From: Christoph Hellwig <hch@infradead.org>
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Cc: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
Message-ID: <20151125090009.GA11255@infradead.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com>
 <20151124065225.GB29141@infradead.org>
 <5654DC7A.7080807@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5654DC7A.7080807@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2015 at 01:54:02PM -0800, santosh shilimkar wrote:
> As already indicated to Sagi [1], RDS IB FR support is work in
> progress and I was hoping to get it ready for 4.5. There are few
> issues we found with one of the HCA and hence the progress
> slowed down. Looking at where we are, 4.6 merge window seems
> to be realistic for me to get RDS FR support.

Ok.

> Now on the iWARP transport itself, it has been bit tough because
> of lack of hardware to tests. I have been requesting test(s) in
> previous RDS patches and haven't seen any interest so far. If
> this continues to be the trend, I might as well get rid of
> RDS iWARP support after couple of merge windows.

I'd say drop the current iWarp transport if it's not testable.  The
only real difference between IB and iWarp is the needed to create
a MR for the RDMA READ sink, and we're much better of adding that into
the current IB transport if new iWarp users show up.
