Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53237 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab0HQTSO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:18:14 -0400
In-Reply-To: <20100817190447.GA28049@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
Date: Tue, 17 Aug 2010 12:18:12 -0700
Message-ID: <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 12:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Right, I think that we probably have to give up ext3 as a lost cause.
> But perhaps we could get away with a hack like this on filesystems that
> can store nanoseconds.

I do not think so.

The problem with "increment mtime by a nanosecond when necessary" is
that timestamps can wind up out of order.  As in:

1) Do a bunch of operations on file A
2) Do one operation on file B

Imagine each operation on A incrementing its timestamp by a nanosecond
"just because".  If all of these operations happen in less than 4 ms,
you can wind up with the timestamp on B being EARLIER than the
timestamp on A.  That is a big no-no (think "make" or anything else
relying on timestamps for relative times).

If you can prove that the last modification on B happens after the
last modification on A, then it is very bad for the mtime on B to be
earlier than the mtime on A.  I guarantee that will break things in
the real world.

As you say, high-resolution timestamps "will extend the useful
lifetime of NFSv3 by quite a bit".  They are also a good idea in
principle, IMO.  Correctness is almost always more important than
performance.

 - Pat
