Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37239 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab0HSWzS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 18:55:18 -0400
Date: Thu, 19 Aug 2010 18:53:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: john stultz <johnstul@us.ibm.com>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100819225300.GD9275@fieldses.org>
References: <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <20100817190447.GA28049@fieldses.org>
 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
 <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
 <20100818181240.GA13050@fieldses.org>
 <AANLkTi=cx31Mgfe7FxJz6LUmTKFR4=9KEBgbFsNLjiSE@mail.gmail.com>
 <20100819023106.GB30151@fieldses.org>
 <1282187834.3575.30.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282187834.3575.30.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 08:17:14PM -0700, john stultz wrote:
> On Wed, 2010-08-18 at 22:31 -0400, J. Bruce Fields wrote:
> > On Wed, Aug 18, 2010 at 06:41:02PM -0700, john stultz wrote:
> > > On Wed, Aug 18, 2010 at 11:12 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > I'm completely ignorant about higher-resolution time sources.  Any
> > > > recommended reading?  What resolution do they actually provide, what's
> > > > the expense of reading them, how reliable are they, and how do the
> > > > answers to those questions vary across different hardware and kernel
> > > > versions?  A quick look at drivers/clocksource/ doesn't suggest
> > > > simple answers.
> > > 
> > > Yea, there aren't simple answers. Clocksource hardware varies
> > > drastically in resolution and access time across systems and
> > > architectures. Further, clocksources may change while the system is
> > > up, so we don't really expose the hardware resolution.
> > > 
> > > On x86, access latency varies from ~50ns (TSC) to ~1.3us (ACPI PM).
> > > (And that is ignoring the PIT, which can be 18us per call - luckily
> > > almost no hardware uses that). The resolution similarly scales from
> > > sub-ns (TSC @ > 1ghz cpus) to ~279ns (ACPI PM). Of course, across
> > > architectures you will see even more variance.
> > 
> > The race in question occurs when you manage to check mtime between two
> > file data updates, with all three operations occurring within a clock
> > tick.
> > 
> > No idea if that's feasible in hundreds of nanoseconds.
> 
> I think this is what Andi meant that you'll always race with time and
> that version counters are the only real solution here.

Yeah.  That'll work for NFSv4.  But if possible it'd be nice to have a
solution for NFSv3.

As compared to using a higher-resolution time source, a solution for
mtime based on a global counter would provide better guarantees (on
filesystems that can store the extra bits), and perform better.  (What
is the worst-case latency if we're bouncing a cache line back and forth
between two CPU's?)  Though I guess the possible performance hit would
rule it out for users that didn't specifically ask for it.  (So, no help
for userspace nfs servers, make, or whoever else might (wisely or not)
already depend on mtime detecting changes reliably.)

> > I'm also not sure how to judge the access latency.  Certainly a
> > microsecond is a lot compared to just reading a cached mtime value.
> > 
> > Will we ever see them go backwards?  (So if I know I wrote to file B
> > after writing to file A, is there ever a case where I could end up with
> > an earlier mtime on B than A?)
> 
> You should not. However, there have been bugs in the past, and there
> will probably be a few more in the future.
> 
> There are also theoretical issues with SMP systems where the TSCs are
> not perfectly synced, but the window for those races should be small
> (ie: smaller then can be detected - otherwise we'll throw out the TSC).

Got it.  Thanks for your help!

--b.
