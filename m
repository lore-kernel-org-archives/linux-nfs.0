Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51372 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751606Ab1AJTfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 14:35:39 -0500
In-Reply-To: <1294687767.3349.28.camel@heimdal.trondhjem.org>
References: <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>
 <1294426405.2929.23.camel@heimdal.trondhjem.org> <20110107190229.GX31708@n2100.arm.linux.org.uk>
 <1294427467.4895.66.camel@mulgrave.site> <1294505384.4181.14.camel@heimdal.trondhjem.org>
 <1294528551.4181.19.camel@heimdal.trondhjem.org> <20110110105019.GC24920@pengutronix.de>
 <1294676734.3349.10.camel@heimdal.trondhjem.org> <4D2B3D03.8050504@pengutronix.de>
 <1294680035.3349.19.camel@heimdal.trondhjem.org> <20110110192552.GG24920@pengutronix.de>
 <1294687767.3349.28.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Jan 2011 11:34:49 -0800
Message-ID: <AANLkTinFenq3BEiUQRsxDy6EKwqSM33RcwFG4fs-sXLJ@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <mkl@pengutronix.de>, linux-arch@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Parisc List <linux-parisc@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/1/10 Trond Myklebust <Trond.Myklebust@netapp.com>:
>
> I usually do this, but there is a slight problem with that approach:
> Greg gets to do all the work of figuring out to which stable kernels
> this particular patch applies. In this case, since we're only talking
> about the 2.6.37 kernel, I prefer to use the mailing lists.

Just do

  Cc: stable@kernel.org  [2.6.37]

or similar. It's quite common.

So EVEN IF you want to email people around about the patch separately,
do add the "Cc: stable" marker. It's worthwhile information about the
patch for everybody involved.

                     Linus
