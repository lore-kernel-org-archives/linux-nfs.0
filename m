Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56307 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705Ab0HQTbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:31:46 -0400
Date: Tue, 17 Aug 2010 15:29:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817192937.GD26609@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <20100817190447.GA28049@fieldses.org>
 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100817203941.729830b7@lxorguk.ukuu.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 08:39:41PM +0100, Alan Cox wrote:
> > The problem with "increment mtime by a nanosecond when necessary" is
> > that timestamps can wind up out of order.  As in:
> 
> Surely that depends on your implementation ?
> 
> > 1) Do a bunch of operations on file A
> > 2) Do one operation on file B
> > 
> > Imagine each operation on A incrementing its timestamp by a nanosecond
> > "just because".  If all of these operations happen in less than 4 ms,
> > you can wind up with the timestamp on B being EARLIER than the
> > timestamp on A.  That is a big no-no (think "make" or anything else
> > relying on timestamps for relative times).
> 
> 
> [time resolution bits of data][value incremented value for that time]
> 
> 
> 	if (time_now == time_last)
> 		return { time_last , ++ct };
> 	else {
> 		ct = 0;
> 		time_last = time_now
> 		return { time_last , 0 };
> 	}
> 
> providing it is done with the same 'ct' across the fs and you can't do
> enough ops/second to wrap the nanosecs - which should be fine for now,
> your ordering is still safe is it not ?

Right, so if I understand correctly, you're proposing a time source
that's global to the filesystem and that guarantees it will always
return a unique value by incrementing the nanoseconds field if jiffies
haven't changed since the last time it was called.

(Does it really need to be global across all filesystems?  Or is it
unreasonable to expect your unbelievably-fast make's to behave well when
sources and targets live on different filesystems?)

--b.
