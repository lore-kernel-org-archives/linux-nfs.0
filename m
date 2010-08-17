Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197Ab0HQTrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:47:08 -0400
Date: Tue, 17 Aug 2010 15:45:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817194504.GF26609@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <20100817190447.GA28049@fieldses.org>
 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
 <AANLkTi=sOW0Cgci+xX6rRmz+B-is0xb8DoKD350bFJN1@mail.gmail.com>
 <20100817205441.200ab9a4@lxorguk.ukuu.org.uk>
 <AANLkTi=BB-zVFyCLgC+RWai9FFecaOad=pUC2=XFnY3J@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTi=BB-zVFyCLgC+RWai9FFecaOad=pUC2=XFnY3J@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 12:43:10PM -0700, Patrick J. LoPresti wrote:
> On Tue, Aug 17, 2010 at 12:54 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> >> Is there any objection to the mount option I am proposing?
> >
> > I have none. I doubt I'd use it as it would be too expensive on system
> > performance for some of my boxes, while having an incrementing value is
> > cheap.
> >
> > I don't see the two as conflicting - in fact the bits you need to do the
> > mount option are the bits you also need to do the counter version as
> > well. One fixes ordering at no real cost, the other adds high res
> > timestamps, both are useful.
> 
> A mount option could also allow a choice of timestamp resolutions:
> 
> Traditional (i.e., fast)
> Alan Cox NFS hack (a tad slower but should fix NFS)
> High-res time (slowest but most accurate)
> 
> I will work on a patch this week (weekend at the latest).

I kind of hate to have mount options that are required for nfs exports
to work correctly; it soon makes things too complicated for users to
realiably get right, so distributions end up setting them, and then we
all end up taking the performance tradeoff anyway.

But a mount-option-based version may at least be useful for further
experiments.

--b.
