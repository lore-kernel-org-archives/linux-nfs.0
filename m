From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Fri, 15 May 2009 17:37:43 -0400
Message-ID: <20090515213743.GE26389@fieldses.org>
References: <20090511081415.GL4694@kernel.dk> <x49skjb21b7.fsf@segfault.boston.devel.redhat.com> <20090511165826.GG4694@kernel.dk> <x494ovp4r51.fsf@segfault.boston.devel.redhat.com> <20090512204433.7eb69075.akpm@linux-foundation.org> <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com> <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com> <1242258338.5407.244.camel@heimdal.trondhjem.org> <20090514175500.GB5675@fieldses.org> <1242325569.6560.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51392 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbZEOViE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2009 17:38:04 -0400
In-Reply-To: <1242325569.6560.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 14, 2009 at 02:26:09PM -0400, Trond Myklebust wrote:
> On Thu, 2009-05-14 at 13:55 -0400, J. Bruce Fields wrote:
> > On Wed, May 13, 2009 at 07:45:38PM -0400, Trond Myklebust wrote:
> > > On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
> > > > Hi, netdev folks.  The summary here is:
> > > > 
> > > > A patch added in the 2.6.30 development cycle caused a performance
> > > > regression in my NFS iozone testing.  The patch in question is the
> > > > following:
> > > > 
> > > > commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> > > > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > > > Date:   Tue Oct 21 14:13:47 2008 -0400
> > > > 
> > > >     svcrpc: take advantage of tcp autotuning
> > > >  
> > > > which is also quoted below.  Using 8 nfsd threads, a single client doing
> > > > 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
> > > > KB/s under 2.6.30-rc4.  I also see more run to run variation under
> > > > 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
> > > > variation disappears (as does the performance regression) when reverting
> > > > the above commit.
> > > 
> > > It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
> > > function. I can see no reason why we should stop processing new incoming
> > > RPC requests just because the send buffer happens to be 2/3 full. If we
> > 
> > I agree, the calculation doesn't look right.  But where do you get the
> > 2/3 number from?
> 
> That's the sk_stream_wspace() vs. sk_stream_min_wspace() comparison.

Oh, I see, so looking at their implementations,

	sk_stream_wspace(sk) < sk_stream_min_wspace(sk)

is equivalent to sk_wmem_queued/2 < sk_->sndbuf - sk_wmem_queued, or
sk_wmem_queued < 2/3 sndbuf, got it.  I didn't understand that the point
of this patch was just to do that calculation around--now I see.--b.
