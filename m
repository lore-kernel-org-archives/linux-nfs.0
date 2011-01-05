Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35507 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753041Ab1AEX3O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 18:29:14 -0500
In-Reply-To: <1294268808.2952.18.camel@heimdal.trondhjem.org>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk>
 <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
 <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
 <1294262208.2952.4.camel@heimdal.trondhjem.org> <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
 <1294268808.2952.18.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 15:28:53 -0800
Message-ID: <AANLkTi=SjMinMp+m726GS1iehj6cQgNy1RqSoUqKhjtv@mail.gmail.com>
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

On Wed, Jan 5, 2011 at 3:06 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Yes. The fix I sent out was a call to invalidate_kernel_vmap_range(),
> which takes care of invalidating the cache prior to a virtual address
> read.
>
> My question was specifically about the write through the regular kernel
> mapping: according to Russell and my reading of the cachetlb.txt
> documentation, flush_dcache_page() is only guaranteed to have an effect
> on page cache pages.

I don't think that should ever matter. It's not like the hardware can
know whether it's a dcache page or not.

And if the sw implementation cares, it's doing something really odd.
But who knows - there's a lot of crap out there, and people sometimes
do really odd things to work around the brokenness of a VIVT cache
with aliases.

                       Linus
