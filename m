Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:45538 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750705Ab0HQTgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:36:54 -0400
Date: Tue, 17 Aug 2010 20:52:20 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817205220.44edb294@lxorguk.ukuu.org.uk>
In-Reply-To: <20100817192937.GD26609@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<20100817192937.GD26609@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> (Does it really need to be global across all filesystems?  Or is it
> unreasonable to expect your unbelievably-fast make's to behave well when
> sources and targets live on different filesystems?)

I don't believe it does for the NFS semantics. You can't do it globally
because then you get weirdness between local file systems that support
u/nsecs and those that don't.

It's enough to fix NFS I believe.

Alan
