Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14404 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab1AHQuE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Jan 2011 11:50:04 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <1294427467.4895.66.camel@mulgrave.site>
References: <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	 <1294262208.2952.4.camel@heimdal.trondhjem.org>
	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
	 <1294268808.2952.18.camel@heimdal.trondhjem.org>
	 <1294270104.16957.73.camel@mulgrave.site>
	 <1294335614.22825.154.camel@mulgrave.site>
	 <1294336054.2905.1.camel@heimdal.trondhjem.org>
	 <AANLkTimusF4KCJ4vHPn+T1dUiKxapXaT0QTtFvh8Ykdd@mail.gmail.com>
	 <1294426405.2929.23.camel@heimdal.trondhjem.org>
	 <20110107190229.GX31708@n2100.arm.linux.org.uk>
	 <1294427467.4895.66.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 08 Jan 2011 11:49:44 -0500
Message-ID: <1294505384.4181.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-07 at 13:11 -0600, James Bottomley wrote: 
> On the other hand, the xdr routines, since they take the pages anyway,
> could use a scatterlist approach to writing through the kernel mapping
> instead of using vmap ... we have all the machinery for this in
> lib/scatterlist.c ... it's not designed for this case, since it's
> designed to allow arbitrary linear reads and writes on a block
> scatterlist, but the principle is the same ... it looks like it would be
> rather a big patch, though ... 

The following alternative seems to work for me, but has only been
lightly tested so far. It's a bit large for a stable patch, but not too
ungainly.

It modifies xdr_stream, adding the ability to iterate through page data.
To avoid kmap()/kunmap(), it does require that pages be allocated in
lowmem, but since the only use case here is when using page arrays as
temporary buffers, that seems like an acceptable compromise.

Cheers
  Trond

--------------------------------------------------------------------------------- 
