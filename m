From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: kernel hacker's pub night
Date: Thu, 26 Jun 2008 17:22:14 -0400
Message-ID: <20080626212214.GD13293@fieldses.org>
References: <OFA5778CCB.84AF3576-ON65257474.0027EF21-65257474.00283248@in.ibm.com> <62137472-FF31-40A2-904D-A9CC2C76B032@oracle.com> <20080626175522.GA10593@fieldses.org> <76bd70e30806261405g9357c6fg51b973ff076ee78b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37605 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbYFZVW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jun 2008 17:22:28 -0400
In-Reply-To: <76bd70e30806261405g9357c6fg51b973ff076ee78b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2008 at 05:05:44PM -0400, Chuck Lever wrote:
> On Thu, Jun 26, 2008 at 1:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Jun 26, 2008 at 01:42:58PM -0400, Chuck Lever wrote:
> >> On Jun 26, 2008, at 3:19 AM, Krishna Kumar2 wrote:
> >>> Benny Halevy <bhalevy@panasas.com> wrote on 06/23/2008 06:10:40 PM:
> >>>
> >>>> Apparently the file is cached.  You needed to restart nfs
> >>>> and remount the file system to make sure it isn't before reading it.
> >>>> Or, you can create a file larger than your host's cache size so
> >>>> when you write (or read) it sequentially, its tail evicts its head
> >>>> out of the cache.  This is a less reliable method, yet creating a
> >>>> file about 25% larger than the host's memory size should work for
> >>>> you.
> >>>
> >>> I did a umount of all filesystems and restart NFS before testing. Here
> >>> is the result:
> >>>
> >>> Local:
> >>>      Read:  69.5 MB/s
> >>>      Write: 70.0 MB/s
> >>> NFS of same FS mounted loopback on same system:
> >>>      Read:  29.5 MB/s  (57% drop)
> >>>      Write: 27.5 MB/s  (60% drop)
> >>>
> >>> The drops seems exceedingly high. How can I figure out the source of
> >>> the
> >>> problem? Even if it is as general as to be able to state: "Problem is
> >>> in
> >>> the NFS client code" or "Problem is in the NFS server code", or
> >>> "Problem
> >>> can be mitigated by tuning" :-)
> >>
> >> It's hard to say what might be the problem just by looking at
> >> performance results.
> >>
> >> You can look at client-side NFS and RPC performance metrics using some
> >> prototype Python tools that were just added to nfs-utils.  The scripts
> >> themselves can be downloaded from:
> >>
> >>    http://oss.oracle.com/~cel/Linux-2.6/2.6.25
> >>
> >> but unfortunately they are not fully documented yet so you will have to
> >> approach them with an open mind and a sense of experimentation.
> >>
> >> You can also capture network traces on your loopback interface to see if
> >> there is, for example, unexpected congestion or latency, or if there are
> >> other problems.
> >>
> >> But for loopback, the problem is often that the client and server are
> >> sharing the same physical memory for caching data.  Analyzing your test
> >> system's physical memory utilization might be revealing.
> >
> > If he's just doing a single large read or write with cold caches (sounds
> > like that's probably the case), then memory probably doesn't matter
> > much, does it?
> 
> I expect it might.
> 
> The client and server would contend for available physical memory as
> the file was first read in from the physical file system by the
> server, and then a second copy was cached by the client.
> 
> A file as small as half the available physical memory on his system
> could trigger this behavior.

So, forgive me for being naive about this stuff, but I would've thought
that the cached pages (which have been read once and then never touched
again) would just be discarded, and life would continue.  Otherwise how
would the kernel be able to get acceptable streaming read performance in
any situation? 

This doesn't sound fundamentally different, e.g., from doing streaming
reads two files on different filesystems at once.

> On older 2.6 kernels (.18 or so), both the server's physical file
> system and the client would trigger bdi congestion throttling.

How does that work?

--b.
