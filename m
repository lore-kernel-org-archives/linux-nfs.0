Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:36341 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458Ab1AFSOf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 13:14:35 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <20110106180530.GI31708@n2100.arm.linux.org.uk>
References: <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	 <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	 <1294262208.2952.4.camel@heimdal.trondhjem.org>
	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
	 <1294268808.2952.18.camel@heimdal.trondhjem.org>
	 <1294270104.16957.73.camel@mulgrave.site>
	 <1294335614.22825.154.camel@mulgrave.site>
	 <20110106180530.GI31708@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Jan 2011 12:14:30 -0600
Message-ID: <1294337670.22825.199.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-06 at 18:05 +0000, Russell King - ARM Linux wrote:
> On Thu, Jan 06, 2011 at 11:40:13AM -0600, James Bottomley wrote:
> > On Wed, 2011-01-05 at 23:28 +0000, James Bottomley wrote:
> > > Can you explain how the code works? it looks to me like you read the xdr
> > > stuff through the vmap region then write it out directly to the pages? 
> > 
> > OK, I think I see how this is supposed to work:  It's a sequential loop
> > of reading in via the pages (i.e. through the kernel mapping) and then
> > updating those pages via the vmap.  In which case, I think this patch is
> > what you need.
> > 
> > The theory of operation is that the readdir on pages actually uses the
> > network DMA operations to perform, so when it's finished, the underlying
> 
> What network DMA operations - what if your NIC doesn't do DMA because
> it's an SMSC device?

So this is the danger area ... we might be caught by our own flushing
tricks.  I can't test this on parisc since all my network drivers use
DMA (which automatically coheres the kernel mapping by
flush/invalidate).

What should happen is that the kernel mapping pages go through the
->readdir() path.  Any return from this has to be ready to map the pages
back to user space, so the kernel alias has to be flushed to make the
underlying page up to date.

The exception is pages we haven't yet mapped to userspace.  Here we set
the PG_dcache_dirty bit (sparc trick) but don't flush the page, since we
expect the addition of a userspace mapping will detect this case and do
the flush and clear the bit before the mapping goes live.  I assume
you're thinking that because this page is allocated and freed internally
to NFS, it never gets a userspace mapping and therefore, we can return
from ->readdir() with a dirty kernel cache (and the corresponding flag
set)?  I think that is a possible hypothesis in certain cases.

James


