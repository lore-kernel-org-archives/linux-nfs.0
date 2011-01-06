Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:48208 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab1AFSFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 13:05:47 -0500
Date: Thu, 6 Jan 2011 18:05:30 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110106180530.GI31708@n2100.arm.linux.org.uk>
References: <20110105200008.GJ8638@n2100.arm.linux.org.uk> <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com> <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com> <1294262208.2952.4.camel@heimdal.trondhjem.org> <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com> <1294268808.2952.18.camel@heimdal.trondhjem.org> <1294270104.16957.73.camel@mulgrave.site> <1294335614.22825.154.camel@mulgrave.site>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294335614.22825.154.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 06, 2011 at 11:40:13AM -0600, James Bottomley wrote:
> On Wed, 2011-01-05 at 23:28 +0000, James Bottomley wrote:
> > Can you explain how the code works? it looks to me like you read the xdr
> > stuff through the vmap region then write it out directly to the pages? 
> 
> OK, I think I see how this is supposed to work:  It's a sequential loop
> of reading in via the pages (i.e. through the kernel mapping) and then
> updating those pages via the vmap.  In which case, I think this patch is
> what you need.
> 
> The theory of operation is that the readdir on pages actually uses the
> network DMA operations to perform, so when it's finished, the underlying

What network DMA operations - what if your NIC doesn't do DMA because
it's an SMSC device?
