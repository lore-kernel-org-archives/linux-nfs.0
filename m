Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54947 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510Ab1AFSB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 13:01:26 -0500
In-Reply-To: <1294336054.2905.1.camel@heimdal.trondhjem.org>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk>
 <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
 <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
 <1294262208.2952.4.camel@heimdal.trondhjem.org> <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
 <1294268808.2952.18.camel@heimdal.trondhjem.org> <1294270104.16957.73.camel@mulgrave.site>
 <1294335614.22825.154.camel@mulgrave.site> <1294336054.2905.1.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Jan 2011 09:55:30 -0800
Message-ID: <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
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

On Thu, Jan 6, 2011 at 9:47 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Why is this line needed? We're not writing through the virtual mapping.

I haven't looked at the sequence of accesses, but you need to be
_very_ aware that "write-through" is absolutely NOT sufficient for
cache coherency.

In cache coherency, you have three options:

 - true coherency (eg physically indexed/tagged caches)

 - exclusion (eg virtual caches, but with an exclusion guarantee that
guarantees that aliases cannot happen: either by using physical
tagging or by not allowing cases that could cause virtual aliases)

 - write-through AND non-cached reads (ie "no caching at all").

You seem to be forgetting the "no cached reads" part. It's not
sufficient to flush after a write - you need to make sure that you
also don't have a cached copy of the alias for the read.

So "We're not writing through the virtual mapping" is NOT a sufficient
excuse. If you're reading through the virtual mapping, you need to
make sure that the virtual mapping is flushed _after_ any writes
through any other mapping and _before_ any reads through the virtual
one.

This is why you really really really generally don't want to have
aliasing. Purely virtual caches are pure crap. Really.

                       Linus
