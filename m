Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35009 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751316Ab0HQTjO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:39:14 -0400
Date: Tue, 17 Aug 2010 20:54:41 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817205441.200ab9a4@lxorguk.ukuu.org.uk>
In-Reply-To: <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> I am having trouble seeing why this is a better idea than a simple
> mount option to obtain decent resolution timestamps.  (Not that we
> can't have both...)  Is there any objection to the mount option I am
> proposing?

I have none. I doubt I'd use it as it would be too expensive on system
performance for some of my boxes, while having an incrementing value is
cheap.

I don't see the two as conflicting - in fact the bits you need to do the
mount option are the bits you also need to do the counter version as
well. One fixes ordering at no real cost, the other adds high res
timestamps, both are useful.

Alan
