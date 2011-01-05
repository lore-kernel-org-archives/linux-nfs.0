Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35559 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1AEPfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 10:35:13 -0500
Date: Wed, 5 Jan 2011 15:34:57 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: "Nori, Sekhar" <nsekhar@ti.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110105153457.GB8638@n2100.arm.linux.org.uk>
References: <20101230171453.GA5787@pengutronix.de> <1293731992.4919.5.camel@heimdal.trondhjem.org> <20101230191846.GB14221@pengutronix.de> <20110103213850.GC25121@pengutronix.de> <1294100558.25100.8.camel@heimdal.trondhjem.org> <20110105084014.GN25121@pengutronix.de> <20110105110517.GQ25121@pengutronix.de> <20110105112701.GA8638@n2100.arm.linux.org.uk> <4D246098.50908@pengutronix.de> <B85A65D85D7EB246BE421B3FB0FBB5930248201279@dbde02.ent.ti.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B85A65D85D7EB246BE421B3FB0FBB5930248201279@dbde02.ent.ti.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 06:32:58PM +0530, Nori, Sekhar wrote:
> Here are some logs:
> 
> fileid changed fsid 0:c: expected fileid 0x2db61d, got 0x2dad20
> 
> fileid changed fsid 0:c: expected fileid 0x100000000000, got 0x7070000000000000

Just to be clear, what I was seeing was things like:

expected fileid <32-bit number> got <64-bit number with same 32-bit LS bits>

so it looked like something was truncating a 64-bit fileid down
to 32-bits.
