Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35343 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab0HQTfA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:35:00 -0400
In-Reply-To: <20100817203941.729830b7@lxorguk.ukuu.org.uk>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
Date: Tue, 17 Aug 2010 12:34:58 -0700
Message-ID: <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 12:39 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

>        if (time_now == time_last)
>                return { time_last , ++ct };
>        else {
>                ct = 0;
>                time_last = time_now
>                return { time_last , 0 };
>        }
>
> providing it is done with the same 'ct' across the fs and you can't do
> enough ops/second to wrap the nanosecs - which should be fine for now,
> your ordering is still safe is it not ?

Yes, that would work.   Assuming you use atomic counters, else there
is a risk of the visible time ticking backwards.  It seems like a lot
of effort just to avoid having accurate timestamps on your files,
though.

I am having trouble seeing why this is a better idea than a simple
mount option to obtain decent resolution timestamps.  (Not that we
can't have both...)  Is there any objection to the mount option I am
proposing?

For the Nth time, I am willing to produce and test the patch, but not
if there is zero chance of it being accepted.

 - Pat
