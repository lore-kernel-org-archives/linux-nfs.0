Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:48942 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754325Ab1AJTbz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 14:31:55 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <mkl@pengutronix.de>, linux-arch@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Parisc List <linux-parisc@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org
In-Reply-To: <1294687767.3349.28.camel@heimdal.trondhjem.org>
References: <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>
	 <1294426405.2929.23.camel@heimdal.trondhjem.org>
	 <20110107190229.GX31708@n2100.arm.linux.org.uk>
	 <1294427467.4895.66.camel@mulgrave.site>
	 <1294505384.4181.14.camel@heimdal.trondhjem.org>
	 <1294528551.4181.19.camel@heimdal.trondhjem.org>
	 <20110110105019.GC24920@pengutronix.de>
	 <1294676734.3349.10.camel@heimdal.trondhjem.org>
	 <4D2B3D03.8050504@pengutronix.de>
	 <1294680035.3349.19.camel@heimdal.trondhjem.org>
	 <20110110192552.GG24920@pengutronix.de>
	 <1294687767.3349.28.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Jan 2011 22:31:49 +0300
Message-ID: <1294687909.6706.885.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-01-10 at 14:29 -0500, Trond Myklebust wrote:
> I usually do this, but there is a slight problem with that approach:
> Greg gets to do all the work of figuring out to which stable kernels
> this particular patch applies. In this case, since we're only talking
> about the 2.6.37 kernel, I prefer to use the mailing lists.

So the non-standard, but accepted way of doing this is

Cc: Stable Tree <stable@kernel.org>	[2.6.37]

James


