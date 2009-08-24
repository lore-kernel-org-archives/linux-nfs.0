From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] SUNRPC: Fix the TCP write space reservations for
	deferred requests
Date: Mon, 24 Aug 2009 17:32:13 -0400
Message-ID: <20090824213213.GC8532@fieldses.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org> <20090518214756.786.33956.stgit@heimdal.trondhjem.org> <20090619222344.GB32083@fieldses.org> <1245534248.5182.45.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Moyer <jmoyer@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbZHXVcM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 17:32:12 -0400
In-Reply-To: <1245534248.5182.45.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 20, 2009 at 05:44:08PM -0400, Trond Myklebust wrote:
> On Fri, 2009-06-19 at 18:23 -0400, J. Bruce Fields wrote:
> > On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
> > > Ensure that deferred requests are accounted for correctly by the write
> > > space reservation mechanism. In order to avoid double counting, remove the
> > > reservation when we defer the request, and save any calculated value, so
> > > that we can restore it when the request is requeued.
> > 
> > I like that it does the addition to xpt_reserved in just one place
> > instead of two, and carrying over the reserved_space is nice, but I
> > don't understand the "double accounting" comment--where exactly is
> > something counted twice?
> 
> Correct me if I'm wrong, but as far as I can see, the current code bumps
> xpt_reserved every time you call svc_xprt_enqueue() irrespective of
> whether or not you are going to process a new RPC call, or whether you
> are processing a deferred call.
> 
> In the latter case, there doesn't appear to be any code that subtracts
> from xpt_reserved prior to the re-enqueue process, hence my belief that
> we are double counting those events...

Sorry for the slow response!  The original request is
dropped--cache_check() returns -EAGAIN on queueing up the deferred
request, the caller returns back to svc_process, and the reservation is
removed from xpt_reserved by svc_drop().

And a new reservation isn't made until the deferred request is
revisited, at which point it's treated as any new request received from
a socket would be.

Your patch would instead have the server keep that reservation while the
request is deferred.

I'm not really sure how to decide which is better.

--b.
