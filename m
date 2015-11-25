Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37389 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbbKYT2j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2015 14:28:39 -0500
Date: Wed, 25 Nov 2015 12:28:24 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sagi Grimberg <sagig@mellanox.com>
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
Message-ID: <20151125192824.GD3223@obsidianresearch.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com>
 <20151124065225.GB29141@infradead.org>
 <5654DC7A.7080807@oracle.com>
 <20151125090009.GA11255@infradead.org>
 <5655EB40.8070508@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5655EB40.8070508@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2015 at 09:09:20AM -0800, santosh shilimkar wrote:
> >I'd say drop the current iWarp transport if it's not testable.  The
> >only real difference between IB and iWarp is the needed to create
> >a MR for the RDMA READ sink, and we're much better of adding that into
> >the current IB transport if new iWarp users show up.
> 
> Agree. I will probably do it along with RDS IB FR support in 4.6

Great news!

Jason
