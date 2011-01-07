Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35341 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab1AGTDF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 14:03:05 -0500
Date: Fri, 7 Jan 2011 19:02:29 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110107190229.GX31708@n2100.arm.linux.org.uk>
References: <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com> <1294262208.2952.4.camel@heimdal.trondhjem.org> <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com> <1294268808.2952.18.camel@heimdal.trondhjem.org> <1294270104.16957.73.camel@mulgrave.site> <1294335614.22825.154.camel@mulgrave.site> <1294336054.2905.1.camel@heimdal.trondhjem.org> <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com> <1294426405.2929.23.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294426405.2929.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 07, 2011 at 01:53:25PM -0500, Trond Myklebust wrote:
> I'd still like to keep the existing code for those architectures that
> don't have problems, since that allows us to send 32k READDIR requests
> instead of being limited to 4k. For large directories, that is a clear
> win.
> For the NOMMU case we will just go back to using a single page for
> storage (and 4k READDIR requests only). Should I just do the same for
> architectures like ARM and PARISC?

I think you said that readdir reads via the vmalloc mapping of the
group of pages, but XDR writes to the individual pages.

As I understand NFS, you receive a packet, you then have to use XDR
to unpack the data, which you presumably write into the set of
struct page *'s using kmap?

Isn't a solution to have XDR write directly into the vmalloc mapping
rather than using struct page * and kmap?
