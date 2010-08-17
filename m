Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36069 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab0HQTnM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:43:12 -0400
In-Reply-To: <20100817205441.200ab9a4@lxorguk.ukuu.org.uk>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
	<20100817205441.200ab9a4@lxorguk.ukuu.org.uk>
Date: Tue, 17 Aug 2010 12:43:10 -0700
Message-ID: <AANLkTi=BB-zVFyCLgC+RWai9FFecaOad=pUC2=XFnY3J@mail.gmail.com>
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

On Tue, Aug 17, 2010 at 12:54 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> Is there any objection to the mount option I am proposing?
>
> I have none. I doubt I'd use it as it would be too expensive on system
> performance for some of my boxes, while having an incrementing value is
> cheap.
>
> I don't see the two as conflicting - in fact the bits you need to do the
> mount option are the bits you also need to do the counter version as
> well. One fixes ordering at no real cost, the other adds high res
> timestamps, both are useful.

A mount option could also allow a choice of timestamp resolutions:

Traditional (i.e., fast)
Alan Cox NFS hack (a tad slower but should fix NFS)
High-res time (slowest but most accurate)

I will work on a patch this week (weekend at the latest).

Thanks, Alan.

 - Pat
