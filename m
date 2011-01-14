Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from straum.hexapodia.org ([207.7.131.186]:52375 "EHLO
	straum.hexapodia.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab1ANEWT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 23:22:19 -0500
Date: Thu, 13 Jan 2011 20:22:19 -0800
From: Andy Isaacson <adi@hexapodia.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110114042219.GA17302@hexapodia.org>
References: <20101230191846.GB14221@pengutronix.de> <20110103213850.GC25121@pengutronix.de> <1294100558.25100.8.camel@heimdal.trondhjem.org> <20110105084014.GN25121@pengutronix.de> <20110105110517.GQ25121@pengutronix.de> <20110105112701.GA8638@n2100.arm.linux.org.uk> <20110105134045.GS25121@pengutronix.de> <1294239193.3014.9.camel@heimdal.trondhjem.org> <20110114022554.GA17397@hexapodia.org> <1294972823.2841.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294972823.2841.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 13, 2011 at 09:40:23PM -0500, Trond Myklebust wrote:
> > My server is running 2.6.36.1, filesystem is ext3 on sda3 on AHCI,
> > client is currently running 2.6.37-rc1.  I'm assuming that 37a09f will
> > fix it.
> 
> Why are you sticking to 2.6.37-rc1 when the final 2.6.37 is out? There
> have been several readdir bugfixes merged in the months since -rc1 came
> out.

No good reason, just hadn't run into any reasons to update; switching
kernels is nonzero cost since the machine in question runs some out of
tree modules ergo updating is slightly more involved than "make && make
install".  Above and beyond the costs of rebooting and losing state.

Actual bug is obviously a good reason to update though.

-andy
