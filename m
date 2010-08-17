Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:38094 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759590Ab0HQSun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 14:50:43 -0400
In-Reply-To: <20100817182920.GD18161@basil.fritz.box>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
Date: Tue, 17 Aug 2010 11:50:40 -0700
Message-ID: <AANLkTi=oTEBiAqs2N0jnC+=n8tLHhjuN7Ns=GfP7oRvr@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 11:29 AM, Andi Kleen <andi@firstfloor.org> wrote:
>
> You cannot be more precise than the backing file system: this causes
> non monotonity when the inodes are flushed (has happened in the past)

True.  But non-toy filesystems designed post-1990 support nanosecond
timestamps.  One-second resolution is a disaster for NFS servers and
always has been.  I wonder how many man-hours have been wasted dealing
with the problem...  I personally have seen it dozens of times in my
career, but "use XFS" was always a solution.  Until now, that is, when
300usec round trip network times, 3GHz processors, and "weak cache
consistency" optimizations have conspired to bring it back, thanks to
4msec resolution timestamps.

Even aside from any NFS issues, I myself would prefer accurate
timestamps over a 10% boost for tight loops calling "utimes()" or
whatever.  But maybe that is just me.

Anyway, to repeat my revised proposal:

1) Add a "sb_current_fs_time" member to "struct super_block".  Make it
a pointer to a function returning "struct timespec".  Have it default
to the current low-resolution implementation.

2) Modify the function "current_fs_time(struct super_block sb *)" to
just "return sb->sb_current_fs_time(sb)".  Might as well inline it
too.

3) Add a mount option to allow the selection of the high-res time
source; i.e., to set sb_current_fs_time to point to the high-res
implementation.

Would patches implementing this stand a realistic chance of being accepted?

 - Pat
