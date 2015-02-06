Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:38217 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754276AbbBFQVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Feb 2015 11:21:12 -0500
Date: Fri, 6 Feb 2015 11:21:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150206162110.GC29783@fieldses.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
 <20150206115456.GA28915@infradead.org>
 <20150206160848.GA29783@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150206160848.GA29783@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 06, 2015 at 11:08:48AM -0500, J. Bruce Fields wrote:
> On Fri, Feb 06, 2015 at 03:54:56AM -0800, Christoph Hellwig wrote:
> > On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
> > > > The problem is that the typical case of all data won't use splice
> > > > every with your patches as the 4.2 client will always send a READ_PLUS.
> > > > 
> > > > So we'll have to find a way to use it where it helps.  While we might be
> > > > able to add some hacks to only use splice for the first segment I guess
> > > > we just need to make the splice support generic enough in the long run.
> > > > 
> > > 
> > > I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
> > 
> > You could also elect to never return more than one data segment as a
> > start:
> > 
> >    In all situations, the
> >    server may choose to return fewer bytes than specified by the client.
> >    The client needs to check for this condition and handle the
> >    condition appropriately.
> 
> Yeah, I think that was more-or-less what Anna's first attempt did and I
> said "what if that means more round trips"?  The client can't anticipate
> the short reads so it can't make up for this with parallelism.
> 
> > But doing any of these for a call that's really just an optimization
> > soudns odd.  I'd really like to see an evaluation of the READ_PLUS
> > impact on various workloads before offering it.
> 
> Yes, unfortunately I don't see a way to make this just an obvious win.

Actually, the other fallback is to return a single data segment, which
shouldn't be any worse than READ as long as the client assumes that's
the normal case.

So as a first pass another idea might be to return a hole *only* if it
covers the entire requested range and otherwise represent the result as
a single data segment?

(Or you could imagine various ways to make it more complicated: e.g.
also allow 1 data segment + 1 hole, also representable with an xdr buf
and without screwing up the client's alignment expectations.  Or allow
additional data segments if they're small enough that we think the
copying cost would be negligible.)

And turn off READ_PLUS over RDMA, but that seems like something that
should be fixed in the spec.

--b.

> 
> (Is there any way we could make it so with better protocol?  Maybe RDMA
> could help get the alignment right in multiple-segment cases?  But then
> I think there needs to be some sort of language about RDMA, or else
> we're stuck with:
> 
> 	https://tools.ietf.org/html/rfc5667#section-5
> 
> which I think forces us to return READ_PLUS data inline, another
> possible READ_PLUS regression.)
> 
> Anyway, ignoring RDMA, I guess the interesting questions to me are:
> 
> 	- How much does READ_PLUS actually help in the cases it was
> 	  meant to?  Perhaps create and age a VM image somehow, and then
> 	  time a read of the entire image?
> 	- What are the worst-case regressions?  Read a large file with a
> 	  lot of small holes and measure time and cpu usage?
> 
> --b.
