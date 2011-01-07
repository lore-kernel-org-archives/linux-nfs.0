Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:56418 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755116Ab1AGTLJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 14:11:09 -0500
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
In-Reply-To: <20110107190229.GX31708@n2100.arm.linux.org.uk>
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
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 07 Jan 2011 13:11:07 -0600
Message-ID: <1294427467.4895.66.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-07 at 19:02 +0000, Russell King - ARM Linux wrote:
> On Fri, Jan 07, 2011 at 01:53:25PM -0500, Trond Myklebust wrote:
> > I'd still like to keep the existing code for those architectures that
> > don't have problems, since that allows us to send 32k READDIR requests
> > instead of being limited to 4k. For large directories, that is a clear
> > win.
> > For the NOMMU case we will just go back to using a single page for
> > storage (and 4k READDIR requests only). Should I just do the same for
> > architectures like ARM and PARISC?
> 
> I think you said that readdir reads via the vmalloc mapping of the
> group of pages, but XDR writes to the individual pages.

Actually it's the other way around, but the point still stands.

> As I understand NFS, you receive a packet, you then have to use XDR
> to unpack the data, which you presumably write into the set of
> struct page *'s using kmap?
> 
> Isn't a solution to have XDR write directly into the vmalloc mapping
> rather than using struct page * and kmap?

So, unfortuantely, I looked at doing this and we can't.  the ->readdir()
call takes an array of pages, not a kernel virtual address of the pages,
so there's no way to tell it to use a different mapping from the usual
kernel one on them.

On the other hand, the xdr routines, since they take the pages anyway,
could use a scatterlist approach to writing through the kernel mapping
instead of using vmap ... we have all the machinery for this in
lib/scatterlist.c ... it's not designed for this case, since it's
designed to allow arbitrary linear reads and writes on a block
scatterlist, but the principle is the same ... it looks like it would be
rather a big patch, though ... 

James


