Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51846 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755041Ab0L3UDT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Dec 2010 15:03:19 -0500
In-Reply-To: <1293737115.4919.47.camel@heimdal.trondhjem.org>
References: <AANLkTi=-dNeeDjcSoznKtwcaNyw1mMXSqepFY89R2i+2@mail.gmail.com>
 <20101230171453.GA5787@pengutronix.de> <AANLkTikvZF6Q1k0rETLHUffkUT3grxAh3FoB_0vs96B8@mail.gmail.com>
 <1293733460.4919.21.camel@heimdal.trondhjem.org> <AANLkTi=sO9M8m1Fpntu_YscVU4SrppKfxBf2eRZ2Dr+L@mail.gmail.com>
 <1293737115.4919.47.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 30 Dec 2010 12:02:23 -0800
Message-ID: <AANLkTinaQJVyY2wm+q-jh6Sr-QpbhRO0p+Sp0obdcqxE@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Chuck Lever <chuck.lever@oracle.com>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 11:25 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> uncached_readdir is not really a problem. The real problem is
> filesystems that generate "infinite directories" by producing looping
> combinations of cookies.

But if we don't have any lseek's, the readdir cache should trivially
take care of this by just incrementing the page_index, and we should
return to user space the (eventually ending) sequence, even if there
are duplicate numbers.

(Also, I suspect that "page_index" should not be a page index, but a
position, and then you the "search_for_pos()" should use that instead
of the file_pos/current_index thing, but that's a detail that would
show up only when you have duplicate cookies within one page worth of
directory caches)

And if the server really sends us an infinite stream of entries, then
that's fine - at least we give to user space the infinite entries that
were given to us, instead of _generating_ an infinite stream from what
was a finite - but broken - stream).

So it seems wrong that the directory caching code resets page_index to
the start when it then does an uncached readdir. That seems wrong.

I'm sure there's some reason for it, but wouldn't it be nice if the
rule for page_index was that it starts off at zero, and only gets
reset by lseek?

> IOW: I've seen servers that generate cookies in a sequence of a form
> vaguely resembling
>
> 1 2 3 4 5 6 7 8 9 10 11 12 3...
>
> (with possibly a thousand or so entries between the first and second
> copy of '3')

Ok, so that' obviously broken, but it's then _doubly_ broken to turn
that long broken sequence into an _endless_ broken sequence.

And I agree that when user space sees such an endless broken sequence,
it's a real stopping problem for user space. But in the absense of
lseek, it should _never_ be a problem for the kernel itself, afaik.
The kernel should happily return just the broken sequence. No?

So then perhaps the solution is to just remove the resetting of
page_index in the uncached_readdir() function? Make sure that the
page_index is monotonically increasing for any readdir(), and you
protect against turning a bad sequence into an endless sequence.

Of course, lseek() will have to reset page_index to zero, and if
somebody does an lseek() on the directory, then the duplicate '3"
entry in the cookie sequence will inevitably be ambiguous, but that
really is unavoidable. And rare. People who use lseek() on directories
are odd and we know they'll break on other filesystems too under
certain circumstances.

                         Linus
