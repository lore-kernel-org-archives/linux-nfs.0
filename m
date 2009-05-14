From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Thu, 14 May 2009 14:26:09 -0400
Message-ID: <1242325569.6560.27.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	 <1242258338.5407.244.camel@heimdal.trondhjem.org>
	 <20090514175500.GB5675@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49914 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbZENS0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 May 2009 14:26:16 -0400
In-Reply-To: <20090514175500.GB5675@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-14 at 13:55 -0400, J. Bruce Fields wrote:
> On Wed, May 13, 2009 at 07:45:38PM -0400, Trond Myklebust wrote:
> > On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
> > > Hi, netdev folks.  The summary here is:
> > > 
> > > A patch added in the 2.6.30 development cycle caused a performance
> > > regression in my NFS iozone testing.  The patch in question is the
> > > following:
> > > 
> > > commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> > > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > > Date:   Tue Oct 21 14:13:47 2008 -0400
> > > 
> > >     svcrpc: take advantage of tcp autotuning
> > >  
> > > which is also quoted below.  Using 8 nfsd threads, a single client doing
> > > 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
> > > KB/s under 2.6.30-rc4.  I also see more run to run variation under
> > > 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
> > > variation disappears (as does the performance regression) when reverting
> > > the above commit.
> > 
> > It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
> > function. I can see no reason why we should stop processing new incoming
> > RPC requests just because the send buffer happens to be 2/3 full. If we
> 
> I agree, the calculation doesn't look right.  But where do you get the
> 2/3 number from?

That's the sk_stream_wspace() vs. sk_stream_min_wspace() comparison.

> ...
> > @@ -964,23 +973,14 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
> >  	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
> >  	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
> >  	int required;
> > -	int wspace;
> > -
> > -	/*
> > -	 * Set the SOCK_NOSPACE flag before checking the available
> > -	 * sock space.
> > -	 */
> > -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > -	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
> > -	wspace = sk_stream_wspace(svsk->sk_sk);
> > -
> > -	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> > -		return 0;
> > -	if (required * 2 > wspace)
> > -		return 0;
> >  
> > -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	required = (atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg) * 2;
> > +	if (sk_stream_wspace(svsk->sk_sk) < required)
> 
> This calculation looks the same before and after--you've just moved the
> "*2" into the calcualtion of "required".  Am I missing something?  Maybe
> you meant to write:
> 
> 	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg * 2;
> 
> without the parentheses?

I wasn't trying to change that part of the calculation. I'm just
splitting out the stuff which has to do with TCP congestion (i.e. the
window size), and stuff which has to do with remaining socket buffer
space. I do, however, agree that we should probably drop that *2.

However there is (as usual) 'interesting behaviour' when it comes to
deferred requests. Their buffer space is already accounted for in the
'xpt_reserved' calculation, but they cannot get re-scheduled unless
svc_tcp_has_wspace() thinks it has enough free socket space for yet
another reply. Can you spell 'deadlock', children?

Trond

