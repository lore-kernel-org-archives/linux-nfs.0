Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44322 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab3AYVM5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2013 16:12:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Myers <bpm@sgi.com>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Olga Kornievskaia <aglo@citi.umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jim Rees <rees@umich.edu>
Subject: RE: sunrpc: socket buffer size tuneable
Date: Fri, 25 Jan 2013 21:12:55 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91833BF5A@sacexcmbx05-prd.hq.netapp.com>
References: <20130125192935.GA32470@sgi.com>
 <20130125202107.GD29596@fieldses.org> <20130125203507.GW30652@sgi.com>
In-Reply-To: <20130125203507.GW30652@sgi.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Ben Myers
> Sent: Friday, January 25, 2013 3:35 PM
> To: J. Bruce Fields
> Cc: Olga Kornievskaia; linux-nfs@vger.kernel.org; Jim Rees
> Subject: Re: sunrpc: socket buffer size tuneable
> 
> Hey Bruce,
> 
> On Fri, Jan 25, 2013 at 03:21:07PM -0500, J. Bruce Fields wrote:
> > > On Fri, Jan 25, 2013 at 01:29:35PM -0600, Ben Myers wrote:
> > > > Hey Bruce & Jim & Olga,
> > > >
> > > > On Fri, Jan 25, 2013 at 02:16:20PM -0500, Jim Rees wrote:
> > > > > J. Bruce Fields wrote:
> > > > >
> > > > >   On Thu, Jan 24, 2013 at 06:59:30PM -0600, Ben Myers wrote:
> > > > >   > At 1020 threads the send buffer size wraps and becomes negative
> causing
> > > > >   > the nfs server to grind to a halt.  Rather than setting bufsize based
> > > > >   > upon the number of nfsd threads, make the buffer sizes tuneable
> via
> > > > >   > module parameters.
> > > > >   >
> > > > >   > Set the buffer sizes in terms of the number of rpcs you want to fit
> into
> > > > >   > the buffer.
> > > > >
> > > > >   From private communication, my understanding is that the original
> > > > >   problem here was due to memory pressure forcing the tcp send
> buffer size
> > > > >   below the size required to hold a single rpc.
> > > >
> > > > Years ago I did see wrapping of the buffer size when tcp was used
> > > > with many threads.  Today's problem is timeouts on a cluster with
> > > > a heavy read workload... and I seem to remember seeing that the
> > > > send buffer size was too small.
> > > >
> > > > >   In which case the important variable here is lock_bufsize, as that's
> > > > >   what prevents the buffer size from going too low.
> > > >
> > > > I tested removing the lock of bufsize and did hit the timeouts, so
> > > > the overflow is starting to look less relevant.  I will test your
> > > > minimal overflow fix to see if this is the case.
> > >
> > > The minimal overflow fix did not resolve the timeouts.
> >
> > OK, thanks, that's expected.
> >
> > > I will test with this to see if it resolves the timeouts:
> >
> > And I'd expect that to do the job--
> 
> It did.
> 
> > but at the expense of some tcp
> > bandwidth.  So you end up needing your other module parameters to get
> > the performance back.
> 
> I didn't put a timer on it, so I'm not sure.  Any ideas for an alternate fix?
> 

Why is it not sufficient to clamp the TCP values of 'snd' and 'rcv' using sysctl_tcp_wmem/sysctl_tcp_rmem?
...and clamp the UDP values using sysctl_[wr]mem_min/sysctl_[wr]mem_max?.

Cheers
  Trond
