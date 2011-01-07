Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:44147 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755056Ab1AGTFE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 14:05:04 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <1294426405.2929.23.camel@heimdal.trondhjem.org>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	 <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	 <1294262208.2952.4.camel@heimdal.trondhjem.org>
	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
	 <1294268808.2952.18.camel@heimdal.trondhjem.org>
	 <1294270104.16957.73.camel@mulgrave.site>
	 <1294335614.22825.154.camel@mulgrave.site>
	 <1294336054.2905.1.camel@heimdal.trondhjem.org>
	 <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>
	 <1294426405.2929.23.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 07 Jan 2011 13:05:00 -0600
Message-ID: <1294427100.4895.58.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-07 at 13:53 -0500, Trond Myklebust wrote:
> There is already code in the SUNRPC layer that calls flush_dcache_page()
> after writing (although as Russell pointed out earlier, that is
> apparently a no-op for non-page cache pages such as these).

Actually (and possibly fortunately) none of our flush_dcache_page()
implementations do this (check for an actual non page cache page and nop
if they find one).  Although, they may according to the docs which say
that flush_dcache_page() is only called on page cache pages.

But it's definitely using the API outside its documented scope.  We have
lots of places in the VFS where we don't call flush_dcache_page() even
after altering a kernel page (even in the page cache) if we know the
page will never be mapped to userspace.  The assumption here is that the
kernel never sets up non-user aliases of these pages, so not doing the
flushing is an optimisation since we only access them through the kernel
address space.  Of course, setting up vmap areas of these pages within
the kernel violates this assumption.

> > This is why you really really really generally don't want to have
> > aliasing. Purely virtual caches are pure crap. Really.
> 
> Well, it looks as if NOMMU is giving us problems due to the lack of a
> vm_map_ram() (see https://bugzilla.kernel.org/show_bug.cgi?id=26262).
> 
> I'd still like to keep the existing code for those architectures that
> don't have problems, since that allows us to send 32k READDIR requests
> instead of being limited to 4k. For large directories, that is a clear
> win.
> For the NOMMU case we will just go back to using a single page for
> storage (and 4k READDIR requests only). Should I just do the same for
> architectures like ARM and PARISC?

Well, that would include any VI architecture (like SPARC and others) as
well.  However, I think we can just make the
invalidate_kernel_vmap_range() work.

James


