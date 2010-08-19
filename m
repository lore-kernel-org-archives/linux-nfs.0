Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:43581 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab0HSBlE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 21:41:04 -0400
In-Reply-To: <20100818181240.GA13050@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
	<20100818181240.GA13050@fieldses.org>
Date: Wed, 18 Aug 2010 18:41:02 -0700
Message-ID: <AANLkTi=cx31Mgfe7FxJz6LUmTKFR4=9KEBgbFsNLjiSE@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: john stultz <johnstul@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 11:12 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> I'm completely ignorant about higher-resolution time sources.  Any
> recommended reading?  What resolution do they actually provide, what's
> the expense of reading them, how reliable are they, and how do the
> answers to those questions vary across different hardware and kernel
> versions?  A quick look at drivers/clocksource/ doesn't suggest
> simple answers.

Yea, there aren't simple answers. Clocksource hardware varies
drastically in resolution and access time across systems and
architectures. Further, clocksources may change while the system is
up, so we don't really expose the hardware resolution.

On x86, access latency varies from ~50ns (TSC) to ~1.3us (ACPI PM).
(And that is ignoring the PIT, which can be 18us per call - luckily
almost no hardware uses that). The resolution similarly scales from
sub-ns (TSC @ > 1ghz cpus) to ~279ns (ACPI PM). Of course, across
architectures you will see even more variance.

thanks
-john
