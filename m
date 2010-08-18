Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35954 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab0HRScW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 14:32:22 -0400
In-Reply-To: <1282155658.13405.36.camel@localhost>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<1282155658.13405.36.camel@localhost>
Date: Wed, 18 Aug 2010 11:32:20 -0700
Message-ID: <AANLkTin2EOzA5grh5qjZghAs0Y4DbcGBhmdfqp=u1S_4@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 11:20 AM, David Woodhouse <dwmw2@infradead.org> wrote:
>
> Um, can't you? You can't *store* timestamps which are more precise, but
> they can be in cache can't they?

No.  That is how Linux used to work, and it caused many problems,
which is why the current_fs_time() function was invented.

> And since you're not going to drop it from cache and bring it back in
> again within 4ms, that ought to suffice?

Not the problem.  As usual, the problem is out-of-order timestamps:

1) Modify file A
2) Modify file B
3) File B's inode gets evicted, truncating its timestamp to disk resolution
4) Call stat() on B, bringing it back in with truncated resolution

And boom, B appears to be OLDER than A.  Which is not allowed.

This is exactly what happened when Linux first added sub-second
timestamps to the generic VFS layer.  Many complaints about "make"
rebuilding files unecessarily, among other things.  Eventually it got
fixed by the introduction of current_fs_time().

 - Pat
