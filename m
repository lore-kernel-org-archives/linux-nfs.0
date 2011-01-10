Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1AJT3c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 14:29:32 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-arch@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Parisc List <linux-parisc@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org
In-Reply-To: <20110110192552.GG24920@pengutronix.de>
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
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Jan 2011 14:29:27 -0500
Message-ID: <1294687767.3349.28.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-01-10 at 20:25 +0100, Uwe Kleine-König wrote: 
> Hello Trond,
> 
> On Mon, Jan 10, 2011 at 12:20:35PM -0500, Trond Myklebust wrote:
> > On Mon, 2011-01-10 at 18:08 +0100, Marc Kleine-Budde wrote: 
> > > On 01/10/2011 05:25 PM, Trond Myklebust wrote:
> > > > On Mon, 2011-01-10 at 11:50 +0100, Uwe Kleine-König wrote: 
> > > >> Hi Trond,
> > > >>
> > > >> On Sat, Jan 08, 2011 at 06:15:51PM -0500, Trond Myklebust wrote:
> > > >>> ----------------------------------------------------------------------------------- 
> > > >> It would be great if you could add a "8<" in the line above next time.
> > > >> Then git-am -c does the right thing (at least I think so).
> > > > 
> > > > Sorry. I wasn't aware of that particular idiom. So something like
> > > > 
> > > > 8<------------------------------------------------------------
> > > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > Subject: .....
> > > 
> > > Yes.
> > > 
> > > From "man git-mailinfo":
> > > "A line that mainly consists of scissors (either ">8" or "8<") and
> > > perforation (dash "-")"
> > > 
> > > BTW:
> > > Is this patch a candidate for stable?
> > 
> > Yes. I'm planning on sending it to the stable list after Linus merges it
> > into mainline.
> So there is another idiom for you:  just put
> 
> 	Cc: stable@kernel.org
> 
> in the S-o-b block and Greg will pick it off "automatically".  (Just in
> case you don't know, and if you do, maybe someone else learned
> something.)

I usually do this, but there is a slight problem with that approach:
Greg gets to do all the work of figuring out to which stable kernels
this particular patch applies. In this case, since we're only talking
about the 2.6.37 kernel, I prefer to use the mailing lists.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

