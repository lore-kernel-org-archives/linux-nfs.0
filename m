Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46706 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752286Ab1AEUt2 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 15:49:28 -0500
In-Reply-To: <1294259637.16957.25.camel@mulgrave.site>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk>
 <1294259637.16957.25.camel@mulgrave.site>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 12:48:32 -0800
Message-ID: <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 5, 2011 at 12:33 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> well, that depends.  For us on parisc, kmap of a user page in !HIGHMEM
> sets up an inequivalent aliase still ... because the cache colour of the
> user and kernel virtual addresses are different.  Depending on the
> return path to userspace, we still usually have to flush to get the user
> to see the changes the kernel has made.

Umm. Again, that has nothing to do with kmap().

This time it's about the user space mapping.

Repeat after me: even without the kmap(), the kernel access to that
mapping would have caused cache aliases.

See? Once more, the kmap() is entirely innocent. You can have a
non-highmem mapping that you never use kmap for, and that you map into
user space, and you'd see exactly the same aliases. Notice? Look ma,
no kmap().

So clearly kmap() is not the issue. The issue continues to be a
totally separate virtual mapping. Whether it's a user mapping or
vm_map_ram() is obviously immaterial - as far as the CPU is concerned,
there is no difference between the two (apart from the trivial
differences of virtual location and permissions).

(You can also force the problem with vmalloc() an then following the
kernel page tables, but I hope nobody does that any more. I suspect
I'm wrong, though, there's probably code that mixes vmalloc and
physical page accesses in various drivers)

                    Linus
