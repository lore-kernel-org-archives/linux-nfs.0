Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:45215 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbbEFQiP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 12:38:15 -0400
Date: Wed, 6 May 2015 10:38:03 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Tom Talpey <tom@talpey.com>, Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150506163803.GB11331@obsidianresearch.com>
References: <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org>
 <55490886.4070502@talpey.com>
 <20150505191012.GA21164@infradead.org>
 <55492ED3.7000507@talpey.com>
 <20150505210627.GA5941@infradead.org>
 <554936E5.80607@talpey.com>
 <20150505223855.GA7696@obsidianresearch.com>
 <5549BC33.30905@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5549BC33.30905@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 09:01:07AM +0200, Bart Van Assche wrote:
> On 05/06/15 00:38, Jason Gunthorpe wrote:
> >Heck, on modern systems 100% of these requirements can be solved just
> >by using the IOMMU. No need for the HCA at all. (HCA may be more
> >performant, of course)
> 
> Hello Jason,
> 
> Any performance tests I have run so far with the IOMMU enabled show
> much worse results than the same test with the IOMMU disabled. The
> perf tool learned me that this performance difference is due to lock
> contention caused by the IOMMU kernel code. I have not yet tried to
> verify whether this is an implementation issue or something
> fundamental.

I'm not surprised, I think that is well known.

Just to be clear I'm not saying we should rely on the IOMMU, or even
implement anything that uses it - but as a thought exercise, the fact
we could implement a page list API entirely with the dumbest HCA and
the IOMMU suggests strongly to me it is a sane API direction to look
at.

If you did have a dumb HCA, using the IOMMU is probably alot faster
that doing a heavy MR registration or doing operations 'page at a
time'. Which would be slower than using a smart HCA with the
IOMMU turned off, for that work load.

Jason
