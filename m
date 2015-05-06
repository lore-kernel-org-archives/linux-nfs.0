Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42235 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbbEFHda (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 03:33:30 -0400
Date: Wed, 6 May 2015 00:33:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150506073328.GA8244@infradead.org>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
 <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org>
 <55490886.4070502@talpey.com>
 <20150505191012.GA21164@infradead.org>
 <55492ED3.7000507@talpey.com>
 <20150505210627.GA5941@infradead.org>
 <554936E5.80607@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <554936E5.80607@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 05:32:21PM -0400, Tom Talpey wrote:
> >But that whole painpoint only existist for userspace ib verbs consumers.
> >And in-kernel consumer fits into the "pinned" or "wired" categegory,
> >as any local DMA requires it.
> 
> True, but I think there's a bit more to it. For example, the buffer
> cache is pinned, but the data on the page isn't dedicated to an i/o,
> it's shared among file-layer stuff. Of course, a file-layer RDMA
> protocol needs to play by those rules, but I'll use it as a warning
> that it's not always simple.

Actually there is no buffer cache anymore, and the page cache now
keeps pages under writeback stable, that is doesn't allow modifications
while the page is written back.

Not that it matters, as both direct I/O for filesystems or SG_IO for
block devices allows I/O to user pages that can be modified while
dma is in progress.  So pretty much every in kernel user has to deal
with this case, maybe with the exception of network protocols.

> >The contiguous requirements isn't something we can alway guarantee.
> >While a lot of I/O will have that form the form where there are holes
> >can happen, although it's not common.
> 
> Yeah, and the important takeaway is that a memory registration API
> can't hide this - meaning, the upper layer needs to address it (hah!).
> Often, once an upper layer has to do this, it can do better by doing
> it itself. But that's perhaps too philosophical here. Let me just
> say that transparency has proved to be the enemy of performance.

Yes, I don't think that something that should be worked around at
an API at a low level.

