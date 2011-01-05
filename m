Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56673 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429Ab1AEVb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 16:31:27 -0500
In-Reply-To: <1294262208.2952.4.camel@heimdal.trondhjem.org>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk>
 <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
 <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
 <1294262208.2952.4.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 13:30:34 -0800
Message-ID: <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
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

On Wed, Jan 5, 2011 at 1:16 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> So what should be the preferred way to ensure data gets flushed when
> you've written directly to a page, and then want to read through the
> vm_map_ram() virtual range? Should we be adding new semantics to
> flush_kernel_dcache_page()?

The "preferred way" is actually simple: "don't do that". IOW, if some
page is accessed through a virtual mapping you've set up, then
_always_ access it through that virtual mapping.

Now, when that is impossible (and yes, it sometimes is), then you
should flush after doing all writes. And if you do the write through
the regular kernel mapping, you should use flush_dcache_page(). And if
you did it through the virtual mapping, you should use
"flush_kernel_vmap_range()" or whatever.

NOTE! I really didn't look those up very closely, and if the accesses
can happen concurrently you are basically screwed, so you do need to
do locking or something else to guarantee that there is some nice
sequential order.  And maybe I forgot something.  Which is why I do
suggest "don't do that" as a primary approach to the problem if at all
possible.

Oh, and you may need to flush before reading too (and many writes do
end up being "read-modify-write" cycles) in case it's possible that
you have stale data from a previous read that was then invalidated by
a write to the aliasing address. Even if that write was flushed out,
the stale read data may exist at the virtual address. I forget what
all we required - in the end the only sane model is "virtual caches
suck so bad that anybody who does them should be laughed at for being
a retard".

                            Linus
