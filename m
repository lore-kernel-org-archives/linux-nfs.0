Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57959 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150Ab0HRSOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 14:14:50 -0400
Date: Wed, 18 Aug 2010 14:12:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100818181240.GA13050@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <20100817190447.GA28049@fieldses.org>
 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
 <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 12:34:58PM -0700, Patrick J. LoPresti wrote:
> On Tue, Aug 17, 2010 at 12:39 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> >        if (time_now == time_last)
> >                return { time_last , ++ct };
> >        else {
> >                ct = 0;
> >                time_last = time_now
> >                return { time_last , 0 };
> >        }
> >
> > providing it is done with the same 'ct' across the fs and you can't do
> > enough ops/second to wrap the nanosecs - which should be fine for now,
> > your ordering is still safe is it not ?
> 
> Yes, that would work.   Assuming you use atomic counters, else there
> is a risk of the visible time ticking backwards.  It seems like a lot
> of effort just to avoid having accurate timestamps on your files,
> though.
> 
> I am having trouble seeing why this is a better idea than a simple
> mount option to obtain decent resolution timestamps.  (Not that we
> can't have both...)  Is there any objection to the mount option I am
> proposing?

I'm completely ignorant about higher-resolution time sources.  Any
recommended reading?  What resolution do they actually provide, what's
the expense of reading them, how reliable are they, and how do the
answers to those questions vary across different hardware and kernel
versions?  A quick look at drivers/clocksource/ doesn't suggest
simple answers.

-b.
