Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58714 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab0HSDRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 23:17:23 -0400
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: john stultz <johnstul@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <20100819023106.GB30151@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	 <87aaolwar8.fsf@basil.nowhere.org> <20100817174134.GA23176@fieldses.org>
	 <20100817182920.GD18161@basil.fritz.box>
	 <20100817190447.GA28049@fieldses.org>
	 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
	 <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
	 <20100818181240.GA13050@fieldses.org>
	 <AANLkTi=cx31Mgfe7FxJz6LUmTKFR4=9KEBgbFsNLjiSE@mail.gmail.com>
	 <20100819023106.GB30151@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 20:17:14 -0700
Message-ID: <1282187834.3575.30.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 22:31 -0400, J. Bruce Fields wrote:
> On Wed, Aug 18, 2010 at 06:41:02PM -0700, john stultz wrote:
> > On Wed, Aug 18, 2010 at 11:12 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > I'm completely ignorant about higher-resolution time sources.  Any
> > > recommended reading?  What resolution do they actually provide, what's
> > > the expense of reading them, how reliable are they, and how do the
> > > answers to those questions vary across different hardware and kernel
> > > versions?  A quick look at drivers/clocksource/ doesn't suggest
> > > simple answers.
> > 
> > Yea, there aren't simple answers. Clocksource hardware varies
> > drastically in resolution and access time across systems and
> > architectures. Further, clocksources may change while the system is
> > up, so we don't really expose the hardware resolution.
> > 
> > On x86, access latency varies from ~50ns (TSC) to ~1.3us (ACPI PM).
> > (And that is ignoring the PIT, which can be 18us per call - luckily
> > almost no hardware uses that). The resolution similarly scales from
> > sub-ns (TSC @ > 1ghz cpus) to ~279ns (ACPI PM). Of course, across
> > architectures you will see even more variance.
> 
> The race in question occurs when you manage to check mtime between two
> file data updates, with all three operations occurring within a clock
> tick.
> 
> No idea if that's feasible in hundreds of nanoseconds.

I think this is what Andi meant that you'll always race with time and
that version counters are the only real solution here.

> I'm also not sure how to judge the access latency.  Certainly a
> microsecond is a lot compared to just reading a cached mtime value.
> 
> Will we ever see them go backwards?  (So if I know I wrote to file B
> after writing to file A, is there ever a case where I could end up with
> an earlier mtime on B than A?)

You should not. However, there have been bugs in the past, and there
will probably be a few more in the future.

There are also theoretical issues with SMP systems where the TSCs are
not perfectly synced, but the window for those races should be small
(ie: smaller then can be detected - otherwise we'll throw out the TSC).


thanks
-john


