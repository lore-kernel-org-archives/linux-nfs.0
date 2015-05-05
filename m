Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42896 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759408AbbEERZl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 13:25:41 -0400
Date: Tue, 5 May 2015 10:25:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150505172540.GA19442@infradead.org>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
 <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 12:04:00PM -0400, Chuck Lever wrote:
> > Just curious if you ever though of moving this into the generic
> > rdma layer?
> 
> Not really. The new files are really just shims that adapt the RPC/RDMA
> transport to memory registration verbs. There?s only a few hundred lines
> per registration mode, and it?s all fairly specific to RPC/RDMA.

While it's using RPC/RDMA specific data structures it basically
abstracts out the action of mapping a number of pages onto the rdma
hardware.   There isn't a whole lot of interaction with the actual
sunrpc layer except for a few hardcoded limits.

Btw, this is not a critique of the code, it's an obvious major
improvement of what was there before, it justs seems like it would be
nice to move it up to a higher layer.

> > And from I see we litterly dont use them much different from the generic
> > dma mapping API helpers (at a very high level) so it seems it should
> > be easy to move a slightly expanded version of your API to the core
> > code.
> 
> IMO FRWR is the only registration mode that has legs for the long term,
> and is specifically designed for storage.
> 
> If you are not working on a legacy piece of code that has to support
> older HCAs, why not stay with FRWR?

The raw FRWR API seems like an absolute nightmare, and I'm bound to
get it wrong at first :)  This is only half joking, but despite that
it's the first target for sure.  It's just very frustrating that there
is no usable common API.
